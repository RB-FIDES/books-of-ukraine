

# VS Code Tasks Reference

> **Purpose**: Track all VS Code tasks, their triggers, and functionality for team reference and maintenance.

## Overview

This document maintains a comprehensive list of all custom VS Code tasks created for the Books of Ukraine project. Each task is designed to automate common workflows and reduce friction in the development process.


## Available Tasks

### 0. Comprehensive Project Diagnostics
- **Task ID**: `comprehensive-project-diagnostics`
- **Trigger Prompt**: "comprehensive project diagnostics" or "environment diagnostics"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); comprehensive_project_diagnostics()"`
- **Description**: Full environment, dependency, and workflow readiness check for new devices. Checks R version, Quarto CLI, Google Sheets authentication, required files/directories, and R packages.
- **When to Use**: New device setup, troubleshooting, or before running the full workflow.
- **Access Method**: Tasks: Run Task → "Comprehensive Project Diagnostics"
- **Expected Output**: Terminal output with diagnostics and readiness summary
- **Status**: ✅ Active

### 1. Load Core Context
- **Task ID**: `load-core-context`
- **Trigger Prompt**: "load core context" or "refresh core context"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); add_core_context()"`
- **Description**: Automatically loads essential AI context components (onboarding-ai, mission, method) into the copilot instructions dynamic section
- **When to Use**: 
  - Starting a new work session
  - After context has been cleared or corrupted
  - When AI needs project background refreshed
- **Access Method**: 
  - Ctrl+Shift+P → "Tasks: Run Task" → "Load Core Context"
  - Or via Command Palette: "Tasks: Run Task"
- **Expected Output**: Updates `.github/copilot-instructions.md` with core context
- **Created**: August 8, 2025
- **Status**: ✅ Active

### 2. Add Data Context
- **Task ID**: `add-data-context`
- **Trigger Prompt**: "add data context"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); add_data_context()"`
- **Description**: Loads data-focused context (CACHE manifest, pipeline) for data processing and manipulation tasks.
- **When to Use**: Data work, pipeline review, or after data changes.
- **Access Method**: Tasks: Run Task → "Add Data Context"
- **Expected Output**: Updates `.github/copilot-instructions.md` with data context
- **Status**: ✅ Active

### 3. Add Compass Context
- **Task ID**: `add-compass-context`
- **Trigger Prompt**: "add compass context"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); add_compass_context()"`
- **Description**: Loads compass-specific context (logbook) for analytical context and decision history.
- **When to Use**: Reviewing project decisions, analytical approaches.
- **Access Method**: Tasks: Run Task → "Add Compass Context"
- **Expected Output**: Updates `.github/copilot-instructions.md` with compass context
- **Status**: ✅ Active

### 4. Add Full Context
- **Task ID**: `add-full-context`
- **Trigger Prompt**: "add full context"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); add_full_context()"`
- **Description**: Loads comprehensive project context for complex tasks (onboarding, mission, method, glossary, pipeline).
- **When to Use**: Deep analysis, onboarding, or troubleshooting.
- **Access Method**: Tasks: Run Task → "Add Full Context"
- **Expected Output**: Updates `.github/copilot-instructions.md` with full context
- **Status**: ✅ Active

### 5. Remove All Dynamic Instructions
- **Task ID**: `remove-all-dynamic-instructions`
- **Trigger Prompt**: "remove all dynamic instructions"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); remove_all_dynamic_instructions()"`
- **Description**: Clears all dynamic content from copilot instructions for a clean slate.
- **When to Use**: Resetting context, troubleshooting, or before loading new context.
- **Access Method**: Tasks: Run Task → "Remove All Dynamic Instructions"
- **Expected Output**: `.github/copilot-instructions.md` is cleared of dynamic content
- **Status**: ✅ Active

### 6. Context Refresh
- **Task ID**: `context-refresh`
- **Trigger Prompt**: "context refresh" or "scan context"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); context_refresh()"`
- **Description**: Complete status scan with setup validation and context options. Shows current context, setup status, and available actions.
- **When to Use**: Project overview, context troubleshooting, or before major work.
- **Access Method**: Tasks: Run Task → "Context Refresh"
- **Expected Output**: Terminal output with context status and options
- **Status**: ✅ Active

### 7. Check Cache Manifest
- **Task ID**: `check-cache-manifest`
- **Trigger Prompt**: "check cache manifest"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); check_cache_manifest()"`
- **Description**: Checks and updates the CACHE manifest based on 0-ellis outputs. Shows dataset status and updates manifest if needed.
- **When to Use**: After running 0-ellis, before data analysis, or when manifest is out of date.
- **Access Method**: Tasks: Run Task → "Check Cache Manifest"
- **Expected Output**: Updated `ai/CACHE-manifest.md` and terminal status
- **Status**: ✅ Active

### 8. Update Cache Manifest
- **Task ID**: `update-cache-manifest`
- **Trigger Prompt**: "update cache manifest"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); update_cache_manifest()"`
- **Description**: Forces update of the CACHE manifest and logbook with current 0-ellis outputs.
- **When to Use**: After major data changes, before sharing data, or for audit trail.
- **Access Method**: Tasks: Run Task → "Update Cache Manifest"
- **Expected Output**: Updated `ai/CACHE-manifest.md` and `ai/logbook.md`
- **Status**: ✅ Active

