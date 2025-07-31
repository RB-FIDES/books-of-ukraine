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
library(testit)    # For asserting conditions meet expected patterns.
library(DBI)       # For database connection and operations
library(RSQLite)   # SQLite database
library(ggrepel)   # for text labels in ggplot2

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
base::source("./scripts/operational-functions.R") # project-level

# ---- declare-globals ---------------------------------------------------------
local_root <- "./analysis/eda-1/"
local_data <- paste0(local_root, "data-local/") # for local outputs

if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

data_private_derived <- "./data-private/derived/eda-1/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

prints_folder <- paste0(local_root, "prints/")
if (!fs::dir_exists(prints_folder)) {fs::dir_create(prints_folder)}

# Data paths
data_manipulation_path <- "./data-private/derived/manipulation/"
sqlite_db_path <- paste0(data_manipulation_path, "SQLite/books-of-ukraine.sqlite")

# Define analysis periods
target_window_opens  <- as.Date("2005-01-01")
target_window_closes <- as.Date("2023-12-31")
target_window <- c(target_window_opens, target_window_closes)

# ---- declare-functions -------------------------------------------------------
# Custom function to check if data files exist
check_data_availability <- function() {
  files_to_check <- c(
    paste0(data_manipulation_path, "ds_year.rds"),
    paste0(data_manipulation_path, "ds_language.rds"),
    paste0(data_manipulation_path, "ds_genre.rds"),
    paste0(data_manipulation_path, "ds_pubtype.rds"),
    paste0(data_manipulation_path, "ds_geography.rds"),
    paste0(data_manipulation_path, "ds_ukr_rus.rds")
  )
  
  missing_files <- files_to_check[!file.exists(files_to_check)]
  
  if (length(missing_files) > 0) {
    cat("Missing data files:\n")
    cat(paste(missing_files, collapse = "\n"))
    cat("\nPlease run manipulation/0-ellis.R first to generate the data.\n")
    return(FALSE)
  } else {
    cat("All required data files are available.\n")
    return(TRUE)
  }
}

# Function to load all datasets
load_books_data <- function() {
  if (!check_data_availability()) {
    stop("Data files are missing. Please run manipulation/0-ellis.R first.")
  }
  
  list(
    ds_year = readRDS(paste0(data_manipulation_path, "ds_year.rds")),
    ds_language = readRDS(paste0(data_manipulation_path, "ds_language.rds")),
    ds_genre = readRDS(paste0(data_manipulation_path, "ds_genre.rds")),
    ds_pubtype = readRDS(paste0(data_manipulation_path, "ds_pubtype.rds")),
    ds_geography = readRDS(paste0(data_manipulation_path, "ds_geography.rds")),
    ds_ukr_rus = readRDS(paste0(data_manipulation_path, "ds_ukr_rus.rds"))
  )
}

# Function to connect to SQLite database
connect_to_db <- function() {
  if (file.exists(sqlite_db_path)) {
    return(dbConnect(RSQLite::SQLite(), sqlite_db_path))
  } else {
    cat("SQLite database not found. Please run manipulation/0-ellis.R first.\n")
    return(NULL)
  }
}

# ---- load-data ---------------------------------------------------------------
# Load all datasets
books_data <- load_books_data()

# Extract individual datasets for easier access
ds_year <- books_data$ds_year
ds_language <- books_data$ds_language
ds_genre <- books_data$ds_genre
ds_pubtype <- books_data$ds_pubtype
ds_geography <- books_data$ds_geography
ds_ukr_rus <- books_data$ds_ukr_rus

# Optional: Connect to SQLite database for SQL queries
# books_db <- connect_to_db()

# ---- inspect-data-0 -----------------------------------------------------------
# Basic inspection of all datasets

# ---- tweak-data-0 ------------------------------------------------------------
# Prepare data for analysis - add regional groupings for geography
ds_geography_enhanced <- ds_geography %>%
  mutate(
    region_group = case_when(
      # Північ (North)
      "м. Київ" > 0 | "Київська область" > 0 | "Чернігівська область" > 0 | 
      "Сумська область" > 0 | "Житомирська область" > 0 ~ "Північ",
      
      # Південь (South) 
      "Одеська область" > 0 | "Миколаївська область" > 0 | "Херсонська область" > 0 |
      "Запорізька область" > 0 | "Автономна Республіка Крим" > 0 | "м. Севастополь" > 0 ~ "Південь",
      
      # Схід (East)
      "Харківська область" > 0 | "Донецька область" > 0 | "Луганська область" > 0 |
      "Дніпропетровська область" > 0 ~ "Схід",
      
      # Захід (West)
      "Львівська область" > 0 | "Івано-Франківська область" > 0 | "Тернопільська область" > 0 |
      "Закарпатська область" > 0 | "Волинська область" > 0 | "Рівненська область" > 0 |
      "Хмельницька область" > 0 | "Чернівецька область" > 0 ~ "Захід",
      
      # Центр (Center)
      "Вінницька область" > 0 | "Полтавська область" > 0 | "Кіровоградська область" > 0 |
      "Черкаська область" > 0 ~ "Центр",
      
      TRUE ~ "Інше"
    )
  )

# Create summary tables for easier graphing
ds_year_summary <- ds_year %>%
  arrange(yr, measure)

ds_language_summary <- ds_language %>%
  select(yr, measure, Українська, Російська, Англійська, `Інші мови`) %>%
  arrange(yr, measure)

# ---- analysis-functions ------------------------------------------------------
# Function to create time series plot
create_time_series <- function(data, value_col, title, subtitle = NULL, y_label = "Count") {
  data %>%
    ggplot(aes(x = yr, y = !!sym(value_col))) +
    geom_line(size = 1.2, color = "steelblue") +
    geom_point(size = 2, color = "steelblue") +
    labs(
      title = title,
      subtitle = subtitle,
      x = "Рік",
      y = y_label
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 12),
      axis.text = element_text(size = 10),
      axis.title = element_text(size = 11)
    ) +
    scale_x_continuous(breaks = seq(2005, 2023, 2)) +
    scale_y_continuous(labels = scales::comma)
}

# Function to create language comparison plot
create_language_comparison <- function(data, measure_type = "title_count") {
  data %>%
    filter(measure == measure_type) %>%
    select(yr, Українська, Російська) %>%
    pivot_longer(cols = c(Українська, Російська), names_to = "Language", values_to = "Count") %>%
    ggplot(aes(x = yr, y = Count, color = Language)) +
    geom_line(size = 1.2) +
    geom_point(size = 2) +
    labs(
      title = if(measure_type == "title_count") "Кількість видань за мовами" else "Кількість копій за мовами",
      x = "Рік",
      y = if(measure_type == "title_count") "Кількість видань" else "Кількість копій",
      color = "Мова"
    ) +
    theme_minimal() +
    scale_color_manual(values = c("Українська" = "#005BBB", "Російська" = "#DC143C")) +
    scale_x_continuous(breaks = seq(2005, 2023, 2)) +
    scale_y_continuous(labels = scales::comma)
}

# ---- analysis-below -----------------------------------------------------------
# Ready for human analysts to create visualizations and conduct analysis
# All data is loaded and prepared for exploration
