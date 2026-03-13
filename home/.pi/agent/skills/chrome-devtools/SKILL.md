---
name: chrome-devtools
description: Uses Chrome DevTools via MCP for efficient debugging, troubleshooting and browser automation. Use when debugging web pages, automating browser interactions, analyzing performance, or inspecting network requests.
---

## Core Concepts

**Browser lifecycle**: Browser starts automatically on first tool call using a persistent Chrome profile. Configure via CLI args in the MCP server configuration: `npx chrome-devtools-mcp@latest --help`.

**Page selection**: Tools operate on the currently selected page. Use `list_pages` to see available pages, then `select_page` to switch context.

**Element interaction**: Use `take_snapshot` to get page structure with element `uid`s. Each element has a unique `uid` for interaction. If an element isn't found, take a fresh snapshot - the element may have been removed or the page changed.

## Workflow Patterns

### Before interacting with a page

1. Navigate: `navigate_page` or `new_page`
2. Wait: `wait_for` to ensure content is loaded if you know what you look for.
3. Snapshot: `take_snapshot` to understand page structure
4. Interact: Use element `uid`s from snapshot for `click`, `fill`, etc.

### Efficient data retrieval

- Use `filePath` parameter for large outputs (screenshots, snapshots, traces)
- Use pagination (`pageIdx`, `pageSize`) and filtering (`types`) to minimize data
- Set `includeSnapshot: false` on input actions unless you need updated page state

### Tool selection

- **Automation/interaction**: `take_snapshot` (text-based, faster, better for automation)
- **Visual inspection**: `take_screenshot` (when user needs to see visual state)
- **Additional details**: `evaluate_script` for data not in accessibility tree

### Parallel execution

You can send multiple tool calls in parallel, but maintain correct order: navigate → wait → snapshot → interact.

## Screenshots

### Taking screenshots with file output

Always use the `filePath` parameter when saving screenshots. This saves to disk and avoids embedding large images in responses:
```
take_screenshot with filePath: "/tmp/screenshot.png"
```

Supported formats: `png` (default), `jpeg`, `webp`

### Opening screenshots without blocking

When the user asks you to preview screenshots, use `nohup` with output redirection to open screenshots without blocking the agent. This allows the agent to continue working while the image viewer is open:

```bash
nohup xdg-open /tmp/screenshot.png > /dev/null 2>&1 &
```

This pattern:

- `nohup` - Makes the process immune to terminal hangups
- `> /dev/null 2>&1` - Redirects all output so it doesn't clutter the terminal
- `&` - Runs in background
