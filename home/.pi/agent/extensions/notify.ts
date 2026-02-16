/**
 * Desktop Notification Extension
 *
 * Sends a native desktop notification via notify-send when the agent finishes
 * and is waiting for input.
 *
 * Adapted from mitsuhiko's notify extension, using notify-send (Linux)
 * instead of OSC 777 terminal escape sequences.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Markdown, type MarkdownTheme } from "@mariozechner/pi-tui";

const isTextPart = (part: unknown): part is { type: "text"; text: string } =>
  Boolean(part && typeof part === "object" && "type" in part && part.type === "text" && "text" in part);

const extractLastAssistantText = (messages: Array<{ role?: string; content?: unknown }>): string | null => {
  for (let i = messages.length - 1; i >= 0; i--) {
    const message = messages[i];
    if (message?.role !== "assistant") {
      continue;
    }

    const content = message.content;
    if (typeof content === "string") {
      return content.trim() || null;
    }

    if (Array.isArray(content)) {
      const text = content.filter(isTextPart).map((part) => part.text).join("\n").trim();
      return text || null;
    }

    return null;
  }

  return null;
};

const plainMarkdownTheme: MarkdownTheme = {
  heading: (text) => text,
  link: (text) => text,
  linkUrl: () => "",
  code: (text) => text,
  codeBlock: (text) => text,
  codeBlockBorder: () => "",
  quote: (text) => text,
  quoteBorder: () => "",
  hr: () => "",
  listBullet: () => "",
  bold: (text) => text,
  italic: (text) => text,
  strikethrough: (text) => text,
  underline: (text) => text,
};

const simpleMarkdown = (text: string, width = 80): string => {
  const markdown = new Markdown(text, 0, 0, plainMarkdownTheme);
  return markdown.render(width).join("\n");
};

const formatNotification = (text: string | null): string => {
  const simplified = text ? simpleMarkdown(text) : "";
  const normalized = simplified.replace(/\s+/g, " ").trim();
  if (!normalized) {
    return "Task completed";
  }

  const maxBody = 200;
  return normalized.length > maxBody ? `${normalized.slice(0, maxBody - 1)}…` : normalized;
};

export default function (pi: ExtensionAPI) {
  const sendNotification = async (
    title: string,
    body: string,
    urgency: "low" | "normal" | "critical" = "normal",
  ): Promise<void> => {
    await pi.exec("notify-send", ["-t", "60000", "-u", urgency, title, body]);
  };

  pi.on("agent_end", async (event) => {
    const lastText = extractLastAssistantText(event.messages ?? []);
    const body = formatNotification(lastText);
    await sendNotification("π", body, "low");
  });
}
