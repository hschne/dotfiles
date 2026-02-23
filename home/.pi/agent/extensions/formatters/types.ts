export interface FormatterConfig {
  command: string[];
  extensions: string[];
  disabled?: boolean;
  environment?: Record<string, string>;
}

export interface FormattersConfig {
  formatters: Record<string, FormatterConfig>;
}

export interface FormatterStatus {
  name: string;
  extensions: string[];
  available: boolean;
}

export interface FormatResult {
  success: boolean;
  formatter: string;
}
