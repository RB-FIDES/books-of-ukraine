# VS Code Tasks Reference

> **Purpose**: Track all VS Code tasks, their triggers, and functionality for team reference and maintenance.

## Overview

This document maintains a comprehensive list of all custom VS Code tasks created for the Books of Ukraine project. Each task is designed to automate common workflows and reduce friction in the development process.

## Available Tasks

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
