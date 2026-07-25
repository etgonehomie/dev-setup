# dev-setup

Flexible macOS workstation bootstrap with an interactive wizard front-end and Ansible backend.

## Requirements
- macOS
- `curl`
- internet access to `github.com` and `raw.githubusercontent.com`

If `curl` is not installed:

```bash
# Install Homebrew (if needed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install curl
brew install curl
```

## Quick Start (no clone)

### Interactive wizard
```bash
curl -fsSL https://raw.githubusercontent.com/etgonehomie/dev-setup/main/main.sh | bash -s -- --wizard
```

### Reuse saved profile (non-interactive)
```bash
curl -fsSL https://raw.githubusercontent.com/etgonehomie/dev-setup/main/main.sh | bash -s -- --profile ~/.config/dev-setup/profile.yml --yes
```

### Dry run
```bash
curl -fsSL https://raw.githubusercontent.com/etgonehomie/dev-setup/main/main.sh | bash -s -- --wizard --dry-run
```

## Safety / reproducibility options

### Pin to a tag
```bash
curl -fsSL https://raw.githubusercontent.com/etgonehomie/dev-setup/v1.0.0/main.sh | bash -s -- --wizard
```

### Pin to a commit SHA
```bash
curl -fsSL https://raw.githubusercontent.com/etgonehomie/dev-setup/<commit-sha>/main.sh | bash -s -- --wizard
```

## Script reference

### `main.sh` (full setup)
Run locally:
```bash
bash main.sh [flags]
```

Key flags:
- `--wizard`: category-first interactive flow
- `--profile <path>`: load saved profile file
- `--yes`: non-interactive mode
- `--groups <csv>`: select categories directly
- `--packages <csv>`: select specific package IDs
- `--upgrade`: run `brew upgrade` before provisioning
- `--resume`: resume using checkpoint state
- `--raycast-config`: apply Raycast config import (requires `RAYCAST_PASSWORD`)
- `--cleanup`: remove ansible-pull clone cache at end
- `--dry-run`: preview only
- `--help`: show all options

Examples:
```bash
# Interactive wizard
bash main.sh --wizard

# Non-interactive from profile
bash main.sh --profile ~/.config/dev-setup/profile.yml --yes
```

### `mac-settings/export-once.sh` (source Mac)
Export one-time macOS settings from your current Mac:
```bash
bash mac-settings/export-once.sh
```

Flags:
- `--output-dir <path>`: export destination (default `~/.config/dev-setup/mac-settings-export`)
- `--force`: overwrite an existing export directory
- `--help`: show all options

Examples:
```bash
# Standard one-time export
bash mac-settings/export-once.sh

# Re-export and overwrite prior output
bash mac-settings/export-once.sh --force
```

### `mac-settings/import.sh` (target Mac)
Apply exported settings directly. This is the only supported import path:
```bash
bash mac-settings/import.sh
```

Flags:
- `--source <path>`: path to exported settings script (default `~/.config/dev-setup/mac-settings-export/exported-settings.sh`)
- `--dry-run`: print what would run without applying settings
- `--help`: show all options

Examples:
```bash
# Import from default location
bash mac-settings/import.sh

# Import from custom location
bash mac-settings/import.sh --source ~/Downloads/exported-settings.sh
```
