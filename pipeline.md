# ./pipeline.md

Sequence of scripts that capture data assembly, modeling and reporting. 

# Data assembly

## `manipulation/0-ellis.R` - Data Import and Standardization

**Purpose**: Import Ukrainian book publishing data from Google Sheets and transform it into analysis-ready datasets.

**Key Operations**:
- Imports publishing data from multiple Google Sheets tabs covering 2005-2023
- Creates standardized datasets with consistent structure (year, measure, values)
- Processes 6 main data domains:
  - `ds_year`: Overall publication counts (titles/copies by year)
  - `ds_language`: Publications by language (including Ukrainian/Russian breakdown)
  - `ds_genre`: Publications by thematic categories/genres
  - `ds_pubtype`: Publications by target audience and purpose
  - `ds_geography`: Regional publication distribution

**Outputs**: 
- **SQLite database**: `data-private/derived/manipulation/SQLite/books-of-ukraine.sqlite` (primary analytical database)
- **RDS files**: Individual R data files for each dataset
- **CSV exports**: Human-readable exports in `data-private/derived/manipulation/csv/`
- **Google Sheets backup**: Cleaned data pushed to analysis spreadsheet

**Moving Forward**: The SQLite database serves as our primary data source for all subsequent analysis, providing structured, normalized data ready for visualization and statistical modeling.

# Workflow Management

## `flow.R` - Master Workflow Orchestration

**Purpose**: Orchestrate the execution of all data processing, analysis, and reporting tasks in the correct sequence.

**🆕 Enhanced Flow Management**:
- **Currency checking**: `check_flow_currency()` - Detects when flow.R is outdated relative to project scripts
- **Intelligent updates**: `analyze_and_update_flow()` - Automatically reconstructs flow.R based on current project structure
- **Script discovery**: Automatically finds and categorizes .R, .qmd, and .sql files across the project
- **Phased organization**: Intelligently organizes scripts into phases (data prep, analysis, reports)
- **Description extraction**: Reads script comments to generate meaningful workflow descriptions

**Key Features**:
- **Automated script organization**: Discovers scripts in manipulation/, analysis/, and scripts/ directories
- **Multi-format support**: Handles R scripts (.R), Quarto documents (.qmd), and SQL files (.sql)
- **Backup safety**: Creates timestamped backups before making changes
- **Syntax validation**: Ensures updated flow.R is syntactically correct
- **Change detection**: Identifies new, modified, or missing scripts

**Integration with CACHE System**:
- Automatically updates data documentation via `check_cache_manifest()`
- Synchronizes workflow structure with actual project state
- Provides comprehensive project status through `analyze_project_status()`

**Usage**:
```r
# Check if flow needs updates
check_flow_currency()

# Update flow automatically
analyze_and_update_flow()

# Run complete workflow
source("flow.R")
```

# Documentation Automation

## CACHE Manifest System

**Purpose**: Automatically maintain comprehensive documentation of all datasets created by the data processing pipeline.

**Features**:
- **Automatic detection**: Scans for all `ds_*.rds` files created by 0-ellis script
- **Timestamp tracking**: Compares file modification times with manifest updates
- **New dataset highlighting**: Marks recently created/updated datasets with 🆕 indicators
- **Comprehensive documentation**: Includes file sizes, primary keys, source sheets, and purposes
- **Logbook integration**: Updates project logbook with change summaries

**Commands**:
- `check_cache_manifest()` - Check status and update if needed
- `update_cache_manifest()` - Force update manifest regardless of status

This enhanced pipeline management system ensures that workflow structure stays synchronized with actual project development, while automatically maintaining comprehensive documentation of all data assets.