### 9. Analyze Project Status
- **Task ID**: `analyze-project-status`
- **Trigger Prompt**: "analyze project status"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); analyze_project_status()"`
- **Description**: Complete project health check: setup, context, memory, data, and recommendations.
- **When to Use**: Onboarding, troubleshooting, or regular project review.
- **Access Method**: Tasks: Run Task → "Analyze Project Status"
- **Expected Output**: Terminal output with 7-section analysis and recommendations
- **Status**: ✅ Active

### 10. Project Setup Check
- **Task ID**: `project-setup-check`
- **Trigger Prompt**: "project setup check"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); project_setup_check()"`
- **Description**: Comprehensive environment validation with detailed diagnostics.
- **When to Use**: After setup, before running scripts, or troubleshooting errors.
- **Access Method**: Tasks: Run Task → "Project Setup Check"
- **Expected Output**: Terminal output with setup status and diagnostics
- **Status**: ✅ Active

### 11. Quick Setup Check
- **Task ID**: `quick-setup-check`
- **Trigger Prompt**: "quick setup check"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); quick_setup_check()"`
- **Description**: Fast setup status check (returns TRUE/FALSE). Lightweight validation for script automation.
- **When to Use**: Before running scripts, in automation, or for quick validation.
- **Access Method**: Tasks: Run Task → "Quick Setup Check"
- **Expected Output**: TRUE/FALSE in terminal
- **Status**: ✅ Active

### 12. Safe Run Script
- **Task ID**: `safe-run-script`
- **Trigger Prompt**: "safe run script"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); safe_run_script('file.R')"`
- **Description**: Executes scripts with automatic setup validation. Prevents failures due to environment issues.
- **When to Use**: For new team members, before running any script, or in automation.
- **Access Method**: Tasks: Run Task → "Safe Run Script"
- **Expected Output**: Script output with setup validation
- **Status**: ✅ Active

### 13. Check Flow Currency
- **Task ID**: `check-flow-currency`
- **Trigger Prompt**: "check flow currency"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); check_flow_currency()"`
- **Description**: Checks if flow.R is current vs project scripts. Identifies scripts not referenced in flow.R.
- **When to Use**: After adding new scripts, before running flow.R, or workflow review.
- **Access Method**: Tasks: Run Task → "Check Flow Currency"
- **Expected Output**: Terminal output with flow.R status
- **Status**: ✅ Active

### 14. Analyze and Update Flow
- **Task ID**: `analyze-and-update-flow`
- **Trigger Prompt**: "analyze and update flow"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); analyze_and_update_flow()"`
- **Description**: Intelligently analyzes and updates flow.R structure, creates backup, and organizes scripts by phase.
- **When to Use**: After major script changes, for workflow automation, or before sharing project.
- **Access Method**: Tasks: Run Task → "Analyze and Update Flow"
- **Expected Output**: Updated flow.R and terminal output
- **Status**: ✅ Active

### 15. Check Flow Status
- **Task ID**: `check-flow-status`
- **Trigger Prompt**: "check flow status"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); check_flow_status()"`
- **Description**: Quick flow.R status check. Returns boolean status for script automation.
- **When to Use**: Automated workflow validation, before running flow.R
- **Access Method**: Tasks: Run Task → "Check Flow Status"
- **Expected Output**: TRUE/FALSE in terminal
- **Status**: ✅ Active

### 16. AI Memory Check
- **Task ID**: `ai-memory-check`
- **Trigger Prompt**: "ai memory check"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); ai_memory_check()"`
- **Description**: Main AI memory function with intent detection. Reviews project memory and offers to capture intentions.
- **When to Use**: Project planning, intent review, or after major decisions.
- **Access Method**: Tasks: Run Task → "AI Memory Check"
- **Expected Output**: Terminal output with memory analysis
- **Status**: ✅ Active

### 17. Memory Status
- **Task ID**: `memory-status`
- **Trigger Prompt**: "memory status"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); memory_status()"`
- **Description**: Quick project memory status overview. Shows memory age, size, and content overview.
- **When to Use**: Memory system check, before/after updates.
- **Access Method**: Tasks: Run Task → "Memory Status"
- **Expected Output**: Terminal output with memory status
- **Status**: ✅ Active

### 18. Generate Project Briefing
- **Task ID**: `generate-project-briefing`
- **Trigger Prompt**: "generate project briefing"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); generate_project_briefing()"`
- **Description**: Comprehensive project briefing generation. Useful for handoffs and status reports.
- **When to Use**: Project handoff, reporting, or onboarding.
- **Access Method**: Tasks: Run Task → "Generate Project Briefing"
- **Expected Output**: Terminal output with project briefing
- **Status**: ✅ Active

