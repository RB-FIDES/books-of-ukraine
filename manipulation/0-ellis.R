# Ellis Script - Long and Wide Format Version
# This script creates CACHE tables and to be described in CACHE-manifest.md
# Format schema: year + measure + [category] + value

rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
cat("\014") # Clear the console
# verify root location
cat("Working directory: ", getwd()) # Must be set to Project Directory
# Project Directory should be the root by default unless overwritten

# ---- load-packages -----------------------------------------------------------
# Choose to be greedy: load only what's needed
# Three ways, from least (1) to most(3) greedy:
# -- 1.Attach these packages so their functions don't need to be qualified: 
# http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr)
library(ggplot2)   # graphs
library(forcats)   # factors
library(stringr)   # strings
library(lubridate) # dates
library(labelled)  # labels
library(dplyr)     # data wrangling
library(tidyr)     # data wrangling
library(scales)    # format
library(broom)     # for model
library(emmeans)   # for interpreting model results
library(ggalluvial)
library(janitor)   # tidy data
library(googlesheets4) # Google Sheets integration
library(DBI)       # For database connection and operations
library(RSQLite)   # SQLite database interface
library(ggrepel)   # improved text positioning
# -- 2.Import only certain functions of a package into the search path.
# import::from("magrittr", "%>%")
# -- 3. Verify these packages are available on the machine, but their functions need to be qualified
requireNamespace("openxlsx"  )# Excel operations
requireNamespace("fs"        )# file system operations

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
base::source("./scripts/operational-functions.R") # project-level
base::source("./scripts/service-account-auth.R") # Google Sheets authentication

# ---- declare-globals ---------------------------------------------------------
local_root <- "./manipulation/"
local_data <- paste0(local_root, "data-local/") # for local outputs

if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

# ---- authenticate-google-sheets ----------------------------------------------
# Automatic authentication using service account (preferred) or cached tokens (fallback)
# This will:
# 1. Try service account authentication (google-service-account.json) - NO BROWSER
# 2. Fall back to cached token authentication if no service account
# 3. Fall back to interactive authentication if neither available
authenticate_google_sheets()

# ---- declare-functions -------------------------------------------------------
# Helper function for robust numeric conversion
safe_numeric_convert <- function(x) {
  # Handle various formats and clean the data
  cleaned <- as.character(x)
  # Remove all non-numeric characters except dots, minus signs, and spaces
  cleaned <- gsub("[^0-9.\\s-]", "", cleaned)
  # Remove extra spaces
  cleaned <- gsub("\\s+", "", cleaned)
  # Replace empty strings, lone dashes, and various null representations with zero
  cleaned[cleaned == "" | cleaned == "-" | cleaned == "NULL" | 
          cleaned == "NA" | cleaned == "n/a" | is.na(cleaned)] <- "0"
  # Handle cases where we might have multiple dots
  cleaned <- gsub("\\.{2,}", ".", cleaned)
  # Convert to numeric
  result <- suppressWarnings(as.numeric(cleaned))
  # Replace any remaining NAs with 0
  result[is.na(result)] <- 0
  return(result)
}

# ---- create-directories ------------------------------------------------------
data_private_derived <- "data-private/derived/manipulation/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

data_private_derived_sqlite <- "data-private/derived/manipulation/SQLite/"
if (!fs::dir_exists(data_private_derived_sqlite)) {fs::dir_create(data_private_derived_sqlite)}

data_private_derived_csv <- "data-private/derived/manipulation/CSV/"
if (!fs::dir_exists(data_private_derived_csv)) {fs::dir_create(data_private_derived_csv)}

# ---- establish-database-connection -------------------------------------------
db_books_of_ukraine <- dbConnect(RSQLite::SQLite(), "data-private/derived/manipulation/SQLite/books-of-ukraine-long.sqlite")

# ---- load-data ---------------------------------------------------------------
# Define the new clean data source
sheet_url <- "https://docs.google.com/spreadsheets/d/1nxMTUD9gRhaE_VIT6WPR4V-_7BWNVwsJu__qjtCtSF0"

# First, scan all available sheets to understand structure
sheet_info <- googlesheets4::gs4_get(sheet_url)
all_sheet_names <- sheet_info$sheets$name

cat("📊 Available sheets in clean data source:\n")
for (i in seq_along(all_sheet_names)) {
  cat(sprintf("  %d. %s\n", i, all_sheet_names[i]))
}
cat("\n")

# Import each sheet as separate tibble for individual processing
sheets_data <- list()

for (sheet_name in all_sheet_names) {
  cat("📥 Loading sheet:", sheet_name, "\n")
  
  sheet_data <- googlesheets4::read_sheet(
    ss = sheet_url,
    sheet = sheet_name,
    .name_repair = "minimal"
  ) %>%
    janitor::clean_names()
  
  sheets_data[[sheet_name]] <- sheet_data
  cat("   ✓ Size:", nrow(sheet_data), "rows ×", ncol(sheet_data), "columns\n")
}

