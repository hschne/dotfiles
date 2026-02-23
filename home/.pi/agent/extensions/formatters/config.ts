import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { FormattersConfig, FormatterConfig } from "./types.js";

/**
 * Load and parse a JSON settings file.
 * Returns empty object if file doesn't exist or is invalid.
 */
function loadSettingsFile(path: string): Record<string, unknown> {
  if (!existsSync(path)) {
    return {};
  }

  try {
    const content = readFileSync(path, "utf-8");
    return JSON.parse(content);
  } catch {
    return {};
  }
}

/**
 * Load formatters configuration from global and project settings.
 * Project settings override global settings.
 */
export function loadConfig(cwd: string): FormattersConfig {
  const globalPath = join(homedir(), ".pi", "agent", "settings.json");
  const projectPath = join(cwd, ".pi", "settings.json");

  // Load settings files
  const globalSettings = loadSettingsFile(globalPath);
  const projectSettings = loadSettingsFile(projectPath);

  // Extract formatters config from each
  const globalFormatters = (globalSettings.formatters ?? {}) as Record<
    string,
    FormatterConfig
  >;
  const projectFormatters = (projectSettings.formatters ?? {}) as Record<
    string,
    FormatterConfig
  >;

  // Merge: project overrides global
  const merged: Record<string, FormatterConfig> = {
    ...globalFormatters,
    ...projectFormatters,
  };

  // Deep merge individual formatter configs when both exist
  for (const name of Object.keys(globalFormatters)) {
    if (projectFormatters[name]) {
      merged[name] = { ...globalFormatters[name], ...projectFormatters[name] };
    }
  }

  // Filter out disabled formatters
  const activeFormatters: Record<string, FormatterConfig> = {};
  for (const [name, config] of Object.entries(merged)) {
    if (!config.disabled) {
      activeFormatters[name] = config;
    }
  }

  return { formatters: activeFormatters };
}

/**
 * Find all formatters that handle a given file extension.
 * Returns in config order (first defined = first run).
 */
export function findFormattersForExtension(
  config: FormattersConfig,
  extension: string,
): Array<{ name: string; config: FormatterConfig }> {
  const result: Array<{ name: string; config: FormatterConfig }> = [];

  for (const [name, formatterConfig] of Object.entries(config.formatters)) {
    if (formatterConfig.extensions.includes(extension)) {
      result.push({ name, config: formatterConfig });
    }
  }

  return result;
}
