import { existsSync } from "node:fs";
import { dirname, extname, join, resolve } from "node:path";
import { LspClient } from "./client.js";
import { findServerForExtension } from "./config.js";
import type { LspConfig, ServerConfig, ServerStatus, Diagnostic } from "./types.js";

/**
 * Manages multiple LSP clients, routing requests by file extension.
 */
export class LspManager {
  private config: LspConfig;
  private cwd: string;
  private clients: Map<string, LspClient> = new Map(); // "serverId:root" -> client
  private brokenServers: Set<string> = new Set(); // "serverId:root"
  private spawning: Map<string, Promise<LspClient | undefined>> = new Map();
  
  constructor(config: LspConfig, cwd: string) {
    this.config = config;
    this.cwd = cwd;
  }
  
  /**
   * Check if any server is configured for this file extension.
   */
  hasServer(filePath: string): boolean {
    const ext = extname(filePath);
    return findServerForExtension(this.config, ext) !== undefined;
  }
  
  /**
   * Get or create a client for the given file.
   */
  async getClient(filePath: string): Promise<LspClient | undefined> {
    const ext = extname(filePath);
    const server = findServerForExtension(this.config, ext);
    
    if (!server) {
      return undefined;
    }
    
    const { id, config } = server;
    const root = await this.findRoot(filePath, config);
    const key = `${id}:${root}`;
    
    // Check if broken
    if (this.brokenServers.has(key)) {
      return undefined;
    }
    
    // Return existing client
    const existing = this.clients.get(key);
    if (existing?.isHealthy) {
      return existing;
    }
    
    // Check if already spawning
    const inflight = this.spawning.get(key);
    if (inflight) {
      return inflight;
    }
    
    // Spawn new client
    const task = this.spawnClient(id, root, config, key);
    this.spawning.set(key, task);
    
    task.finally(() => {
      if (this.spawning.get(key) === task) {
        this.spawning.delete(key);
      }
    });
    
    return task;
  }
  
  /**
   * Spawn a new LSP client.
   */
  private async spawnClient(
    serverId: string,
    root: string,
    config: ServerConfig,
    key: string
  ): Promise<LspClient | undefined> {
    const client = new LspClient(serverId, root, config);
    
    try {
      await client.initialize();
      this.clients.set(key, client);
      return client;
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      console.log(`[lsp] ${serverId}: ${msg}`);
      this.brokenServers.add(key);
      return undefined;
    }
  }
  
  /**
   * Check if the server for this file is broken (failed to start).
   */
  isServerBroken(filePath: string): boolean {
    const ext = extname(filePath);
    const server = findServerForExtension(this.config, ext);
    if (!server) return false;
    
    for (const key of this.brokenServers) {
      if (key.startsWith(server.id + ":")) return true;
    }
    return false;
  }
  
  /**
   * Find workspace root for a file by searching upward for root patterns.
   */
  private async findRoot(filePath: string, config: ServerConfig): Promise<string> {
    const patterns = config.rootPatterns ?? [];
    
    if (patterns.length === 0) {
      return this.cwd;
    }
    
    let dir = dirname(resolve(filePath));
    const stopAt = this.cwd;
    
    while (dir.length >= stopAt.length) {
      for (const pattern of patterns) {
        const candidate = join(dir, pattern);
        if (existsSync(candidate)) {
          return dir;
        }
      }
      
      const parent = dirname(dir);
      if (parent === dir) break;
      dir = parent;
    }
    
    return this.cwd;
  }
  
  /**
   * Touch a file (open/update and optionally wait for diagnostics).
   */
  async touchFile(filePath: string, waitForDiagnostics = false): Promise<void> {
    const client = await this.getClient(filePath);
    if (!client) return;
    
    const absolutePath = resolve(this.cwd, filePath);
    
    if (waitForDiagnostics) {
      const waitPromise = client.waitForDiagnostics(absolutePath);
      await client.openFile(absolutePath);
      await waitPromise;
    } else {
      await client.openFile(absolutePath);
    }
  }
  
  /**
   * Get diagnostics for a specific file.
   */
  async getDiagnostics(filePath: string): Promise<Diagnostic[]> {
    const client = await this.getClient(filePath);
    if (!client) return [];
    
    const absolutePath = resolve(this.cwd, filePath);
    return client.getDiagnostics(absolutePath);
  }
  
  /**
   * Get all diagnostics across all clients.
   */
  getAllDiagnostics(): Record<string, Diagnostic[]> {
    const result: Record<string, Diagnostic[]> = {};
    
    for (const client of this.clients.values()) {
      if (!client.isHealthy) continue;
      
      for (const [path, diagnostics] of client.getAllDiagnostics()) {
        const existing = result[path] ?? [];
        existing.push(...diagnostics);
        result[path] = existing;
      }
    }
    
    return result;
  }
  
  /**
   * Get status of all configured servers.
   */
  status(): ServerStatus[] {
    const result: ServerStatus[] = [];
    
    // Add connected clients
    for (const client of this.clients.values()) {
      result.push({
        id: client.serverId,
        root: client.root,
        status: client.isHealthy ? "connected" : "error",
      });
    }
    
    // Add broken servers
    for (const key of this.brokenServers) {
      const [id, root] = key.split(":");
      if (!result.some((s) => s.id === id && s.root === root)) {
        result.push({ id, root, status: "error" });
      }
    }
    
    return result;
  }
  
  /**
   * Get list of connected server IDs (deduplicated).
   */
  getConnectedServerIds(): string[] {
    const ids = new Set<string>();
    for (const client of this.clients.values()) {
      if (client.isHealthy) {
        ids.add(client.serverId);
      }
    }
    return Array.from(ids);
  }
  
  /**
   * Shutdown all LSP servers.
   */
  async shutdownAll(): Promise<void> {
    const shutdowns = Array.from(this.clients.values()).map((client) =>
      client.shutdown().catch(() => {})
    );
    
    await Promise.all(shutdowns);
    this.clients.clear();
  }
  
  // ============ LSP Operations ============
  
  async definition(filePath: string, line: number, character: number) {
    const client = await this.getClient(filePath);
    if (!client) return [];
    return client.definition(resolve(this.cwd, filePath), line - 1, character - 1);
  }
  
  async references(filePath: string, line: number, character: number) {
    const client = await this.getClient(filePath);
    if (!client) return [];
    return client.references(resolve(this.cwd, filePath), line - 1, character - 1);
  }
  
  async hover(filePath: string, line: number, character: number) {
    const client = await this.getClient(filePath);
    if (!client) return null;
    return client.hover(resolve(this.cwd, filePath), line - 1, character - 1);
  }
  
  async documentSymbols(filePath: string) {
    const client = await this.getClient(filePath);
    if (!client) return [];
    return client.documentSymbols(resolve(this.cwd, filePath));
  }
  
  async workspaceSymbols(filePath: string, query: string) {
    const client = await this.getClient(filePath);
    if (!client) return [];
    return client.workspaceSymbols(query);
  }
  
  async implementation(filePath: string, line: number, character: number) {
    const client = await this.getClient(filePath);
    if (!client) return [];
    return client.implementation(resolve(this.cwd, filePath), line - 1, character - 1);
  }
  
  async incomingCalls(filePath: string, line: number, character: number) {
    const client = await this.getClient(filePath);
    if (!client) return [];
    return client.incomingCalls(resolve(this.cwd, filePath), line - 1, character - 1);
  }
  
  async outgoingCalls(filePath: string, line: number, character: number) {
    const client = await this.getClient(filePath);
    if (!client) return [];
    return client.outgoingCalls(resolve(this.cwd, filePath), line - 1, character - 1);
  }
}
