/**
 * Plan Save Extension
 *
 * Provides a /plan-save command that moves a finished plan from the
 * local plans/ directory to ~/Documents/Wiki/projects/<project>/plans/
 * and indexes it with `qmd update`.
 *
 * Auto-detects the project from:
 * 1. Git remote origin name
 * 2. Current directory name
 * 3. Falls back to asking the user
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { join, basename } from "node:path";
import { readdir, rename, mkdir, access } from "node:fs/promises";

const WIKI_PROJECTS = join(process.env.HOME ?? "~", "Documents/Wiki/projects");

async function getWikiProjects(): Promise<string[]> {
  try {
    const entries = await readdir(WIKI_PROJECTS, { withFileTypes: true });
    return entries.filter((e) => e.isDirectory()).map((e) => e.name);
  } catch {
    return [];
  }
}

async function detectProject(
  pi: ExtensionAPI,
  cwd: string,
): Promise<string | null> {
  const projects = await getWikiProjects();
  if (projects.length === 0) return null;

  // Try git remote origin
  try {
    const result = await pi.exec("git", ["remote", "get-url", "origin"], {
      timeout: 3000,
    });
    if (result.code === 0 && result.stdout.trim()) {
      const url = result.stdout.trim();
      // Extract repo name from URL (e.g. git@github.com:user/mapit.git -> mapit)
      const repoName = basename(url, ".git")
        .replace(/\.git$/, "")
        .toLowerCase();
      const match = projects.find((p) => p === repoName);
      if (match) return match;
    }
  } catch {}

  // Try cwd basename
  const dirName = basename(cwd).toLowerCase();
  const match = projects.find((p) => p === dirName);
  if (match) return match;

  return null;
}

async function getPlanFiles(cwd: string): Promise<string[]> {
  const plansDir = join(cwd, "plans");
  try {
    await access(plansDir);
    const entries = await readdir(plansDir);
    return entries.filter((f) => f.endsWith(".md")).sort();
  } catch {
    return [];
  }
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("plan-save", {
    description:
      "Move a draft plan from plans/ to Wiki/projects/<project>/plans/",
    handler: async (args, ctx) => {
      if (!ctx.isIdle()) {
        ctx.ui.notify("Agent is busy — wait for it to finish first", "warning");
        return;
      }

      const cwd = ctx.cwd;

      // Find plan files
      const planFiles = await getPlanFiles(cwd);
      if (planFiles.length === 0) {
        ctx.ui.notify("No .md files found in plans/", "warning");
        return;
      }

      // Pick plan file
      let planFile: string;
      if (planFiles.length === 1) {
        planFile = planFiles[0];
      } else {
        const picked = await ctx.ui.select("Which plan to save?", planFiles);
        if (!picked) return;
        planFile = picked;
      }

      // Detect or ask for project
      let project = await detectProject(pi, cwd);
      if (!project) {
        const projects = await getWikiProjects();
        if (projects.length === 0) {
          ctx.ui.notify("No projects found in Wiki", "error");
          return;
        }
        const picked = await ctx.ui.select("Which project?", projects);
        if (!picked) return;
        project = picked;
      }

      const srcPath = join(cwd, "plans", planFile);
      const destDir = join(WIKI_PROJECTS, project, "plans");
      const destPath = join(destDir, planFile);

      // Ensure destination exists
      await mkdir(destDir, { recursive: true });

      // Check if destination already exists
      try {
        await access(destPath);
        const overwrite = await ctx.ui.confirm(
          "Plan exists",
          `${project}/plans/${planFile} already exists. Overwrite?`,
        );
        if (!overwrite) return;
      } catch {
        // Doesn't exist, good
      }

      // Move the file
      try {
        await rename(srcPath, destPath);
      } catch (err: any) {
        // rename fails across filesystems, fall back to copy+delete
        if (err.code === "EXDEV") {
          const { copyFile, unlink } = await import("node:fs/promises");
          await copyFile(srcPath, destPath);
          await unlink(srcPath);
        } else {
          throw err;
        }
      }

      // Index
      try {
        await pi.exec("qmd", ["update"], { timeout: 15000 });
      } catch {
        // Non-fatal
      }

      ctx.ui.notify(`Saved: ${project}/plans/${planFile}`, "success");
    },
  });
}
