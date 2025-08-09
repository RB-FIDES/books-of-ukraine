# Ellis Script - Long and Wide Format Version
# This script creates CACHE tables in both long and wide formats as specified in CACHE-manifest.md
# Long format schema: year + measure + [category] + value
# Wide format schema: year + measure + [category columns with values]

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
import_selected_sheets <- function(sheet_url, sheets_to_import, clean_names = TRUE) {
  
  # Get sheet information
  sheet_info <- googlesheets4::gs4_get(sheet_url)
  all_sheet_names <- sheet_info$sheets$name
  
  cat("Доступні вкладки (sheets):\n")
  cat(paste(all_sheet_names, collapse = ", "), "\n")
  
  # Check which sheets to import
  valid_sheets <- sheets_to_import[sheets_to_import %in% all_sheet_names]
  
  if (length(valid_sheets) == 0) {
    stop("Жодної з вказаних вкладок не знайдено у Google Sheets.")
  }
  
  cat("\nБуде імпортовано", length(valid_sheets), "вкладок:\n")
  cat(paste(valid_sheets, collapse = ", "), "\n")
  
  # Import selected sheets and combine into a data frame
  all_tables <- list()
  
  for (sheet_name in valid_sheets) {
    cat("Завантажуємо вкладку:", sheet_name, "\n")
    
    # Import the sheet
    sheet_data <- googlesheets4::read_sheet(
      ss = sheet_url,
      sheet = sheet_name,
      .name_repair = "minimal"
    )
    
    # Clean column names if requested
    if (clean_names) {
      sheet_data <- janitor::clean_names(sheet_data)
    }
    
    # Store in list
    all_tables[[sheet_name]] <- sheet_data
    
    cat("  - Розмір:", nrow(sheet_data), "рядків x", ncol(sheet_data), "колонок\n")
  }
  
  # Combine all sheets into a single data frame (no sheet_name column)
  combined_table <- dplyr::bind_rows(all_tables, .id = NULL)
  
  return(combined_table)
}

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



# ------------------------------------------------------------------ DS_YEAR ----------------------------------------------------------------------------------------------------------------------------------------------

# ---- load-data ---------------------------------------------------------------
df_raw <- import_selected_sheets(
  sheet_url = "https://docs.google.com/spreadsheets/d/1nxMTUD9gRhaE_VIT6WPR4V-_7BWNVwsJu__qjtCtSF0",
  sheets_to_import = "Рік"
)

# ----data-cleaning-------------------------------------------------------------


# Clean and reshape the raw data to match CACHE manifest (ds_year_long)

years_expected <- 2005:2024
measures_expected <- c("title_count", "copy_count")

# Remove whitespace from column names and ensure all are character
df_raw <- df_raw %>% rename_with(~trimws(as.character(.)))

# Check for columns to pivot
if (ncol(df_raw) <= 1) {
  stop("No year columns found in input data after cleaning. Check your input sheet and column names.")
}

# Reshape to long format and robustly parse years
df_long <- df_raw %>%
  rename(measure_raw = 1) %>%
  pivot_longer(
    cols = -measure_raw,
    names_to = "year",
    values_to = "value"
  ) %>%
  mutate(
    year = as.integer(gsub("[^0-9]", "", year)),
    measure = case_when(
      str_detect(measure_raw, "Наіменувань") ~ "title_count",
      str_detect(measure_raw, "Примірників") ~ "copy_count",
      TRUE ~ NA_character_
    ),
    value = safe_numeric_convert(value)
  ) %>%
  filter(year %in% years_expected & measure %in% measures_expected) %>%
  select(year, measure, value)

# Create full grid and join, but only fill NA if truly missing
df_year <- expand.grid(year = years_expected, measure = measures_expected, stringsAsFactors = FALSE) %>%
  left_join(df_long, by = c("year", "measure")) %>%
  arrange(year, measure)

