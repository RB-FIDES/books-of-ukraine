# Ellis Script 2 - Extra/Custom Data Integration  
# This script integrates custom, user-contributed data with the core pipeline:
# 1. Imports Stage 1 database (from 1-ellis-ua-admin.R)
# 2. Processes additional custom data sources (configured in extra-data-config.R)
# 3. Creates Stage 2 database with extended analytics
# 4. Maintains separation between core stable data and custom contributions
#
# 🎯 USER-FRIENDLY: To add new custom data sources, see extra-data-config.R
# 📚 DOCUMENTATION: See manipulation/README.md for complete pipeline overview

# Clear memory
rm(list = ls(all.names = TRUE))
cat("\014") # Clear console
cat("Working directory: ", getwd()) # Must be set to Project Directory

# ---- load-packages -----------------------------------------------------------
library(magrittr)
library(dplyr)     # data wrangling
library(tidyr)     # data wrangling
library(stringr)   # strings
library(purrr)     # functional programming
library(DBI)       # database interface
library(RSQLite)   # SQLite database
library(googlesheets4) # Google Sheets integration
library(janitor)   # tidy data

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
base::source("./scripts/operational-functions.R") # project-level

# Load modular extra data processing system
source("./manipulation/extra-data-config.R")      # Configuration for custom data sources  
source("./manipulation/extra-data-functions.R")   # Processing functions for different data types

# ---- declare-globals ---------------------------------------------------------
local_root <- "./manipulation/"
local_data <- paste0(local_root, "data-local/")
if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

data_private_derived <- "./data-private/derived/manipulation/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

# Database paths for stage 2
stage_1_db_path <- "data-private/derived/manipulation/SQLite/books-of-ukraine-1.sqlite"
stage_2_db_path <- "data-private/derived/manipulation/SQLite/books-of-ukraine-2.sqlite"

# 🎯 CUSTOM DATA SOURCES: Configured in extra-data-config.R
# Users can add new data sources there without modifying this script

# ---- declare-functions -------------------------------------------------------

# Function to safely convert numeric values (preserved from core pipeline)
safe_numeric_convert <- function(x) {
  # Remove Ukrainian thousands separators, handle decimals, convert to numeric
  cleaned <- str_replace_all(x, "[\\s,]", "")  # Remove spaces and commas
  cleaned <- str_replace(cleaned, ",", ".")    # Convert decimal separator
  as.numeric(cleaned)                          # Convert to numeric
}

# ---- establish-database-connections ------------------------------------------
# Connect to Stage 1 database (input)
stage_1_db <- dbConnect(RSQLite::SQLite(), stage_1_db_path)

# Create Stage 2 database (output)
stage_2_db <- dbConnect(RSQLite::SQLite(), stage_2_db_path)

# ---- copy-stage-1-data -------------------------------------------------------
cat("📋 COPYING STAGE 1 DATA TO STAGE 2...\n")

# Get all tables from Stage 1
stage_1_tables <- dbListTables(stage_1_db)

# Copy all tables to Stage 2
for (table_name in stage_1_tables) {
  cat("   📄 Copying table:", table_name, "\n")
  
  # Read table from Stage 1
  table_data <- dbReadTable(stage_1_db, table_name)
  
  # Write table to Stage 2
  dbWriteTable(stage_2_db, table_name, table_data, overwrite = TRUE)
  
  cat("   ✓ Copied:", nrow(table_data), "records\n")
}

cat("✅ STAGE 1 DATA COPIED TO STAGE 2\n\n")

# ------------------------------------------------------------------ EXTRA DATA PROCESSING ----------------------------------------------------------------------------------------------------------------------------------------------

# ---- load-extra-data ---------------------------------------------------------
cat("📊 LOADING EXTRA/CUSTOM DATA SOURCES...\n")

# STEP 1: Connect to extra data Google Sheets source
cat("🔗 Connecting to extra data source...\n")
sheet_info <- googlesheets4::gs4_get(extra_sheet_url)
all_sheet_names <- sheet_info$sheets$name

# STEP 2: Display available sheets
cat("📊 Available sheets in extra data source:\n")
for (i in seq_along(all_sheet_names)) {
  cat(sprintf("  %d. %s\n", i, all_sheet_names[i]))
}
cat("\n")

# STEP 3: Import all sheets into a structured list
sheets_data <- list()
for (sheet_name in all_sheet_names) {
  cat("📥 Loading sheet:", sheet_name, "\n")
  
  # Import with error handling
  tryCatch({
    sheet_content <- googlesheets4::read_sheet(extra_sheet_url, sheet = sheet_name)
    sheets_data[[sheet_name]] <- sheet_content
    cat("   ✓ Loaded:", nrow(sheet_content), "rows ×", ncol(sheet_content), "columns\n")
  }, error = function(e) {
    cat("   ❌ Error loading sheet", sheet_name, ":", e$message, "\n")
  })
}

cat("✅ EXTRA DATA LOADING COMPLETE\n\n")

# ---- process-extra-sheets ----------------------------------------------------
cat("🔧 PROCESSING EXTRA SHEETS...\n")

# Initialize list to store processed tables
processed_extra_tables <- list()