cat("\n📋 All sheets loaded successfully!\n\n")

# ---- inspect-data-0 ----------------------------------------------------------
# Quick inspection of each sheet structure
cat("🔍 SHEET STRUCTURE OVERVIEW:\n")
cat(paste(rep("=", 50), collapse = ""), "\n")

for (sheet_name in names(sheets_data)) {
  cat("\n📄", sheet_name, ":\n")
  cat("   Dimensions:", nrow(sheets_data[[sheet_name]]), "×", ncol(sheets_data[[sheet_name]]), "\n")
  ncols_to_show <- min(5, ncol(sheets_data[[sheet_name]]))
  if (ncols_to_show > 0) {
    cat("   Columns:", paste(names(sheets_data[[sheet_name]])[seq_len(ncols_to_show)], collapse = ", "))
    if (ncol(sheets_data[[sheet_name]]) > 5) cat("...")
  }
  cat("\n")
}

# ---- tweak-data-0 ------------------------------------------------------------
# Process each sheet according to its structure and create star schema tables

# =============================================================================
# STAR SCHEMA DESIGN FOR BOOKS OF UKRAINE RESEARCH DATABASE
# =============================================================================
# FACT TABLE: book_publications (grain: year + category + measure)
# DIMENSION TABLES: dim_years, dim_languages, dim_genres, dim_geographies, dim_pubtypes
# 
# This design optimizes for:
# - Analytical queries across multiple dimensions
# - Time series analysis (primary use case)
# - Flexible aggregation and filtering
# - Consistent long format for all measures
# =============================================================================

processed_tables <- list()

# Process each sheet based on its consistent structure
for (sheet_name in names(sheets_data)) {
  cat("🔧 Processing sheet:", sheet_name, "\n")
  
  sheet_data <- sheets_data[[sheet_name]]
  
  # All sheets now have consistent structure: pokaznik + category_column + year_columns
  if (sheet_name == "Рік") {
    # YEAR-LEVEL DATA: Total publications by year (no category dimension)
    processed_tables[["year_totals"]] <- sheet_data %>%
      mutate(
        category_type = "total",
        category_value = "all_books"
      ) %>%
      pivot_longer(
        cols = starts_with("x") | matches("\\d{4}"),
        names_to = "year",
        values_to = "value"
      ) %>%
      mutate(
        year = as.integer(str_extract(year, "\\d{4}")),
        value = safe_numeric_convert(value),
        measure_type = case_when(
          pokaznik == "Наіменувань" ~ "title_count",
          str_detect(pokaznik, "Примірників") ~ "copy_count",
          TRUE ~ "title_count"  # default
        )
      ) %>%
      filter(!is.na(year), !is.na(value)) %>%
      select(year, category_type, category_value, measure_type, value)
    
  } else {
    # CATEGORICAL DATA: Language, Theme, Territory, Purpose
    # Get the category column name (second column after pokaznik)
    category_col <- names(sheet_data)[2]
    
    # Create translated table name
    table_key <- case_when(
      sheet_name == "Мова" ~ "language",
      sheet_name == "Тема" ~ "theme", 
      sheet_name == "Територія" ~ "territory",
      sheet_name == "Призначення" ~ "purpose",
      TRUE ~ tolower(sheet_name)
    )
    
    processed_tables[[table_key]] <- sheet_data %>%
      pivot_longer(
        cols = starts_with("x") | matches("\\d{4}"),
        names_to = "year",
        values_to = "value"
      ) %>%
      mutate(
        year = as.integer(str_extract(year, "\\d{4}")),
        value = safe_numeric_convert(value),
        category_type = case_when(
          sheet_name == "Мова" ~ "language",
          sheet_name == "Тема" ~ "theme", 
          sheet_name == "Територія" ~ "territory",
          sheet_name == "Призначення" ~ "purpose",
          TRUE ~ tolower(sheet_name)
        ),
        category_value = .data[[category_col]],
        measure_type = case_when(
          pokaznik == "Наіменувань" ~ "title_count",
          str_detect(pokaznik, "Примірників") ~ "copy_count", 
          TRUE ~ "title_count"  # default
        )
      ) %>%
      filter(!is.na(year), !is.na(value), !is.na(category_value)) %>%
      select(year, category_type, category_value, measure_type, value)
  }
  
  cat("   ✓ Processed:", nrow(processed_tables[[length(processed_tables)]]), "records\n")
}

# Combine all processed data into unified fact table
fact_book_publications <- bind_rows(processed_tables) %>%
  arrange(year, category_type, category_value, measure_type)

# Create dimension tables for star schema
dim_years <- fact_book_publications %>%
  distinct(year) %>%
  arrange(year) %>%
  mutate(
    year_id = row_number(),
    decade = paste0(floor(year/10)*10, "s"),
    period = case_when(
      year <= 2010 ~ "early_2000s",
      year <= 2015 ~ "early_2010s", 
      year <= 2020 ~ "late_2010s",
      TRUE ~ "2020s"
    )
  )

