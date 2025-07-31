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
# library(ggalluvial)
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
    
    # Convert all columns to character
    sheet_data <- sheet_data %>% dplyr::mutate(across(everything(), as.character))
    
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
# ----- define-query -----------------------------------------------------------


# ---- load-data ---------------------------------------------------------------
# let's import data from a Google Sheet located at the URL below
# https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=0#gid=0
# We will import sheets one by one. So, first let's get the names of the sheets
sheet_names <- googlesheets4::sheet_names("https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=0#gid=0")

print(sheet_names)

# make sure you import each column is imported as a character data type:
ds0 <- import_selected_sheets(
  sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
  sheets_to_import = "К-ть видань"
)
ds0 %>% glimpse()
# ---- tweak-data ---------------------------------
# some  numerical values contain spaces (e.g. "15 720", but we need it to be numeric 15720)
# mutate each column startin with "x" to remove spaces and convert to numeric
# replace "x" prefix with "year_" prefix
# ---- tweak-data ---------------------------------
ds1 <- ds0 %>%
    dplyr::mutate(across(starts_with("x"), ~ as.numeric(gsub(" ", "", .)))) %>%
    dplyr::rename_with(~ paste0("year_", sub("^x", "", .)), starts_with("x")) # add "year_" prefix
ds1 %>% glimpse()

# change values of measure_name to english equivalents:
# "Всього наіменувань" = title_count 
# "тираж (тис.)" = copies_count_k
ds2 <- 
  ds1 %>% 
  dplyr::mutate(
    measure_name = dplyr::case_when(
      measure_name == "Всього наіменувань" ~ "title_count",
      measure_name == "тираж (тис.)" ~ "copies_count_k",
      TRUE ~ measure_name
    )
  ) 
ds2 %>% glimpse()

# create a long form of the data and clean up values of the 'year' column (remove previx "year_") and store as integer
ds3 <-
   ds2 %>%
  tidyr::pivot_longer(
    cols = starts_with("year_"),
    names_to = "year",
    values_to = "value"
  ) %>% 
  dplyr::mutate(
    year = as.integer(gsub("year_", "", year)), # remove "year_" prefix and convert to integer
    measure_name = factor(measure_name, levels = c("title_count", "copies_count_k")) # set factor levels
  ) 
ds3

# ---- inspect-data --------------------------------


# ---- write-to-disk -------------------------
ds2 %>% readr::write_csv("./data-public/derived/manipulation/0-ellis-v2-ds2.csv")
ds3 %>% readr::write_csv("./data-public/derived/manipulation/0-ellis-v2-ds3.csv")
