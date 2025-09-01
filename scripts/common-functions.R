# Functions loaded by EVERY script in the project
baseSize <- 10
print_all <- function(d){ print(d,n=nrow(d) )}

`%not in%` <- Negate(`%in%`)

# Null-coalesce helper
`%||%` <- function(a, b) if (!is.null(a)) a else b

library(ggplot2)
ggplot2::theme_set(
  ggplot2::theme_bw(
  )+
    theme(
      strip.background = element_rect(fill="grey95", color = NA)
      ,panel.grid = element_line(color = "grey95")
      ,panel.border = element_rect(color = "grey80")
      ,axis.ticks = element_blank()
      ,text=element_text(size=baseSize)
    )
)
quick_save <- function(g,name,...){
  ggplot2::ggsave(
    filename = paste0(name,".jpg"),
    plot     = g,
    device   = "jpg",
    path     = prints_folder,
    # width    = width,
    # height   = height,
    # units = "cm",
    dpi      = 'retina',
    limitsize = FALSE,
    ...
  )
}

# adds neat styling to your knitr table
neat <- function(x, output_format = "html"){
  # knitr.table.format = output_format
  if(output_format == "pandoc"){
    x_t <- knitr::kable(x, format = "pandoc")
  }else{
    x_t <- x %>%
      # x %>%
      # knitr::kable() %>%
      knitr::kable(format=output_format) %>%
      kableExtra::kable_styling(
        bootstrap_options = c("striped", "hover", "condensed","responsive"),
        # bootstrap_options = c( "condensed"),
        full_width = F,
        position = "left"
      )
  }
  return(x_t)
}


# ----- database-connection-functions ----------------------------------------

#' Connect to Books of Ukraine Database
#' 
#' @description 
#' Modern standardized database connection using centralized configuration.
#' Supports different database stages for specific analytical needs.
#' This replaces the outdated config::get() approach that was causing issues.
#' 
#' @param db_type Character. Database type to connect to:
#'   - "main" (default): Final analytical database (books-of-ukraine.sqlite)
#'   - "stage_0": Core books data only (books-of-ukraine-0.sqlite)
#'   - "stage_1": Books + Ukrainian administrative data (books-of-ukraine-1.sqlite)
#'   - "stage_2": Books + admin + custom data (books-of-ukraine-2.sqlite)
#' @param config_path Character. Path to config.yml file. Default: "config.yml"
#' 
#' @return DBI database connection object
#' 
#' @examples
#' # Standard connection for analysis
#' db <- connect_books_db()
#' 
#' # Connect to specific stage for territorial analysis
#' db <- connect_books_db("stage_1")
#' 
#' # Connect to comprehensive database with all data
#' db <- connect_books_db("stage_2")
#' 
#' # Always close connection when done
#' DBI::dbDisconnect(db)
connect_books_db <- function(db_type = "main", config_path = "config.yml") {
  if (!requireNamespace("yaml", quietly = TRUE)) {
    stop("yaml package required. Install with: install.packages('yaml')")
  }
  if (!requireNamespace("DBI", quietly = TRUE)) {
    stop("DBI package required. Install with: install.packages('DBI')")
  }
  if (!requireNamespace("RSQLite", quietly = TRUE)) {
    stop("RSQLite package required. Install with: install.packages('RSQLite')")
  }
  
  # Load configuration
  if (!file.exists(config_path)) {
    stop(paste0("Configuration file not found: ", config_path))
  }
  
  config <- yaml::read_yaml(config_path)
  
  # Handle nested config structure (config$default$database vs config$database)  
  if ("default" %in% names(config)) {
    config <- config$default
  }
  
  # Get database path based on type
  db_path <- switch(db_type,
    "main" = config$database$books_of_ukraine$main,
    "stage_0" = config$database$books_of_ukraine$stage_0,
    "stage_1" = config$database$books_of_ukraine$stage_1,
    "stage_2" = config$database$books_of_ukraine$stage_2,
    stop(paste0("Unknown db_type: ", db_type, ". Use 'main', 'stage_0', 'stage_1', or 'stage_2'."))
  )
  
  if (is.null(db_path)) {
    stop(paste0("Database path not found in config for type: ", db_type))
  }
  
  # Check if database exists
  if (!file.exists(db_path)) {
    warning(paste0("Database file not found: ", db_path, 
                  "\nRun Ellis pipeline scripts to create databases."))
  }
  
  # Create connection
  DBI::dbConnect(RSQLite::SQLite(), db_path)
}

