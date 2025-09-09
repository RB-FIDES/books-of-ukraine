# Ellis Extra Data Processing Functions
# Modular functions for processing different types of custom data

# Load required packages
library(dplyr)
library(tidyr) 
library(stringr)
library(janitor)
library(rlang)

# ---- column-standardization --------------------------------------------------

# Ukrainian to English column name mapping
# Supports both Ukrainian and English inputs, standardizes to English
ukrainian_to_english_columns <- list(
  # Indicator/Measure columns (case variations)
  "Показник" = "pokaznik", "показник" = "pokaznik", "ПОКАЗНИК" = "pokaznik",
  "Measure" = "pokaznik", "measure" = "pokaznik", "MEASURE" = "pokaznik",
  "Indicator" = "pokaznik", "indicator" = "pokaznik", "INDICATOR" = "pokaznik",
  
  # Territory/Region columns  
  "Територія" = "teritoria", "територія" = "teritoria", "ТЕРИТОРІЯ" = "teritoria",
  "Territory" = "teritoria", "territory" = "teritoria", "TERRITORY" = "teritoria",
  "Region" = "teritoria", "region" = "teritoria", "REGION" = "teritoria",
  
  # Administrative divisions
  "Область" = "oblast", "область" = "oblast", "ОБЛАСТЬ" = "oblast",
  "Oblast" = "oblast", "oblast" = "oblast", "OBLAST" = "oblast",
  
  # Time columns
  "Рік" = "year", "рік" = "year", "РІК" = "year",
  "Year" = "year", "year" = "year", "YEAR" = "year"
)

# Ukrainian to English measure value mapping
ukrainian_to_english_measures <- list(
  # Bookstore counts
  "Кількість книгарень" = "bookstore_count",
  "кількість книгарень" = "bookstore_count", 
  "КІЛЬКІСТЬ КНИГАРЕНЬ" = "bookstore_count",
  "Number of Bookstores" = "bookstore_count",
  "Bookstore Count" = "bookstore_count",
  
  # Title counts
  "Наіменувань" = "title_count",
  "наіменувань" = "title_count",
  "НАІМЕНУВАНЬ" = "title_count", 
  "Title Count" = "title_count",
  "Titles" = "title_count",
  
  # Copy counts  
  "Примірників" = "copy_count",
  "примірників" = "copy_count",
  "ПРИМІРНИКІВ" = "copy_count",
  "Copy Count" = "copy_count",
  "Copies" = "copy_count"
)

#' Standardize column names from Ukrainian or English to standardized English
#' @param data Data frame with potentially mixed Ukrainian/English column names
#' @return Data frame with standardized English column names
standardize_column_names <- function(data) {
  # First apply Ukrainian → English mapping
  current_names <- names(data)
  standardized_names <- ifelse(
    current_names %in% names(ukrainian_to_english_columns),
    unlist(ukrainian_to_english_columns[current_names]),
    current_names
  )
  names(data) <- standardized_names
  
  # Then apply janitor::clean_names for consistent formatting
  data %>% janitor::clean_names()
}

#' Standardize measure values from Ukrainian or English to standardized English
#' @param measure_value Character value representing a measure
#' @return Standardized English measure type
standardize_measure_value <- function(measure_value) {
  if (measure_value %in% names(ukrainian_to_english_measures)) {
    return(ukrainian_to_english_measures[[measure_value]])
  }
  
  # Fallback: try pattern matching for partial matches
  if (str_detect(measure_value, "книгарн|bookstore|Bookstore")) {
    return("bookstore_count")
  } else if (str_detect(measure_value, "наімен|title|Title")) {
    return("title_count") 
  } else if (str_detect(measure_value, "примірн|copy|Copy")) {
    return("copy_count")
  }
  
  # Default fallback
  return("title_count")
}

# ---- validation-functions ---------------------------------------------------

