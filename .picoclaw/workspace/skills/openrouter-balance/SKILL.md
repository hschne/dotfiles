---
name: openrouter-balance
description: "Check OpenRouter API credit balance and usage stats (daily, weekly, monthly). Triggers on: 'check balance', 'how many credits', 'openrouter balance', 'remaining credits', 'api usage' queries."
---

# OpenRouter Balance

## Script

`~/.scripts/openrouter-balance` — checks your OpenRouter credit balance.

### Usage

```bash
~/.scripts/openrouter-balance
```

### Output

Shows total credits, total usage, remaining credits, plus daily/weekly/monthly breakdown in a formatted table.

## How It Works

- Reads the API key from `$PICOCLAW_SECURITY` or `~/.picoclaw/.security.yml`
- Queries OpenRouter's `/api/v1/credits` and `/api/v1/auth/key` endpoints
- Key pattern: `sk-or-v1-...`

## Notes

- No arguments needed. `-h`/`--help` prints usage.
- Requires `curl`, `python3`, and a valid OpenRouter API key.