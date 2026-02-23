import type {
  ExtensionAPI,
  ExtensionContext,
} from "@mariozechner/pi-coding-agent";

// =============================================================================
// Types
// =============================================================================

type Provider = "anthropic" | "google-gemini-cli" | "openrouter";

interface ClaudeUsageData {
  provider: "anthropic";
  utilization: number;
  resetsAt: number | null;
}

interface GeminiUsageData {
  provider: "google-gemini-cli";
  utilization: number; // percentage used (0-100)
  resetsAt: number | null;
}

interface OpenRouterUsageData {
  provider: "openrouter";
  credits: number;
}

type UsageData = ClaudeUsageData | GeminiUsageData | OpenRouterUsageData;

interface ClaudeOAuthUsageResponse {
  five_hour?: { utilization?: number; resets_at?: string };
}

interface GeminiQuotaResponse {
  buckets?: Array<{
    modelId?: string;
    remainingFraction?: number;
    resetTime?: string;
  }>;
}

interface OpenRouterCreditsResponse {
  data?: {
    total_credits: number;
    total_usage: number;
  };
}

// =============================================================================
// Constants
// =============================================================================

const STATUS_KEY = "usage";
const REFRESH_INTERVAL = 60 * 1000; // 1 minute
const ICON = "󰓅";

const CLAUDE_USAGE_ENDPOINT = "https://api.anthropic.com/api/oauth/usage";
const CLAUDE_BETA_HEADER = "oauth-2025-04-20";
const GEMINI_QUOTA_ENDPOINT =
  "https://cloudcode-pa.googleapis.com/v1internal:retrieveUserQuota";

const OPENROUTER_CREDITS_ENDPOINT = "https://openrouter.ai/api/v1/credits";

const SUPPORTED_PROVIDERS: Provider[] = [
  "anthropic",
  "google-gemini-cli",
  "openrouter",
];

// =============================================================================
// State
// =============================================================================

let cachedUsage: UsageData | null = null;
let lastError: string | null = null;
let refreshTimer: ReturnType<typeof setInterval> | null = null;

function resetState() {
  cachedUsage = null;
  lastError = null;
}

// =============================================================================
// Helpers
// =============================================================================

function isSupported(provider: string | undefined): provider is Provider {
  return !!provider && SUPPORTED_PROVIDERS.includes(provider as Provider);
}

function parseISO8601ToUnix(dateStr: string | undefined): number | null {
  if (!dateStr) return null;
  const date = new Date(dateStr);
  return Number.isNaN(date.getTime())
    ? null
    : Math.floor(date.getTime() / 1000);
}

function formatDuration(resetsAtUnix: number | null): string {
  if (resetsAtUnix === null) return "?";
  const seconds = resetsAtUnix - Math.floor(Date.now() / 1000);
  if (seconds <= 0) return "now";
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  return h > 0 ? `${h}h${m}m` : `${m}m`;
}

function getUsageColor(percent: number): "error" | "warning" | "dim" {
  if (percent >= 90) return "error";
  if (percent >= 70) return "warning";
  return "dim";
}

async function checkResponse(res: Response): Promise<void> {
  if (res.status === 401) {
    throw new Error("unauthorized");
  }
  if (!res.ok) {
    const body = await res.text().catch(() => "");
    throw new Error(`HTTP ${res.status}: ${body.slice(0, 100)}`);
  }
}

// =============================================================================
// Fetching
// =============================================================================

async function fetchClaudeUsage(token: string): Promise<ClaudeUsageData> {
  const res = await fetch(CLAUDE_USAGE_ENDPOINT, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${token}`,
      "anthropic-beta": CLAUDE_BETA_HEADER,
      Accept: "application/json",
      "User-Agent": "pi-extension-usage/1.0",
    },
  });

  await checkResponse(res);
  const data: ClaudeOAuthUsageResponse = await res.json();

  if (data.five_hour?.utilization === undefined) {
    throw new Error("missing five_hour usage data");
  }

  const result: ClaudeUsageData = {
    provider: "anthropic",
    utilization: Math.round(data.five_hour.utilization),
    resetsAt: parseISO8601ToUnix(data.five_hour.resets_at),
  };

  return result;
}

async function fetchGeminiUsage(apiKeyJson: string): Promise<GeminiUsageData> {
  const { token, projectId } = JSON.parse(apiKeyJson) as {
    token: string;
    projectId: string;
  };

  const res = await fetch(GEMINI_QUOTA_ENDPOINT, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      "User-Agent": "pi-extension-usage/1.0",
      "X-Goog-Api-Client": "gl-node/22.17.0",
    },
    body: JSON.stringify({ project: projectId }),
  });

  await checkResponse(res);
  const data: GeminiQuotaResponse = await res.json();

  if (!data.buckets || data.buckets.length === 0) {
    throw new Error("no quota buckets");
  }

  // Find the bucket with the lowest remaining fraction
  let lowestFraction = 1;
  let lowestResetTime: string | null = null;

  for (const bucket of data.buckets) {
    if (
      bucket.remainingFraction !== undefined &&
      bucket.remainingFraction < lowestFraction
    ) {
      lowestFraction = bucket.remainingFraction;
      lowestResetTime = bucket.resetTime || null;
    }
  }

  return {
    provider: "google-gemini-cli",
    utilization: Math.round((1 - lowestFraction) * 100),
    resetsAt: parseISO8601ToUnix(lowestResetTime),
  };
}

async function fetchOpenRouterUsage(token: string): Promise<OpenRouterUsageData> {
  const res = await fetch(OPENROUTER_CREDITS_ENDPOINT, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${token}`,
      "User-Agent": "pi-extension-usage/1.0",
    },
  });

  await checkResponse(res);
  const data: OpenRouterCreditsResponse = await res.json();

  if (data.data?.total_credits === undefined) {
    throw new Error("missing credits data");
  }

  return {
    provider: "openrouter",
    credits: data.data.total_credits - data.data.total_usage,
  };
}

