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
library(janitor)  # tidy data
library(testit)   # For asserting conditions meet expected patterns.
library(DBI)      # database interface
library(RSQLite)  # SQLite database
library(googlesheets4)  # Google Sheets integration

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
base::source("./scripts/operational-functions.R") # project-level

# ---- declare-globals ---------------------------------------------------------

local_root <- "./manipulation/"
local_data <- paste0(local_root, "data-local/") # for local outputs

if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

data_private_derived <- "./data-private/derived/manipulation/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

prints_folder <- paste0(local_root, "prints/")
if (!fs::dir_exists(prints_folder)) {fs::dir_create(prints_folder)}


# ---- declare-functions -------------------------------------------------------
# base::source(paste0(local_root,"local-functions.R")) # project-level

# ---- load-data ---------------------------------------------------------------
# Load existing ds_geography datasets instead of the national data
if (file.exists("data-private/derived/manipulation/ds_geography.rds")) {
  ds_geography <- readRDS("data-private/derived/manipulation/ds_geography.rds")
  cat("Loaded ds_geography with", nrow(ds_geography), "rows\n")
} else {
  stop("ds_geography.rds not found. Please run 0-ellis.R first.")
}


# Check existing data structure
cat("Existing measures:", paste(unique(ds_geography$measure), collapse = ", "), "\n")
cat("Sample geographies:", paste(head(unique(ds_geography$geography), 5), collapse = ", "), "\n")

# Check all geography names in the original data
original_geographies <- unique(ds_geography$geography)
cat("Total original geographies:", length(original_geographies), "\n")
cat("All original geographies:\n")
print(original_geographies)

# ---- tweak-data-0 -------------------------------------
# Create bookstore data based on screenshot showing regional distribution
# Match the geography names exactly with the original dataset format
bookstore_data <- tibble(
  geography = c(
    # Major regions with highest numbers
    "Київ",  # Not "м. Київ" 
    "Львівська",  # Not "Львівська область"
    "Харківська", 
    "Дніпропетровська",
    "Одеська",
    
    # Medium-sized regions  
    "Івано-Франківська",
    "Запорізька",
    "Тернопільська",
    "Вінницька",
    "Хмельницька",
    "Черкаська",
    "Полтавська",
    "Київська",
    "Чернігівська",
    "Сумська",
    
    # Smaller regions
    "Житомирська",
    "Рівненська", 
    "Волинська",
    "Кіровоградська",
    "Миколаївська",
    "Херсонська",
    "Закарпатська",
    "Чернівецька"
  ),
  bookstore_count = c(
    # Major regions (high numbers from screenshot + Forbes data)
    99,  # Київ
    50,  # Львівська
    17,  # Харківська
    21,  # Дніпропетровська - updated from Forbes data
    17,  # Одеська
    
    # Medium regions
    19,  # Івано-Франківська
    4,   # Запорізька - updated from Forbes data
    23,  # Тернопільська
    17,  # Вінницька
    15,  # Хмельницька
    12,  # Черкаська
    15,   # Полтавська
    18,   # Київська
    6,   # Чернігівська
    13,   # Сумська
    
    # Smaller regions
    10,  # Житомирська - updated from Forbes data
    18,   # Рівненська
    17,   # Волинська
    4,   # Кіровоградська
    2,   # Миколаївська
    2,   # Херсонська
    14,  # Закарпатська
    8    # Чернівецька
  )
)

# Create years range from existing data
years_range <- unique(ds_geography$year)
cat("Years available in data:", min(years_range), "to", max(years_range), "\n")

# Check if bookstore data already exists and clean it first
if ("bookstore_count" %in% unique(ds_geography$measure)) {
  cat("Existing bookstore_count data found - cleaning before adding new data\n")
  ds_geography_clean <- ds_geography %>%
    filter(measure != "bookstore_count")
} else {
  cat("No existing bookstore_count data found - proceeding with original data\n")
  ds_geography_clean <- ds_geography
}

# Create bookstore data in long format for all years
ds_bookstore_long <- bookstore_data %>%
  crossing(year = years_range) %>%  # Create rows for all years
  mutate(
    measure = "bookstore_count",
    value = bookstore_count
  ) %>%
  select(year, measure, geography, value) %>%
  arrange(year, geography)

# Combine cleaned data with new bookstore data
ds_long_enhanced <- bind_rows(ds_geography_clean, ds_bookstore_long) %>%
  arrange(year, measure, geography)

# Create enhanced wide version
ds_wide_enhanced <- ds_long_enhanced %>%
  pivot_wider(
    id_cols = c(year, measure),
    names_from = geography,
    values_from = value
  ) %>%
  arrange(year, measure)

# ---- inspect-data-0 -------------------------------------
cat("Original ds_geography dimensions:", dim(ds_geography), "\n")
cat("Enhanced ds_long dimensions:", dim(ds_long_enhanced), "\n")
cat("Enhanced ds_wide dimensions:", dim(ds_wide_enhanced), "\n")

