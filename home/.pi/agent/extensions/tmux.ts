import { execFileSync, execSync } from "node:child_process";
import { homedir } from "node:os";
import { basename, join } from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const MARKER = "π";
const MAX_SESSION_TITLE_LEN = 30;

const is_tmux = (): boolean => {
  return !!process.env.TMUX;
};

const tmux = (cmd: string): string => {
  try {
    return execSync(`tmux ${cmd}`, { encoding: "utf-8", timeout: 2000 }).trim();
  } catch {
    return "";
  }
};

const run_set_pane_title = (pane_id: string, title?: string): void => {
  const script = join(homedir(), ".scripts", "set-tmux-pane-title");
  const args = ["--pane-id", pane_id];

  if (title) {
    args.push("--title", title);
  } else {
    args.push("--clear");
  }

  try {
    execFileSync(script, args, { stdio: "ignore", timeout: 2000 });
  } catch {
    // Ignore missing script or tmux errors.
  }
};

const shorten_model = (id: string): string => {
  let short = id;
  short = short.replace(/-\d{8}$/, "");
  short = short.replace(/^claude-/, "");
  return short;
};

const truncate = (str: string, max: number): string => {
  if (str.length <= max) return str;
  return `${str.slice(0, max - 1)}…`;
};

export default function (pi: ExtensionAPI) {
  if (!is_tmux()) return;

  const pane_id = tmux("display-message -p '#{pane_id}'");
  if (!pane_id) return;

  const project_name = basename(process.cwd());
  let model_name = "";
  let is_working = false;

  const get_session_title = (ctx?: {
    sessionManager: { getBranch(): any[] };
  }): string | undefined => {
    const name = pi.getSessionName();
    if (name) return name;

    if (!ctx) return undefined;

    try {
      for (const entry of ctx.sessionManager.getBranch()) {
        if (
          entry.type === "message" &&
          entry.message?.role === "user" &&
          Array.isArray(entry.message.content)
        ) {
          const text_part = entry.message.content.find(
            (c: any) => c.type === "text",
          );
          if (text_part?.text) {
            const first_line = text_part.text.split("\n")[0].trim();
            if (first_line) return first_line;
          }
        }
      }
    } catch {
      // Ignore errors reading session.
    }

    return undefined;
  };

  const update_title = (ctx?: { sessionManager: { getBranch(): any[] } }) => {
    const status_icon = is_working ? `${MARKER}*` : MARKER;
    const model_part = model_name ? ` · ${model_name}` : "";
    const session_title = get_session_title(ctx);
    const session_part = session_title
      ? ` · ${truncate(session_title, MAX_SESSION_TITLE_LEN)}`
      : "";

    run_set_pane_title(
      pane_id,
      `${status_icon} ${project_name}${model_part}${session_part}`,
    );
  };

  const clear_title = () => {
    run_set_pane_title(pane_id);
  };

  pi.on("session_start", async (_event, ctx) => {
    if (ctx.model) {
      model_name = shorten_model(ctx.model.id);
    }
    update_title(ctx);
  });

  pi.on("model_select", async (event, ctx) => {
    model_name = shorten_model(event.model.id);
    update_title(ctx);
  });

  pi.on("session_switch", async (_event, ctx) => {
    update_title(ctx);
  });

  pi.on("session_fork", async (_event, ctx) => {
    update_title(ctx);
  });

  pi.on("agent_start", async (_event, ctx) => {
    is_working = true;
    update_title(ctx);
  });

  pi.on("agent_end", async (_event, ctx) => {
    is_working = false;
    update_title(ctx);
  });

  pi.on("session_shutdown", async () => {
    clear_title();
  });
}