// =============================================================================
// UI
// =============================================================================

function updateUI(ctx: ExtensionContext) {
  const provider = ctx.model?.provider;

  if (!isSupported(provider)) {
    ctx.ui.setStatus(STATUS_KEY, undefined);
    return;
  }

  if (lastError) {
    const errorText = lastError === "unauthorized" ? "auth!" : "err!";
    ctx.ui.setStatus(
      STATUS_KEY,
      ctx.ui.theme.fg("error", `${ICON} ${errorText}`),
    );
    return;
  }

  if (!cachedUsage || cachedUsage.provider !== provider) {
    ctx.ui.setStatus(STATUS_KEY, ctx.ui.theme.fg("dim", `${ICON} ...`));
    return;
  }

  if (cachedUsage.provider === "openrouter") {
    const text = `${ICON} $${cachedUsage.credits.toFixed(2)}`;
    ctx.ui.setStatus(STATUS_KEY, ctx.ui.theme.fg("dim", text));
    return;
  }

  const { utilization, resetsAt } = cachedUsage;
  const text = `${ICON} ${utilization}%·${formatDuration(resetsAt)}`;

  ctx.ui.setStatus(
    STATUS_KEY,
    ctx.ui.theme.fg(getUsageColor(utilization), text),
  );
}

// =============================================================================
// Refresh Logic
// =============================================================================

async function performRefresh(ctx: ExtensionContext): Promise<void> {
  const provider = ctx.model?.provider;

  if (!isSupported(provider)) {
    resetState();
    updateUI(ctx);
    return;
  }

  try {
    const apiKey = await ctx.modelRegistry.getApiKeyForProvider(provider);

    if (!apiKey) {
      lastError = "no token";
      cachedUsage = null;
      updateUI(ctx);
      return;
    }

    if (provider === "anthropic") {
      cachedUsage = await fetchClaudeUsage(apiKey);
    } else if (provider === "google-gemini-cli") {
      cachedUsage = await fetchGeminiUsage(apiKey);
    } else {
      cachedUsage = await fetchOpenRouterUsage(apiKey);
    }
    lastError = null;
  } catch (err) {
    lastError = err instanceof Error ? err.message : "unknown error";
    cachedUsage = null;
  }

  updateUI(ctx);
}

function startRefreshTimer(ctx: ExtensionContext) {
  stopRefreshTimer();
  refreshTimer = setInterval(() => performRefresh(ctx), REFRESH_INTERVAL);
}

function stopRefreshTimer() {
  if (refreshTimer) {
    clearInterval(refreshTimer);
    refreshTimer = null;
  }
}

// =============================================================================
// Extension Entry Point
// =============================================================================

export default function (pi: ExtensionAPI) {
  pi.on("model_select", async (event, ctx) => {
    const wasSupported = isSupported(event.previousModel?.provider);
    const isNowSupported = isSupported(event.model.provider);
    const providerChanged =
      event.previousModel?.provider !== event.model.provider;

    if (isNowSupported && (!wasSupported || providerChanged)) {
      // Switched TO a supported provider (or between supported providers)
      resetState();
      updateUI(ctx);
      await performRefresh(ctx);
      startRefreshTimer(ctx);
    } else if (!isNowSupported && wasSupported) {
      // Switched AWAY from supported provider
      stopRefreshTimer();
      resetState();
      updateUI(ctx);
    } else if (isNowSupported) {
      // Still on same supported provider
      updateUI(ctx);
    }
  });

  pi.on("session_start", async (_, ctx) => {
    if (isSupported(ctx.model?.provider)) {
      await performRefresh(ctx);
      startRefreshTimer(ctx);
    }
  });

  pi.on("session_shutdown", () => {
    stopRefreshTimer();
  });
}
