import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI, Theme } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

interface UsageStats {
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
  cost: number;
  contextPercent: number;
  contextWindow: number;
  thinkingLevel: string;
}

/**
 * Aggregates usage and session data from the current message branch
 */
function getUsageStats(ctx: any): UsageStats {
  let input = 0, output = 0, cacheRead = 0, cacheWrite = 0, cost = 0;
  let thinkingLevel = "off";
  let lastAssistant: AssistantMessage | undefined;

  const sessionEvents = ctx.sessionManager?.getBranch() || [];
  for (const e of sessionEvents) {
    if (e.type === "thinking_level_change" && e.thinkingLevel) {
      thinkingLevel = e.thinkingLevel;
    }
    if (e.type === "message" && e.message.role === "assistant") {
      const m = e.message as AssistantMessage;
      if (m.stopReason === "error" || m.stopReason === "aborted") continue;
      input += m.usage.input;
      output += m.usage.output;
      cacheRead += m.usage.cacheRead;
      cacheWrite += m.usage.cacheWrite;
      cost += m.usage.cost.total;
      lastAssistant = m;
    }
  }

  const contextWindow = ctx.model?.contextWindow || 0;
  const contextTokens = lastAssistant ? (lastAssistant.usage.input + lastAssistant.usage.output + (lastAssistant.usage.cacheRead || 0) + (lastAssistant.usage.cacheWrite || 0)) : 0;
  const contextPercent = contextWindow > 0 ? (contextTokens / contextWindow) * 100 : 0;

  return { input, output, cacheRead, cacheWrite, cost, contextPercent, contextWindow, thinkingLevel };
}

/**
 * Returns formatted working directory (last 3 components with .. prefix)
 */
function getFolderName(): string {
  const pwd = process.cwd();
  const home = process.env.HOME || "";
  const displayPwd = pwd.startsWith(home) ? `~${pwd.slice(home.length)}` : pwd;

  const parts = displayPwd.split(/[/\\]/).filter(Boolean);
  if (parts.length > 3) {
    const sep = displayPwd.includes("\\") ? "\\" : "/";
    return ".." + sep + parts.slice(-3).join(sep);
  }
  return displayPwd;
}

/**
 * Renders the usage and cost part (right aligned)
 */
function renderRightPart(stats: UsageStats, theme: Theme): string {
  const fmt = (n: number) => (n < 1000 ? `${n}` : `${(n / 1000).toFixed(1)}k`);
  const cacheStr = (stats.cacheRead || stats.cacheWrite)
    ? theme.fg("dim", ` (c: ↑${fmt(stats.cacheWrite)} ↓${fmt(stats.cacheRead)})`)
    : "";
  const contextStr = stats.contextWindow
    ? theme.fg("dim", ` [${stats.contextPercent.toFixed(1)}%]`)
    : "";

  return (
    theme.fg("dim", `↑${fmt(stats.input)} ↓${fmt(stats.output)}`) +
    cacheStr +
    contextStr +
    " " +
    theme.fg("text", `$${stats.cost.toFixed(3)} `)
  );
}

/**
 * Renders the info segments (left aligned)
 */
function renderLeftPart(ctx: any, stats: UsageStats, footerData: any, theme: Theme): string {
  const SEP = theme.fg("dim", "  ");
  const segments: string[] = [];

  // Model & Thinking
  let modelName = ctx.model?.name || ctx.model?.id || "no-model";
  if (modelName.startsWith("Claude ")) modelName = modelName.slice(7);

  let modelText = theme.fg("customMessageLabel", "π " + modelName);
  if (stats.thinkingLevel !== "off") {
    const levelMap: Record<string, string> = {
      minimal: "min", low: "low", medium: "med", high: "high", xhigh: "xhigh"
    };
    modelText += theme.fg("dim", ` (${levelMap[stats.thinkingLevel] || stats.thinkingLevel})`);
  }
  segments.push(modelText);

  // Path
  segments.push(theme.fg("mdLink", "" + getFolderName()));

  // Git
  const branch = footerData.getGitBranch();
  if (branch) {
    segments.push(theme.fg("success", " " + branch));
  }

  // Extension Statuses (Compact)
  const statuses = footerData.getExtensionStatuses() || new Map();
  const compactStatuses: string[] = [];
  for (const value of statuses.values()) {
    if (value && !value.trimStart().startsWith('[')) {
      compactStatuses.push(value);
    }
  }
  if (compactStatuses.length > 0) {
    segments.push(theme.fg("warning", compactStatuses.join(" | ")));
  }

  return " " + segments.join(SEP);
}

export default function (pi: ExtensionAPI) {
  let enabled = true;

  const applyFooter = (ctx: any) => {
    if (!ctx.hasUI) return;

    ctx.ui.setFooter((tui: any, theme: any, footerData: any) => {
      const unsub = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose: unsub,
        invalidate() { },
        render(width: number): string[] {
          if (!enabled) return [];
          const stats = getUsageStats(ctx);
          const left = renderLeftPart(ctx, stats, footerData, theme);
          const right = renderRightPart(stats, theme);

          const padWidth = Math.max(1, width - visibleWidth(left) - visibleWidth(right));
          const content = left + " ".repeat(padWidth) + right;

          return [truncateToWidth(content, width)];
        },
      };
    });
  }

  pi.on("session_start", async (_event, ctx) => {
    if (enabled) applyFooter(ctx);
  });

  pi.registerCommand("footer", {
    description: "Toggle custom footer",
    handler: async (_args, ctx) => {
      enabled = !enabled;
      if (enabled) {
        applyFooter(ctx);
        ctx.ui.notify("Custom footer enabled", "info");
      } else {
        ctx.ui.setFooter(undefined);
        ctx.ui.notify("Default footer restored", "info");
      }
    },
  });
}
