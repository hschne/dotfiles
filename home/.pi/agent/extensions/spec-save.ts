/**
 * Spec Save Extension
 *
 * Provides a /spec-save command that moves a finished spec from the
 * local specs/ directory to ~/Documents/Wiki/projects/<project>/specs/
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

async function getSpecFiles(cwd: string): Promise<string[]> {
  const specsDir = join(cwd, "specs");
  try {
    await access(specsDir);
    const entries = await readdir(specsDir);
    return entries.filter((f) => f.endsWith(".md")).sort();
  } catch {
    return [];
  }
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("spec-save", {
    description:
      "Move a draft spec from specs/ to Wiki/projects/<project>/specs/",
    handler: async (args, ctx) => {
      if (!ctx.isIdle()) {
        ctx.ui.notify("Agent is busy — wait for it to finish first", "warning");
        return;
      }

      const cwd = ctx.cwd;

      // Find spec files
      const specFiles = await getSpecFiles(cwd);
      if (specFiles.length === 0) {
        ctx.ui.notify("No .md files found in specs/", "warning");
        return;
      }

      // Pick spec file
      let specFile: string;
      if (specFiles.length === 1) {
        specFile = specFiles[0];
      } else {
        const items = specFiles.map((f) => ({ label: f, value: f }));
        const picked = await ctx.ui.select("Which spec to save?", items);
        if (!picked) return;
        specFile = picked;
      }

      // Detect or ask for project
      let project = await detectProject(pi, cwd);
      if (!project) {
        const projects = await getWikiProjects();
        if (projects.length === 0) {
          ctx.ui.notify("No projects found in Wiki", "error");
          return;
        }
        const items = projects.map((p) => ({ label: p, value: p }));
        const picked = await ctx.ui.select("Which project?", items);
        if (!picked) return;
        project = picked;
      }

      const srcPath = join(cwd, "specs", specFile);
      const destDir = join(WIKI_PROJECTS, project, "specs");
      const destPath = join(destDir, specFile);

      // Ensure destination exists
      await mkdir(destDir, { recursive: true });

      // Check if destination already exists
      try {
        await access(destPath);
        const overwrite = await ctx.ui.confirm(
          "Spec exists",
          `${project}/specs/${specFile} already exists. Overwrite?`,
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

      // Clean up specs/ if empty
      const remaining = await getSpecFiles(cwd);
      if (remaining.length === 0) {
        try {
          const { rmdir } = await import("node:fs/promises");
          await rmdir(join(cwd, "specs"));
        } catch {
          // Not empty or other error, leave it
        }
      }

      // Index
      try {
        await pi.exec("qmd", ["update"], { timeout: 15000 });
      } catch {
        // Non-fatal
      }

      ctx.ui.notify(`Saved: ${project}/specs/${specFile}`, "success");
    },
  });
}
