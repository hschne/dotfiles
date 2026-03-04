/**
 * Pi LSP Extension
 * 
 * Provides Language Server Protocol integration for pi coding agent.
 * 
 * Features:
 * - `lsp` tool: Query code intelligence (diagnostics, definitions, references, etc.)
 * - Automatic diagnostics after edit/write operations
 * - `/lsp` command: Check server status
 * 
 * Configuration in ~/.pi/agent/settings.json or .pi/settings.json:
 * 
 * {
 *   "lsp": {
 *     "servers": {
 *       "typescript": {
 *         "command": ["typescript-language-server", "--stdio"],
 *         "extensions": [".ts", ".tsx"],
 *         "rootPatterns": ["package.json", "tsconfig.json"]
 *       }
 *     }
 *   }
 * }
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { StringEnum } from "@mariozechner/pi-ai";

import { loadConfig } from "./config.js";
import { LspManager } from "./manager.js";
import { executeLspTool, formatDiagnostic, LSP_TOOL_DESCRIPTION } from "./tool.js";
import { LSP_OPERATIONS, DiagnosticSeverity } from "./types.js";

const MAX_DIAGNOSTICS_DISPLAY = 20;

export default function lspExtension(pi: ExtensionAPI) {
  let manager: LspManager | null = null;
  let cwd: string = process.cwd();
  let ui: any = null;

  // Update footer status with connected servers
  function updateStatus() {
    if (!ui || !manager) return;

    const connected = manager.getConnectedServerIds();
    if (connected.length === 0) {
      ui.setStatus("lsp", undefined);
    } else {
      ui.setStatus("lsp", ui.theme.fg("success", `󰒍 ${connected.join(" ")}`));
    }
  }

  // ============ Initialize on session start ============

  pi.on("session_start", async (_event, ctx) => {
    cwd = ctx.cwd;
    ui = ctx.ui;
    const config = loadConfig(cwd);

    const serverCount = Object.keys(config.servers).length;
    if (serverCount > 0) {
      manager = new LspManager(config, cwd);
    }
  });

  // ============ Shutdown on exit ============

  pi.on("session_shutdown", async () => {
    if (manager) {
      await manager.shutdownAll();
      manager = null;
    }
  });

  // ============ Register LSP tool ============

  pi.registerTool({
    name: "lsp",
    label: "LSP",
    description: LSP_TOOL_DESCRIPTION,
    parameters: Type.Object({
      operation: StringEnum([...LSP_OPERATIONS] as unknown as readonly string[] & { 0: string }, {
        description: "The LSP operation to perform",
      }),
      filePath: Type.String({
        description: "Path to the file (relative or absolute)",
      }),
      line: Type.Optional(Type.Number({
        description: "Line number (1-based, as shown in editors)",
      })),
      character: Type.Optional(Type.Number({
        description: "Character offset (1-based, as shown in editors)",
      })),
      query: Type.Optional(Type.String({
        description: "Search query (for workspaceSymbols operation)",
      })),
    }),

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      if (!manager) {
        return {
          content: [{
            type: "text",
            text: "No LSP servers configured. Add server config to settings.json.",
          }],
          details: { error: true },
        };
      }

      const { output, title } = await executeLspTool(
        manager,
        {
          operation: params.operation as typeof LSP_OPERATIONS[number],
          filePath: params.filePath,
          line: params.line,
          character: params.character,
          query: params.query,
        },
        ctx.cwd
      );

      // Update status after operation (may have spawned a server)
      updateStatus();

      return {
        content: [{ type: "text", text: output }],
        details: { title },
      };
    },
  });

  // ============ Hook into edit/write for diagnostics ============

  pi.on("tool_result", async (event, _ctx) => {
    if (!manager) return;

    // Only process write and edit tools
    if (event.toolName !== "write" && event.toolName !== "edit") {
      return;
    }

    // Extract file path from tool input
    const filePath = (event.input as { path?: string })?.path;
    if (!filePath) return;

    // Check if we have a server for this file type
    if (!manager.hasServer(filePath)) return;

    try {
      // Touch file and wait for diagnostics
      await manager.touchFile(filePath, true);
      updateStatus();
      const diagnostics = await manager.getDiagnostics(filePath);

      // Filter to errors only
      const errors = diagnostics.filter((d) => d.severity === DiagnosticSeverity.Error);

      if (errors.length > 0) {
        const limited = errors.slice(0, MAX_DIAGNOSTICS_DISPLAY);
        const formatted = limited.map(formatDiagnostic).join("\n");
        const suffix = errors.length > MAX_DIAGNOSTICS_DISPLAY
          ? `\n... and ${errors.length - MAX_DIAGNOSTICS_DISPLAY} more`
          : "";

        // Append diagnostics to the result
        const existingText = event.content
          .filter((c): c is { type: "text"; text: string } => c.type === "text")
          .map((c) => c.text)
          .join("\n");

        return {
          content: [{
            type: "text" as const,
            text: `${existingText}\n\nLSP errors detected in this file, please fix:\n${formatted}${suffix}`,
          }],
        };
      }
    } catch {
      // Silently ignore diagnostic errors
    }
  });

  // ============ /lsp status command ============

  pi.registerCommand("lsp", {
    description: "Show LSP server status",
    handler: async (_args, ctx) => {
      if (!manager) {
        ctx.ui.notify("No LSP servers configured", "info");
        return;
      }

      const status = manager.status();

      if (status.length === 0) {
        ctx.ui.notify("No LSP servers connected (they start on first file access)", "info");
        return;
      }

      const lines = status.map((s) => {
        const icon = s.status === "connected" ? "✓" : "✗";
        const root = s.root.replace(cwd, ".") || ".";
        return `${icon} ${s.id}: ${s.status} (${root})`;
      });

      ctx.ui.notify(lines.join("\n"), "info");
    },
  });
}
