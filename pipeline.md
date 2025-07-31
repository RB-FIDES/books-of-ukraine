# ./pipeline.md

Sequence of scripts tha capture data assembly, modeling and reporting. 

# Data assembly

## `manipulation/0-ellis.R` - Data Import and Standardization

**Purpose**: Import Ukrainian book publishing data from Google Sheets and transform it into analysis-ready datasets.

**Key Operations**:
- Imports publishing data from multiple Google Sheets tabs covering 2005-2023
- Creates standardized datasets with consistent structure (yr, measure, values)
- Processes 6 main data domains:
  - `ds_year`: Overall publication counts (titles/copies by year)
  - `ds_language`: Publications by language (including Ukrainian/Russian breakdown)
  - `ds_genre`: Publications by thematic categories/genres
  - `ds_pubtype`: Publications by target audience and purpose
  - `ds_geography`: Regional publication distribution
  - `ds_ukr_rus`: Detailed Ukrainian vs Russian language analysis with percentages

**Outputs**: 
- **SQLite database**: `data-private/derived/manipulation/SQLite/books-of-ukraine.sqlite` (primary analytical database)
- **RDS files**: Individual R data files for each dataset
- **CSV exports**: Human-readable exports in `data-private/derived/manipulation/csv/`
- **Google Sheets backup**: Cleaned data pushed to analysis spreadsheet

**Moving Forward**: The SQLite database serves as our primary data source for all subsequent analysis, providing structured, normalized data ready for visualization and statistical modeling.


