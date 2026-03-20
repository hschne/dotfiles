---
name: svelte
description: Apply Svelte best practices for writing maintainable, reusable Svelte views and components
---

# Svelte

Apply best practices when writing or refactoring Svelte components or views. These patterns emphasize code reusability, proper separation of concerns, and SOLID design principles.

## When to Use This Skill

Invoke this skill when:
- Writing new Svelte components
- Refactoring existing Svelte code
- Reviewing Svelte components
- Integrating third-party JavaScript libraries
- Implementing form submission logic
- Managing controller state
- Setting up Turbo integration

## Svelte Conventions

- prefer constant function declarations
- prefer early returns over nested branching
- keep components presentation-focused when backend can compute state

## Svelte i18n

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