#' Validate sheet structure based on data type
#' @param sheet_data Data frame from Google Sheets
#' @param data_type Type of data (categorical_time_series, lookup_table, fact_table)
#' @param sheet_name Name of the sheet for error reporting
#' @return List with validation results
validate_sheet_structure <- function(sheet_data, data_type, sheet_name) {
  validation_result <- list(
    valid = TRUE,
    errors = character(),
    warnings = character()
  )
  
  # Check basic requirements
  if (nrow(sheet_data) == 0) {
    validation_result$valid <- FALSE
    validation_result$errors <- c(validation_result$errors, 
                                 paste("Sheet", sheet_name, "is empty"))
    return(validation_result)
  }
  
  # Type-specific validation
  if (data_type == "categorical_time_series") {
    # Check for pokaznik column (case-insensitive)
    if (!any(str_detect(tolower(names(sheet_data)), "показник|pokaznik"))) {
      validation_result$valid <- FALSE
      validation_result$errors <- c(validation_result$errors,
                                   paste("Sheet", sheet_name, "missing 'показник' or 'pokaznik' column"))
    }
    
    # Check for year columns (more flexible pattern)
    year_cols <- names(sheet_data)[str_detect(names(sheet_data), "^x?\\d{4}$|^\\d{4}$")]
    if (length(year_cols) == 0) {
      validation_result$valid <- FALSE
      validation_result$errors <- c(validation_result$errors,
                                   paste("Sheet", sheet_name, "missing year columns (format: 2023 or x2023)"))
    }
    
    # Check for category column (non-year, non-pokaznik column)
    non_data_cols <- c("pokaznik", year_cols)
    category_cols <- names(sheet_data)[!tolower(names(sheet_data)) %in% tolower(non_data_cols)]
    if (length(category_cols) == 0) {
      validation_result$warnings <- c(validation_result$warnings,
                                     paste("Sheet", sheet_name, "may be missing category column"))
    }
  }
  
  return(validation_result)
}

#' Detect category column automatically
#' @param sheet_data Data frame from Google Sheets  
#' @param sheet_name Sheet name for error reporting
#' @return Name of the category column or NULL
detect_category_column <- function(sheet_data, sheet_name) {
  # Find non-year, non-pokaznik columns
  year_cols <- names(sheet_data)[str_detect(names(sheet_data), "^x?\\d{4}$|^\\d{4}$")]
  pokaznik_cols <- names(sheet_data)[str_detect(tolower(names(sheet_data)), "показник|pokaznik")]
  non_data_cols <- c(pokaznik_cols, year_cols)
  category_cols <- names(sheet_data)[!names(sheet_data) %in% non_data_cols]
  
  if (length(category_cols) == 0) {
    cat("   ⚠️  Warning: No category column detected in", sheet_name, "\n")
    return(NULL)
  }
  
  # Use the first non-data column as category column
  category_col <- category_cols[1]
  
  if (length(category_cols) > 1) {
    cat("   ℹ️  Info: Multiple potential category columns in", sheet_name, 
        ". Using:", category_col, "\n")
    cat("        Other columns:", paste(category_cols[-1], collapse = ", "), "\n")
  }
  
  return(category_col)
}

# ---- processing-functions --------------------------------------------------

#' Process categorical time series data (dimensions × years format)
#' @param sheet_data Data frame from Google Sheets
#' @param config Processing configuration for this data source
#' @param sheet_name Original sheet name
#' @param table_key English table key for this data
#' @return Processed data frame in long format
process_categorical_time_series <- function(sheet_data, config, sheet_name, table_key) {
  cat("   📊 Processing as categorical time series data\n")
  
  # Standardize column names (Ukrainian → English, then clean)
  sheet_data <- standardize_column_names(sheet_data)
  cat("   🔧 Column names standardized to English\n")
  
  # Detect category column (now working with standardized names)
  category_col <- if ("category_column_detection" %in% names(config) && 
                     config$category_column_detection != "auto") {
    config$category_column_detection
  } else {
    detect_category_column(sheet_data, sheet_name)
  }
  
  if (is.null(category_col)) {
    stop("Could not detect category column in sheet: ", sheet_name)
  }
  
  cat("   📝 Using category column:", category_col, "\n")
  
  # Process the data
  processed_data <- sheet_data %>%
    pivot_longer(
      cols = starts_with("x") | matches("^\\d{4}$"),  # Match both x2023 and 2023 formats
      names_to = "year",
      values_to = "value"
    ) %>%
    mutate(
      year = as.integer(str_extract(year, "\\d{4}")),
      value = safe_numeric_convert(value),
      # Determine category_type based on data content - if it's bookstores data organized by oblasts, use "territory"
      category_type = if (table_key == "bookstores" && category_col == "teritoria") {
        "territory"
      } else {
        table_key
      },
      measure_type = if ("pokaznik" %in% names(.)) {
        # Use vectorized approach for Ukrainian/English measure mapping
        sapply(pokaznik, standardize_measure_value, USE.NAMES = FALSE)
      } else {
        "title_count"  # Default if no measure column
      }
    ) %>%
    # Add category_value using dynamic column reference
    {
      if (category_col %in% names(.)) {
        mutate(., category_value = .data[[category_col]])
      } else {
        stop("Category column '", category_col, "' not found after standardization")
      }
    } %>%
    filter(!is.na(year), !is.na(value), !is.na(category_value)) %>%
    select(year, category_type, category_value, measure_type, value)
  
  return(processed_data)
}