# MAIN PROCESSING LOOP: Handle each extra sheet
for (sheet_name in names(sheets_data)) {
  cat("🔧 Processing extra sheet:", sheet_name, "\n")
  
  # Get the sheet data
  sheet_data <- sheets_data[[sheet_name]]
  
  # Skip empty sheets
  if (nrow(sheet_data) == 0) {
    cat("   ⚠️ Skipping empty sheet\n")
    next
  }
  
  # DETECT SHEET TYPE AND PROCESSING STRATEGY
  # Check if this is a categorical data sheet (like the core 5 sheets)
  has_year_columns <- any(str_detect(names(sheet_data), "\\d{4}|^x\\d{4}"))
  has_pokaznik <- "показник" %in% tolower(names(sheet_data))
  
  if (has_year_columns && has_pokaznik) {
    cat("   📊 Processing as categorical dimension data\n")
    
    # STANDARDIZE COLUMN NAMES: Convert to English for consistency
    sheet_data <- sheet_data %>%
      janitor::clean_names() %>%
      # Handle potential Ukrainian column name variations
      rename_with(~ case_when(
        str_detect(tolower(.x), "показник|pokaznik") ~ "pokaznik",
        TRUE ~ .x
      ))
    
    # IDENTIFY THE CATEGORY COLUMN: Find the non-year, non-pokaznik column
    year_cols <- names(sheet_data)[str_detect(names(sheet_data), "\\d{4}|^x\\d{4}")]
    non_data_cols <- c("pokaznik", year_cols)
    category_cols <- names(sheet_data)[!names(sheet_data) %in% non_data_cols]
    
    # Use the first non-data column as the category column
    category_col <- category_cols[1]
    cat("   📝 Using category column:", category_col, "\n")
    
    # GENERATE CONSISTENT TABLE KEY
    # Map sheet names to consistent English table keys
    table_key <- case_when(
      sheet_name == "Книгарні" ~ "bookstores",  # Bookstores by region dimension
      TRUE ~ tolower(str_replace_all(sheet_name, "\\s+", "_"))  # Fallback: clean name
    )
    
    # PROCESS CATEGORICAL DATA: Same pivot logic as core pipeline
    processed_extra_tables[[table_key]] <- sheet_data %>%
      # PIVOT TRANSFORMATION: Convert wide format to long format
      pivot_longer(
        cols = starts_with("x") | matches("\\d{4}"),  # Year columns to pivot
        names_to = "year",                            # Extract years
        values_to = "value"                           # Extract values
      ) %>%
      # DATA STANDARDIZATION AND ENRICHMENT
      mutate(
        # Clean and convert year values
        year = as.integer(str_extract(year, "\\d{4}")),
        # Clean numeric values with robust conversion
        value = safe_numeric_convert(value),
        # CATEGORY TYPE MAPPING: Standardize dimension names
        category_type = case_when(
          sheet_name == "Книгарні" ~ "bookstores",
          TRUE ~ tolower(str_replace_all(sheet_name, "\\s+", "_"))
        ),
        # CATEGORY VALUE: Extract the actual category (e.g., region names)
        category_value = .data[[category_col]],  # Use dynamic column reference
        # MEASURE TYPE: Standardize measure types
        measure_type = case_when(
          pokaznik == "Кількість книгарень" ~ "bookstore_count",
          pokaznik == "Наіменувань" ~ "title_count",
          str_detect(pokaznik, "Примірників") ~ "copy_count", 
          TRUE ~ "title_count"  # default
        )
      ) %>%
      # DATA QUALITY: Remove incomplete records
      filter(!is.na(year), !is.na(value), !is.na(category_value)) %>%
      # FINAL STRUCTURE: Consistent schema matching core pipeline
      select(year, category_type, category_value, measure_type, value)
    
    # PROGRESS TRACKING
    cat("   ✓ Processed:", nrow(processed_extra_tables[[table_key]]), "records\n")
  } else {
    cat("   ⚠️ Unknown sheet format, skipping processing\n")
  }
}

cat("✅ EXTRA SHEET PROCESSING COMPLETE\n\n")

# ---- save-extra-tables-to-database ------------------------------------------
cat("💾 SAVING EXTRA TABLES TO STAGE 2 DATABASE...\n")

# Save each processed extra table to the database
for (table_name in names(processed_extra_tables)) {
  table_data <- processed_extra_tables[[table_name]]
  
  if (nrow(table_data) > 0) {
    # Write to database with systematic naming: ds_[table_key]
    db_table_name <- paste0("ds_", table_name)
    
    cat("💾 Saving table:", db_table_name, "\n")
    dbWriteTable(stage_2_db, db_table_name, table_data, overwrite = TRUE)
    cat("   ✓ Saved:", nrow(table_data), "records to", db_table_name, "\n")
  }
}

cat("✅ EXTRA TABLES SAVED TO DATABASE\n\n")

# ---- database-documentation --------------------------------------------------
cat("📋 STAGE 2 DATABASE DOCUMENTATION:\n")

# List all tables in the Stage 2 database
stage_2_tables <- dbListTables(stage_2_db)
cat("📊 Tables in Stage 2 database:\n")

total_records <- 0
for (table_name in stage_2_tables) {
  record_count <- dbGetQuery(stage_2_db, paste("SELECT COUNT(*) as count FROM", table_name))$count
  total_records <- total_records + record_count
  
  # Mark extra/custom tables
  table_type <- ifelse(str_detect(table_name, "^ds_bookstores"), " [EXTRA/CUSTOM]", " [CORE]")
  cat(sprintf("  📄 %-25s %8d records%s\n", table_name, record_count, table_type))
}

cat(sprintf("\n📊 TOTAL RECORDS IN STAGE 2 DATABASE: %d\n", total_records))

# Show database file size
db_size <- file.info(stage_2_db_path)$size / (1024^2)  # Convert to MB
cat(sprintf("💾 STAGE 2 DATABASE SIZE: %.2f MB\n", db_size))

# ---- cleanup -----------------------------------------------------------------
# Close database connections
dbDisconnect(stage_1_db)
dbDisconnect(stage_2_db)

cat("✅ ELLIS SCRIPT 2 (EXTRA DATA INTEGRATION) COMPLETE\n")
cat("🎯 Stage 2 database ready for analytical processing in last-ellis.R\n")
