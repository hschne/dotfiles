### Visual Inspection with Chrome DevTools MCP

**Important**: When the user explictly requests this, use Chrome DevTools to visually verify the feature and check for JavaScript errors. 

**Load the DevTools controller:**

```
read({ path: "/home/hschne/.pi/agent/skills/chrome-devtools/SKILL.md" })
```

**Common verification tasks:**

#### Navigate to the Feature

Open the page in the browser and interact with it:

```
mcp({
  tool: "chrome_devtools_navigate",
  args: '{"url": "http://localhost:3000/path/to/feature"}'
})
```

#### Inspect for JavaScript Errors

Check the console for any JavaScript errors or warnings:

```
mcp({
  tool: "chrome_devtools_get_console",
  args: '{}'
})
```

If errors appear, fix them before proceeding.

#### Take Screenshots for Review

Capture the page state for your own review or to show the user:

```
mcp({
  tool: "chrome_devtools_screenshot",
  args: '{"fileName": "feature-screenshot"}'
})
```

#### Interact with the Feature

Simulate user interactions (clicks, form submissions, etc.):

```
mcp({
  tool: "chrome_devtools_click",
  args: '{"selector": ".button-class"}'
})
```

```
mcp({
  tool: "chrome_devtools_fill_form",
  args: '{"formSelector": "form#my-form", "values": {"field_name": "value"}}'
})
```

#### Check Network Requests

Verify API calls and network activity:

```
mcp({
  tool: "chrome_devtools_get_network_logs",
  args: '{}'
})
```

Look for failed requests (4xx, 5xx status codes) or unexpected API calls.

#### Verify DOM Structure

Inspect the rendered HTML to ensure elements are properly placed:

```
mcp({
  tool: "chrome_devtools_get_dom",
  args: '{"selector": ".container"}'
})
```

#### Check Styles & Layout

Use DevTools to verify CSS is applied correctly:

```
mcp({
  tool: "chrome_devtools_get_element_styles",
  args: '{"selector": ".element-to-inspect"}'
})
```


