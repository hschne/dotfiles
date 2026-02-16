import type {
  Diagnostic,
  Location,
  Hover,
  DocumentSymbol,
  SymbolInformation,
  CallHierarchyItem,
  CallHierarchyIncomingCall,
  CallHierarchyOutgoingCall,
} from "vscode-languageserver-types";

export type {
  Diagnostic,
  Location,
  Hover,
  DocumentSymbol,
  SymbolInformation,
  CallHierarchyItem,
  CallHierarchyIncomingCall,
  CallHierarchyOutgoingCall,
};

/**
 * Server configuration from settings.json
 */
export interface ServerConfig {
  command: string[];
  extensions: string[];
  rootPatterns?: string[];
  disabled?: boolean;
  env?: Record<string, string>;
  initialization?: Record<string, unknown>;
}

/**
 * LSP configuration section from settings.json
 */
export interface LspConfig {
  servers: Record<string, ServerConfig>;
}

/**
 * Server status for /lsp command
 */
export interface ServerStatus {
  id: string;
  status: "connected" | "error" | "stopped";
  root: string;
  error?: string;
}

/**
 * Position in a file (1-based, as shown in editors)
 */
export interface Position {
  line: number;
  character: number;
}

/**
 * LSP operations supported by the tool
 */
export const LSP_OPERATIONS = [
  "diagnostics",
  "definition",
  "references",
  "hover",
  "documentSymbols",
  "workspaceSymbols",
  "implementation",
  "incomingCalls",
  "outgoingCalls",
] as const;

export type LspOperation = (typeof LSP_OPERATIONS)[number];

/**
 * Language ID mapping from file extension
 */
export const LANGUAGE_IDS: Record<string, string> = {
  ".ts": "typescript",
  ".tsx": "typescriptreact",
  ".js": "javascript",
  ".jsx": "javascriptreact",
  ".mjs": "javascript",
  ".cjs": "javascript",
  ".mts": "typescript",
  ".cts": "typescript",
  ".rb": "ruby",
  ".rake": "ruby",
  ".gemspec": "ruby",
  ".ru": "ruby",
  ".svelte": "svelte",
  ".md": "markdown",
  ".markdown": "markdown",
  ".yaml": "yaml",
  ".yml": "yaml",
};

/**
 * Diagnostic severity levels
 */
export const DiagnosticSeverity = {
  Error: 1,
  Warning: 2,
  Information: 3,
  Hint: 4,
} as const;
