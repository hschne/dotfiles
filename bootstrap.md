# Bootstrap manual steps

The yadm bootstrap handles the safe, non-secret setup. Run these steps manually after it finishes.

## 1. Change the temporary NixOS password

```bash
passwd
```

## 2. Restore SSH identity

Preferred: restore the existing `~/.ssh/id_ed25519` from Proton Pass or backup. That keeps GitHub access and fnox age-decrypted secrets compatible.

If you need a new key instead:

```bash
ssh-keygen -t ed25519 -C "hschne@rocinante" -f ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

Add the public key to GitHub, then verify:

```bash
ssh -T git@github.com
```

If this is a new SSH key, update `~/.config/fnox/config.toml` so `providers.age.recipients` contains the new public key before re-syncing secrets.

## 3. Log in to Proton Pass and sync secrets

```bash
pass-cli login
pass-cli test
fnox doctor
fnox provider test protonpass
fnox sync --global --source protonpass --provider age
fnox provider test age
fnox doctor
```

## 4. Authenticate GitHub CLI

If `GH_TOKEN` is available through fnox:

```bash
fnox get GH_TOKEN | gh auth login --with-token
gh auth status
```

Otherwise:

```bash
gh auth login
gh auth status
```

## 5. Verify dotfiles and repos

```bash
yadm status
yadm remote -v
git -C ~/Source/nixfiles status
git -C ~/Source/nixfiles remote -v
```

## 6. Verify developer tools

```bash
mise doctor
mise ls
node --version
ruby --version
go version
python --version
pi --version
qmd update
qmd embed
```

## 7. Rebuild NixOS from the checked-out repo

After the generated hardware config has been committed to nixfiles:

```bash
cd ~/Source/nixfiles
sudo nixos-rebuild switch --flake .#rocinante
```