# Check for NA values in value column for present data
na_rows <- df_year[is.na(df_year$value) & paste(df_year$year, df_year$measure) %in% paste(df_long$year, df_long$measure), ]
if(nrow(na_rows) > 0) {
  cat("Warning: NA values found for present year/measure combinations:\n")
  print(na_rows)
}



# Preview cleaned data
print(df_year)

# ----- rm() cleaning ---------------------------------------------------
rm(df_raw, df_long, na_rows)

# ------ SAVE CSV ---------------------------------------------------
csv_path <- file.path(data_private_derived_csv, "ds_year.csv")
write.csv(df_year, csv_path, row.names = FALSE, fileEncoding = "UTF-8")
cat("Saved CSV to:", csv_path, "\n")

# ------ SAVE SQLite ---------------------------------------------------
dbWriteTable(db_books_of_ukraine, "ds_year", df_year, overwrite = TRUE)
cat("Saved table 'ds_year' to SQLite database.\n")

# ------ SAVE RDS   ---------------------------------------------------
rds_path <- file.path(data_private_derived, "ds_year.rds")
saveRDS(df_year, rds_path)
cat("Saved RDS to:", rds_path, "\n")

# ------ SAVE Google Sheets ---------------------------------------------------
gs_url_out <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?usp=sharing"
sheet_write(df_year, ss = gs_url_out, sheet = "ds_year")
cat("Saved to Google Sheet (long):", gs_url_out, "\n")


# ------------------------------------------------------------------ DS_LANGUAGE ----------------------------------------------------------------------------------------------------------------------------------------------



## -- load-data ---------------------------------------------------------------
df_raw <- import_selected_sheets(
  sheet_url = "https://docs.google.com/spreadsheets/d/1nxMTUD9gRhaE_VIT6WPR4V-_7BWNVwsJu__qjtCtSF0",
  sheets_to_import = "Мова"
)
## ------- data-cleaning-------------------------------------------------------------

# Clean and reshape the raw data to match CACHE manifest (ds_language)
years_expected <- 2005:2024
measures_expected <- c("title_count", "copy_count")

# Remove whitespace from column names and ensure all are character
df_raw <- df_raw %>% rename_with(~trimws(as.character(.)))

# Check for columns to pivot
if (ncol(df_raw) <= 2) {
  stop("No year columns found in input data after cleaning. Check your input sheet and column names.")
}

# Reshape to long format and robustly parse years
df_long <- df_raw %>%
  rename(measure_raw = 1, language = 2) %>%
  pivot_longer(
    cols = -c(measure_raw, language),
    names_to = "year",
    values_to = "value"
  ) %>%
  mutate(
    year = as.integer(gsub("[^0-9]", "", year)),
    measure = case_when(
      str_detect(measure_raw, "Наіменувань") ~ "title_count",
      str_detect(measure_raw, "Примірників") ~ "copy_count",
      TRUE ~ NA_character_
    ),
    value = safe_numeric_convert(value),
    language = as.character(language)
  ) %>%
  filter(year %in% years_expected & measure %in% measures_expected & !is.na(language) & language != "") %>%
  select(year, measure, language, value)

# Create full grid and join, but only fill NA if truly missing
language_all <- unique(df_long$language)
df_language <- expand.grid(year = years_expected, measure = measures_expected, language = language_all, stringsAsFactors = FALSE) %>%
  left_join(df_long, by = c("year", "measure", "language")) %>%
  arrange(year, measure, language)

# Check for NA values in value column for present data
na_rows <- df_language[is.na(df_language$value) & paste(df_language$year, df_language$measure, df_language$language) %in% paste(df_long$year, df_long$measure, df_long$language), ]
if(nrow(na_rows) > 0) {
  cat("Warning: NA values found for present year/measure/language combinations:\n")
  print(na_rows)
}

# Preview cleaned data
print(df_language)

# ----- rm() cleaning ---------------------------------------------------
rm(df_raw, df_long, na_rows)

