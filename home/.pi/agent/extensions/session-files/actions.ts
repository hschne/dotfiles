/** Actions: open in editor, yank path to prompt. */

import { relative } from "node:path";
import type { ExtensionContext } from "@mariozechner/pi-coding-agent";

type ExecFn = (
  command: string,
  args: string[],
  options?: { signal?: AbortSignal; timeout?: number; cwd?: string },
) => Promise<{ stdout: string; stderr: string; code: number; killed: boolean }>;

function inTmux(): boolean {
  return !!process.env.TMUX;
}

function editor(): string {
  return process.env.EDITOR || process.env.VISUAL || "vim";
}

export async function openInEditor(
  filePath: string,
  exec: ExecFn,
): Promise<{ success: boolean; error?: string }> {
  try {
    if (inTmux()) {
      await exec(
        "tmux",
        [
          "display-popup",
          "-E",
          "-w",
          "90%",
          "-h",
          "90%",
          "--",
          editor(),
          filePath,
        ],
        { timeout: 300_000 },
      );
    } else {
      await exec(editor(), [filePath], { timeout: 300_000 });
    }
    return { success: true };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : String(error),
    };
  }
}

export function yankToPrompt(ctx: ExtensionContext, filePath: string): void {
  const rel = relative(ctx.cwd, filePath);
  const mentionTarget =
    rel.startsWith("..") || rel.startsWith("/") ? filePath : rel;
  const mention = `@${mentionTarget}`;
  const current = ctx.ui.getEditorText();
  const sep = current && !current.endsWith(" ") ? " " : "";
  ctx.ui.setEditorText(`${current}${sep}${mention}`);
  ctx.ui.notify(`Added ${mention}`, "info");
}
