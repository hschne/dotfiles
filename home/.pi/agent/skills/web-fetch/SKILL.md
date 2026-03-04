---
name: web-fetch
description: "Instructions for manually fetching web content using curl and bash. Does NOT provide an MCP tool. Read this file when a URL needs to be fetched."
---

# Web Fetch Skill

Fetches web content efficiently based on URL type.

## Usage

### GitHub Files

For GitHub file URLs, convert to raw.githubusercontent.com and fetch directly:

```bash
# Original: https://github.com/github/copilot.vim/blob/release/plugin/copilot.vim
# Convert: remove '/blob' from the path
curl -s 'https://raw.githubusercontent.com/github/copilot.vim/release/plugin/copilot.vim'
```

**Pattern:**

```
https://github.com/{owner}/{repo}/blob/{branch}/{path}
→ https://raw.githubusercontent.com/{owner}/{repo}/{branch}/{path}
```

### Articles & Web Pages

For all other URLs, try markdown.new proxy first, fallback to raw curl:

```bash
# Try markdown.new first
result=$(curl -s 'https://markdown.new/https://example.com/article')

# If it fails (contains error JSON), fallback to raw curl
if echo "$result" | grep -q '"success":false'; then
  curl -s 'https://example.com/article'
else
  echo "$result"
fi
```

Or simply try markdown.new, and if it returns an error, use raw curl:

```bash
curl -s 'https://markdown.new/https://example.com/article'
# If output contains "success":false, retry with:
curl -s 'https://example.com/article'
```

## Strategy Selection

| URL Pattern                     | Strategy                                            |
| ------------------------------- | --------------------------------------------------- |
| `github.com/.../blob/...`       | Convert to raw.githubusercontent.com, curl directly |
| `raw.githubusercontent.com/...` | Curl directly (already raw)                         |
| Everything else                 | Try markdown.new, fallback to raw curl              |

## Failure Handling

If markdown.new returns `{"success":false,...}`:

1. Fallback to raw `curl -s 'URL'`
2. If that also fails or returns unusable HTML, use the `web-browser` skill

**Note:** markdown.new does not work with:

- GitHub URLs (use raw conversion instead)
- Pages requiring authentication
- Some JavaScript-heavy sites

## Examples

### Fetch a GitHub file

```bash
# User gives: https://github.com/astral-sh/uv/blob/main/README.md
curl -s 'https://raw.githubusercontent.com/astral-sh/uv/main/README.md'
```

### Fetch an article

```bash
# User gives: https://blog.example.com/some-article
curl -s 'https://markdown.new/https://blog.example.com/some-article'
# If fails, fallback:
curl -s 'https://blog.example.com/some-article'
```

### Fetch documentation

```bash
# User gives: https://docs.python.org/3/library/asyncio.html
curl -s 'https://markdown.new/https://docs.python.org/3/library/asyncio.html'
# If fails, fallback:
curl -s 'https://docs.python.org/3/library/asyncio.html'
```
