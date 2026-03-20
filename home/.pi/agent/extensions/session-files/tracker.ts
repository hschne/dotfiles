/**
 * Track files accessed by tool calls, keeping the most significant operation per file.
 *
 * Priority (high → low): write > edit > read > grep > find > ls
 */

import { resolve } from "node:path";

export type FileOperation = "read" | "edit" | "write" | "grep" | "find" | "ls";

const OPERATION_PRIORITY: Record<FileOperation, number> = {
  write: 6,
  edit: 5,
  read: 4,
  grep: 3,
  find: 2,
  ls: 1,
};

export interface TrackedFile {
  absolutePath: string;
  operation: FileOperation;
  lastTouched: number;
}

export interface SerializedTrackerState {
  files: TrackedFile[];
}

export class FileTracker {
  private files = new Map<string, TrackedFile>();

  trackPath(inputPath: string, operation: FileOperation, cwd: string): void {
    const absolutePath = normalizePath(inputPath, cwd);
    const existing = this.files.get(absolutePath);

    if (existing) {
      existing.lastTouched = Date.now();
      if (
        OPERATION_PRIORITY[operation] > OPERATION_PRIORITY[existing.operation]
      ) {
        existing.operation = operation;
      }
    } else {
      this.files.set(absolutePath, {
        absolutePath,
        operation,
        lastTouched: Date.now(),
      });
    }
  }

  trackPaths(paths: string[], operation: FileOperation, cwd: string): void {
    for (const path of paths) this.trackPath(path, operation, cwd);
  }

  getFiles(): TrackedFile[] {
    return Array.from(this.files.values()).sort((a, b) => {
      if (a.lastTouched !== b.lastTouched) return b.lastTouched - a.lastTouched;
      return a.absolutePath.localeCompare(b.absolutePath);
    });
  }

  serialize(): SerializedTrackerState {
    return { files: this.getFiles() };
  }

  restore(state: SerializedTrackerState | undefined): void {
    this.files.clear();
    if (!state?.files) return;
    for (const file of state.files) {
      this.files.set(file.absolutePath, file);
    }
  }

  restoreFromBranch(
    entries: Array<{ type: string; customType?: string; data?: unknown }>,
  ): void {
    let lastState: SerializedTrackerState | undefined;
    for (const entry of entries) {
      if (entry.type === "custom" && entry.customType === "session-files") {
        const data = entry.data as SerializedTrackerState | undefined;
        if (data?.files) lastState = data;
      }
    }
    this.restore(lastState);
  }
}

function normalizePath(inputPath: string, cwd: string): string {
  const cleaned = inputPath.startsWith("@") ? inputPath.slice(1) : inputPath;
  return resolve(cwd, cleaned);
}

export function parseGrepPaths(resultText: string): string[] {
  const paths = new Set<string>();
  for (const line of resultText.split("\n")) {
    const match = line.match(/^([^:]+):(\d+)[:-]/);
    if (!match?.[1]) continue;
    const path = match[1].trim();
    if (!path || path.startsWith("--") || path.includes("Binary file"))
      continue;
    paths.add(path);
  }
  return Array.from(paths);
}

export function parseFindPaths(resultText: string): string[] {
  const paths = new Set<string>();
  for (const line of resultText.split("\n")) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("find:") || trimmed.startsWith("["))
      continue;
    paths.add(trimmed);
  }
  return Array.from(paths);
}
