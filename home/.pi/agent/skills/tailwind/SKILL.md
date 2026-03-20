---
name: tailwind
description: Use Tailwind and DaisyUI for styling applications. Covers utility-first styling, component usage.
---

# DaisyUI and Tailwind

Use this skill when adding or changing styling in ERB or Svelte.

## Core Principles

- Prefer Tailwind utilities and DaisyUI components over custom CSS
- Prefer modern layout primitives like flex and grid
- Keep styling close to markup
- Avoid JavaScript string interpolation for class toggling when framework-native patterns exist

## Rails / ERB

Use `class_names` for conditional classes.

Good:

```erb
<div class="<%= class_names('mb-5', active: item.for_sale?) %>">
```

Bad:

```erb
<div class="mb-5 <%= item.for_sale? ? 'active' : '' %>">
```

## Svelte

Prefer Svelte class directives over interpolated class strings.

Good:

```svelte
<input
  class="file-input file-input-bordered w-full"
  class:file-input-error={errors['image']}
>
```

Bad:

```svelte
<input class="file-input file-input-bordered w-full {errors['image'] ? 'file-input-error' : ''}">
```

## Use Cases

Invoke this skill when:

- styling Rails views
- styling Svelte components
- choosing between custom CSS and utility classes
- refactoring class logic in templates
