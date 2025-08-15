# ./ai/README.md

## 🧠 Purpose

This folder provides a minimal, rigorous, and extensible framework for **human–AI collaborative data analysis**, where the human serves as **philosopher–scientist** and the AI functions as a **modal translator and analytic executor**.

## 📂 ./ai/ Core Files

| File | Function |
|------|----------|
| `mission.md` | Declares purpose and impact goals |
| `glossary.md` | Defines key terms and constructs |
| `method.md` | Articulates valid methods and inference rules |
| `semiology.md` | Maps how meaning is expressed across dialects |
| `onboarding-ai.md` | Guides how AI should behave and support the human |
| `logbook.md` | Captures all major analytic decisions over time |
| `FIDES.md` | Validation tests and epistemic safeguards |
| `CACHE-manifest-0.md` | Core star schema documentation (0-ellis.R) |
| `CACHE-MANIFEST-1.md` | Enhanced database schema documentation (1-ellis.R) |
| `CACHE-manifest-analytical.md` | Analytical tables documentation (last-ellis.R) |

## 🆕 Automated Documentation System

The **CACHE manifest** is now automatically maintained by the project management system:

- **Purpose**: Comprehensive documentation of all datasets created by the data processing pipeline
- **Automatic Updates**: The system detects when datasets change and updates documentation accordingly  
- **Smart Integration**: Manifest updates are automatically logged in `logbook.md`
- **AI Context**: Updated manifests immediately improve AI assistance quality

### Managing the CACHE Manifest:
```r
# Check manifest status and update if needed
check_cache_manifest()

# Force update manifest documentation  
update_cache_manifest()
```

## 📝 File Change Tracking System

The project includes an **automated file change tracking system** that maintains an audit trail of all modifications:

- **Purpose**: Track file modifications with timestamps, user information, and change descriptions
- **Integration**: All changes are logged to `logbook.md` for team visibility
- **AI Context**: Change logs help AI understand project evolution and decision-making

### File Change Tracking Commands:
```r
# Log changes to any project file
log_file_change("path/to/file.ext", "description of changes")
log_change("file.ext", "description")  # Short alias

# Examples
log_change("analysis/eda-1/eda-1.R", "Added regional comparison analysis")
log_change("manipulation/0-ellis.R", "Fixed data type conversion issue")
```

### What gets tracked:
- **File path and modification timestamp**
- **User who made the change**
- **Description of what was changed**
- **When the change was logged**

This creates a comprehensive audit trail that supports team collaboration and project transparency.

## 🔗 Project Pipeline

`./pipeline.md` outlines the flow of analytic work specific to this project.

## 🔁 Use Case


Use this framework to launch any project that aims to:
- Maintain high interpretability in AI-assisted analytics
- Avoid black-box decisions and silent assumptions
- Structure team handoffs or long-running analytic workflows
- Build cumulative knowledge over iterative modeling cycles

## 🧭 Getting Started

1. Fork or clone this repository.
2. Initiate `./data-private/raw/research_request.md` to document your research request and its evolution. You will add communication feedback from the client here to trace the evolution of the research request.
3. Customize `./ai/mission.md` to define your project's purpose, axioms, and logic.
4. Tailor `./ai/glossary.md` to your domain.
5. Begin logging analytic moves in `./ai/logbook.md`.
6. Ensure AI agents are prompted using the `./ai/onboarding_ai.md` structure.

## 📜 Attribution

Developed collaboratively by [Andriy Koval](https://github.com/andkov) and ChatGPT-4o, building on a dialectical epistemology of human–AI symbiosis.

> AI contributions provided by OpenAI's ChatGPT, operating under the guidance of the human author. Attribution preferred as:
>
> **"Human–AI co-developed framework using ChatGPT-4o under the authorship and epistemic direction of Andriy Koval."**

## 📘 License

MIT License — open for modification, redistribution, and adaptation with attribution.
