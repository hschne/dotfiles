/** Display helpers: nerd font icons, fuzzy matching, path formatting. */

import { relative } from "node:path";
import type { FileOperation, TrackedFile } from "./tracker.js";

// ── Nerd font icons (single most-significant per file) ──────────────────────

const OPERATION_ICON: Record<FileOperation, string> = {
  write: "\uf0c7", //  (floppy / save)
  edit: "\uf044", //  (pen-to-square)
  read: "\uf06e", //  (eye)
  grep: "\uf002", //  (magnifying glass)
  find: "\uf1e5", //  (binoculars)
  ls: "\uf07b", //  (folder)
};

export function operationIcon(operation: FileOperation): string {
  return OPERATION_ICON[operation] ?? "?";
}

// ── Display file ─────────────────────────────────────────────────────────────

export interface DisplayFile extends TrackedFile {
  displayPath: string;
  icon: string;
}

export function toDisplayFiles(
  files: TrackedFile[],
  cwd: string,
): DisplayFile[] {
  return files.map((file) => {
    const rel = relative(cwd, file.absolutePath);
    const displayPath =
      rel.startsWith("..") || rel.startsWith("/") ? file.absolutePath : rel;
    return {
      ...file,
      displayPath,
      icon: operationIcon(file.operation),
    };
  });
}

// ── Fuzzy matching ───────────────────────────────────────────────────────────

export interface FuzzyResult {
  matched: boolean;
  score: number;
}

/**
 * Simple fzf-style fuzzy match.
 *
 * Each query character must appear in order in the text. Score rewards:
 *  - Consecutive character runs (biggest factor)
 *  - Matches after path separators or at start
 *  - Earlier first-match position
 */
export function fuzzyMatch(query: string, text: string): FuzzyResult {
  const q = query.toLowerCase();
  const t = text.toLowerCase();

  if (q.length === 0) return { matched: true, score: 0 };
  if (q.length > t.length) return { matched: false, score: 0 };

  let qi = 0;
  let score = 0;
  let consecutive = 0;
  let firstMatchIndex = -1;

  for (let ti = 0; ti < t.length && qi < q.length; ti++) {
    if (t[ti] === q[qi]) {
      if (firstMatchIndex === -1) firstMatchIndex = ti;

      consecutive++;
      // Consecutive bonus grows quadratically
      score += consecutive * consecutive;

      // Bonus for match after separator or at start
      if (
        ti === 0 ||
        t[ti - 1] === "/" ||
        t[ti - 1] === "-" ||
        t[ti - 1] === "_" ||
        t[ti - 1] === "."
      ) {
        score += 10;
      }

      qi++;
    } else {
      consecutive = 0;
    }
  }

  if (qi < q.length) return { matched: false, score: 0 };

  // Penalise late first matches
  score -= firstMatchIndex * 0.5;

  return { matched: true, score };
}

/**
 * Filter and sort display files by fuzzy query.
 * Empty query returns all files in original order.
 */
export function filterFiles(
  files: DisplayFile[],
  query: string,
): DisplayFile[] {
  const q = query.trim();
  if (!q) return files;

  const scored: { file: DisplayFile; score: number }[] = [];
  for (const file of files) {
    const result = fuzzyMatch(q, file.displayPath);
    if (result.matched) {
      scored.push({ file, score: result.score });
    }
  }

  scored.sort((a, b) => b.score - a.score);
  return scored.map((s) => s.file);
}
