/**
 * External Editor Extension
 *
 * Opens the current pi editor buffer in the user's preferred external editor
 * ($VISUAL → $EDITOR → vim). When inside tmux, the editor opens in a tmux
 * popup overlay (no TUI disruption). Outside tmux, the TUI suspends while the
 * editor takes over the terminal, then restores cleanly on exit.
 *
 * Keybinding: Ctrl+Shift+Z
 *
 * Usage:
 *   Set $VISUAL or $EDITOR to your preferred editor.
 *   For editors that need a flag (e.g. VS Code): VISUAL="code --wait"
 */

import { spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

type ExitResult = {
  status: number | null;
  signal: string | null;
};

function shellQuote(value: string): string {
  return `'${value.replace(/'/g, `'"'"'`)}'`;
}

function formatFailure(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}

function notifyExit(
  notify: (message: string, level: "warning") => void,
  result: ExitResult,
) {
  if (result.status === 0 && result.signal == null) {
    return;
  }

  const detail = result.signal
    ? `signal ${result.signal}`
    : `code ${result.status ?? "unknown"}`;
  notify(`External editor exited with ${detail}`, "warning");
}

export default function (pi: ExtensionAPI) {
  pi.registerShortcut("ctrl+shift+z", {
    description: "Edit current buffer in external editor ($VISUAL/$EDITOR)",
    handler: async (ctx) => {
      if (!ctx.hasUI) {
        return;
      }

      const editor = process.env.VISUAL || process.env.EDITOR || "vim";
      const shell = process.env.SHELL || "/bin/sh";
      const currentText = ctx.ui.getEditorText();

      const tempDir = mkdtempSync(join(tmpdir(), "pi-edit-"));
      const tmpFile = join(tempDir, "buffer.md");
      writeFileSync(tmpFile, currentText, { encoding: "utf8", flag: "wx" });

      const command = `${editor} ${shellQuote(tmpFile)}`;

      try {
        let result: ExitResult;

        if (process.env.TMUX) {
          // tmux display-popup blocks until the popup command exits.
          const tmuxResult = spawnSync(
            "tmux",
            [
              "display-popup",
              "-E",
              "-w",
              "50%",
              "-h",
              "50%",
              shell,
              "-c",
              command,
            ],
            { stdio: "inherit", env: process.env },
          );

          if (tmuxResult.error) {
            throw tmuxResult.error;
          }

          result = { status: tmuxResult.status, signal: tmuxResult.signal };
        } else {
          let spawnError: Error | null = null;

          result = await ctx.ui.custom((tui, _theme, _kb, done) => {
            tui.stop();
            process.stdout.write("\x1b[2J\x1b[H");

            let customResult: ExitResult = { status: null, signal: null };
            try {
              const editorResult = spawnSync(shell, ["-c", command], {
                stdio: "inherit",
                env: process.env,
              });

              if (editorResult.error) {
                spawnError = editorResult.error;
              }

              customResult = {
                status: editorResult.status,
                signal: editorResult.signal,
              };
            } finally {
              tui.start();
              tui.requestRender(true);
            }

            done(customResult);
            return { render: () => [], invalidate: () => {} };
          });

          if (spawnError) {
            throw spawnError;
          }
        }

        notifyExit(ctx.ui.notify.bind(ctx.ui), result);

        const modifiedText = readFileSync(tmpFile, "utf8");
        if (modifiedText !== currentText) {
          ctx.ui.setEditorText(modifiedText);
        }
      } catch (err) {
        ctx.ui.notify(`External editor failed: ${formatFailure(err)}`, "error");
      } finally {
        try {
          rmSync(tempDir, { recursive: true, force: true });
        } catch {
          // Ignore cleanup failures
        }
      }
    },
  });
}