# ------ SAVE CSV ---------------------------------------------------
csv_path <- file.path(data_private_derived_csv, "ds_language.csv")
write.csv(df_language, csv_path, row.names = FALSE, fileEncoding = "UTF-8")
cat("Saved CSV to:", csv_path, "\n")

# ------ SAVE SQLite ---------------------------------------------------
dbWriteTable(db_books_of_ukraine, "ds_language", df_language, overwrite = TRUE)
cat("Saved table 'ds_language' to SQLite database.\n")

# ------ SAVE RDS   ---------------------------------------------------
rds_path <- file.path(data_private_derived, "ds_language.rds")
saveRDS(df_language, rds_path)
cat("Saved RDS to:", rds_path, "\n")

# ------ SAVE Google Sheets ---------------------------------------------------
gs_url_out <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?usp=sharing"
sheet_write(df_language, ss = gs_url_out, sheet = "ds_language")
cat("Saved to Google Sheet (ds_language):", gs_url_out, "\n")

# ------------------------------------------------------------------ DS_GENRE ----------------------------------------------------------------------------------------------------------------------------------------------

# -- load-data ---------------------------------------------------------------
df_raw <- import_selected_sheets(
  sheet_url = "https://docs.google.com/spreadsheets/d/1nxMTUD9gRhaE_VIT6WPR4V-_7BWNVwsJu__qjtCtSF0",
  sheets_to_import = "Тема"
)

# ------- data-cleaning-------------------------------------------------------------
years_expected <- 2005:2024
measures_expected <- c("title_count", "copy_count")

# Remove whitespace from column names and ensure all are character
df_raw <- df_raw %>% rename_with(~trimws(as.character(.)))

# Check for columns to pivot
if (ncol(df_raw) <= 2) {
  stop("No year columns found in input data after cleaning. Check your input sheet and column names.")
}

# Reshape to long format and robustly parse years
df_long <- df_raw %>%
  rename(measure_raw = 1, genre = 2) %>%
  pivot_longer(
    cols = -c(measure_raw, genre),
    names_to = "year",
    values_to = "value"
  ) %>%
  mutate(
    year = as.integer(gsub("[^0-9]", "", year)),
    measure = case_when(
      str_detect(measure_raw, "Наіменувань") ~ "title_count",
      str_detect(measure_raw, "Примірників") ~ "copy_count",
      TRUE ~ NA_character_
    ),
    value = safe_numeric_convert(value),
    genre = as.character(genre)
  ) %>%
  filter(year %in% years_expected & measure %in% measures_expected & !is.na(genre) & genre != "") %>%
  select(year, measure, genre, value)

# Create full grid and join, but only fill NA if truly missing
genre_all <- unique(df_long$genre)
df_genre <- expand.grid(year = years_expected, measure = measures_expected, genre = genre_all, stringsAsFactors = FALSE) %>%
  left_join(df_long, by = c("year", "measure", "genre")) %>%
  arrange(year, measure, genre)

# Check for NA values in value column for present data
na_rows <- df_genre[is.na(df_genre$value) & paste(df_genre$year, df_genre$measure, df_genre$genre) %in% paste(df_long$year, df_long$measure, df_long$genre), ]
if(nrow(na_rows) > 0) {
  cat("Warning: NA values found for present year/measure/genre combinations:\n")
  print(na_rows)
}

# Preview cleaned data
print(df_genre)

# ----- rm() cleaning ---------------------------------------------------
rm(df_raw, df_long, na_rows)

# ------ SAVE CSV ---------------------------------------------------
csv_path <- file.path(data_private_derived_csv, "ds_genre.csv")
write.csv(df_genre, csv_path, row.names = FALSE, fileEncoding = "UTF-8")
cat("Saved CSV to:", csv_path, "\n")

# ------ SAVE SQLite ---------------------------------------------------
dbWriteTable(db_books_of_ukraine, "ds_genre", df_genre, overwrite = TRUE)
cat("Saved table 'ds_genre' to SQLite database.\n")

