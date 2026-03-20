/**
 * Session Files Extension
 *
 * /files command and Ctrl+Shift+F shortcut to browse files the agent accessed
 * during the current session. Shows an overlay with fuzzy search, nerd font
 * icons indicating access type (most significant), open in $EDITOR (tmux popup
 * when available), and yank path to prompt.
 */

import type {
  ExtensionAPI,
  ExtensionCommandContext,
  ExtensionContext,
} from "@mariozechner/pi-coding-agent";
import { openInEditor, yankToPrompt } from "./actions.js";
import { SessionFilesSelector, type SelectorResult } from "./selector.js";
import { FileTracker, parseGrepPaths, parseFindPaths } from "./tracker.js";
import { toDisplayFiles } from "./utils.js";

export default function sessionFilesExtension(pi: ExtensionAPI) {
  const tracker = new FileTracker();
  let lastQuery = "";
  let lastSelectedIndex = 0;

  function persistState(): void {
    pi.appendEntry("session-files", tracker.serialize());
  }

  function restoreState(ctx: ExtensionContext): void {
    tracker.restoreFromBranch(ctx.sessionManager.getBranch());
  }

  // ── Track file access via tool events ────────────────────────────────────

  // Track in-memory only during tool events; persist once at turn_end so we
  // don't append custom entries mid-turn (which would disrupt the session tree).
  let dirty = false;

  pi.on("tool_call", async (event, ctx) => {
    if (
      event.toolName === "read" ||
      event.toolName === "edit" ||
      event.toolName === "write"
    ) {
      const path = event.input.path as string;
      if (path) {
        tracker.trackPath(path, event.toolName, ctx.cwd);
        dirty = true;
      }
    }

    if (event.toolName === "ls") {
      const path = (event.input.path as string | undefined) ?? ctx.cwd;
      tracker.trackPath(path, "ls", ctx.cwd);
      dirty = true;
    }
  });

  pi.on("tool_result", async (event, ctx) => {
    if (event.toolName !== "grep" && event.toolName !== "find") return;

    const textContent = event.content
      ?.filter((c: { type: string; text?: string }) => c.type === "text")
      .map((c: { text?: string }) => c.text ?? "")
      .join("\n");

    if (!textContent) return;

    if (event.toolName === "grep") {
      const paths = parseGrepPaths(textContent);
      if (paths.length > 0) {
        tracker.trackPaths(paths, "grep", ctx.cwd);
        dirty = true;
      }
    }

    if (event.toolName === "find") {
      const paths = parseFindPaths(textContent);
      if (paths.length > 0) {
        tracker.trackPaths(paths, "find", ctx.cwd);
        dirty = true;
      }
    }
  });

  pi.on("turn_end", async () => {
    if (dirty) {
      persistState();
      dirty = false;
    }
  });

  // ── Overlay file browser ─────────────────────────────────────────────────

  async function showFiles(ctx: ExtensionCommandContext): Promise<void> {
    if (!ctx.hasUI) return;

    let keepOpen = true;
    while (keepOpen) {
      keepOpen = false;

      const files = toDisplayFiles(tracker.getFiles(), ctx.cwd);
      const result = await ctx.ui.custom<SelectorResult | null>(
        (tui, theme, _kb, done) => {
          const selector = new SessionFilesSelector(
            files,
            theme,
            done,
            lastQuery,
            lastSelectedIndex,
          );
          return {
            render(width: number) {
              return selector.render(width);
            },
            invalidate() {
              selector.invalidate();
            },
            handleInput(data: string) {
              selector.handleInput(data);
              tui.requestRender();
            },
            get focused() {
              return selector.focused;
            },
            set focused(value: boolean) {
              selector.focused = value;
            },
          };
        },
        {
          overlay: true,
          overlayOptions: {
            anchor: "center",
            width: 84,
            minHeight: 24,
            maxHeight: 24,
          },
        },
      );

      if (!result || result.action === "close") return;

      lastQuery = result.query;
      lastSelectedIndex = result.selectedIndex;

      if (!result.file) {
        keepOpen = true;
        continue;
      }

      switch (result.action) {
        case "open": {
          const open = await openInEditor(
            result.file.absolutePath,
            pi.exec.bind(pi),
          );
          if (!open.success)
            ctx.ui.notify(open.error ?? "Open failed", "error");
          keepOpen = true;
          break;
        }
        case "yank": {
          yankToPrompt(ctx, result.file.absolutePath);
          keepOpen = true;
          break;
        }
      }
    }
  }

  // ── Command + shortcut ───────────────────────────────────────────────────

  pi.registerCommand("files", {
    description: "Browse files the agent accessed in this session",
    handler: async (_args, ctx) => {
      await showFiles(ctx);
    },
  });

  pi.registerShortcut("ctrl+shift+i", {
    description: "Browse session files",
    handler: async (ctx) => {
      await showFiles(ctx as ExtensionCommandContext);
    },
  });

  // ── Session lifecycle ────────────────────────────────────────────────────

  pi.on("session_start", async (_event, ctx) => restoreState(ctx));
  pi.on("session_tree", async (_event, ctx) => restoreState(ctx));
  pi.on("session_fork", async (_event, ctx) => restoreState(ctx));
}
