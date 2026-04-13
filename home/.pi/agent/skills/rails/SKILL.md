---
name: rails
description: Reusable Rails conventions for apps that favor Rails defaults. See references for models, controllers, data, testing, Hotwire, Inertia, routing, and i18n. Use this any time you read or write to a Rails app.
---

# Rails

Use this skill any time you work in a Rails application. When touching any part of the rails code base you MUST read the corresponding reference file and adhere to it.

## When to Use This Skill

Invoke this skill when:

- Changing or reading any Rails application code
- Writing or reviewing migrations and schema changes
- Writing or refactoring Rails views
- Deciding where logic belongs in a Rails app
- Reviewing test structure, fixtures, or i18n usage

## Style Guide

Regardless of what you change these core principles always apply.

- Do not add code comments, good code is self-explanatory.
- Prefer guard clauses over nested conditions, return early.
- Trust Rails conventions instead of fighting the framework
- Keep logic at the right layer: models handle data, controllers handle HTTP, jobs orchestrate workflows
- Name things after business concepts, not technical patterns
- Normalize data into proper tables instead of piling concerns into one model

## References

Use the focused reference that matches the task:

| Topic | Path | Reference |
| --- | --- | --- |
| models | `app/models/**/*` | [models](references/models.md) |
| controllers | `app/controllers/**/*` | [controllers](references/controllers.md) |
| policies | `app/policies/**/*` | [policies](references/policies.md) |
| migrations and data | `db/migrate/**/*`, `db/schema.rb`, `db/seeds.rb` | [migrations-and-data](references/migrations-and-data.md) |
| testing | `test/**/*` | [testing](references/testing.md) |
| views | `app/views/**/*` | [views](references/views.md) |
| hotwire | `app/views/**/*`, `aep/javascript/controllers/**/*` | [hotwire](references/hotwire.md) |
| routing | `config/routes.rb` | [routing](references/routing.md) |
| inertia | `app/controllers/**/*`, `app/javascript/**/*` | [inertia](references/inertia.md) |
| i18n | `config/locales/**/*` | [i18n](references/i18n.md) |

## Related Skills

- `better-stimulus` for Stimulus controller architecture and lifecycle patterns
- `tailwind` for CSS, utility classes, DaisyUI usage.
- `svelte` when using Svelte as fronted framework for InertiaJS

## Quick Workflow

1. Read the relevant reference(s)
2. Implement by adhering to references
5. Verify with lint, formatting, type checks, and tests
