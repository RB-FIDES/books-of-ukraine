# PowerShell Scripts Directory

This directory contains PowerShell scripts used for **workflow automation** in the Books of Ukraine project.

## Organization Principle

- **Root-level `.ps1` files**: Bootstrapping/setup scripts (e.g., `setup-nodejs.ps1`, `project-status.ps1`)
- **`./scripts/ps1/`**: Workflow automation scripts that assume the project is already set up

## Current Scripts

### Workflow Automation

- `run-complete-ellis-pipeline.ps1` - Executes the complete 4-stage Ellis data pipeline

## Standards

⚠️ **IMPORTANT**: All `.ps1` files must follow ASCII-only standards (no emojis/Unicode).
See `ai/onboarding-ai.md` → "PowerShell Scripting Standards" for complete guidelines.

## Usage

These scripts are typically executed via VS Code tasks or directly.

On Windows (PowerShell):

```powershell
# Via PowerShell
powershell -File "scripts/ps1/run-complete-ellis-pipeline.ps1"
```

On macOS / Linux use the cross-platform PowerShell executable `pwsh` (preferred):

```bash
# Via pwsh
pwsh -File "scripts/ps1/run-complete-ellis-pipeline.ps1"
```

If you prefer not to edit tasks, you can use the small wrapper shell script added to the repo:

```bash
./scripts/ps1/run-ps1.sh scripts/ps1/run-complete-ellis-pipeline.ps1
```

The wrapper will call `pwsh` if available and print install instructions if not.
