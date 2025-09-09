# silent-mini-eda.R
# Silent mini-EDA function for behind-the-scenes data structure analysis
# Returns structured information to inform intelligent ggplot design decisions
#
# ENHANCED ERROR HANDLING: This version includes comprehensive error recovery
# to prevent the analysis pipeline from failing due to data type issues,
# R's finicky summary functions, or environment access problems.

#' Safe wrapper for potentially problematic R operations
safe_operation <- function(expr, default_value = NA, error_prefix = "Operation failed") {
  tryCatch({
    eval(expr)
  }, error = function(e) {
    attr(default_value, "error") <- paste(error_prefix, ":", e$message)
    return(default_value)
  })
}

# Database Configuration Validator
validate_db_config <- function(verbose = FALSE) {
  if (!file.exists("./scripts/common-functions.R")) {
    stop("ERROR: common-functions.R not found. Cannot validate database configuration.")
  }
  
  source("./scripts/common-functions.R", local = TRUE)
  
  tryCatch({
    main_path <- get_db_path("main")
    stage_1_path <- get_db_path("stage_1") 
    stage_2_path <- get_db_path("stage_2")
    
    if (verbose) {
      cat("Database configuration validated:\n")
      cat("   Main:", main_path, if(file.exists(main_path)) "[EXISTS]" else "[MISSING]", "\n")
      cat("   Stage 1:", stage_1_path, if(file.exists(stage_1_path)) "[EXISTS]" else "[MISSING]", "\n") 
      cat("   Stage 2:", stage_2_path, if(file.exists(stage_2_path)) "[EXISTS]" else "[MISSING]", "\n")
    }
    
    return(list(
      main = main_path,
      stage_1 = stage_1_path,
      stage_2 = stage_2_path,
      config_valid = TRUE
    ))
  }, error = function(e) {
    stop("ERROR: Database configuration error: ", e$message, 
         "\nREMINDER: Always use get_db_path() or connect_books_db() functions")
  })
}

