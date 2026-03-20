/** Searchable overlay selector for session files. */

import type { Theme } from "@mariozechner/pi-coding-agent";
import {
  CURSOR_MARKER,
  type Focusable,
  matchesKey,
  truncateToWidth,
  visibleWidth,
} from "@mariozechner/pi-tui";
import type { DisplayFile } from "./utils.js";
import { filterFiles } from "./utils.js";

export type SelectorAction = "open" | "yank" | "close";

export interface SelectorResult {
  action: SelectorAction;
  file: DisplayFile | null;
  query: string;
  selectedIndex: number;
}

export class SessionFilesSelector implements Focusable {
  focused = false;
  private query: string;
  private cursor: number;
  private selectedIndex: number;
  private filtered: DisplayFile[] = [];
  private cachedWidth?: number;
  private cachedLines?: string[];

  constructor(
    private files: DisplayFile[],
    private theme: Theme,
    private done: (result: SelectorResult) => void,
    initialQuery = "",
    initialSelectedIndex = 0,
  ) {
    this.query = initialQuery;
    this.cursor = initialQuery.length;
    this.selectedIndex = initialSelectedIndex;
    this.applyFilter();
  }

  handleInput(data: string): void {
    if (matchesKey(data, "escape")) {
      this.emit("close");
      return;
    }
    if (matchesKey(data, "return") || matchesKey(data, "enter")) {
      this.emit("open");
      return;
    }
    if (matchesKey(data, "ctrl+shift+y")) {
      this.emit("yank");
      return;
    }

    // Navigation
    if (matchesKey(data, "up")) {
      if (this.selectedIndex > 0) this.selectedIndex--;
      this.invalidate();
      return;
    }
    if (matchesKey(data, "down")) {
      if (this.selectedIndex < this.filtered.length - 1) this.selectedIndex++;
      this.invalidate();
      return;
    }
    if (matchesKey(data, "pageUp")) {
      this.selectedIndex = Math.max(0, this.selectedIndex - 10);
      this.invalidate();
      return;
    }
    if (matchesKey(data, "pageDown")) {
      this.selectedIndex = Math.min(
        this.filtered.length - 1,
        this.selectedIndex + 10,
      );
      this.invalidate();
      return;
    }

    // Cursor movement in search input
    if (matchesKey(data, "left")) {
      if (this.cursor > 0) this.cursor--;
      this.invalidate();
      return;
    }
    if (matchesKey(data, "right")) {
      if (this.cursor < this.query.length) this.cursor++;
      this.invalidate();
      return;
    }

    // Editing search input
    if (matchesKey(data, "backspace")) {
      if (this.cursor > 0) {
        this.query =
          this.query.slice(0, this.cursor - 1) + this.query.slice(this.cursor);
        this.cursor--;
        this.applyFilter();
        this.invalidate();
      }
      return;
    }
    if (data.length === 1 && data.charCodeAt(0) >= 32) {
      this.query =
        this.query.slice(0, this.cursor) + data + this.query.slice(this.cursor);
      this.cursor++;
      this.applyFilter();
      this.invalidate();
    }
  }

  render(width: number): string[] {
    if (this.cachedLines && this.cachedWidth === width) return this.cachedLines;

    const t = this.theme;
    const w = Math.min(width, 84);
    const inner = w - 2;
    const lines: string[] = [];

    /** Padded content row: │ content + padding │ */
    const row = (content: string): string => {
      const pad = Math.max(0, inner - visibleWidth(content));
      return t.fg("border", "│") + content + " ".repeat(pad) + t.fg("border", "│");
    };

    /** Horizontal border line. */
    const hline = (l: string, f: string, r: string): string =>
      t.fg("border", `${l}${f.repeat(inner)}${r}`);

    // Top border
    lines.push(hline("╭", "─", "╮"));

    // Title
    lines.push(
      row(
        ` ${t.fg("accent", t.bold(`Files (${this.filtered.length}/${this.files.length})`))}`,
      ),
    );
    lines.push(row(""));

    // Search input
    lines.push(row(` ${this.renderSearchInput(t)}`));
    lines.push(row(""));

    // Separator
    lines.push(hline("├", "─", "┤"));

    // File list — always render exactly VISIBLE_FILES rows so height stays constant.
    const VISIBLE_FILES = 15;
    const total = this.filtered.length;
    const start = Math.max(
      0,
      Math.min(
        this.selectedIndex - Math.floor(VISIBLE_FILES / 2),
        total - VISIBLE_FILES,
      ),
    );
    const end = Math.min(start + VISIBLE_FILES, total);
    const rendered = end - start;

    if (total === 0) {
      lines.push(row(t.fg("dim", "  No matching files")));
      for (let i = 1; i < VISIBLE_FILES; i++) lines.push(row(""));
    } else {
      for (let i = start; i < end; i++) {
        const file = this.filtered[i]!;
        const selected = i === this.selectedIndex;
        const prefix = selected ? t.fg("accent", " → ") : "   ";
        const icon = colorIcon(file.icon, file.operation, t);
        const path = selected
          ? t.fg("accent", file.displayPath)
          : file.displayPath;
        lines.push(
          row(truncateToWidth(`${prefix}${icon} ${path}`, inner, "…")),
        );
      }
      // Pad remaining rows so height doesn't shrink
      for (let i = rendered; i < VISIBLE_FILES; i++) lines.push(row(""));
    }

    // Scroll indicator sits in the last padded row's slot when needed
    if (total > VISIBLE_FILES) {
      lines[lines.length - 1] = row(
        t.fg("dim", `  (${this.selectedIndex + 1}/${total})`),
      );
    }

    // Help
    lines.push(row(""));
    lines.push(row(t.fg("dim", " enter open • c-s-y yank • esc close")));

    // Bottom border
    lines.push(hline("╰", "─", "╯"));

    this.cachedWidth = width;
    this.cachedLines = lines;
    return lines;
  }

  invalidate(): void {
    this.cachedWidth = undefined;
    this.cachedLines = undefined;
  }

  private renderSearchInput(t: Theme): string {
    if (this.query.length === 0) {
      const marker = this.focused ? CURSOR_MARKER : "";
      return `${marker}\x1b[7m \x1b[27m${t.fg("dim", "search files…")}`;
    }
    const before = this.query.slice(0, this.cursor);
    const at = this.cursor < this.query.length ? this.query[this.cursor]! : " ";
    const after = this.query.slice(this.cursor + 1);
    const marker = this.focused ? CURSOR_MARKER : "";
    return `${before}${marker}\x1b[7m${at}\x1b[27m${after}`;
  }

  private emit(action: SelectorAction): void {
    this.done({
      action,
      file: this.filtered[this.selectedIndex] ?? null,
      query: this.query,
      selectedIndex: this.selectedIndex,
    });
  }

  private applyFilter(): void {
    this.filtered = filterFiles(this.files, this.query);
    this.selectedIndex = Math.max(
      0,
      Math.min(this.selectedIndex, this.filtered.length - 1),
    );
  }
}

function colorIcon(icon: string, operation: string, theme: Theme): string {
  switch (operation) {
    case "write":
      return theme.fg("success", icon);
    case "edit":
      return theme.fg("warning", icon);
    case "read":
      return theme.fg("accent", icon);
    case "grep":
    case "find":
      return theme.fg("muted", icon);
    case "ls":
      return theme.fg("dim", icon);
    default:
      return icon;
  }
}