# ------ SAVE RDS   ---------------------------------------------------
rds_path <- file.path(data_private_derived, "ds_genre.rds")
saveRDS(df_genre, rds_path)
cat("Saved RDS to:", rds_path, "\n")

# ------ SAVE Google Sheets ---------------------------------------------------
gs_url_out <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?usp=sharing"
sheet_write(df_genre, ss = gs_url_out, sheet = "ds_genre")
cat("Saved to Google Sheet (ds_genre):", gs_url_out, "\n")

# ------------------------------------------------------------------ DS_GEOGRAPHY ----------------------------------------------------------------------------------------------------------------------------------------------

# -- load-data ---------------------------------------------------------------
df_raw <- import_selected_sheets(
  sheet_url = "https://docs.google.com/spreadsheets/d/1nxMTUD9gRhaE_VIT6WPR4V-_7BWNVwsJu__qjtCtSF0",
  sheets_to_import = "Територія"
)

# ------- data-cleaning-------------------------------------------------------------
years_expected <- 2005:2024
measures_expected <- c("title_count", "copy_count")

# Remove whitespace from column names and ensure all are character
df_raw <- df_raw %>% rename_with(~trimws(as.character(.)))

# Check for columns to pivot
if (ncol(df_raw) <= 2) {
  stop("No year columns found in input data after cleaning. Check your input sheet and column names.")
}

# Reshape to long format and robustly parse years
df_long <- df_raw %>%
  rename(measure_raw = 1, geography = 2) %>%
  pivot_longer(
    cols = -c(measure_raw, geography),
    names_to = "year",
    values_to = "value"
  ) %>%
  mutate(
    year = as.integer(gsub("[^0-9]", "", year)),
    measure = case_when(
      str_detect(measure_raw, "Наіменувань") ~ "title_count",
      str_detect(measure_raw, "Примірників") ~ "copy_count",
      TRUE ~ NA_character_
    ),
    value = safe_numeric_convert(value),
    geography = as.character(geography)
  ) %>%
  filter(year %in% years_expected & measure %in% measures_expected & !is.na(geography) & geography != "") %>%
  select(year, measure, geography, value)

# Create full grid and join, but only fill NA if truly missing
geography_all <- unique(df_long$geography)
df_geography <- expand.grid(year = years_expected, measure = measures_expected, geography = geography_all, stringsAsFactors = FALSE) %>%
  left_join(df_long, by = c("year", "measure", "geography")) %>%
  arrange(year, measure, geography)

# Check for NA values in value column for present data
na_rows <- df_geography[is.na(df_geography$value) & paste(df_geography$year, df_geography$measure, df_geography$geography) %in% paste(df_long$year, df_long$measure, df_long$geography), ]
if(nrow(na_rows) > 0) {
  cat("Warning: NA values found for present year/measure/geography combinations:\n")
  print(na_rows)
}

# Preview cleaned data
print(df_geography)

# ----- rm() cleaning ---------------------------------------------------
rm(df_raw, df_long, na_rows)

# ------ SAVE CSV ---------------------------------------------------
csv_path <- file.path(data_private_derived_csv, "ds_geography.csv")
write.csv(df_geography, csv_path, row.names = FALSE, fileEncoding = "UTF-8")
cat("Saved CSV to:", csv_path, "\n")

# ------ SAVE SQLite ---------------------------------------------------
dbWriteTable(db_books_of_ukraine, "ds_geography", df_geography, overwrite = TRUE)
cat("Saved table 'ds_geography' to SQLite database.\n")

# ------ SAVE RDS   ---------------------------------------------------
rds_path <- file.path(data_private_derived, "ds_geography.rds")
saveRDS(df_geography, rds_path)
cat("Saved RDS to:", rds_path, "\n")

