#!/usr/bin/env bash
set -euo pipefail

echo "[post-start] Ensuring PowerShell alias compatibility and R convenience"
# Some VS Code tasks may invoke 'powershell' instead of 'pwsh'. Provide a shim if missing.
if command -v pwsh >/dev/null 2>&1 && ! command -v powershell >/dev/null 2>&1; then
  sudo ln -s "$(command -v pwsh)" /usr/local/bin/powershell || true
fi
# Add an R alias for interactive terminal profile if desired
if ! grep -q "alias rcli=" /home/rstudio/.bashrc; then
  echo "alias rcli='R --no-save --quiet'" >> /home/rstudio/.bashrc
fi
chown rstudio:rstudio /home/rstudio/.bashrc || true

echo "[post-start] Done"
