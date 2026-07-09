# Bootstrap

## Browser Login

Open up Firefox and login to Proton Pass

```
firefox
```

## Login to Proton Pass CLI

```bash
pass-cli login
```

## Restore Identity & GPG From Pass CLI

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh

pass-cli item view --vault-name Personal --item-title id_ed25519 --output json \
  | jq -r '.. | objects | select(.field_name? == "value") | .value' \
  > ~/.ssh/id_ed25519

chmod 600 ~/.ssh/id_ed25519
ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
chmod 644 ~/.ssh/id_ed25519.pub
```

```bash
pass-cli item view --vault-name Personal --item-title gpg --output json \
  | jq -r '.. | objects | select(.field_name? == "value") | .value' \
  | gpg --batch --import

gpg --list-secret-keys --keyid-format LONG
```

### Sync Keys to FNOX

```bash

fnox provider test protonpass
fnox sync --global --source protonpass --provider age
fnox provider test age
```

## 4. Authenticate GitHub CLI

If `GH_TOKEN` is available through fnox:

```bash
fnox get GH_TOKEN | gh auth login --with-token
gh auth status
```

```bash
gh auth login
gh auth status
```
