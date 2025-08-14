# First-step.md

## Welcome to the Project: First Steps for New Device Setup

This guide will help you set up your environment and get started with this repository. Follow these steps carefully to ensure your device is ready for analysis and collaboration.

---

### 1. Install Required Software

- **R** (latest version recommended)
- **RStudio** (optional, but recommended)
- **Quarto CLI** ([Download here](https://quarto.org/docs/get-started/))
- **Git** (for version control)

---

### 2. Clone the Repository

Open a terminal and run:

```sh
git clone <REPO_URL>
cd books-of-ukraine
```

---

### 3. Install Required R Packages

Open R or RStudio and run:

```r
install.packages(c(
  "dplyr", "readr", "googlesheets4", "DBI", "RSQLite", "quarto", "stringr", "yaml", "knitr", "rmarkdown"
))
```

---

### 4. Add Required Files

- Place your Google Sheets authentication file as `.secrets` in the project root (see `docs/google-auth-setup.md` for help).
- Ensure the following directories exist: `manipulation`, `analysis`, `scripts`, `ai`, `data-private`, `data-public` (these should be present if you cloned the repo).

---

### 5. Project Overview

- **Purpose:** Investigate publishing trends in Ukraine since 2005, with a focus on regional differences and the use of Russian language in books.
- **Structure:** Modular scripts, reproducible reports, and robust context/memory management for collaborative analysis.
- **Documentation:** See `README.md`, `COMMAND-REFERENCE.md`, and `docs/` for detailed guides.

---

## 🚦 First Commands to Run

Open R or RStudio, set your working directory to the project root, and run these commands in order:

```r
# 1. Comprehensive environment and workflow check
comprehensive_project_diagnostics()

# 2. Analyze overall project status
analyze_project_status()

# 3. Check flow.R status
check_flow_status()

# 4. Check current AI context
context_refresh()
```

These commands will:
- Validate your environment and dependencies
- Check for required files and data
- Assess project health and readiness
- Guide you to the next steps

---

## Need Help?
- See `COMMAND-REFERENCE.md` for all available commands and their usage
- Review `README.md` for project background and structure
- For authentication issues, see `docs/google-auth-setup.md`
- For further assistance, contact the project maintainer

---

**Welcome aboard!**
