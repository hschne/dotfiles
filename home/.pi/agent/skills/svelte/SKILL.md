---
name: svelte
description: Apply Svelte best practices for writing maintainable, reusable Svelte views and components. Use this whenever you are reading or writing Svelte files.
---

# Svelte

Apply best practices when writing or refactoring Svelte components or views. These patterns emphasize code reusability, proper separation of concerns, and SOLID design principles.

## When To Use This Skill

Invoke this skill when:
- Writing new Svelte components
- Refactoring existing Svelte code
- Reviewing Svelte components

## General Conventions

- prefer constant function declarations
- prefer early returns over nested branching
- keep components presentation-focused when backend can compute state
- run `pnpm check` after Svelte changes and treat warnings as design feedback, not noise

## Props Captured Only Once

Do not initialize `$state(...)` from props when you expect later prop updates to flow through.

Doing `$state(user?.name ?? '')` captures the initial value only, so later prop updates will not automatically update that local state. This creates stale UI, especially after Inertia reloads, optimistic updates, or parent-driven prop changes.

Bad:

```svelte
let { user } = $props()
let name = $state(user?.name ?? '')
```

Good:

```svelte
let { user } = $props()
let name = $state('')

$effect(() => {
  name = user?.name ?? ''
})
```

## Derive Values From Props

When a value should always track props, derive it.

Bad:

```svelte
const styleUrl = `https://example.com?key=${apiKey}`
```

Good:

```svelte
const styleUrl = $derived(`https://example.com?key=${apiKey}`)
```

## Normalize Props Without Mutation

Never mutate incoming props just to normalize or extend them.

Bad:

```svelte
if (!propSettings.snapPoints.includes(1)) {
  propSettings.snapPoints.push(1)
}
```

Good:

```svelte
const normalizedSettings = $derived.by(() => {
  const snapPoints = [...(propSettings.snapPoints ?? [1])]
  if (!snapPoints.includes(1)) snapPoints.push(1)

  return { ...propSettings, snapPoints }
})
```

## Latest Callback Value

When storing prop callbacks inside context objects or API objects, wrap them in a closure if they should always use the latest prop value.

Why:
- assigning the callback directly can capture an outdated prop reference
- closures make it explicit that the latest callback should be invoked at call time
- this avoids subtle bugs when parent components replace handlers

Bad:

```svelte
const api = {
  onChange: onchange,
}
```

Good:

```svelte
const api = {
  onChange: (event) => onchange?.(event),
}
```
## Markup And A11y

If a non-interactive wrapper listens to touch or pointer events only for event plumbing, add the appropriate ARIA role such as `role="presentation"`.
Event handlers on otherwise static elements can trigger accessibility warnings unless intent is made explicit.

**Bad**:

```svelte
<div
  ontouchmove={handleTouchMove}
  class={`fixed left-0 right-0 ${isActive ? 'z-50' : 'z-10'}`}
  style="top: {topPosition}; overscroll-behavior: contain;"
>
  <slot />
</div>
```

**Good**:

```svelte
<div
  ontouchmove={handleTouchMove}
  role="presentation"
  class="fixed inset-x-0"
  class:z-50={isActive}
  class:z-10={!isActive}
  style:top={topPosition}
  style:overscroll-behavior="contain"
>
  <slot />
</div>
```

## Class Directives

Prefer Svelte class directives over manually constructing class strings with JavaScript conditionals.

Why:
- class directives are easier to read than interpolated string logic
- they reduce accidental whitespace, duplication, and conflicting class bugs
- they make reactive intent explicit at the markup site instead of hiding it in string-building code
- they align with Svelte's templating model and are easier to lint and refactor

Prefer:

```svelte
<div
  class="btn"
  class:btn-primary={primary}
  class:btn-disabled={disabled}
/>
```

Over:

```svelte
<div class={`btn ${primary ? 'btn-primary' : ''} ${disabled ? 'btn-disabled' : ''}`} />
```

When using Tailwind or DaisyUI, keep stable classes in `class="..."` and toggle only the conditional pieces with `class:name={condition}`.

## Svelte I18n

Use `i18n` for client-side translations in Svelte/Inertia pages.

```svelte
<script>
  import { t,l } from "@/i18n";
</script>

<h1>{t('projects.title')}</h1>
<!-- Date localization -->
<p>{l("date.formats.long", new Date(endAt))}</p>
<!-- Pluralization -->
<p>{t("time.days", { count: days }}</p>
```