#' Silent Mini-EDA for Dataset Structure Analysis
#' 
#' Performs a comprehensive but silent analysis of a dataset to inform
#' intelligent plotting decisions. Returns structured information instead
#' of printing to console.
#' 
#' @param dataset_name Character string name of the dataset to analyze
#' @param .env Environment to look for the dataset (default: .GlobalEnv)
#' @param include_samples Logical, whether to include sample data rows
#' @param verbose Logical, whether to print analysis to console (default: FALSE)
#' 
#' @return List with structured information about the dataset
silent_mini_eda <- function(dataset_name, .env = .GlobalEnv, include_samples = TRUE, verbose = FALSE) {
  
  # Enhanced dataset existence and access checking
  tryCatch({
    # Check if dataset exists
    if (!exists(dataset_name, envir = .env)) {
      warning(paste("Dataset", dataset_name, "not found in specified environment"))
      return(list(
        dataset_name = dataset_name,
        exists = FALSE,
        error = paste("Dataset", dataset_name, "not found")
      ))
    }
    
    # Safely get the dataset
    df <- get(dataset_name, envir = .env)
    
  }, error = function(e) {
    return(list(
      dataset_name = dataset_name,
      exists = FALSE,
      error = paste("Failed to access dataset:", e$message)
    ))
  })
  
  if (!is.data.frame(df)) {
    warning(paste("Object", dataset_name, "is not a data frame"))
    return(list(
      dataset_name = dataset_name,
      exists = TRUE,
      is_dataframe = FALSE,
      error = paste("Object", dataset_name, "is not a data frame")
    ))
  }
  
  # Basic structure
  structure_info <- list(
    dataset_name = dataset_name,
    exists = TRUE,
    is_dataframe = TRUE,
    dimensions = list(
      rows = nrow(df),
      cols = ncol(df)
    ),
    column_names = names(df)
  )
  
  # Column analysis
  column_analysis <- list()
  categorical_vars <- character(0)
  continuous_vars <- character(0)
  date_vars <- character(0)
  
  for (col in names(df)) {
    # Defensive column analysis with error handling
    tryCatch({
      col_data <- df[[col]]
      col_info <- list(
        name = col,
        class = paste(class(col_data), collapse = ", "),  # Handle multiple classes
        n_unique = length(unique(col_data)),
        n_missing = sum(is.na(col_data)),
        pct_missing = round(sum(is.na(col_data)) / nrow(df) * 100, 2)
      )
    }, error = function(e) {
      col_info <- list(
        name = col,
        class = "unknown",
        n_unique = NA,
        n_missing = NA,
        pct_missing = NA,
        error = paste("Column analysis failed:", e$message)
      )
      return(col_info)
    })
    
    # Determine variable type for plotting
    if (is.numeric(col_data) || is.integer(col_data)) {
      if (col_info$n_unique <= 10 && col_info$n_unique < nrow(df) * 0.5) {
        col_info$plot_type <- "categorical_numeric"
        categorical_vars <- c(categorical_vars, col)
      } else {
        col_info$plot_type <- "continuous"
        continuous_vars <- c(continuous_vars, col)
        # Safe range calculation with error handling
        tryCatch({
          col_info$range <- range(col_data, na.rm = TRUE)
          col_info$summary <- summary(col_data)
        }, error = function(e) {
          col_info$range <- c(NA, NA)
          col_info$summary <- list(error = paste("Summary failed:", e$message))
        })
      }
    } else if (is.character(col_data) || is.factor(col_data)) {
      col_info$plot_type <- "categorical"
      categorical_vars <- c(categorical_vars, col)
      if (col_info$n_unique <= 20) {  # Only show frequencies for manageable number of categories
        col_info$value_counts <- sort(table(col_data, useNA = "ifany"), decreasing = TRUE)
      }
    } else if (inherits(col_data, c("Date", "POSIXct", "POSIXt"))) {
      col_info$plot_type <- "date"
      date_vars <- c(date_vars, col)
      # Safe date range calculation
      tryCatch({
        col_info$date_range <- range(col_data, na.rm = TRUE)
      }, error = function(e) {
        col_info$date_range <- c(NA, NA)
        col_info$date_range_error <- e$message
      })
    } else {
      col_info$plot_type <- "other"
    }
    
    column_analysis[[col]] <- col_info
  }
  
  # Variable type summary
  variable_types <- list(
    categorical = categorical_vars,
    continuous = continuous_vars,
    date = date_vars,
    n_categorical = length(categorical_vars),
    n_continuous = length(continuous_vars),
    n_date = length(date_vars)
  )
  
  # Data samples with safe handling
  samples <- NULL
  if (include_samples) {
    samples <- list()
    tryCatch({
      samples$head <- head(df, min(6, nrow(df)))
      samples$tail <- tail(df, min(3, nrow(df)))
      if (nrow(df) > 20) {
        set.seed(42)  # Reproducible sampling
        samples$random_sample <- df[sample(nrow(df), min(5, nrow(df))), ]
      }
    }, error = function(e) {
      samples$error <- paste("Sample extraction failed:", e$message)
    })
  }
  
  # Plotting recommendations
  plotting_recommendations <- generate_plotting_recommendations(df, variable_types, column_analysis)
  
  # Compile results
  result <- list(
    structure = structure_info,
    columns = column_analysis,
    variable_types = variable_types,
    samples = samples,
    plotting_recommendations = plotting_recommendations,
    timestamp = Sys.time()
  )
  
  # Optional verbose output
  if (verbose) {
    print_mini_eda_summary(result)
  }
  
  return(result)
}

#' Generate intelligent plotting recommendations based on data structure
generate_plotting_recommendations <- function(df, var_types, col_analysis) {
  
  recommendations <- list()
  
  # Time series detection
  if (any(grepl("year|date|time", names(df), ignore.case = TRUE))) {
    time_vars <- names(df)[grepl("year|date|time", names(df), ignore.case = TRUE)]
    if (length(var_types$continuous) > 0 || length(var_types$categorical) > 0) {
      recommendations$time_series <- list(
        suitable = TRUE,
        time_var = time_vars[1],
        y_vars = var_types$continuous,
        grouping_vars = var_types$categorical[var_types$categorical != time_vars[1]]
      )
    }
  }
  
  # Categorical analysis recommendations
  if (length(var_types$categorical) > 0 && length(var_types$continuous) > 0) {
    recommendations$categorical_continuous <- list(
      suitable = TRUE,
      categorical_vars = var_types$categorical,
      continuous_vars = var_types$continuous,
      suggested_plots = c("boxplot", "violin", "bar_chart", "point_plot")
    )
  }
  
  # Multiple categorical variables
  if (length(var_types$categorical) >= 2) {
    recommendations$multiple_categorical <- list(
      suitable = TRUE,
      vars = var_types$categorical,
      suggested_plots = c("stacked_bar", "grouped_bar", "alluvial", "heatmap")
    )
  }
  
  # Continuous variables relationships
  if (length(var_types$continuous) >= 2) {
    recommendations$continuous_relationships <- list(
      suitable = TRUE,
      vars = var_types$continuous,
      suggested_plots = c("scatter", "line", "smooth", "correlation_matrix")
    )
  }
  
  # Long-format data detection (common in tidy data)
  if ("measure" %in% names(df) && "value" %in% names(df)) {
    recommendations$long_format <- list(
      detected = TRUE,
      measure_var = "measure",
      value_var = "value",
      grouping_vars = setdiff(var_types$categorical, "measure"),
      suggested_approach = "Pivot wider for some analyses, or use measure as grouping variable"
    )
  }
  
  return(recommendations)
}

