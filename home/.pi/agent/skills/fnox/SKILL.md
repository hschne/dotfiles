---
name: fnox
description: "Use fnox for secret management on the command line. Covers providers, secret mappings, local sync, profiles, retrieval, diagnostics, and mise integration patterns. Use when configuring fnox, debugging secret resolution, or wiring env secrets into projects."
---

# fnox Skill

Use `fnox` to manage secret providers, map environment variables to secret backends, sync remote secrets to local encrypted storage, and expose secrets to commands or project environments.

## When to use

Use this skill when the user wants to:

- configure fnox providers
- map environment variables to secret backends
- retrieve or test secrets from fnox
- debug fnox config, providers, profiles, or resolution errors
- sync secrets from a remote provider to a local encrypted provider
- integrate fnox with mise
- set up project-scoped secret loading

## Current known setup on this machine

- Global config file: `~/.config/fnox/config.toml`
- Proton Pass provider name: `protonpass`
- Proton Pass CLI: `pass-cli`
- Local encrypted provider name: `age`
- Proton Pass item convention for env secrets:
  - custom item
  - item title = exact env var name
  - one hidden field named `value`
- Working Proton Pass provider keys use full Pass URIs, e.g.:
  - `pass://Personal/ANTHROPIC_API_KEY/value`

## Core commands

### Inspect configuration

```bash
fnox config-files
fnox doctor
fnox profiles
fnox list --sources
```

Use these first when debugging resolution or profile issues.

### Inspect providers

```bash
fnox provider list
fnox provider test protonpass
fnox provider test age
```

List provider help:

```bash
fnox provider --help
fnox provider add --help
```

### Get a secret

```bash
fnox get ANTHROPIC_API_KEY
fnox get GH_TOKEN
```

### Export or run with secrets

```bash
fnox export --format json
fnox exec -- env
fnox exec -- your-command
```

Use `fnox exec -- ...` when secrets should be loaded on demand for one command.

## Provider configuration

### Proton Pass provider

Example global provider config:

```toml
[providers.protonpass]
type = "proton-pass"
vault = "Personal"
```

CLI example:

```bash
fnox provider add protonpass proton-pass --global --vault Personal
```

### Age provider

Current machine pattern uses an age provider with an SSH recipient.

Example config shape:

```toml
[providers.age]
type = "age"
recipients = ["ssh-rsa AAAA... hschne"]
```

Test it with:

```bash
fnox provider test age
```

## Mapping secrets to providers

### Important Proton Pass note

For Proton Pass custom items, do **not** assume the item title alone is enough.

Use the full Pass URI with field name:

```text
pass://<vault>/<item-title>/<field-name>
```

Example:

```text
pass://Personal/ANTHROPIC_API_KEY/value
```

### Mapping commands

```bash
fnox set ANTHROPIC_API_KEY --global --provider protonpass --key-name 'pass://Personal/ANTHROPIC_API_KEY/value'
fnox set GEMINI_API_KEY --global --provider protonpass --key-name 'pass://Personal/GEMINI_API_KEY/value'
fnox set CONTEXT7_API_KEY --global --provider protonpass --key-name 'pass://Personal/CONTEXT7_API_KEY/value'
fnox set RAINDROP_API_KEY --global --provider protonpass --key-name 'pass://Personal/RAINDROP_API_KEY/value'
fnox set NPM_TOKEN --global --provider protonpass --key-name 'pass://Personal/NPM_TOKEN/value'
fnox set GH_TOKEN --global --provider protonpass --key-name 'pass://Personal/GH_TOKEN/value'
fnox set GEM_HOST_API_KEY --global --provider protonpass --key-name 'pass://Personal/GEM_HOST_API_KEY/value'
```

Verify afterward:

```bash
fnox list --sources
fnox get ANTHROPIC_API_KEY
fnox get GH_TOKEN
```

## Removing or fixing secrets

Remove a secret mapping:

```bash
fnox rm MY_SECRET --global
```

If `fnox rm` says the secret is not found, inspect where it is defined:

```bash
fnox config-files
fnox list --sources
```

A secret may be defined in a local `fnox.toml` rather than the global config.

## Sync remote secrets to local encrypted storage

Use `fnox sync` with flags, not positional source/target arguments.

### Sync all Proton Pass-backed secrets into age

```bash
fnox sync --global --source protonpass --provider age
```

### Sync only selected keys

```bash
fnox sync --global --source protonpass --provider age ANTHROPIC_API_KEY GEMINI_API_KEY
```

### Verify sync

```bash
fnox doctor
fnox list --sources
```

On this machine, synced values are stored as inline `sync = { provider = "age", value = "..." }` metadata inside `~/.config/fnox/config.toml`.

## Shell usage guidance

### Avoid global fnox shell activation for Proton Pass-backed secrets

This can make shell startup slow:

```zsh
eval "$(fnox activate zsh)"
```

Because fnox may resolve all top-level configured secrets during shell startup.

### Prefer one of these patterns

#### On-demand command execution

```bash
fnox exec -- your-command
```

#### Mise integration

Use mise to load fnox secrets per project instead of globally for every shell.

## Mise integration

Read the fnox mise integration docs when working on this setup. The intended plugin is `jdx/mise-env-fnox`.

Project `mise.toml`:

```toml
[plugins]
fnox-env = "https://github.com/jdx/mise-env-fnox"

[tools]
fnox = "latest"

[env]
_.fnox-env = { tools = true }
```

With profile:

```toml
[env]
_.fnox-env = { tools = true, profile = "dev" }
```

`tools = true` is required when fnox is installed via mise.

### Shell setup for mise

```zsh
export MISE_ENV_CACHE=1
eval "$(mise activate zsh)"
```

Do not also enable global fnox shell activation unless the user explicitly wants that behavior.

### Mise behavior

The fnox mise plugin:

1. searches for `fnox.toml` in the current directory and parents
2. resolves secrets using configured providers
3. exports them to the environment
4. supports caching with `MISE_ENV_CACHE=1`

## Troubleshooting

### Provider not configured in profile

If fnox says something like:

```text
Provider 'protonpass' not configured in profile 'default'
```

Check that the provider exists in an active config file:

```bash
fnox config-files
fnox doctor
fnox provider list
```

Then inspect `~/.config/fnox/config.toml` and ensure a matching provider block exists:

```toml
[providers.protonpass]
type = "proton-pass"
vault = "Personal"
```

### Secret not found in Proton Pass

If fnox says:

```text
Proton Pass: secret 'pass://Personal/ANTHROPIC_API_KEY/password' not found
```

It likely defaulted to `password` but the item is a custom item with hidden field `value`.

Use:

```bash
fnox set ANTHROPIC_API_KEY --global --provider protonpass --key-name 'pass://Personal/ANTHROPIC_API_KEY/value'
```

### Shell startup is slow

If zsh startup becomes slow, check for:

```zsh
eval "$(fnox activate zsh)"
```

Prefer mise integration and/or `fnox exec -- ...`.

### Config seems wrong or inconsistent

Use:

```bash
fnox doctor
fnox list --sources
fnox config-files
```

And read `~/.config/fnox/config.toml` before making changes.

## Practical workflow on this machine

1. Store env secrets in Proton Pass custom items
2. Map them in fnox using full `pass://.../value` URIs
3. Sync them locally into the `age` provider
4. Use mise integration for project-scoped loading
5. Use `MISE_ENV_CACHE=1` to speed repeated loads
6. Avoid eager global shell loading through fnox itself
