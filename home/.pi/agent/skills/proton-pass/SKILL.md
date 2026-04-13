---
name: proton-pass
description: "Manage secrets in Proton Pass using `pass-cli`. Use when creating, updating, viewing, listing, or organizing Proton Pass items and vaults, especially for API keys, tokens, and other env-style secrets."
---

# Proton Pass Skill

Use Proton Pass via the `pass-cli` command.

## When to use

Use this skill when the user wants to:

- create or update secrets in Proton Pass
- inspect existing Proton Pass items or vaults
- migrate API keys or tokens into Proton Pass
- organize items for later use by tools like fnox
- verify Proton Pass CLI authentication or session state

## Assumptions and conventions

- Proton Pass CLI binary is `pass-cli`
- A valid session is required before item operations work
- For secret-style entries, prefer **custom items** with a consistent schema
- Recommended convention for env-style secrets:
  - item title = exact env var name, e.g. `ANTHROPIC_API_KEY`
  - one hidden field named `value`
- No new vault is required unless the user explicitly asks for one

## First checks

Verify CLI availability and authentication:

```bash
pass-cli --help
pass-cli test
pass-cli info
```

If authentication is broken or expired:

```bash
pass-cli login
```

## Vault operations

List available vaults:

```bash
pass-cli vault list
pass-cli vault list --output json
```

Many item creation commands require one of:

- `--vault-name <VAULT_NAME>`
- `--share-id <SHARE_ID>`

Prefer `--vault-name` unless the user specifically wants share IDs.

## Item operations

### List items

```bash
pass-cli item list <VAULT_NAME>
pass-cli item list <VAULT_NAME> --output json
```

Filter by type if useful:

```bash
pass-cli item list <VAULT_NAME> --filter-type custom --output json
```

### View an item

By title:

```bash
pass-cli item view --vault-name <VAULT_NAME> --item-title <TITLE>
```

By item ID/share ID:

```bash
pass-cli item view --share-id <SHARE_ID> --item-id <ITEM_ID>
```

Fetch JSON when you need structure:

```bash
pass-cli item view --vault-name <VAULT_NAME> --item-title <TITLE> --output json
```

### Create a custom item

Get the template first:

```bash
pass-cli item create custom --get-template
```

Recommended JSON shape for env-style secrets:

```json
{
  "title": "ANTHROPIC_API_KEY",
  "note": "Managed via Proton Pass",
  "sections": [
    {
      "section_name": "Secrets",
      "fields": [
        {
          "field_name": "value",
          "field_type": "hidden",
          "value": "sk-ant-..."
        }
      ]
    }
  ]
}
```

Create it:

```bash
pass-cli item create custom --vault-name <VAULT_NAME> --from-template /path/to/template.json
```

### Update an item

```bash
pass-cli item update \
  --vault-name <VAULT_NAME> \
  --item-title <TITLE> \
  --field 'value=NEW_SECRET'
```

If field-only updates do not behave as expected for a complex item, inspect the item JSON first and fall back to recreating it from a template.

## Safe workflow for secret migration

When migrating existing secrets into Proton Pass:

1. Read the source secret from its current location
2. Create a temporary JSON template file with restrictive permissions
3. Create the Proton Pass item with `pass-cli item create custom`
4. Verify the item exists and contains the expected hidden field
5. Delete the temporary file

Example:

```bash
pass-cli item create custom --get-template > /tmp/proton-item.json
chmod 600 /tmp/proton-item.json
# edit template
pass-cli item create custom --vault-name <VAULT_NAME> --from-template /tmp/proton-item.json
rm /tmp/proton-item.json
```

## Suggested naming convention

For env-style secrets, use:

- title: exact env var name
- hidden field: `value`

Examples:

- `ANTHROPIC_API_KEY`
- `GEMINI_API_KEY`
- `CONTEXT7_API_KEY`
- `RAINDROP_API_KEY`
- `NPM_TOKEN`
- `GH_TOKEN`
- `GEM_HOST_API_KEY`

This keeps later automation simple and predictable.

## Troubleshooting

### Authentication errors

If `pass-cli test` reports session/encryption issues:

```bash
pass-cli login
pass-cli test
pass-cli info
```

### Missing vault error

If Proton Pass says:

```text
Please provide either --share-id or --vault-name
```

List vaults first, then retry with `--vault-name`:

```bash
pass-cli vault list
pass-cli item create custom --vault-name <VAULT_NAME> --from-template /path/to/template.json
```

### Inspect available commands

```bash
pass-cli help
pass-cli item --help
pass-cli vault --help
```

## Notes

- Use `--output json` when you need stable, machine-readable output
- Prefer `--vault-name` over `--share-id` for readability
- Prefer custom items for API keys and tokens
- Keep Proton Pass item structure consistent so future automation is easy