#' Get Database Path from Configuration
#' 
#' @description 
#' Utility function to get database path without creating connection.
#' Useful for file operations or when connection object not needed.
#' Updated to support all Ellis pipeline stages.
#' 
#' @param db_type Character. Database type ("main", "stage_0", "stage_1", "stage_2")
#' @param config_path Character. Path to config.yml file
#' 
#' @return Character. Full path to database file
get_db_path <- function(db_type = "main", config_path = "config.yml") {
  if (!requireNamespace("yaml", quietly = TRUE)) {
    stop("yaml package required. Install with: install.packages('yaml')")
  }
  
  config <- yaml::read_yaml(config_path)
  
  # Handle nested config structure (config$default$database vs config$database)
  if ("default" %in% names(config)) {
    config <- config$default
  }
  
  db_path <- switch(db_type,
    "main" = config$database$books_of_ukraine$main,
    "stage_0" = config$database$books_of_ukraine$stage_0,
    "stage_1" = config$database$books_of_ukraine$stage_1,
    "stage_2" = config$database$books_of_ukraine$stage_2,
    stop(paste0("Unknown db_type: ", db_type, ". Use 'main', 'stage_0', 'stage_1', or 'stage_2'."))
  )
  
  if (is.null(db_path)) {
    stop(paste0("Database path not found in config for type: ", db_type))
  }
  
  return(db_path)
}



# Function to safely convert numeric values 
safe_numeric_convert <- function(x) {
  cleaned <- as.character(x)
  cleaned <- gsub("[^0-9.\\s-]", "", cleaned)
  cleaned <- gsub("\\s+", "", cleaned)
  cleaned[cleaned == "" | cleaned == "-" | cleaned == "NULL" | 
          cleaned == "NA" | cleaned == "n/a" | is.na(cleaned)] <- "0"
  cleaned <- gsub("\\.{2,}", ".", cleaned)
  result <- suppressWarnings(as.numeric(cleaned))
  result[is.na(result)] <- 0
  return(result)
}



# ---- Silent Mini-EDA Integration ----
# Load silent mini-EDA functions for behind-the-scenes data analysis
source_silent_mini_eda <- function() {
  silent_eda_path <- "./scripts/silent-mini-eda.R"
  if (file.exists(silent_eda_path)) {
    source(silent_eda_path, local = TRUE)
    return(TRUE)
  } else {
    warning("Silent mini-EDA script not found at: ", silent_eda_path)
    return(FALSE)
  }
}

# Smart plotting assistant wrapper - loads silent mini-EDA if needed
smart_plot <- function(dataset_name, plot_intent = "explore", verbose = FALSE) {
  # Ensure silent mini-EDA functions are loaded
  if (!exists("silent_mini_eda")) {
    if (!source_silent_mini_eda()) {
      stop("Cannot load silent mini-EDA functions")
    }
  }
  
  # Source the functions into current environment
  source("./scripts/silent-mini-eda.R", local = FALSE)
  
  # Run the smart assistant
  result <- smart_ggplot_assistant(dataset_name, plot_intent)
  
  if (verbose) {
    cat("=== SMART PLOT ASSISTANT ===\n")
    cat("Dataset:", dataset_name, "\n")
    cat("Intent:", plot_intent, "\n\n")
    
    if (!is.null(result$plot_suggestions)) {
      cat("SUGGESTED PLOTS:\n")
      for (name in names(result$plot_suggestions)) {
        cat("\n", toupper(name), ":\n")
        cat(result$plot_suggestions[[name]], "\n")
      }
    }
    
    if (!is.null(result$recommended_aesthetics$color)) {
      cat("\nCOLOR MAPPING RECOMMENDATION:\n")
      if (!is.null(result$recommended_aesthetics$color$variable)) {
        cat("Use", result$recommended_aesthetics$color$variable, "for color aesthetic\n")
        cat("Reason:", result$recommended_aesthetics$color$rationale, "\n")
      } else {
        cat("Warning:", result$recommended_aesthetics$color$warning, "\n")
      }
    }
    
    if (length(result$data_preprocessing_needed) > 0) {
      cat("\nDATA PREPROCESSING SUGGESTIONS:\n")
      for (suggestion in result$data_preprocessing_needed) {
        cat("- ", suggestion, "\n")
      }
    }
  }
  
  # Return the assistant's raw result (informational list). Do not attach ggplot objects.
  return(result)
}

 