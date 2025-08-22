# Getting Started Guide

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
### Or download the repository as a ZIP file from GitHub and extract it to your desired location. **(recomended for beginners)**
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

- Place your Google Sheets authentication file as `.secrets` in the project root (see `guides/setup-google-access.md` for help).
## Here some instructions on how to do it:

**Local VS Code settings:** Copy the example settings file to create your local workspace settings (this file is ignored by git):

```powershell
copy .vscode\settings.json.example .vscode\settings.json
```

### Set Up Google Sheets Authentication

To access project data in Google Sheets, you must authenticate your R environment. There are two supported methods:

#### Method 1: Service Account (Recommended for automation and teams)

1. **Obtain the service account JSON file** from your project admin, or follow the guide in `guides/setup-google-access.md` to create your own.
2. **Rename** the file to `google-service-account.json`.
3. **Place** it in the project root directory:

  ```
  books-of-ukraine/
  ├── google-service-account.json  ← Place here
  ├── manipulation/
  ├── scripts/
  └── ...
  ```
4. **Share the Google Sheet** with the service account email (see the `client_email` field in your JSON file) as an Editor.
5. **Test your setup** by running:
  ```bash
  Rscript scripts/test-service-account.R
  ```
  You should see a success message if authentication is working.

**Security:** Never commit `google-service-account.json` to Git. This file contains private keys and is already in `.gitignore`.

#### Method 2: One-Time Interactive Authentication (Quick start for individuals)

1. Open R and run:
  ```r
  library(googlesheets4)
  gs4_auth(cache = ".secrets", email = TRUE)
  ```
  This will open a browser window for you to sign in and grant access.
2. A `.secrets` folder will be created in your project root. This stores your authentication token.
3. All subsequent runs will use this cached token automatically.

**Troubleshooting:**
- If you get permission errors, make sure your Google account has access to the sheet.
- For more help, see `guides/setup-google-access.md` for comprehensive authentication setup.

---

**Also ensure the following directories exist:** `manipulation`, `analysis`, `scripts`, `ai`, `data-private`, `data-public` (these should be present if you cloned the repo).

---

### 5. Project Overview

- **Purpose:** Investigate publishing trends in Ukraine since 2005, with a focus on regional differences and the use of Russian language in books.
- **Structure:** Modular scripts, reproducible reports, and robust context/memory management for collaborative analysis.
- **Documentation:** See `README.md`, `guides/command-reference.md`, and `guides/` for detailed guides.


## The best documetns to visuit:

- `README.md` - Project overview and setup instructions
- `guides/command-reference.md` - Detailed command usage and options
- `guides/flow-usage.md` - How to use the flow system for project management
- `guides/command-guide.md` - Comprehensive command guide for all available functions
- `pipeline.md` - Detailed pipeline steps and outputs

---

## 🚦 First Commands to Run

Open R or RStudio, set your working directory to the project root, and run these commands in order:

```r
# 1. Comprehensive environment and workflow check
comprehensive_project_diagnostics() # Checks your R environment, required packages, project structure, and reports any missing dependencies or setup issues. Does NOT install packages automatically.

# 2. Analyze overall project status
analyze_project_status() # Summarizes project health, recent changes, and provides recommendations for next steps in your workflow.

# 3. Check flow.R status
check_flow_status() # Validates the flow.R pipeline, checks for missing or outdated steps, and reports on the status of data and report generation.

# 4. Check current AI context
context_refresh() # Scans and summarizes the current AI/project memory context, showing which components are loaded and available for analysis.
```

These commands will:
- Validate your environment and dependencies
- Check for required files and data
- Assess project health and readiness
- Guide you to the next steps

---

## Need Help?
- See `guides/command-reference.md` for all available commands and their usage
- Review `README.md` for project background and structure
- For authentication issues, see `guides/setup-google-access.md`
- For further assistance, contact the project maintainer

---

**Welcome aboard!**
