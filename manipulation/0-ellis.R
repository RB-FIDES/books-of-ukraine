# Ellis Script - Long and Wide Format Version
# This script creates CACHE tables in both long and wide formats as specified in CACHE-manifest.md
# Long format schema: year + measure + [category] + value
# Wide format schema: year + measure + [category columns with values]

# Manual Authentical process (obsolete)
# To run this document, you need to connect your profile to Google account, first:
# Use this command to connect your profile to Google account:
# library(googlesheets4) - run it in console first
# gs4_auth() - then run this, and connect account
# ------------------------------------- Important to run ------------------------------------- 
# If you run this scripts first, you can run chunks below in order you want
## ------- Preparation -------
rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
cat("\014") # Clear the console 
# verify root location
cat("Working directory: ", getwd()) # Must be set to Project Directory
# Project Directory should be the root by default unless overwritten

## ------- Google Sheets Authentication -------
# Automatic authentication using service account (preferred) or cached tokens (fallback)
source("scripts/service-account-auth.R")

# This will:
# 1. Try service account authentication (google-service-account.json) - NO BROWSER
# 2. Fall back to cached token authentication if no service account
# 3. Fall back to interactive authentication if neither available
authenticate_google_sheets()

## ------- Creating a Function -------
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

## -------Load libraries-------
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
library(janitor)
library(openxlsx)
library(DBI)      # For database connection and operations
library(RSQLite)
library(ggrepel)
library(googlesheets4)
library(fs)        # file system operations

## --- Creating folders for data manipulation ----
data_private_derived <- "data-private/derived/manipulation/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)} # nolint

data_private_derived_sqlite <- "data-private/derived/manipulation/SQLite/"
if (!fs::dir_exists(data_private_derived_sqlite)) {fs::dir_create(data_private_derived_sqlite)}

data_private_derived_csv <- "data-private/derived/manipulation/CSV/"
if (!fs::dir_exists(data_private_derived_csv)) {fs::dir_create(data_private_derived_csv)}

db_books_of_ukraine <- dbConnect(RSQLite::SQLite(), "data-private/derived/manipulation/SQLite/books-of-ukraine-long.sqlite")

## ------ Data import ------
df_raw <- import_selected_sheets(
  sheet_url = "https://docs.google.com/spreadsheets/d/1nxMTUD9gRhaE_VIT6WPR4V-_7BWNVwsJu__qjtCtSF0",
  sheets_to_import = "Рік"
)