#' Print summary of mini-EDA results (for verbose mode)
print_mini_eda_summary <- function(eda_result) {
  cat("=== SILENT MINI-EDA SUMMARY ===\n")
  cat("Dataset:", eda_result$structure$dataset_name, "\n")
  cat("Dimensions:", eda_result$structure$dimensions$rows, "rows x", eda_result$structure$dimensions$cols, "columns\n\n")
  
  cat("Variable Types:\n")
  cat("  Categorical (", eda_result$variable_types$n_categorical, "):", paste(eda_result$variable_types$categorical, collapse = ", "), "\n")
  cat("  Continuous (", eda_result$variable_types$n_continuous, "):", paste(eda_result$variable_types$continuous, collapse = ", "), "\n")
  cat("  Date (", eda_result$variable_types$n_date, "):", paste(eda_result$variable_types$date, collapse = ", "), "\n\n")
  
  if (!is.null(eda_result$plotting_recommendations$time_series)) {
    cat("Time Series Potential: YES\n")
  }
  
  if (!is.null(eda_result$plotting_recommendations$long_format)) {
    cat("Long Format Detected: YES\n")
  }
  
  cat("Analysis completed at:", format(eda_result$timestamp), "\n")
}

#' Smart ggplot design assistant using silent mini-EDA
#' 
#' Analyzes dataset structure and provides intelligent ggplot code suggestions
#' 
#' @param dataset_name Name of the dataset
#' @param plot_intent Character describing what kind of plot is desired
#' @param .env Environment containing the dataset
smart_ggplot_assistant <- function(dataset_name, plot_intent = "explore", .env = .GlobalEnv) {
  
  # Run silent mini-EDA
  eda <- silent_mini_eda(dataset_name, .env = .env, verbose = FALSE)
  # Support two possible return shapes from silent_mini_eda():
  # 1) error case returns top-level fields: list(dataset_name=..., exists=FALSE, error=...)
  # 2) normal case returns nested structure: list(structure=list(exists=TRUE, is_dataframe=TRUE), ...)
  exists_flag <- NULL
  is_df_flag <- NULL
  err_msg <- NULL

  if (!is.null(eda$exists)) {
    exists_flag <- eda$exists
  } else if (!is.null(eda$structure) && !is.null(eda$structure$exists)) {
    exists_flag <- eda$structure$exists
  }

  if (!is.null(eda$is_dataframe)) {
    is_df_flag <- eda$is_dataframe
  } else if (!is.null(eda$structure) && !is.null(eda$structure$is_dataframe)) {
    is_df_flag <- eda$structure$is_dataframe
  }

  if (!is.null(eda$error)) err_msg <- eda$error
  if (is.null(err_msg) && !is.null(eda$structure) && !is.null(eda$structure$error)) err_msg <- eda$structure$error

  # Defensive defaults: assume dataset exists & is a dataframe unless explicitly false
  if (is.null(exists_flag)) exists_flag <- TRUE
  if (is.null(is_df_flag)) is_df_flag <- TRUE

  if (!exists_flag || !is_df_flag) {
    return(paste("Cannot analyze dataset:", if (!is.null(err_msg)) err_msg else dataset_name))
  }
  
  # Generate smart recommendations based on intent and data structure
  suggestions <- list()
  
  # Time series suggestions
  if (!is.null(eda$plotting_recommendations$time_series) && 
      grepl("time|trend|dynamic|year|temporal", plot_intent, ignore.case = TRUE)) {
    
    time_rec <- eda$plotting_recommendations$time_series
    suggestions$time_series <- paste0(
      "# Time series plot detected:\n",
      "ggplot(", dataset_name, ", aes(x = ", time_rec$time_var, ", y = value)) +\n",
      "  geom_line() +\n",
      "  geom_point()",
      if (length(time_rec$grouping_vars) > 0) paste0(" +\n  # Consider grouping by: ", paste(time_rec$grouping_vars, collapse = ", ")) else ""
    )
  }
  
 
  return(list(
    dataset_analysis = eda,
    plot_suggestions = suggestions,
    recommended_aesthetics = get_aesthetic_recommendations(eda),
    data_preprocessing_needed = get_preprocessing_suggestions(eda)
  ))
}

