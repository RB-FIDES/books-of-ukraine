# Ellis Extra Data Sources Configuration
# This file defines custom/extra data sources for the Ellis Pipeline Stage 2
# Users can add new data sources here without modifying the main R scripts

# ---- data-sources-configuration ---------------------------------------------

# CUSTOM DATA SOURCES: Add your Google Sheets URLs and processing instructions here
# Each data source should follow this structure:

extra_data_sources <- list(
  
  # EXAMPLE 1: Bookstores Data (Currently Active)
  bookstores = list(
    name = "Ukrainian Bookstores by Region",
    description = "Number of bookstores per region for 2023",
    url = "https://docs.google.com/spreadsheets/d/1ovYOr_jmdDprYjcGMWAa-w9D1-h7kwwjbRgUgVtlUa0",
    data_type = "categorical_time_series",  # Options: categorical_time_series, lookup_table, fact_table
    active = TRUE,
    processing_notes = list(
      sheet_mapping = list(
        "Книгарні" = "bookstores"  # Sheet name -> table key mapping
      ),
      measure_mapping = list(
        "Кількість книгарень" = "bookstore_count"  # Ukrainian measure -> English measure
      ),
      category_column_detection = "auto",  # "auto" or specify column name
      expected_sheets = c("Книгарні")
    )
  )
  
  # TEMPLATES FOR ADDING NEW DATA SOURCES:
  # See guides/custom-data-guide.md for complete examples of:
  # - categorical_time_series (like bookstores above)
  # - lookup_table (reference/mapping data) 
  # - fact_table (event/survey data)
  
)

# ---- data-type-definitions -------------------------------------------------

# SUPPORTED DATA TYPES AND THEIR REQUIREMENTS:

# 1. CATEGORICAL_TIME_SERIES:
#    - Format: Rows = categories, Columns = years (x2005, x2006, etc.)
#    - Must have: pokaznik column, category column, year columns
#    - Example: Bookstores by region over time
#    - Processing: Automatically pivoted to long format

# 2. LOOKUP_TABLE: 
#    - Format: Simple key-value or multi-column reference table
#    - Must have: Clearly defined key columns
#    - Example: Region name to code mappings
#    - Processing: Imported as-is for joining with other data

# 3. FACT_TABLE:
#    - Format: Standard tabular data with defined columns
#    - Must have: Consistent column structure
#    - Example: Event listings, survey responses
#    - Processing: Imported with basic cleaning and validation

# ---- validation-rules ------------------------------------------------------

# VALIDATION RULES FOR EACH DATA TYPE:
validation_rules <- list(
  categorical_time_series = list(
    required_patterns = c("pokaznik", "x\\d{4}"),  # Must have pokaznik and year columns
    min_columns = 3,
    year_column_pattern = "^x\\d{4}$"
  ),
  lookup_table = list(
    min_columns = 2,
    no_duplicate_keys = TRUE
  ),
  fact_table = list(
    min_columns = 1,
    consistent_types = TRUE
  )
)

# ---- user-instructions ----------------------------------------------------

# HOW TO ADD NEW CUSTOM DATA SOURCES:
#
# 1. CREATE YOUR GOOGLE SHEET:
#    - Follow the data type format (see examples above)
#    - Ensure proper column naming and structure
#    - Make the sheet accessible (same sharing settings as main data)
#
# 2. ADD TO CONFIGURATION:
#    - Copy one of the templates above
#    - Update name, description, URL, and processing_notes
#    - Set active = TRUE when ready to process
#
# 3. TEST YOUR DATA:
#    - Run 2-ellis-extra.R to validate your data
#    - Check the console output for any validation errors
#    - Fix issues in your Google Sheet if needed
#
# 4. VERIFY INTEGRATION:
#    - Run the complete pipeline (0-ellis through last-ellis)
#    - Check that your tables appear in the final database
#    - Verify CSV exports are created correctly

cat("📊 Extra Data Sources Configuration Loaded\n")
cat("   Available data sources:", length(extra_data_sources), "\n")
active_sources <- sum(sapply(extra_data_sources, function(x) x$active))
cat("   Active data sources:", active_sources, "\n")