dim_categories <- fact_book_publications %>%
  distinct(category_type, category_value) %>%
  arrange(category_type, category_value) %>%
  mutate(category_id = row_number())

dim_measures <- fact_book_publications %>%
  distinct(measure_type) %>%
  arrange(measure_type) %>%
  mutate(
    measure_id = row_number(),
    measure_description = case_when(
      measure_type == "title_count" ~ "Number of unique book titles published",
      measure_type == "copy_count" ~ "Total number of book copies printed",
      TRUE ~ measure_type
    )
  )

cat("\n📊 STAR SCHEMA SUMMARY:\n")
cat("   FACT TABLE: fact_book_publications (", nrow(fact_book_publications), " records)\n")
cat("   DIM TABLES:\n")
cat("     - dim_years (", nrow(dim_years), " years)\n")
cat("     - dim_categories (", nrow(dim_categories), " categories)\n") 
cat("     - dim_measures (", nrow(dim_measures), " measures)\n")

rm(sheet_data, sheet_info)
# ---- save-to-disk ------------------------------------------------------------
cat("\n💾 SAVING TO DATABASE AND FILES:\n")

# Save fact table and dimensions to SQLite
dbWriteTable(db_books_of_ukraine, "fact_book_publications", fact_book_publications, overwrite = TRUE)
dbWriteTable(db_books_of_ukraine, "dim_years", dim_years, overwrite = TRUE)
dbWriteTable(db_books_of_ukraine, "dim_categories", dim_categories, overwrite = TRUE)
dbWriteTable(db_books_of_ukraine, "dim_measures", dim_measures, overwrite = TRUE)

# Save raw sheets data for reference
for (sheet_name in names(sheets_data)) {
  safe_name <- str_replace_all(sheet_name, "[^a-zA-Z0-9]", "_")
  dbWriteTable(db_books_of_ukraine, paste0("raw_", safe_name), sheets_data[[sheet_name]], overwrite = TRUE)
}

# Save to CSV for external access
write.csv(fact_book_publications, paste0(data_private_derived_csv, "fact_book_publications.csv"), row.names = FALSE)
write.csv(dim_years, paste0(data_private_derived_csv, "dim_years.csv"), row.names = FALSE)
write.csv(dim_categories, paste0(data_private_derived_csv, "dim_categories.csv"), row.names = FALSE)
write.csv(dim_measures, paste0(data_private_derived_csv, "dim_measures.csv"), row.names = FALSE)

# Save processed tables as RDS
saveRDS(fact_book_publications, paste0(data_private_derived, "fact_book_publications.rds"))
saveRDS(dim_years, paste0(data_private_derived, "dim_years.rds"))
saveRDS(dim_categories, paste0(data_private_derived, "dim_categories.rds"))
saveRDS(dim_measures, paste0(data_private_derived, "dim_measures.rds"))

cat("   ✓ Saved to SQLite database\n")
cat("   ✓ Saved to CSV files\n")
cat("   ✓ Saved to RDS files\n")

# Close database connection
dbDisconnect(db_books_of_ukraine)

cat("\n🎉 PROCESSING COMPLETE!\n")
cat("Star schema database ready for analysis at:\n")
cat("📁 ", "data-private/derived/manipulation/SQLite/books-of-ukraine-long.sqlite", "\n")

# ---- analysis-below ----------------------------------------------------------
# This section can be used for immediate analysis/validation of the processed data

# Quick validation queries
cat("\n📊 QUICK VALIDATION:\n")

# Re-connect to check data
db_books_of_ukraine <- dbConnect(RSQLite::SQLite(), "data-private/derived/manipulation/SQLite/books-of-ukraine-long.sqlite")

# Count records by table
tables <- c("fact_book_publications", "dim_years", "dim_categories", "dim_measures")
for (table in tables) {
  count <- dbGetQuery(db_books_of_ukraine, paste("SELECT COUNT(*) as count FROM", table))$count
  cat("   ✓", table, ":", count, "records\n")
}

# Sample of fact table
cat("\n📋 SAMPLE FROM FACT TABLE:\n")
sample_data <- dbGetQuery(db_books_of_ukraine, 
  "SELECT * FROM fact_book_publications LIMIT 10")
print(sample_data)

dbDisconnect(db_books_of_ukraine)

cat("\n✅ Script completed successfully!\n")
cat("💡 Next steps: Use analysis/eda-* scripts to explore the data\n")

# ---- cleanup-environment -----------------------------------------------------
# Remove temporary objects, keep only sheets_data for further analysis
objects_to_keep <- c("sheets_data", "safe_numeric_convert")
objects_to_remove <- setdiff(ls(), objects_to_keep)
rm(list = objects_to_remove)

cat("\n🧹 Environment cleaned - kept sheets_data and safe_numeric_convert\n")

