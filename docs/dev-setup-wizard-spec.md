# Dev Setup Wizard Spec (Phase 1)

## Goal
Make Mac setup flexible, idempotent, and rerunnable via an interactive wizard with a non-interactive profile mode and no-clone bootstrap option.

## Scope
- Platform: macOS only
- Installer backend: Ansible
- Front-end UX: Bash CLI wizard (with `gum`/`fzf` when available, auto-fallback to plain prompts)

## Core Behavior
- Category-first selection, then optional per-package overrides inside selected categories.
- Skip already-installed items on reruns.
- Prompt before dotfile overwrite and create backups.
- Optional cask failures should not stop the whole run; summarize at end.
- `brew upgrade` is opt-in via `--upgrade` (not default).
- Save and reuse profile at `~/.config/dev-setup/profile.yml`.

## Phase 1 Categories
- `core`
- `dev`
- `browsers`
- `productivity` (includes Raycast app + optional Raycast config import step)
- `local-ai` (no preselected packages; user chooses)
- `security` (includes Tailscale)
- `data`
- `media-creator` (includes Shottr and 4K Video Downloader+)

## Added Requirements (from brainstorming follow-up)
1. **Dry-run mode (`--dry-run`)**
   - Show planned actions (installs/config changes/skips) without mutating the system.
   - Works in both wizard and profile/non-interactive mode.

2. **Preflight checks**
   - Detect Apple Silicon vs Intel.
   - Validate network reachability for required endpoints.
   - Validate privilege expectations (sudo/admin when required).
   - Check Rosetta availability only when a selected package requires it.

3. **Checkpoint + resume state**
   - Persist step-level state and failures to a local state file.
   - Resume from last incomplete step via `--resume`.
   - Keep state readable for troubleshooting.

4. **Dotfile conflict and restore strategy**
   - On conflict: prompt with options (skip / backup+replace).
   - Backup naming convention includes timestamp.
   - Provide clear restore command(s) in final summary.

5. **Post-install report**
   - Final machine-readable + human-readable summary:
     - installed
     - already present / skipped
     - failed
     - manual action required

6. **Non-interactive mode**
   - Profile-driven run with no prompts:
     - `--profile ~/.config/dev-setup/profile.yml --yes`
   - Suitable for CI and scripted execution.

7. **Remote script safety guidance in README**
   - Primary quick-start tracks `main`.
   - Also document safer pinned usage (tag or commit SHA) for reproducibility.

8. **Regression test matrix**
   - Cover wizard flow branches in `main.sh`.
   - Cover non-interactive profile mode.
   - Cover dry-run output.
   - Cover idempotent rerun behavior (already-installed paths).
   - Cover Ansible-tag/category execution mapping.

9. **Pinned package strategy**
   - Add optional reproducible mode via pinned inputs (tag/SHA-backed package profile).
   - Default mode can track latest, but pinned mode must produce repeatable rebuilds.
   - Document when to use latest vs pinned mode and how to switch between them.

10. **Secrets-safe configuration handling**
   - Do not store secrets in tracked repo files.
   - Accept sensitive values via environment variables or local ignored files.
   - Prompt at runtime only when required and avoid echoing secret values.
   - Provide a sample non-secret template file for user-specific config.

## README Direction
- Promote no-clone one-liner as primary entrypoint:
  - `curl -fsSL https://raw.githubusercontent.com/etgonehomie/dev-setup/main/main.sh | bash -s -- --wizard`
- Include profile reuse example:
  - `curl -fsSL https://raw.githubusercontent.com/etgonehomie/dev-setup/main/main.sh | bash -s -- --profile ~/.config/dev-setup/profile.yml --yes`
- Include pinned variant example (tag or SHA).

## Non-Goals (Phase 1)
- Linux support
- Mandatory failure on optional cask errors
- Authoring a full how-to guide for extracting and importing Raycast config + macOS settings between machines (deferred to a future release using new dev-setup export/import features)
