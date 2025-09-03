#!/usr/bin/env bash
# Wrapper to run a PowerShell .ps1 script using pwsh (cross-platform)
# Usage: ./run-ps1.sh path/to/script.ps1 [args...]

set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 script.ps1 [args...]"
  exit 2
fi

SCRIPT="$1"
shift || true

if command -v pwsh >/dev/null 2>&1; then
  exec pwsh -File "$SCRIPT" "$@"
fi

# If pwsh not found, provide macOS install instructions
OS_NAME=$(uname -s)
if [ "$OS_NAME" = "Darwin" ]; then
  cat <<'MSG'

pwsh (PowerShell) not found on this mac.
Install via Homebrew:

  brew update
  brew install --cask powershell

Then run the wrapper again.

MSG
  exit 1
fi

# For Linux, suggest package install
cat <<'MSG'

pwsh not found. Install PowerShell for your platform:
https://learn.microsoft.com/powershell/scripting/install/installing-powershell

MSG
exit 1
