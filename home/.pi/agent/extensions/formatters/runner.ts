import { execSync, spawn } from "node:child_process";
import { resolve } from "node:path";
import type {
  FormatterConfig,
  FormatResult,
  FormatterStatus,
} from "./types.js";

const FORMAT_TIMEOUT_MS = 30000;

/**
 * Check if a command exists in PATH.
 */
export function commandExists(cmd: string): boolean {
  try {
    execSync(`which ${cmd}`, { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}

/**
 * Run a formatter on a file.
 * Logs errors to console but doesn't throw (matches opencode behavior).
 */
export async function runFormatter(
  name: string,
  config: FormatterConfig,
  filePath: string,
  cwd: string,
): Promise<FormatResult> {
  const [cmd, ...args] = config.command;

  // Check if command exists (fail silently)
  if (!commandExists(cmd)) {
    return { success: false, formatter: name };
  }

  // Build command with $FILE replaced
  const absolutePath = resolve(cwd, filePath);
  const finalArgs = args.map((arg) => arg.replace("$FILE", absolutePath));

  return new Promise((resolvePromise) => {
    const proc = spawn(cmd, finalArgs, {
      cwd,
      env: { ...process.env, ...config.environment },
      stdio: ["ignore", "ignore", "ignore"], // Ignore all output (like opencode)
    });

    const timeout = setTimeout(() => {
      proc.kill();
      resolvePromise({ success: false, formatter: name });
    }, FORMAT_TIMEOUT_MS);

    proc.on("close", (code) => {
      clearTimeout(timeout);
      resolvePromise({ success: code === 0, formatter: name });
    });

    proc.on("error", () => {
      clearTimeout(timeout);
      resolvePromise({ success: false, formatter: name });
    });
  });
}

/**
 * Get status of all configured formatters.
 */
export function getFormatterStatus(
  formatters: Record<string, FormatterConfig>,
): FormatterStatus[] {
  const result: FormatterStatus[] = [];

  for (const [name, config] of Object.entries(formatters)) {
    const [cmd] = config.command;
    result.push({
      name,
      extensions: config.extensions,
      available: commandExists(cmd),
    });
  }

  return result;
}
