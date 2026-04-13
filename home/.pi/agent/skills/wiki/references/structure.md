# Wiki Structure

Use this reference when deciding where a document belongs in `~/Documents/Wiki/`.

## Collection Layout

```text
~/Documents/Wiki/
  projects/          # Active projects, each with plans/ and log/
  areas/             # Ongoing responsibilities
  resources/         # Reusable reference knowledge
  memory/            # AI workflow artifacts
    agents/          # Reusable AGENTS.md fragments
    sessions/        # Session summaries
  archive/           # Inactive or historical material
```

## Collection Rules

| Collection  | Use for                                                | Default search             |
| ----------- | ------------------------------------------------------ | -------------------------- |
| `projects`  | Active project files and project-specific documents    | yes                        |
| `areas`     | Ongoing domains like community, writing, or life admin | yes                        |
| `resources` | Reusable references, runbooks, and research            | yes                        |
| `memory`    | Agent artifacts and session summaries                  | yes                        |
| `archive`   | Old or inactive material                               | no, only search explicitly |

## Where to Save What

| User intent                  | Path pattern                                    | Naming                    |
| ---------------------------- | ----------------------------------------------- | ------------------------- |
| Save a spec                  | `projects/<project>/specs/<slug>.md`            | lowercase hyphenated slug |
| Write a project plan         | `projects/<project>/plans/<yy-mm-dd>-<slug>.md` | dated file name           |
| Save to the project          | `projects/<project>/<name>.md`                  | varies by context         |
| Create a runbook or resource | `resources/<slug>.md`                           | lowercase hyphenated slug |
| Add to an area               | `areas/<area>/<slug>.md`                        | lowercase hyphenated slug |
| Save session output          | `memory/sessions/<name>.md`                     | descriptive slug          |
| Save agent guidance          | `memory/agents/<name>.md`                       | descriptive slug          |
| Save inactive history        | `archive/<path>.md`                             | preserve context          |

## Selection Heuristics

- Prefer `projects` when the document belongs to one active project.
- Prefer `resources` when the document should be reusable outside a single project.
- Prefer `areas` for long-lived responsibilities that are not projects.
- Prefer `memory` for agent-facing artifacts and session history.
- Use `archive` only for inactive material or when explicitly requested.
