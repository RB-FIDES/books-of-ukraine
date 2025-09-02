# adapt-tasks-for-mac.ps1
# PowerShell script to adapt VS Code tasks.json for macOS
# This script modifies the tasks.json file to use macOS-compatible commands
# while preserving Windows functionality

param(
    [string]$TasksJsonPath = ".\.vscode\tasks.json"
)

# Function to read JSON file
function Read-JsonFile {
    param([string]$Path)
    if (Test-Path $Path) {
        return Get-Content $Path -Raw | ConvertFrom-Json
    } else {
        Write-Error "File not found: $Path"
        exit 1
    }
}

# Function to write JSON file
function Write-JsonFile {
    param([string]$Path, [object]$Content)
    $Content | ConvertTo-Json -Depth 10 | Set-Content $Path -Encoding UTF8
}

# Function to adapt a task for macOS
function Convert-TaskForMac {
    param([object]$Task)

    # Skip tasks that are already cross-platform or don't need adaptation
    if ($Task.type -eq "process" -or $Task.command -eq "quarto" -or $Task.command -eq "Rscript") {
        return $Task
    }

    # Adapt PowerShell tasks
    if ($Task.command -eq "powershell") {
        # Add macOS override using pwsh
        $Task | Add-Member -MemberType NoteProperty -Name "osx" -Value @{
            "command" = "pwsh"
            "args" = $Task.args
        } -Force

        # Add Linux override using pwsh
        $Task | Add-Member -MemberType NoteProperty -Name "linux" -Value @{
            "command" = "pwsh"
            "args" = $Task.args
        } -Force
    }

    # Adapt specific tasks with custom macOS commands
    switch ($Task.label) {
        "Memory System Status Check" {
            $Task.osx = @{
                "command" = "bash"
                "args" = @(
                    "-lc",
                    'echo "Memory System Status:"; for f in ai/*.md; do [ -f "$f" ] || continue; ts=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$f" 2>/dev/null || stat --format="%y" "$f" 2>/dev/null | cut -c1-16); echo "$(basename "$f"): $ts"; done'
                )
            }
            $Task.linux = @{
                "command" = "zsh"
                "args" = @(
                    "-lc",
                    'echo "Memory System Status:"; for f in ai/*.md; do [ -f "$f" ] || continue; ts=$(stat --format="%y" "$f" 2>/dev/null | cut -c1-16 || stat -c "%y" "$f" 2>/dev/null | cut -c1-16); echo "$(basename "$f"): $ts"; done'
                )
            }
        }
        "Project Files Overview" {
            $Task.osx = @{
                "command" = "bash"
                "args" = @(
                    "-lc",
                    'echo "Project Structure:"; if command -v tree >/dev/null 2>&1; then tree -a -L 2 | head -n 50; else find . -maxdepth 2 -print | head -n 50; fi'
                )
            }
            $Task.linux = @{
                "command" = "zsh"
                "args" = @(
                    "-lc",
                    'echo "Project Structure:"; if command -v tree >/dev/null 2>&1; then tree -a -L 2 | head -n 50; else find . -maxdepth 2 -print | head -n 50; fi'
                )
            }
        }
    }

    return $Task
}

# Main script execution
try {
    Write-Host "Reading tasks.json from: $TasksJsonPath"
    $tasksConfig = Read-JsonFile -Path $TasksJsonPath

    # Create backup of original tasks.json as task-win.json
    $backupPath = Join-Path (Split-Path $TasksJsonPath -Parent) "task-win.json"
    Write-Host "Creating backup: $backupPath"
    Copy-Item -Path $TasksJsonPath -Destination $backupPath -Force

    Write-Host "Adapting $($tasksConfig.tasks.Count) tasks for macOS..."

    # Adapt each task
    $adaptedTasks = @()
    foreach ($task in $tasksConfig.tasks) {
        $adaptedTask = Convert-TaskForMac -Task $task
        $adaptedTasks += $adaptedTask
    }

    # Update the tasks array
    $tasksConfig.tasks = $adaptedTasks

    # Write back to file
    Write-Host "Writing adapted tasks.json..."
    Write-JsonFile -Path $TasksJsonPath -Content $tasksConfig

    Write-Host "✅ Successfully adapted tasks.json for macOS!"
    Write-Host "Tasks now include macOS (osx) and Linux (linux) overrides where applicable."
    Write-Host "  - macOS: Uses bash for shell commands"
    Write-Host "  - Linux: Uses zsh for shell commands"
    Write-Host "  - PowerShell tasks: Use pwsh on both macOS and Linux"

} catch {
    Write-Error "An error occurred: $_"
    exit 1
}