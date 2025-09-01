# demonstration-smart-plotting.R
# A demonstration of the Silent Mini-EDA intelligent plotting system
# Created: 2025-08-31
# Purpose: Show how to use smart_plot() function for automated visualization

# This file demonstrates the complete workflow for using the silent mini-EDA system
# which provides intelligent plotting recommendations based on data types and user intent

# ---- load-silent-eda ----
# Load intelligent plotting system
cat("Loading Silent Mini-EDA system...\n")

# Load silent mini-EDA for intelligent plotting
if (file.exists("./scripts/silent-mini-eda.R")) {
  source("./scripts/silent-mini-eda.R")
  source("./scripts/common-functions.R") 
  cat("✅ Silent Mini-EDA system loaded successfully\n")
} else {
  stop("❌ Silent Mini-EDA files not found. Ensure scripts/silent-mini-eda.R exists.")
}

# ---- demo-setup ----
# Load required libraries
library(dplyr)
library(ggplot2)

# Load project database if available
if (file.exists("data-private/derived/manipulation/SQLite/books-of-ukraine.sqlite")) {
  library(DBI)
  library(RSQLite)
  con <- dbConnect(SQLite(), "data-private/derived/manipulation/SQLite/books-of-ukraine.sqlite")
  cat("✅ Connected to books-of-ukraine database\n")
} else {
  cat("ℹ️ Database not found, using built-in demo data\n")
  con <- NULL
}

# ---- demo-basic-usage ----
cat("\n=== DEMO 1: Basic Usage with Built-in Data ===\n")

# Demonstrate with mtcars dataset
cat("Analyzing mtcars dataset:\n")
mtcars_minieda <- silent_mini_eda("mtcars", verbose = TRUE)
cat("Result type:", class(mtcars_minieda), "\n")

# Use smart_plot function for specific visualizations
cat("\nCreating smart plot - scatter relationship:\n")
plot1_prep <- smart_plot("mtcars", "relationship between mpg and wt")
# Inspect the recommendation object returned by smart_plot()
print(names(plot1_prep))
if (!is.null(plot1_prep$plot_suggestions)) print(plot1_prep$plot_suggestions)
if (!is.null(plot1_prep$recommended_aesthetics)) print(plot1_prep$recommended_aesthetics)

cat("\nCreating smart plot - distribution:\n")
plot2_prep <- smart_plot("mtcars", "distribution of mpg")
print(names(plot2_prep))
if (!is.null(plot2_prep$plot_suggestions)) print(plot2_prep$plot_suggestions)

# ---- demo-project-data ----
if (!is.null(con)) {
  cat("\n=== DEMO 2: Project-Specific Usage ===\n")
  
  # Get available tables
  tables <- dbListTables(con)
  cat("Available tables:", paste(tables, collapse = ", "), "\n")
  
  if ("book" %in% tables) {
    # Load book data
    ds_book <- dbGetQuery(con, "SELECT * FROM book LIMIT 1000")
    cat("Loaded", nrow(ds_book), "book records\n")
    
    # Demonstrate smart plotting with project data
    cat("\nAnalyzing language distribution:\n")
    if ("language_book" %in% names(ds_book)) {
      plot3 <- smart_plot("ds_book", "distribution of language_book")
      print(plot3)
    }
    
    cat("\nAnalyzing temporal trends:\n")
    if ("year_publication" %in% names(ds_book)) {
      plot4 <- smart_plot("ds_book", "time trends of year_publication")
      print(plot4)
    }
    
    # Demonstrate the intelligent analysis
    cat("\nFull intelligent analysis of book data:\n")
    result_books <- silent_mini_eda("ds_book", verbose = TRUE)
  }
  
  # Clean up
  dbDisconnect(con)
  cat("✅ Database connection closed\n")
}

# ---- demo-advanced-features ----
cat("\n=== DEMO 3: Advanced Features ===\n")

# Show how the system handles different data types
cat("Testing with iris dataset (mixed data types):\n")
result_iris <- silent_mini_eda("iris", verbose = TRUE)

# Demonstrate specific plot requests
cat("\nSpecific visualization requests:\n")
plot5 <- smart_plot("iris", "comparison between species")
print(plot5)

plot6 <- smart_plot("iris", "correlation between sepal length and width")
print(plot6)

# ---- demo-summary ----
cat("\n=== DEMONSTRATION COMPLETE ===\n")
cat("The Silent Mini-EDA system provides:\n")
cat("• Automatic data type detection\n")
cat("• Intelligent plot recommendations\n")
cat("• Natural language plot requests\n")
cat("• Integration with project workflows\n")
cat("• Verbose feedback for understanding decisions\n")

cat("\nKey functions demonstrated:\n")
cat("• silent_mini_eda(dataset_name, verbose=TRUE) - Full analysis\n")
cat("• smart_plot(dataset_name, intent) - Specific visualizations\n")

cat("\n✅ Demonstration completed successfully!\n")