### 19. Update Project Memory
- **Task ID**: `update-project-memory`
- **Trigger Prompt**: "update project memory"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); update_project_memory()"`
- **Description**: Manual project memory updates. For capturing specific decisions or changes.
- **When to Use**: After major decisions, project planning, or memory corrections.
- **Access Method**: Tasks: Run Task → "Update Project Memory"
- **Expected Output**: Terminal output with memory update status
- **Status**: ✅ Active

### 20. Log File Change
- **Task ID**: `log-file-change`
- **Trigger Prompt**: "log file change"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); log_file_change('path/to/file.ext', 'description')"`
- **Description**: Log file modifications to project logbook. Records file, user, and change description.
- **When to Use**: After significant file changes, before commits, or for audit trail.
- **Access Method**: Tasks: Run Task → "Log File Change"
- **Expected Output**: Updated `ai/logbook.md` with file change entry
- **Status**: ✅ Active

### 21. Log Change (Short Alias)
- **Task ID**: `log-change`
- **Trigger Prompt**: "log change"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); log_change('file.ext', 'description')"`
- **Description**: Short alias for log_file_change(). Same functionality, less typing.
- **When to Use**: Frequent file change logging, quick documentation.
- **Access Method**: Tasks: Run Task → "Log Change"
- **Expected Output**: Updated `ai/logbook.md` with file change entry
- **Status**: ✅ Active

### 22. Get Command Help
- **Task ID**: `get-command-help`
- **Trigger Prompt**: "get command help"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); get_command_help()"`
- **Description**: Detailed help for specific commands. Shows usage, purpose, and when to use.
- **When to Use**: Learning new commands, troubleshooting, or onboarding.
- **Access Method**: Tasks: Run Task → "Get Command Help"
- **Expected Output**: Terminal output with command help
- **Status**: ✅ Active

### 23. Create Next Ellis
- **Task ID**: `create-next-ellis`
- **Trigger Prompt**: "create next ellis"
- **Command**: `Rscript -e "source('scripts/update-copilot-context.R'); create_next_ellis()"`
- **Description**: Generates a new ellis-phase script (e.g., 11-ellis.R) based on the current project state and naming convention. Useful for extending the ETL pipeline in a standardized way.
- **When to Use**: When you need to add a new ellis-phase script for additional data processing or transformation.
- **Access Method**: Tasks: Run Task → "Create Next Ellis"
- **Expected Output**: New ellis-phase script scaffolded in the manipulation/ directory, ready for editing.
- **Created**: August 10, 2025
- **Status**: ✅ Active

## Task Categories

### Context Management Tasks
- **Load Core Context**: Essential AI context loading

### Future Task Categories (Planned)
- **Data Processing Tasks**: Automation for data ferry operations
- **Analysis Tasks**: Quick execution of analysis scripts
- **Report Generation Tasks**: Automated report building
- **Quality Assurance Tasks**: Setup validation and health checks

## Usage Patterns

### Common Workflow Triggers
- **"load core context"** → Execute Load Core Context task
- **"refresh context"** → Execute Load Core Context task
- **"setup context"** → Execute Load Core Context task

### Task Naming Convention
- Tasks use kebab-case naming: `task-name-description`
- Task labels use Title Case: "Task Name Description"
- Group related tasks by category prefix when applicable

## Technical Implementation Notes

### PowerShell Command Structure
```powershell
Rscript -e "source('scripts/update-copilot-context.R'); function_name()"
```

### Task Configuration Location
- **File**: `.vscode/tasks.json`
- **Schema**: VS Code Task 2.0.0
- **Shell**: PowerShell (Windows default)

### Error Handling
- Tasks should include appropriate error handling in the R functions
- Exit codes are captured and displayed in VS Code terminal
- Failed tasks show in the terminal with diagnostic information

## Maintenance

### Adding New Tasks
1. Define the task in `.vscode/tasks.json`
2. Test the task execution
3. Document the task in this reference file
4. Update project memory if significant workflow change

### Task Documentation Template
```markdown
### Task Name
- **Task ID**: `task-id`
- **Trigger Prompt**: "natural language trigger"
- **Command**: `command to execute`
- **Description**: What this task does and why
- **When to Use**: Specific use cases
- **Access Method**: How to run the task
- **Expected Output**: What should happen
- **Created**: Date
- **Status**: ✅ Active | ⚠️ Deprecated | ❌ Broken
```

## Integration with AI Workflow

### Context Refresh Automation
The Load Core Context task specifically supports the AI collaboration workflow by:
- Ensuring consistent AI context across team members
- Reducing manual context management overhead
- Providing reliable starting point for AI interactions
- Supporting the project's context management system defined in `scripts/update-copilot-context.R`

### Natural Language Triggers
Tasks are designed to respond to natural language prompts that team members might naturally use:
- "load core context" → Context management
- "refresh setup" → (future) Setup validation
- "run analysis" → (future) Analysis execution

## Version History

### v1.0 (August 8, 2025)
- Initial creation with Load Core Context task
- Established documentation pattern
- Created task reference system

---

**Last Updated**: August 8, 2025  
**Maintained By**: Project Team  
**Related Files**: 
- `.vscode/tasks.json` - Task definitions
- `scripts/update-copilot-context.R` - Context management functions
- `ai/project-memory.md` - Project decision history