#' Process lookup table data (reference/mapping tables)
#' @param sheet_data Data frame from Google Sheets
#' @param config Processing configuration
#' @param sheet_name Original sheet name 
#' @param table_key English table key
#' @return Processed lookup table
process_lookup_table <- function(sheet_data, config, sheet_name, table_key) {
  cat("   📋 Processing as lookup table\n")
  
  # Basic cleaning
  processed_data <- sheet_data %>%
    janitor::clean_names()
  
  # Validate key columns if specified
  if ("key_columns" %in% names(config)) {
    missing_cols <- setdiff(config$key_columns, names(processed_data))
    if (length(missing_cols) > 0) {
      stop("Missing key columns in ", sheet_name, ": ", paste(missing_cols, collapse = ", "))
    }
  }
  
  return(processed_data)
}

#' Process fact table data (standard tabular data)
#' @param sheet_data Data frame from Google Sheets
#' @param config Processing configuration
#' @param sheet_name Original sheet name
#' @param table_key English table key  
#' @return Processed fact table
process_fact_table <- function(sheet_data, config, sheet_name, table_key) {
  cat("   📄 Processing as fact table\n")
  
  # Basic cleaning
  processed_data <- sheet_data %>%
    janitor::clean_names()
  
  # Validate expected columns if specified
  if ("expected_columns" %in% names(config)) {
    missing_cols <- setdiff(config$expected_columns, names(processed_data))
    if (length(missing_cols) > 0) {
      cat("   ⚠️  Warning: Missing expected columns in", sheet_name, ":", 
          paste(missing_cols, collapse = ", "), "\n")
    }
  }
  
  return(processed_data)
}

#' Main processing dispatcher - routes data to appropriate processing function
#' @param sheet_data Data frame from Google Sheets
#' @param data_source_config Complete data source configuration
#' @param sheet_name Original sheet name
#' @param table_key English table key
#' @return Processed data frame
process_sheet_data <- function(sheet_data, data_source_config, sheet_name, table_key) {
  data_type <- data_source_config$data_type
  config <- data_source_config$processing_notes
  
  # Validate sheet structure
  validation <- validate_sheet_structure(sheet_data, data_type, sheet_name)
  
  if (!validation$valid) {
    cat("   ❌ Validation errors in sheet", sheet_name, ":\n")
    for (error in validation$errors) {
      cat("      •", error, "\n")
    }
    return(NULL)
  }
  
  if (length(validation$warnings) > 0) {
    for (warning in validation$warnings) {
      cat("   ⚠️ ", warning, "\n")
    }
  }
  
  # Dispatch to appropriate processing function
  switch(data_type,
    "categorical_time_series" = process_categorical_time_series(sheet_data, config, sheet_name, table_key),
    "lookup_table" = process_lookup_table(sheet_data, config, sheet_name, table_key), 
    "fact_table" = process_fact_table(sheet_data, config, sheet_name, table_key),
    {
      cat("   ❌ Unknown data type:", data_type, "for sheet:", sheet_name, "\n")
      return(NULL)
    }
  )
}

cat("🔧 Extra Data Processing Functions Loaded\n")
