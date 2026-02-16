import { spawn, type ChildProcess, execSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { extname } from "node:path";
import { pathToFileURL, fileURLToPath } from "node:url";
import {
  createMessageConnection,
  StreamMessageReader,
  StreamMessageWriter,
  type MessageConnection,
} from "vscode-jsonrpc/node.js";
import type {
  ServerConfig,
  Diagnostic,
  Location,
  Hover,
  DocumentSymbol,
  SymbolInformation,
  CallHierarchyItem,
  CallHierarchyIncomingCall,
  CallHierarchyOutgoingCall,
} from "./types.js";
import { LANGUAGE_IDS } from "./types.js";

const DIAGNOSTICS_DEBOUNCE_MS = 150;
const DIAGNOSTICS_TIMEOUT_MS = 3000;
const INITIALIZE_TIMEOUT_MS = 30000;

/**
 * Check if a command exists in PATH.
 */
function commandExists(cmd: string): boolean {
  try {
    execSync(`which ${cmd}`, { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}

/**
 * LSP client for a single server instance.
 */
export class LspClient {
  readonly serverId: string;
  readonly root: string;
  readonly config: ServerConfig;
  
  private process: ChildProcess | null = null;
  private connection: MessageConnection | null = null;
  private diagnostics: Map<string, Diagnostic[]> = new Map();
  private openFiles: Map<string, number> = new Map(); // path -> version
  private diagnosticWaiters: Map<string, () => void> = new Map();
  private _isHealthy = false;
  
  constructor(serverId: string, root: string, config: ServerConfig) {
    this.serverId = serverId;
    this.root = root;
    this.config = config;
  }
  
  get isHealthy(): boolean {
    return this._isHealthy;
  }
  
  /**
   * Start the LSP server and initialize the connection.
   */
  async initialize(): Promise<void> {
    const [cmd, ...args] = this.config.command;
    
    // Check if command exists before trying to spawn
    if (!commandExists(cmd)) {
      throw new Error(`Command not found: ${cmd}. Please install the language server.`);
    }
    
    // Spawn the process
    this.process = spawn(cmd, args, {
      cwd: this.root,
      env: { ...process.env, ...this.config.env },
      stdio: ["pipe", "pipe", "pipe"],
    });
    
    // Wait for process to actually start (or fail)
    await new Promise<void>((resolve, reject) => {
      const onError = (err: Error) => {
        cleanup();
        reject(err);
      };
      
      const onSpawn = () => {
        cleanup();
        resolve();
      };
      
      const cleanup = () => {
        this.process?.off("error", onError);
        this.process?.off("spawn", onSpawn);
      };
      
      this.process!.once("error", onError);
      this.process!.once("spawn", onSpawn);
    });
    
    // Process started successfully, set up connection
    this.connection = createMessageConnection(
      new StreamMessageReader(this.process.stdout!),
      new StreamMessageWriter(this.process.stdin!)
    );
    
    // Handle process death
    this.process.on("exit", () => {
      this._isHealthy = false;
    });
    
    // Handle diagnostics
    this.connection.onNotification(
      "textDocument/publishDiagnostics",
      (params: { uri: string; diagnostics: Diagnostic[] }) => {
        const filePath = fileURLToPath(params.uri);
        this.diagnostics.set(filePath, params.diagnostics);
        this.diagnosticWaiters.get(filePath)?.();
      }
    );
    
    // Handle server requests gracefully
    this.connection.onNotification(() => {});
    this.connection.onRequest("window/workDoneProgress/create", () => null);
    this.connection.onRequest("workspace/configuration", () => [this.config.initialization ?? {}]);
    this.connection.onRequest("client/registerCapability", () => {});
    this.connection.onRequest("client/unregisterCapability", () => {});
    this.connection.onRequest("workspace/workspaceFolders", () => [
      { name: "workspace", uri: pathToFileURL(this.root).href },
    ]);
    
    this.connection.listen();
    
    // Initialize with timeout
    await Promise.race([
      this.connection.sendRequest("initialize", {
        processId: process.pid,
        rootUri: pathToFileURL(this.root).href,
        workspaceFolders: [{ name: "workspace", uri: pathToFileURL(this.root).href }],
        initializationOptions: this.config.initialization ?? {},
        capabilities: {
          workspace: {
            configuration: true,
            workspaceFolders: true,
          },
          textDocument: {
            synchronization: { didOpen: true, didChange: true },
            publishDiagnostics: { versionSupport: true },
            hover: { contentFormat: ["markdown", "plaintext"] },
            definition: {},
            references: {},
            documentSymbol: { hierarchicalDocumentSymbolSupport: true },
            implementation: {},
            callHierarchy: {},
          },
        },
      }),
      new Promise((_, reject) => 
        setTimeout(() => reject(new Error("Initialize timeout")), INITIALIZE_TIMEOUT_MS)
      ),
    ]);
    
    await this.connection.sendNotification("initialized", {});
    
    if (this.config.initialization) {
      await this.connection.sendNotification("workspace/didChangeConfiguration", {
        settings: this.config.initialization,
      });
    }
    
    this._isHealthy = true;
    console.log(`[lsp:${this.serverId}] Initialized for ${this.root}`);
  }
  
  /**
   * Shutdown the LSP server.
   */
  async shutdown(): Promise<void> {
    this._isHealthy = false;
    
    if (this.connection) {
      try {
        await this.connection.sendRequest("shutdown");
        await this.connection.sendNotification("exit");
      } catch {}
      try {
        this.connection.end();
        this.connection.dispose();
      } catch {}
      this.connection = null;
    }
    
    if (this.process) {
      try { this.process.kill(); } catch {}
      this.process = null;
    }
  }
  
  /**
   * Open or update a file.
   */
  async openFile(filePath: string): Promise<void> {
    if (!this._isHealthy || !this.connection) return;
    if (!existsSync(filePath)) return;
    
    const uri = pathToFileURL(filePath).href;
    const ext = extname(filePath);
    const languageId = LANGUAGE_IDS[ext] ?? "plaintext";
    const content = readFileSync(filePath, "utf-8");
    
    try {
      const version = this.openFiles.get(filePath);
      
      if (version !== undefined) {
        const newVersion = version + 1;
        this.openFiles.set(filePath, newVersion);
        await this.connection.sendNotification("textDocument/didChange", {
          textDocument: { uri, version: newVersion },
          contentChanges: [{ text: content }],
        });
      } else {
        this.openFiles.set(filePath, 0);
        this.diagnostics.delete(filePath);
        await this.connection.sendNotification("textDocument/didOpen", {
          textDocument: { uri, languageId, version: 0, text: content },
        });
      }
    } catch {
      this._isHealthy = false;
    }
  }
  
  /**
   * Wait for diagnostics after file change.
   */
  async waitForDiagnostics(filePath: string): Promise<void> {
    return new Promise<void>((resolve) => {
      let debounceTimer: ReturnType<typeof setTimeout> | undefined;
      let done = false;
      
      const finish = () => {
        if (done) return;
        done = true;
        if (debounceTimer) clearTimeout(debounceTimer);
        this.diagnosticWaiters.delete(filePath);
        resolve();
      };
      
      this.diagnosticWaiters.set(filePath, () => {
        if (debounceTimer) clearTimeout(debounceTimer);
        debounceTimer = setTimeout(finish, DIAGNOSTICS_DEBOUNCE_MS);
      });
      
      setTimeout(finish, DIAGNOSTICS_TIMEOUT_MS);
    });
  }
  
  getDiagnostics(filePath: string): Diagnostic[] {
    return this.diagnostics.get(filePath) ?? [];
  }
  
  getAllDiagnostics(): Map<string, Diagnostic[]> {
    return new Map(this.diagnostics);
  }
  
  // ============ LSP Requests (all return empty/null on error) ============
  
  async definition(filePath: string, line: number, character: number): Promise<Location[]> {
    if (!this._isHealthy || !this.connection) return [];
    return this.connection.sendRequest("textDocument/definition", {
      textDocument: { uri: pathToFileURL(filePath).href },
      position: { line, character },
    }).then(normalizeLocations).catch(() => []);
  }
  
  async references(filePath: string, line: number, character: number): Promise<Location[]> {
    if (!this._isHealthy || !this.connection) return [];
    return this.connection.sendRequest("textDocument/references", {
      textDocument: { uri: pathToFileURL(filePath).href },
      position: { line, character },
      context: { includeDeclaration: true },
    }).then(normalizeLocations).catch(() => []);
  }
  
  async hover(filePath: string, line: number, character: number): Promise<Hover | null> {
    if (!this._isHealthy || !this.connection) return null;
    return this.connection.sendRequest("textDocument/hover", {
      textDocument: { uri: pathToFileURL(filePath).href },
      position: { line, character },
    }).catch(() => null) as Promise<Hover | null>;
  }
  
  async documentSymbols(filePath: string): Promise<DocumentSymbol[]> {
    if (!this._isHealthy || !this.connection) return [];
    return this.connection.sendRequest("textDocument/documentSymbol", {
      textDocument: { uri: pathToFileURL(filePath).href },
    }).then((r) => (r as DocumentSymbol[]) ?? []).catch(() => []);
  }
  
  async workspaceSymbols(query: string): Promise<SymbolInformation[]> {
    if (!this._isHealthy || !this.connection) return [];
    return this.connection.sendRequest("workspace/symbol", { query })
      .then((r) => ((r as SymbolInformation[]) ?? []).slice(0, 50))
      .catch(() => []);
  }
  
  async implementation(filePath: string, line: number, character: number): Promise<Location[]> {
    if (!this._isHealthy || !this.connection) return [];
    return this.connection.sendRequest("textDocument/implementation", {
      textDocument: { uri: pathToFileURL(filePath).href },
      position: { line, character },
    }).then(normalizeLocations).catch(() => []);
  }
  
  async incomingCalls(filePath: string, line: number, character: number): Promise<CallHierarchyIncomingCall[]> {
    if (!this._isHealthy || !this.connection) return [];
    try {
      const items = await this.connection.sendRequest("textDocument/prepareCallHierarchy", {
        textDocument: { uri: pathToFileURL(filePath).href },
        position: { line, character },
      }) as CallHierarchyItem[] | null;
      if (!items?.length) return [];
      return (await this.connection.sendRequest("callHierarchy/incomingCalls", { item: items[0] }) as CallHierarchyIncomingCall[]) ?? [];
    } catch { return []; }
  }
  
  async outgoingCalls(filePath: string, line: number, character: number): Promise<CallHierarchyOutgoingCall[]> {
    if (!this._isHealthy || !this.connection) return [];
    try {
      const items = await this.connection.sendRequest("textDocument/prepareCallHierarchy", {
        textDocument: { uri: pathToFileURL(filePath).href },
        position: { line, character },
      }) as CallHierarchyItem[] | null;
      if (!items?.length) return [];
      return (await this.connection.sendRequest("callHierarchy/outgoingCalls", { item: items[0] }) as CallHierarchyOutgoingCall[]) ?? [];
    } catch { return []; }
  }
}

function normalizeLocations(result: unknown): Location[] {
  if (!result) return [];
  if (Array.isArray(result)) {
    return result.map((item) => {
      if ("targetUri" in item) {
        return { uri: item.targetUri, range: item.targetRange ?? item.targetSelectionRange };
      }
      return item;
    }).filter(Boolean);
  }
  return [result as Location];
}