#' Get aesthetic recommendations based on data structure
get_aesthetic_recommendations <- function(eda) {
  aesthetics <- list()
  
  # Color recommendations
  if (eda$variable_types$n_categorical > 0) {
    cat_var <- eda$variable_types$categorical[1]
    n_categories <- eda$columns[[cat_var]]$n_unique
    
    if (n_categories <= 8) {
      aesthetics$color <- list(
        variable = cat_var,
        palette = "viridis_d",
        rationale = paste("Categorical variable with", n_categories, "categories - suitable for color mapping")
      )
    } else {
      aesthetics$color <- list(
        warning = paste("Variable", cat_var, "has", n_categories, "categories - consider filtering or grouping")
      )
    }
  }
  
  return(aesthetics)
}

#' Get data preprocessing suggestions
get_preprocessing_suggestions <- function(eda) {
  suggestions <- character(0)
  
  # Missing data
  missing_vars <- sapply(eda$columns, function(x) x$pct_missing > 0)
  if (any(missing_vars)) {
    suggestions <- c(suggestions, "Consider handling missing values in variables with NA data")
  }
  
  # Long format detection
  if (!is.null(eda$plotting_recommendations$long_format)) {
    suggestions <- c(suggestions, "Data appears to be in long format - consider pivot_wider() for some analyses")
  }
  
  return(suggestions)
}

#' Diagnostic function to troubleshoot silent_mini_eda issues
#' 
#' @param dataset_name Name of dataset to diagnose
#' @param .env Environment to check
diagnose_mini_eda_issues <- function(dataset_name, .env = .GlobalEnv) {
  cat("=== SILENT MINI-EDA DIAGNOSTIC ===\n")
  
  # Environment check
  cat("Environment check:\n")
  cat("  - Target environment:", deparse(substitute(.env)), "\n")
  cat("  - Objects in environment:", length(ls(envir = .env)), "\n")
  
  # Dataset existence
  cat("Dataset existence:\n")
  cat("  - Dataset name:", dataset_name, "\n")
  cat("  - Exists in environment:", exists(dataset_name, envir = .env), "\n")
  
  if (exists(dataset_name, envir = .env)) {
    obj <- get(dataset_name, envir = .env)
    cat("  - Object class:", paste(class(obj), collapse = ", "), "\n")
    cat("  - Is data.frame:", is.data.frame(obj), "\n")
    
    if (is.data.frame(obj)) {
      cat("  - Dimensions:", paste(dim(obj), collapse = " x "), "\n")
      n_cols_show <- min(5, ncol(obj))
      if (n_cols_show > 0) {
        cat("  - Column names:", paste(names(obj)[seq_len(n_cols_show)], collapse = ", "), 
            if(ncol(obj) > 5) "..." else "", "\n")
      }
      
      # Test problematic operations
      cat("Problematic operations test:\n")
      n_cols_test <- min(3, ncol(obj))
      if (n_cols_test > 0) {
        for (col in names(obj)[seq_len(n_cols_test)]) {
          cat("  - Column", col, ":\n")
          col_data <- obj[[col]]
          cat("    - Class:", paste(class(col_data), collapse = ", "), "\n")
          cat("    - Length:", length(col_data), "\n")
          
          # Test range operation
          if (is.numeric(col_data)) {
            tryCatch({
              r <- range(col_data, na.rm = TRUE)
              cat("    - Range: OK (", paste(r, collapse = " to "), ")\n")
            }, error = function(e) {
              cat("    - Range: FAILED -", e$message, "\n")
            })
          }
        }
      }
    }
  }
  
  cat("=== END DIAGNOSTIC ===\n")
}
