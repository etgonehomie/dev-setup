# Windows Laptop Spec (WSL2-first)

## Goal
Adapt the dev-setup experience to a Windows laptop while keeping the same user promise: one interactive bootstrap flow, one non-interactive profile mode, and a reproducible way to get a dev machine ready.

## Core Decision
- Target platform: Windows 11, with Windows 10 supported where WSL2 is available.
- Execution model: **Windows host + WSL2 Linux environment** for most developer tooling.
- Windows-native tasks are limited to host prerequisites, integration, and any tools that must stay on Windows.

## Scope
- Install and configure WSL2 if missing.
- Install a Linux distro for the dev environment.
- Run the main provisioning flow inside WSL2.
- Keep a host-side launcher that starts the flow from Windows.
- Preserve the existing UX patterns:
  - interactive wizard
  - saved profile
  - non-interactive mode
  - dry run
  - pinned/reproducible execution

## Recommended User Journey
1. User runs a single Windows bootstrap command.
2. Bootstrapper checks for admin rights and WSL2 availability.
3. If WSL2 is missing, prompt to install/enable it.
4. If no distro exists, install the chosen distro.
5. Enter WSL2 and run the Linux setup flow.
6. Save the resulting profile for future reruns.

## Architecture
- **Windows launcher**: PowerShell entrypoint on the host.
- **WSL2 backend**: Linux shell/Ansible flow reused as much as possible.
- **Profile storage**: local config file under the user profile on Windows and mirrored inside WSL2 when needed.
- **State/resume**: local checkpoint file on the side that owns the run.

## What the spec should include
- Prerequisites:
  - Windows version support
  - WSL2 installation requirements
  - internet access
  - admin/UAC expectations
- Bootstrap steps:
  - detect WSL2
  - install/enable WSL2
  - install distro
  - launch setup in WSL2
- Flow parity with macOS:
  - wizard
  - profile reuse
  - dry run
  - pinned version option
  - resume support
- Host/guest split:
  - what runs on Windows
  - what runs in WSL2
  - what stays unsupported on Windows-native only
- Validation:
  - WSL2 present
  - shell available
  - package manager available inside distro
  - repo access and network checks

## Windows-Specific Decisions
- Prefer `winget` for host prerequisites when available.
- Use WSL2 as the default dev shell instead of trying to reimplement the full macOS flow in native Windows tooling.
- Treat Windows-only desktop apps as optional add-ons, not the core provisioning path.

## Non-Goals
- Pure Windows parity for every macOS package.
- Supporting every possible Windows shell or distro combination in phase 1.
- Rewriting the whole backend in PowerShell.

## Open Questions
- Which Linux distro should be the default WSL2 target?
- Should the host launcher install WSL2 automatically or only guide the user?
- Which Windows-native apps should be first-class in the wizard?
- Do we want the Windows spec to mirror the macOS categories exactly or define Windows-specific categories?

## Suggested First Pass
- Make WSL2 the required backend for dev setup.
- Keep the Windows launcher thin.
- Reuse the Linux provisioning logic wherever possible.
- Add Windows-native support only for setup tasks that cannot live inside WSL2.