# ------ SAVE Google Sheets ---------------------------------------------------
gs_url_out <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?usp=sharing"
sheet_write(df_geography, ss = gs_url_out, sheet = "ds_geography")
cat("Saved to Google Sheet (ds_geography):", gs_url_out, "\n")

# ------------------------------------------------------------------ DS_PUBTYPE ----------------------------------------------------------------------------------------------------------------------------------------------

# -- load-data ---------------------------------------------------------------
df_raw <- import_selected_sheets(
  sheet_url = "https://docs.google.com/spreadsheets/d/1nxMTUD9gRhaE_VIT6WPR4V-_7BWNVwsJu__qjtCtSF0",
  sheets_to_import = "Призначення"
)

# ------- data-cleaning-------------------------------------------------------------
years_expected <- 2005:2024
measures_expected <- c("title_count", "copy_count")

# Remove whitespace from column names and ensure all are character
df_raw <- df_raw %>% rename_with(~trimws(as.character(.)))

# Check for columns to pivot
if (ncol(df_raw) <= 2) {
  stop("No year columns found in input data after cleaning. Check your input sheet and column names.")
}

# Reshape to long format and robustly parse years
df_long <- df_raw %>%
  rename(measure_raw = 1, pubtype = 2) %>%
  pivot_longer(
    cols = -c(measure_raw, pubtype),
    names_to = "year",
    values_to = "value"
  ) %>%
  mutate(
    year = as.integer(gsub("[^0-9]", "", year)),
    measure = case_when(
      str_detect(measure_raw, "Наіменувань") ~ "title_count",
      str_detect(measure_raw, "Примірників") ~ "copy_count",
      TRUE ~ NA_character_
    ),
    value = safe_numeric_convert(value),
    pubtype = as.character(pubtype)
  ) %>%
  filter(year %in% years_expected & measure %in% measures_expected & !is.na(pubtype) & pubtype != "") %>%
  select(year, measure, pubtype, value)

# Create full grid and join, but only fill NA if truly missing
pubtype_all <- unique(df_long$pubtype)
df_pubtype <- expand.grid(year = years_expected, measure = measures_expected, pubtype = pubtype_all, stringsAsFactors = FALSE) %>%
  left_join(df_long, by = c("year", "measure", "pubtype")) %>%
  arrange(year, measure, pubtype)

# Check for NA values in value column for present data
na_rows <- df_pubtype[is.na(df_pubtype$value) & paste(df_pubtype$year, df_pubtype$measure, df_pubtype$pubtype) %in% paste(df_long$year, df_long$measure, df_long$pubtype), ]
if(nrow(na_rows) > 0) {
  cat("Warning: NA values found for present year/measure/pubtype combinations:\n")
  print(na_rows)
}

# Preview cleaned data
print(df_pubtype)

# ----- rm() cleaning ---------------------------------------------------
rm(df_raw, df_long, na_rows)

# ------ SAVE CSV ---------------------------------------------------
csv_path <- file.path(data_private_derived_csv, "ds_pubtype.csv")
write.csv(df_pubtype, csv_path, row.names = FALSE, fileEncoding = "UTF-8")
cat("Saved CSV to:", csv_path, "\n")

# ------ SAVE SQLite ---------------------------------------------------
dbWriteTable(db_books_of_ukraine, "ds_pubtype", df_pubtype, overwrite = TRUE)
cat("Saved table 'ds_pubtype' to SQLite database.\n")

# ------ SAVE RDS   ---------------------------------------------------
rds_path <- file.path(data_private_derived, "ds_pubtype.rds")
saveRDS(df_pubtype, rds_path)
cat("Saved RDS to:", rds_path, "\n")

# ------ SAVE Google Sheets ---------------------------------------------------
gs_url_out <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?usp=sharing"
sheet_write(df_pubtype, ss = gs_url_out, sheet = "ds_pubtype")
cat("Saved to Google Sheet (ds_pubtype):", gs_url_out, "\n")





