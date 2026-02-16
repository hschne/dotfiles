import { fileURLToPath } from "node:url";
import { relative } from "node:path";
import type { LspManager } from "./manager.js";
import type {
  Diagnostic,
  Location,
  Hover,
  DocumentSymbol,
  SymbolInformation,
  CallHierarchyIncomingCall,
  CallHierarchyOutgoingCall,
  LspOperation,
} from "./types.js";
import { DiagnosticSeverity, LSP_OPERATIONS } from "./types.js";

export const LSP_TOOL_DESCRIPTION = `Query language servers for code intelligence.

Parameters:
- operation: The operation to perform (see below)
- filePath: Path to the file (required, use "filePath" not "path")
- line: Line number, 1-based (required for some operations)
- character: Character offset, 1-based (required for some operations)
- query: Search query (for workspaceSymbols only)

Operations:
- diagnostics: Get errors and warnings for a file
- definition: Find where a symbol is defined (requires line, character)
- references: Find all references to a symbol (requires line, character)
- hover: Get type info and documentation (requires line, character)
- documentSymbols: List all symbols (functions, classes, etc.) in a file
- workspaceSymbols: Search for symbols across the workspace (requires query)
- implementation: Find implementations of an interface/method (requires line, character)
- incomingCalls: Find functions that call the function at position (requires line, character)
- outgoingCalls: Find functions called by the function at position (requires line, character)`;

export interface LspToolParams {
  operation: LspOperation;
  filePath: string;
  line?: number;
  character?: number;
  query?: string;
}

/**
 * Execute an LSP operation and format the result.
 */
export async function executeLspTool(
  manager: LspManager,
  params: LspToolParams,
  cwd: string
): Promise<{ output: string; title: string }> {
  const { operation, filePath, line, character, query } = params;
  
  const title = `lsp ${operation} ${filePath}${line ? `:${line}:${character}` : ""}`;
  
  if (!LSP_OPERATIONS.includes(operation)) {
    return { title, output: `Unknown operation: ${operation}` };
  }
  
  if (!manager.hasServer(filePath)) {
    return { title, output: `No LSP server configured for this file type.` };
  }
  
  if (manager.isServerBroken(filePath)) {
    return { title, output: `LSP server not available. The language server may not be installed.` };
  }
  
  const needsPosition = ["definition", "references", "hover", "implementation", "incomingCalls", "outgoingCalls"];
  if (needsPosition.includes(operation) && (line === undefined || character === undefined)) {
    return { title, output: `Operation "${operation}" requires line and character.` };
  }
  if (operation === "workspaceSymbols" && !query) {
    return { title, output: `Operation "workspaceSymbols" requires query.` };
  }

  switch (operation) {
    case "diagnostics":
      await manager.touchFile(filePath, true);
      return { title, output: formatDiagnostics(await manager.getDiagnostics(filePath)) };
    case "definition":
      return { title, output: formatLocations(await manager.definition(filePath, line!, character!), cwd) };
    case "references":
      return { title, output: formatLocations(await manager.references(filePath, line!, character!), cwd) };
    case "hover":
      return { title, output: formatHover(await manager.hover(filePath, line!, character!)) };
    case "documentSymbols":
      await manager.touchFile(filePath);
      return { title, output: formatDocumentSymbols(await manager.documentSymbols(filePath)) };
    case "workspaceSymbols":
      return { title, output: formatWorkspaceSymbols(await manager.workspaceSymbols(filePath, query!), cwd) };
    case "implementation":
      return { title, output: formatLocations(await manager.implementation(filePath, line!, character!), cwd) };
    case "incomingCalls":
      return { title, output: formatIncomingCalls(await manager.incomingCalls(filePath, line!, character!), cwd) };
    case "outgoingCalls":
      return { title, output: formatOutgoingCalls(await manager.outgoingCalls(filePath, line!, character!), cwd) };
    default:
      return { title, output: `Unknown operation: ${operation}` };
  }
}