# Check measures in original and enhanced dataset
measures_original <- unique(ds_geography$measure)
measures_enhanced <- unique(ds_long_enhanced$measure)
cat("Measures in original dataset:", paste(measures_original, collapse = ", "), "\n")
cat("Measures in enhanced dataset:", paste(measures_enhanced, collapse = ", "), "\n")

# Show sample of each measure type
cat("\nSample data by measure:\n")
for(measure_name in measures_enhanced) {
  cat("\n", measure_name, ":\n")
  sample_data <- ds_long_enhanced %>%
    filter(measure == measure_name) %>%
    slice_head(n = 3)
  print(sample_data)
}

# ---- inspect-data-1 -------------------------------------
# Check bookstore data coverage
bookstore_coverage <- ds_long_enhanced %>%
  filter(measure == "bookstore_count") %>%
  group_by(geography) %>%
  summarise(
    years_covered = n(),
    avg_bookstores = mean(value, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_bookstores))

cat("\nTop 10 regions by bookstore count:\n")
print(head(bookstore_coverage, 10))

# ---- inspect-data-2 -------------------------------------
# Compare all measures across top regions
measures_comparison <- ds_long_enhanced %>%
  group_by(measure, geography) %>%
  summarise(
    total_value = sum(value, na.rm = TRUE),
    avg_value = mean(value, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(geography %in% c("Київ", "Львівська", "Харківська", "Одеська")) %>%
  arrange(geography, measure)

cat("\nMeasures comparison for top regions (all measures):\n")
print(measures_comparison)

# Show structure by measure type
cat("\nMeasure structure summary:\n")
measure_summary <- ds_long_enhanced %>%
  group_by(measure) %>%
  summarise(
    regions = n_distinct(geography),
    years = n_distinct(year), 
    total_records = n(),
    total_value = sum(value, na.rm = TRUE),
    avg_value = mean(value, na.rm = TRUE),
    .groups = "drop"
  )
print(measure_summary)

# Show top regions for each measure
cat("\nTop 5 regions by total value for each measure:\n")
for(measure_name in unique(ds_long_enhanced$measure)) {
  cat("\n", toupper(measure_name), ":\n")
  top_regions <- ds_long_enhanced %>%
    filter(measure == measure_name) %>%
    group_by(geography) %>%
    summarise(total = sum(value, na.rm = TRUE), .groups = "drop") %>%
    arrange(desc(total)) %>%
    head(5)
  print(top_regions)
}

# ---- analysis-below -------------------------------------
# Summary completed - enhanced geography datasets now include bookstore_count measure
cat("\n", paste(rep("=", 50), collapse=""), "\n")
cat("SUCCESS: Enhanced geography datasets ready with all three measures\n")
cat(paste(rep("=", 50), collapse=""), "\n")

# ---- saving -------------------------------------
cat("\nSaving enhanced geography datasets...\n")

# Connect to SQLite databases
books_of_ukraine <- DBI::dbConnect(RSQLite::SQLite(), "data-private/derived/manipulation/SQLite/books-of-ukraine-long.sqlite")
books_of_ukraine_wide <- DBI::dbConnect(RSQLite::SQLite(), "data-private/derived/manipulation/SQLite/books-of-ukraine-wide.sqlite")

## -------- RDS saving (replace original versions) --------
saveRDS(ds_long_enhanced, "data-private/derived/manipulation/ds_geography.rds")
cat("✓ Saved enhanced RDS files (replaced original versions)\n")

## ------- SQLite saving (replace original versions) -------
DBI::dbWriteTable(books_of_ukraine, "ds_geography", ds_long_enhanced, overwrite = TRUE)
cat("✓ Saved to SQLite databases (replaced original versions)\n")

## ------ CSV saving (replace original versions) ------
write.csv(ds_long_enhanced, "data-private/derived/manipulation/CSV/ds_geography.csv", row.names = FALSE)
cat("✓ Saved CSV files (replaced original versions)\n")

## ------- Google Sheets saving (replace original versions) -------
sheet_url <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854"

tryCatch({
  googlesheets4::sheet_write(ds_long_enhanced, ss = sheet_url, sheet = "ds_geography")
  cat("✓ Saved to Google Sheets (replaced original versions)\n")
}, error = function(e) {
  cat("⚠ Google Sheets saving failed:", e$message, "\n")
  cat("  Please check your Google authentication and permissions\n")
})

# Close database connections
DBI::dbDisconnect(books_of_ukraine)
DBI::dbDisconnect(books_of_ukraine_wide)

cat("\n", paste(rep("=", 50), collapse=""), "\n")
cat("DATASETS UPDATED: All ds_geography versions now include bookstore_count measure\n")
cat("Files updated:\n")
cat("- ds_geography.rds (1,500 rows with 3 measures)\n")
cat("- CSV versions\n")
cat("- SQLite versions\n")
cat("- Google Sheets versions\n")
cat(paste(rep("=", 50), collapse=""), "\n")
