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
# -- 2.Import only certain functions of a package into the search path.
# import::from("magrittr", "%>%")
# -- 3. Verify these packages are available on the machine, but their functions need to be qualified
requireNamespace("readr"    )# data import/export
requireNamespace("readxl"   )# data import/export
requireNamespace("janitor"  )# tidy data
requireNamespace("testit"   )# For asserting conditions meet expected patterns.
requireNamespace("googlesheets4") # for Google Sheets import

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

#' Import all sheets from Google Spreadsheet
#' 
#' This function imports all available sheets (tabs) from a Google Spreadsheet
#' and returns them as a named list of data frames
#'
#' @param sheet_url Character string with Google Sheets URL
#' @param clean_names Logical, whether to clean column names using janitor
#' @return Named list of data frames, one for each sheet
import_all_sheets <- function(sheet_url, clean_names = TRUE) {
  
  # Get sheet information
  sheet_info <- googlesheets4::gs4_get(sheet_url)
  sheet_names <- sheet_info$sheets$name
  
  cat("Знайдено", length(sheet_names), "вкладок (sheets):\n")
  cat(paste(sheet_names, collapse = ", "), "\n")
  
  # Import each sheet
  all_sheets <- list()
  
  for (sheet_name in sheet_names) {
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
    
    # Store in list with sheet name as key
    all_sheets[[sheet_name]] <- sheet_data
    
    cat("  - Розмір:", nrow(sheet_data), "рядків x", ncol(sheet_data), "колонок\n")
  }
  
  return(all_sheets)
}

# ----- define-query -----------------------------------------------------------

# ---- load-data ---------------------------------------------------------------
# a google spreadsheet with multiple tabs stores the main input of the project
# https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?usp=sharing

# URL Google Spreadsheet
main_spreadsheet_url <- "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?usp=sharing"

# Authenticate with Google Sheets (якщо потрібно)
# googlesheets4::gs4_auth() # Розкоментуйте якщо потрібна автентифікація

# For public sheets, disable authentication
googlesheets4::gs4_deauth()

cat("Починаємо завантаження даних з Google Spreadsheet...\n")

# Import all sheets from the main spreadsheet
all_data <- import_all_sheets(
  sheet_url = main_spreadsheet_url,
  clean_names = TRUE
)

# Display summary of imported data
cat("\n=== ПІДСУМОК ЗАВАНТАЖЕННЯ ===\n")
cat("Загалом завантажено", length(all_data), "таблиць:\n")

for (sheet_name in names(all_data)) {
  df <- all_data[[sheet_name]]
  cat(sprintf("  • %s: %d рядків × %d колонок\n", 
              sheet_name, nrow(df), ncol(df)))
  
  # Show first few column names
  col_preview <- head(names(df), 5)
  if (ncol(df) > 5) {
    col_preview <- c(col_preview, "...")
  }
  cat(sprintf("    Колонки: %s\n", paste(col_preview, collapse = ", ")))
}

# Create individual data frames for easier access
# Automatically assign each sheet to a variable based on its name
for (sheet_name in names(all_data)) {
  # Create a valid R variable name from sheet name
  var_name <- janitor::make_clean_names(sheet_name)
  assign(var_name, all_data[[sheet_name]])
  cat("Створено змінну:", var_name, "\n")
}

# ---- write-to-disk -------------------------

# Save all imported data to local files for faster access in future runs
cat("\nЗбереження даних на диск...\n")

# Save the complete list of all sheets
saveRDS(
  object = all_data,
  file = paste0(data_private_derived, "all_sheets_raw.rds")
)
cat("Збережено повний список таблиць у:", paste0(data_private_derived, "all_sheets_raw.rds\n"))

# Save each sheet as individual RDS file
for (sheet_name in names(all_data)) {
  file_name <- paste0(janitor::make_clean_names(sheet_name), ".rds")
  file_path <- paste0(data_private_derived, file_name)
  
  saveRDS(
    object = all_data[[sheet_name]],
    file = file_path
  )
  cat("Збережено:", sheet_name, "→", file_path, "\n")
} 

# Optional: Save as CSV files for external access
csv_folder <- paste0(data_private_derived, "csv/")
if (!fs::dir_exists(csv_folder)) {fs::dir_create(csv_folder)}

for (sheet_name in names(all_data)) {
  file_name <- paste0(janitor::make_clean_names(sheet_name), ".csv")
  file_path <- paste0(csv_folder, file_name)
  
  readr::write_csv(
    x = all_data[[sheet_name]],
    file = file_path
  )
}
cat("CSV файли збережено у:", csv_folder, "\n")

cat("\n=== ЗАВЕРШЕНО ===\n")
cat("Всі дані успішно завантажено та збережено!\n")

