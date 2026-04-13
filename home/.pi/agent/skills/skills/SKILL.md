---
name: skills
description: Write and maintain agent skills. Use when creating a new skill, restructuring an existing skill, improving skill discovery, organizing references, or documenting reusable workflows and conventions for agents.
---

# Skills

Use this skill when creating or editing another skill.

## Goals

A good skill is easy to discover, concise once loaded, and organized for progressive disclosure.

Core rules:

- Keep `SKILL.md` concise. Add only information the agent truly needs.
- Put detailed material in one-level-deep reference files and tell the agent exactly when to read them.
- Match instruction strictness to task fragility: heuristics for flexible tasks, exact steps for fragile workflows.
- Prefer reusable workflows, templates, examples, and validators over long prose.
- Test skills against real tasks and iterate based on observed failures.

## Frontmatter

Every `SKILL.md` must start with YAML frontmatter:

```yaml
---
name: writing-skills
description: Write and maintain agent skills. Use when creating a new skill, improving an existing skill, or organizing reusable references and workflows for agents.
---
```

Rules:

- `name` uses lowercase letters, numbers, and hyphens only
- `name` should be specific, not vague
- prefer names that describe the capability clearly
- `description` must explain both what the skill does and when to use it
- write descriptions in third person

## SKILL.md Structure

Use this structure unless there is a clear reason not to:

```md
# <Skill Name>

<One short sentence explaining what the skill is for.>

## When to Use This Skill

- Trigger or task type
- Trigger or task type
- Trigger or task type

## Core Rules

- Short, durable rule
- Short, durable rule
- Short, durable rule

## Workflow

1. Read the relevant reference(s)
2. Execute the task using the prescribed pattern
3. Validate the result
4. Iterate until checks pass

## References

Always use a table for references.

Use this general shape:

| Topic   | <Meta>                                                                        | Reference                      |
| ------- | ----------------------------------------------------------------------------- | ------------------------------ |
| <topic> | <additional metadata that helps the agent decide when to read this reference> | [<name>](references/<file>.md) |

Rules:

- always use a table, never a list
- the first column is the topic or concern
- the second column is additional metadata for choosing the reference
- the third column links to the reference file
- name the second column after the kind of metadata that is most useful for the skill

Common second-column names include `Path`, `Description`, `Usage`, `Elements`, `Trigger`, or another context-specific label.
```

## Writing Guidelines

### Be concise

Assume the agent is already capable. Only include domain knowledge, constraints, file locations, workflows, and conventions that are not obvious.

**Good:**

```md
- Run `bin/rails test` after controller changes.
```

**Bad:**

```md
- Rails applications usually have tests, and tests are important because they help catch regressions and ensure the application continues to work as intended after code changes, so after changing controllers you should usually consider running tests.
```

### Set the right degree of freedom

Use:

- high freedom for style guidance and heuristics
- medium freedom for preferred patterns with some adaptation
- low freedom for fragile, order-dependent, or destructive operations

**Good:**

```md
For migrations:

1. Add the schema change
2. Add constraints and indexes
3. Migrate data separately when needed
4. Run migration and rollback locally
```

**Bad:**

```md
Handle migrations however seems appropriate.
```

### Prefer progressive disclosure

`SKILL.md` should act like a table of contents. Put long or domain-specific details in reference files and link them directly from `SKILL.md`.

Rules:

- keep references one level deep from `SKILL.md`
- avoid chains like `SKILL.md -> guide.md -> more-guide.md`
- if a reference file gets long, add a table of contents at the top
- use descriptive file names

### Use durable language

Avoid time-sensitive instructions unless they are explicitly historical. Prefer stable conventions over commentary about current trends.

### Use consistent terminology

Pick one term per concept and reuse it throughout the skill.

## Pattern / Anti-Pattern Format

When documenting conventions, prefer paired examples that show the desired pattern and the thing to avoid.

Use this structure:

````md
## <Topic>

**Good:**

```ruby
# example
```

**Bad:**

```ruby
# example
```
````

Add a short why only when it helps the agent choose correctly.

### Example

`````md
## Turbo Stream Responses

**Good:**

````ruby
def create
  @record = Record.create!(record_params)

  respond_to do |format|
    format.html { redirect_to records_path }
    format.turbo_stream
  end
end

**Bad:**

```ruby
def create
  @record = Record.create!(record_params)
  render turbo_stream: turbo_stream.append("records", partial: "records/record", locals: { record: @record })
