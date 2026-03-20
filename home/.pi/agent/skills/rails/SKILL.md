---
name: rails
description: Reusable Rails conventions for apps that favor Rails defaults, thin controllers, clear models, Hotwire, Minitest, and simple maintainable architecture. See references for models, controllers, data, testing, Hotwire, Inertia/Svelte, routing, and i18n.
---

# Rails

Use this skill for general Rails work that should follow a conventional, maintainable style.

## When to Use This Skill

Invoke this skill when:

- Adding or refactoring any Rails application code
- Writing or reviewing migrations and schema changes
- Writing or refactoring Rails views
- Deciding where logic belongs in a Rails app
- Reviewing test structure, fixtures, or i18n usage

## Core Principles

- Trust Rails conventions instead of fighting the framework
- Keep logic at the right layer: models handle data, controllers handle HTTP, jobs orchestrate workflows
- Prefer readable code over abstraction-heavy patterns
- Name things after business concepts, not technical patterns
- Normalize data into proper tables instead of piling concerns into one model
- Return simple values or Active Record objects; raise on errors rather than inventing result wrappers

## Architecture Rules

- Do not introduce `app/services/`, `app/contexts/`, or `app/operations/`
- Do not add use case / interactor style abstractions by default
- Keep controllers thin and use guard clauses
- Prefer namespaced model classes for extracted complexity

## References

Use the focused reference that matches the task:

- `references/models` 
- `references/controllers.md` 
- `references/policies.md` - for authorization logic
- `references/migrations-and-data.md` 
- `references/testing.md` - when writing tests
- `references/views.md` - when writing views
- `references/hotwire.md` - when using Hotwire/Turbo for improving views
- `references/routing.md` 
- `references/inertia.md` - when using InertiaJS for rendering views
- `references/i18n.md`

## Related Skills

- `better-stimulus` for Stimulus controller architecture and lifecycle patterns
- `tailwind` for CSS, utility classes, DaisyUI usage.
- `svelte` when using Svelte as fronted framework for InertiaJS

## Quick Workflow

1. Pick the right Rails layer for the change
2. Read the relevant reference(s)
3. Implement using Rails defaults first
4. Keep code small and obvious
5. Verify with lint, formatting, type checks, and tests
