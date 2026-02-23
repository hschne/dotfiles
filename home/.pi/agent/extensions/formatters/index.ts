/**
 * Pi Formatters Extension
 *
 * Automatically formats files after write/edit operations.
 *
 * Features:
 * - Auto-format on edit (synchronous, before tool returns)
 * - Silent operation (console logging only)
 * - `/format` command: Check formatter status
 *
 * Configuration in ~/.pi/agent/settings.json or .pi/settings.json:
 *
 * {
 *   "formatters": {
 *     "prettier": {
 *       "command": ["npx", "prettier", "--write", "$FILE"],
 *       "extensions": [".js", ".ts", ".json"]
 *     }
 *   }
 * }
 */

import { extname } from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { loadConfig, findFormattersForExtension } from "./config.js";
import { runFormatter, getFormatterStatus } from "./runner.js";
import type { FormattersConfig } from "./types.js";

export default function formattersExtension(pi: ExtensionAPI) {
  let config: FormattersConfig = { formatters: {} };
  let cwd: string = process.cwd();

  // ============ Initialize on session start ============

  pi.on("session_start", async (_event, ctx) => {
    cwd = ctx.cwd;
    config = loadConfig(cwd);
  });

  // ============ Hook into edit/write to run formatters ============

  pi.on("tool_result", async (event, _ctx) => {
    // Only process write and edit tools
    if (event.toolName !== "write" && event.toolName !== "edit") {
      return;
    }

    // Extract file path from tool input
    const filePath = (event.input as { path?: string })?.path;
    if (!filePath) return;

    // Find matching formatters
    const ext = extname(filePath);
    const formatters = findFormattersForExtension(config, ext);

    if (formatters.length === 0) return;

    // Run all matching formatters in order (completely silent)
    for (const { name, config: formatterConfig } of formatters) {
      await runFormatter(name, formatterConfig, filePath, cwd);
    }
  });

  // ============ /format status command ============

  pi.registerCommand("format", {
    description: "Show formatter status",
    handler: async (_args, ctx) => {
      const statuses = getFormatterStatus(config.formatters);

      if (statuses.length === 0) {
        ctx.ui.notify("No formatters configured", "info");
        return;
      }

      const lines = statuses.map((s) => {
        const icon = s.available ? "✓" : "✗";
        const exts = s.extensions.join(", ");
        return `${icon} ${s.name}: ${exts}`;
      });

      ctx.ui.notify(lines.join("\n"), "info");
    },
  });
}