end
````
`````

## References

References should always be presented as tables.

Use a short lead-in sentence before the table, then a 3-column structure:

```md
## References

<Short sentence that tells the agent how to use the references below.>

| Topic   | <Meta>                | Reference                      |
| ------- | --------------------- | ------------------------------ |
| <topic> | <additional metadata> | [<name>](references/<file>.md) |
```

Examples of good lead-in sentences:

- `Use the focused reference that matches the task:`
- `Read the relevant reference based on the area you are changing:`
- `Use these references to choose the feature-specific documentation you need:`
- `Choose the reference that best matches the concept or API involved:`

Rules:

- always use a table, never a list
- add a short lead-in sentence before the table
- the lead-in sentence should tell the agent how to choose from the references
- the first column is the topic or concern
- the second column is additional metadata that helps the agent decide when to read the reference
- the third column links to the reference file
- choose the second column name based on what is most useful for the skill
- use direct links to files inside `references/`
- keep references one level deep from `SKILL.md`
- if some references are optional, make that obvious in the metadata column

Common second-column patterns:

### Path-based

Best for framework or codebase skills where files strongly signal which reference applies.

| Topic       | Path                   | Reference                                |
| ----------- | ---------------------- | ---------------------------------------- |
| controllers | `app/controllers/**/*` | [controllers](references/controllers.md) |
| models      | `app/models/**/*`      | [models](references/models.md)           |
| tests       | `test/**/*`            | [testing](references/testing.md)         |

### Description-based

Best for concept or documentation-heavy skills where the agent chooses based on what the task is about.

| Topic           | Description                                            | Reference                                        |
| --------------- | ------------------------------------------------------ | ------------------------------------------------ |
| markdown syntax | Slide separators, frontmatter, notes, and code blocks  | [core-syntax](references/core-syntax.md)         |
| animations      | `v-click`, transitions, and motion features            | [core-animations](references/core-animations.md) |
| async patterns  | Promise coordination, cancellation, and error handling | [async](references/async.md)                     |

### Usage-based

Best when the agent should choose based on examples, commands, or capabilities.

| Topic         | Usage              | Reference                                    |
| ------------- | ------------------ | -------------------------------------------- |
| monaco editor | ` ```ts {monaco} ` | [editor-monaco](references/editor-monaco.md) |
| code tabs     | `::code-group`     | [code-groups](references/code-groups.md)     |

The important rule is consistency and usefulness: the metadata column should make reference selection easier for the agent.

## Workflow Patterns

For complex skills, include a short workflow.

Preferred pattern:

1. Identify the task area
2. Read the matching reference(s)
3. Apply the convention or workflow
4. Run validation steps
5. Fix issues and re-run validation

If the workflow is fragile or destructive, make the steps explicit and ordered.

## Validation and Iteration

A skill should tell the agent how to verify success.

Use feedback loops when possible:

- run validator
- inspect errors
- fix issues
- rerun validator

Examples of validators:

- test suites
- linters
- formatters
- type checks
- custom scripts
- reference checklists

When a skill supports critical operations, prefer deterministic scripts over asking the agent to improvise.

## Scripts and Tooling

If the skill includes scripts:

- say whether the agent should run the script or read it as reference
- handle errors in the script instead of punting failure handling to the agent
- document required dependencies
- use forward slashes in all file paths
- prefer descriptive script names

## Anti-Patterns

Avoid:

- vague names like `helper` or `utils`
- first-person descriptions like `I can help...`
- bloated `SKILL.md` files that should be split into references
- nested references several files deep
- offering many equivalent options without guidance
- including stale, time-sensitive advice in the main guidance
- undocumented magic values or unexplained scripts

## Checklist

Before finishing a skill, verify:

- frontmatter is valid
- description says what the skill does and when to use it
- `SKILL.md` is concise
- long details are moved into reference files
- references are one level deep
- references use a lead-in sentence plus a 3-column table with `Topic`, a useful metadata column, and `Reference`
- important conventions include good and bad examples when useful
- workflow includes validation steps
- terminology is consistent
- paths use forward slashes
- the skill has been exercised on real tasks