// ============ Formatters ============

const SEVERITY_NAMES: Record<number, string> = {
  [DiagnosticSeverity.Error]: "ERROR",
  [DiagnosticSeverity.Warning]: "WARN",
  [DiagnosticSeverity.Information]: "INFO",
  [DiagnosticSeverity.Hint]: "HINT",
};

export function formatDiagnostic(d: Diagnostic): string {
  const severity = SEVERITY_NAMES[d.severity ?? 1] ?? "ERROR";
  return `${severity} [${d.range.start.line + 1}:${d.range.start.character + 1}] ${d.message}`;
}

function formatDiagnostics(diagnostics: Diagnostic[]): string {
  if (!diagnostics.length) return "No diagnostics.";
  return [...diagnostics]
    .sort((a, b) => (a.severity ?? 1) - (b.severity ?? 1))
    .slice(0, 50)
    .map(formatDiagnostic)
    .join("\n") + (diagnostics.length > 50 ? `\n... and ${diagnostics.length - 50} more` : "");
}

function formatLocations(locations: Location[], cwd: string): string {
  if (!locations.length) return "No results found.";
  return locations.slice(0, 20).map((loc) => 
    `${relative(cwd, fileURLToPath(loc.uri))}:${loc.range.start.line + 1}:${loc.range.start.character + 1}`
  ).join("\n");
}

function formatHover(hover: Hover | null): string {
  if (!hover) return "No hover information.";
  const c = hover.contents;
  if (typeof c === "string") return c;
  if (Array.isArray(c)) return c.map((x) => (typeof x === "string" ? x : x.value)).join("\n\n");
  if ("value" in c) return c.value;
  return JSON.stringify(c, null, 2);
}

function formatDocumentSymbols(symbols: DocumentSymbol[], indent = 0): string {
  if (!symbols.length) return indent === 0 ? "No symbols found." : "";
  return symbols.map((s) => {
    const prefix = "  ".repeat(indent);
    const kind = SYMBOL_KINDS[s.kind] ?? "symbol";
    const children = s.children?.length ? "\n" + formatDocumentSymbols(s.children, indent + 1) : "";
    return `${prefix}${kind} ${s.name} [line ${s.range.start.line + 1}]${children}`;
  }).join("\n");
}

function formatWorkspaceSymbols(symbols: SymbolInformation[], cwd: string): string {
  if (!symbols.length) return "No symbols found.";
  return symbols.map((s) => {
    const path = relative(cwd, fileURLToPath(s.location.uri));
    return `${SYMBOL_KINDS[s.kind] ?? "symbol"} ${s.name} - ${path}:${s.location.range.start.line + 1}`;
  }).join("\n");
}

function formatIncomingCalls(calls: CallHierarchyIncomingCall[], cwd: string): string {
  if (!calls.length) return "No incoming calls found.";
  return calls.map((c) => 
    `${c.from.name} - ${relative(cwd, fileURLToPath(c.from.uri))}:${c.from.range.start.line + 1}`
  ).join("\n");
}

function formatOutgoingCalls(calls: CallHierarchyOutgoingCall[], cwd: string): string {
  if (!calls.length) return "No outgoing calls found.";
  return calls.map((c) => 
    `${c.to.name} - ${relative(cwd, fileURLToPath(c.to.uri))}:${c.to.range.start.line + 1}`
  ).join("\n");
}

const SYMBOL_KINDS: Record<number, string> = {
  1: "File", 2: "Module", 3: "Namespace", 4: "Package", 5: "Class",
  6: "Method", 7: "Property", 8: "Field", 9: "Constructor", 10: "Enum",
  11: "Interface", 12: "Function", 13: "Variable", 14: "Constant", 15: "String",
  16: "Number", 17: "Boolean", 18: "Array", 19: "Object", 20: "Key",
  21: "Null", 22: "EnumMember", 23: "Struct", 24: "Event", 25: "Operator", 26: "TypeParameter",
};
