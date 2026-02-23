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

For all other URLs, use the markdown.new proxy to get clean markdown:

```bash
curl -s 'https://markdown.new/https://example.com/article'
```

This returns the page content as clean, token-efficient markdown.

## Strategy Selection

| URL Pattern                     | Strategy                                            |
| ------------------------------- | --------------------------------------------------- |
| `github.com/.../blob/...`       | Convert to raw.githubusercontent.com, curl directly |
| `raw.githubusercontent.com/...` | Curl directly (already raw)                         |
| Everything else                 | Use markdown.new proxy                              |

## Failure Handling

If the primary strategy fails:

1. Report the error clearly
2. Ask the user if they want to try the `web-browser` skill as fallback

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
```

### Fetch documentation

```bash
# User gives: https://docs.python.org/3/library/asyncio.html
curl -s 'https://markdown.new/https://docs.python.org/3/library/asyncio.html'
```
