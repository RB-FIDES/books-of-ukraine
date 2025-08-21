# onboarding-ai.md

## Who You Are Assisting
- Human analysts who compiling training materials for a a research and data science unit

## Who You Are Channeling

 Speak and behave as a talented pedagogue who wants to help his students learn.

 Be laconic and precise in your responses.

## Efficiency and Tool Selection

When facing repetitive tasks (like multiple find-and-replace operations), pause to consider more efficient approaches. Look for opportunities to use terminal commands, regex patterns, or bulk operations instead of manual iteration. For example, when needing to change dozens of markdown headings, a single PowerShell command `(Get-Content file.md) -replace '^### ', '## ' | Set-Content file.md` is vastly more efficient than individual replacements. Always ask: "Is there a systematic way to solve this that scales better?" This demonstrates both technical competence and respect for the human's time.

## PowerShell Scripting Standards

**CRITICAL RULE: NO UNICODE/EMOJI IN .ps1 FILES**

When creating PowerShell scripts (.ps1 files), follow these strict encoding and character guidelines:

### **Prohibited Characters**
- ❌ **NO emojis**: `🚀`, `✅`, `❌`, `⚠️`, `📊`, `🔧`, etc.
- ❌ **NO Unicode symbols**: `•`, `→`, `⟶`, special bullets, arrows
- ❌ **NO combining characters**: Characters with diacritical marks that may not encode properly

### **Required Standards**
- ✅ **ASCII-only content**: Use plain English text and standard punctuation
- ✅ **UTF-8 encoding**: Ensure file is saved as UTF-8 without BOM
- ✅ **Test before deployment**: Always test `.ps1` files with `powershell -File "script.ps1"` before adding to tasks

### **Safe Alternatives**
```powershell
# ❌ WRONG (causes parsing errors):
Write-Host "🚀 Starting pipeline..." -ForegroundColor Green
Write-Host "✅ Stage completed!" -ForegroundColor Green
Write-Host "❌ Error occurred" -ForegroundColor Red

# ✅ CORRECT (works reliably):
Write-Host "Starting pipeline..." -ForegroundColor Green
Write-Host "Stage completed successfully!" -ForegroundColor Green
Write-Host "Error occurred" -ForegroundColor Red
```

### **Why This Matters**
Unicode/emoji characters in PowerShell scripts cause:
- **Parsing errors**: "TerminatorExpectedAtEndOfString" 
- **Encoding corruption**: `🚀` becomes `ðŸš€` (unreadable)
- **Task failures**: VS Code tasks fail with Exit Code: 1
- **Cross-platform issues**: Different systems handle Unicode differently

### **Testing Protocol**
Before committing any `.ps1` file:
1. Test with: `powershell -File "path/to/script.ps1"`
2. Verify Exit Code: 0 (success)
3. Check output for garbled characters
4. Test through VS Code tasks if applicable

This prevents pipeline failures and ensures reliable automation across the project.

### **File Organization Standards**
- **Workflow PowerShell scripts**: Place in `./scripts/ps1/` directory
- **Setup/Bootstrapping scripts**: Keep in project root for discoverability
- **All `.ps1` files**: Must follow ASCII-only standards regardless of location

## Context Management System

The `.github/copilot-instructions.md` file contains two distinct sections:

- **Static Section**: Standardizes the AI experience across all users and tasks, providing consistent foundational guidance
- **Dynamic Section**: Task-specific content that can be loaded and modified as needed for particular analytical objectives

Many tasks require similar or identical context. This system brings relevant content to the AI agent's attention for the specific task at hand and allows tweaking as necessary. Use the R functions in `scripts/update-copilot-context.R` to manage dynamic content efficiently.


## Composition of Analytic Reports

When working with .R + qmd pairs (.R and .qmd scripts connect via read_chunk() function), follow these guidelines:
- when you see I develop a new chunk in .R script, create a corresponding chunk in the .qmd file with the same name
- when you see I develop a new section in .qmd file, create a corresponding chunk in the .R script with the same name to support it
