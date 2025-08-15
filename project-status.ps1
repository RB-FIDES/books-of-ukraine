# project-status.ps1
# Clean PowerShell script for project status with memory system support
# Adapted for Books of Ukraine project context

param(
    [switch]$Detailed,
    [switch]$MemoryCheck,
    [switch]$GoogleAuth
)

Write-Host "BOOKS OF UKRAINE PROJECT STATUS CHECK" -ForegroundColor Magenta
Write-Host "=====================================" -ForegroundColor Magenta

# 1. Check project structure
Write-Host ""
Write-Host "Step 1: Project Structure" -ForegroundColor Cyan
$criticalPaths = @(
    "ai/mission.md",
    "ai/glossary.md", 
    "ai/memory-human.md",
    "data-public",
    "data-private",
    "analysis",
    "manipulation/0-ellis.R",
    "config.yml",
    "books-of-ukraine.Rproj"
)

foreach ($path in $criticalPaths) {
    if (Test-Path $path) {
        Write-Host "OK $path" -ForegroundColor Green
    } else {
        Write-Host "MISSING $path" -ForegroundColor Red
    }
}

# 2. Books of Ukraine specific checks
Write-Host ""
Write-Host "Step 2: Books of Ukraine Specific Components" -ForegroundColor Cyan

# Check Google authentication setup
if (Test-Path "google-service-account.json") {
    Write-Host "OK Google service account configured" -ForegroundColor Green
} else {
    Write-Host "WARNING: Google service account not found" -ForegroundColor Yellow
    Write-Host "  See guides/setup-google-access.md for setup instructions" -ForegroundColor Gray
}

# Check Ukrainian publishing data directories
$ukraineDataPaths = @(
    "data-private/derived/manipulation",
    "data-private/derived/manipulation/SQLite",
    "data-private/derived/manipulation/CSV"
)

foreach ($path in $ukraineDataPaths) {
    if (Test-Path $path) {
        Write-Host "OK $path" -ForegroundColor Green
    } else {
        Write-Host "MISSING $path (will be created by 0-ellis.R)" -ForegroundColor Yellow
    }
}

# Check main analysis database
if (Test-Path "data-private/derived/manipulation/SQLite/books-of-ukraine-long.sqlite") {
    $dbSize = (Get-Item "data-private/derived/manipulation/SQLite/books-of-ukraine-long.sqlite").Length
    $dbSizeMB = [math]::Round($dbSize / 1MB, 2)
    Write-Host "OK Main database found ($dbSizeMB MB)" -ForegroundColor Green
} else {
    Write-Host "WARNING: Main database not found" -ForegroundColor Yellow
    Write-Host "  Run manipulation/0-ellis.R to create database" -ForegroundColor Gray
}

# 3. Git status
Write-Host ""
Write-Host "Step 3: Git Status" -ForegroundColor Cyan
try {
    $gitBranch = git branch --show-current 2>$null
    $gitStatus = git status --porcelain 2>$null
    
    if ($gitBranch) {
        Write-Host "Current branch: $gitBranch" -ForegroundColor Green
        if ($gitStatus) {
            Write-Host "WARNING: Uncommitted changes detected" -ForegroundColor Yellow
        } else {
            Write-Host "Working directory clean" -ForegroundColor Green
        }
    } else {
        Write-Host "Not a git repository or git not available" -ForegroundColor Red
    }
} catch {
    Write-Host "Git status check failed" -ForegroundColor Red
}

# 4. Workspace validation
Write-Host ""
Write-Host "Step 4: Workspace Configuration" -ForegroundColor Cyan
$workspaceFiles = Get-ChildItem -Name "*.code-workspace"
if ($workspaceFiles) {
    Write-Host "Workspace file detected: $($workspaceFiles -join ', ')" -ForegroundColor Green
} else {
    Write-Host "WARNING: Workspace file not found" -ForegroundColor Yellow
}

# Check R project file
if (Test-Path "books-of-ukraine.Rproj") {
    Write-Host "OK R Project file found" -ForegroundColor Green
} else {
    Write-Host "WARNING: R Project file missing" -ForegroundColor Yellow
}

# 5. Project memory
Write-Host ""
Write-Host "Step 5: Project Memory System" -ForegroundColor Cyan
$memoryFiles = @(
    "ai/memory-ai.md",
    "ai/memory-human.md", 
    "ai/memory-hub.md",
    "ai/memory-guide.md"
)

$foundMemoryFiles = @()
foreach ($memFile in $memoryFiles) {
    if (Test-Path $memFile) {
        $foundMemoryFiles += $memFile
    }
}

if ($foundMemoryFiles.Count -gt 0) {
    Write-Host "Multi-file memory system active" -ForegroundColor Green
    Write-Host "Memory files found: $($foundMemoryFiles.Count)/$($memoryFiles.Count)" -ForegroundColor Gray
    foreach ($file in $foundMemoryFiles) {
        $fileName = Split-Path $file -Leaf
        Write-Host "   $fileName" -ForegroundColor Green
    }
} else {
    Write-Host "WARNING: No memory files found" -ForegroundColor Yellow
}

# 6. Google authentication test (if requested)
if ($GoogleAuth) {
    Write-Host ""
    Write-Host "Step 6: Google Authentication Test" -ForegroundColor Cyan
    if (Test-Path "scripts/test-service-account.R") {
        try {
            Write-Host "Running Google authentication test..." -ForegroundColor Yellow
            $testResult = Rscript scripts/test-service-account.R 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Google authentication test PASSED" -ForegroundColor Green
            } else {
                Write-Host "Google authentication test FAILED" -ForegroundColor Red
                Write-Host "Output: $testResult" -ForegroundColor Gray
            }
        } catch {
            Write-Host "Could not run authentication test" -ForegroundColor Red
        }
    } else {
        Write-Host "Google authentication test script not found" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "BOOKS OF UKRAINE PROJECT STATUS CHECK COMPLETE" -ForegroundColor Magenta

# Optional detailed output
if ($Detailed) {
    Write-Host ""
    Write-Host "=== DETAILED PROJECT INFORMATION ===" -ForegroundColor Cyan
    
    # Analysis directories
    if (Test-Path "analysis") {
        $analysisDir = Get-ChildItem "analysis" -Directory
        Write-Host "Analysis directories: $($analysisDir.Count)" -ForegroundColor Gray
        foreach ($dir in $analysisDir) {
            Write-Host "  - $($dir.Name)" -ForegroundColor Gray
        }
    }
    
    # Recent log files
    if (Test-Path "ai/log") {
        $logFiles = Get-ChildItem "ai/log" -Filter "*.md" | Sort-Object LastWriteTime -Descending | Select-Object -First 3
        if ($logFiles.Count -gt 0) {
            Write-Host "Recent log files:" -ForegroundColor Gray
            foreach ($log in $logFiles) {
                $age = [math]::Round(((Get-Date) - $log.LastWriteTime).TotalHours, 1)
                Write-Host "  - $($log.Name) ($age hrs old)" -ForegroundColor Gray
            }
        }
    }
}
