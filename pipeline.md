# ./pipeline.md

Sequence of scripts that capture data assembly, modeling and reporting. 

# Data assembly

## Ellis Pipeline - Staged Data Processing

The Ellis pipeline processes Ukrainian book publishing data through three progressive stages, each building upon the previous stage's output.

### **Ellis Stage 0: Core Data Foundation** 
#### `manipulation/0-ellis.R` - Data Import and Standardization

**Purpose**: Import Ukrainian book publishing data from Google Sheets and create the foundational analytical database.

**Key Operations**:
- Imports publishing data from multiple Google Sheets tabs covering 2005-2023
- Creates standardized star schema with fact and dimension tables
- Processes 6 main data domains:
  - Overall publication counts (titles/copies by year)
  - Publications by language (including Ukrainian/Russian breakdown)
  - Publications by thematic categories/genres
  - Publications by target audience and purpose
  - Regional publication distribution

**Outputs**: 
- **Stage 0 Database**: `books-of-ukraine-0.sqlite` (core books data only)
- **Supporting formats**: RDS files, CSV exports for compatibility

### **Ellis Stage 1: Administrative Integration**
#### `manipulation/1-ellis-ua-admin.R` - Ukrainian Administrative Data Integration

**Purpose**: Integrate core books data with Ukrainian administrative context for territorial analysis.

**Key Operations**:
- Copies Stage 0 database as foundation
- Downloads Ukrainian hromada-level data from KSE Decentralization Reform project
- Creates oblast-level aggregations (24 oblasts, 1,438 hromadas)
- Integrates demographic, economic, and administrative indicators

**Key Tables Added**:
- `ua_oblasts_aggregated`: Oblast-level indicators for choropleth mapping
- `dim_oblasts`: Oblast dimension with geographic metadata
- `fact_hromadas`: Hromada-level detailed territorial data

**Outputs**: 
- **Stage 1 Database**: `books-of-ukraine-1.sqlite` (books + administrative data)

### **Ellis Final: Analytical Optimization**
#### `manipulation/last-ellis.R` - Analytical Database Creation

**Purpose**: Create the final analytical database optimized for analysis workflows.

**Key Operations**:
- Transforms Stage 1 data into analysis-ready formats
- Creates both wide and long format tables for different analytical needs
- Generates comprehensive analytical views by category (language, territory, theme, purpose)

**Outputs**:
- **Default Database**: `books-of-ukraine.sqlite` (final analytical database)
- **Auto-generated Documentation**: Comprehensive table descriptions and usage examples

---

## 🏗️ **Ellis Pipeline Architecture**

```
Stage 0: Core Foundation
├── 0-ellis.R → books-of-ukraine-0.sqlite (0.26 MB)
│   └── Core books publication data with star schema
│
Stage 1: Administrative Integration  
├── 1-ellis-ua-admin.R → books-of-ukraine-1.sqlite (1.96 MB)
│   └── Core + Ukrainian territorial & demographic data
│
Final: Analytical Optimization
└── last-ellis.R → books-of-ukraine.sqlite (0.29 MB)
    └── Analysis-ready wide/long format tables
```

## 📊 **Default Database Paradigm**

**Key Principle**: Analysis scripts in `./analysis/` automatically connect to the **default database** unless specifically targeting intermediate stages.

**Configuration-Driven Access**:
```r
# Standard pattern for analysis scripts
library(yaml)
config <- yaml::read_yaml("config.yml")
db_path <- config$database$books_of_ukraine$main  # → books-of-ukraine.sqlite
db <- dbConnect(RSQLite::SQLite(), db_path)
```

**When to Use Intermediate Databases**:
- **books-of-ukraine-0.sqlite**: Quality control of core data processing
- **books-of-ukraine-1.sqlite**: Specialized territorial analysis requiring administrative context
- **books-of-ukraine.sqlite**: Standard analysis workflows (90% of use cases)

---

## ⚙️ **Configuration Management**

**Centralized Configuration** (`config.yml`):
All database paths and project settings are managed through a centralized configuration file:

```yaml
database:
  books_of_ukraine:
    main: "./data-private/derived/manipulation/SQLite/books-of-ukraine.sqlite"
    stage_0: "./data-private/derived/manipulation/SQLite/books-of-ukraine-0.sqlite"
    stage_1: "./data-private/derived/manipulation/SQLite/books-of-ukraine-1.sqlite"
  directories:
    cache: "./ai/"
    derived: "./data-private/derived/"
    raw: "./data-private/raw/"
```

**Standard Usage Pattern**:
```r
# Load configuration
library(yaml)
config <- yaml::read_yaml("config.yml")

# Connect to appropriate database
db_path <- config$database$books_of_ukraine$main  # Default for analysis
# db_path <- config$database$books_of_ukraine$stage_1  # For territorial analysis
# db_path <- config$database$books_of_ukraine$stage_0  # For core data QC

db <- dbConnect(RSQLite::SQLite(), db_path)
```

**Enhanced Usage with Helper Functions**:
```r
# Source common functions for database utilities  
source("scripts/common-functions.R")

# Connect using standardized helper function
db <- connect_books_db("main")  # or "stage_1", "stage_0"

# Query data
result <- dbGetQuery(db, "SELECT * FROM fact_book_publications LIMIT 5")

# Always close connection when done
dbDisconnect(db)
```

**Benefits**:
- Single point of configuration management
- Environment-independent path handling
- Easy database switching for different analytical needs
- Simplified maintenance when moving between development/production environments

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

