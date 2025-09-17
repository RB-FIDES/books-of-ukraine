# CACHE Manifest Validation Script
# Ensures manifests stay accurate with database reality

#' Validate CACHE manifest accuracy against actual database
#' @param manifest_path Path to CACHE-MANIFEST-*.md file
#' @param database_path Path to corresponding .sqlite database
#' @return List with validation results
validate_cache_manifest <- function(manifest_path, database_path) {
  
  # Check if files exist
  if (!file.exists(manifest_path)) {
    return(list(valid = FALSE, error = "Manifest file not found"))
  }
  if (!file.exists(database_path)) {
    return(list(valid = FALSE, error = "Database file not found"))
  }
  
  # Parse YAML frontmatter from manifest
  manifest_content <- readLines(manifest_path, warn = FALSE)
  yaml_start <- which(manifest_content == "---")[1]
  yaml_end <- which(manifest_content == "---")[2]
  
  if (is.na(yaml_start) || is.na(yaml_end)) {
    return(list(valid = FALSE, error = "No YAML frontmatter found"))
  }
  
  yaml_content <- paste(manifest_content[(yaml_start + 1):(yaml_end - 1)], collapse = "\n")
  
  # Parse YAML (simple parsing for key values)
  extract_yaml_value <- function(yaml_text, key) {
    pattern <- paste0("^", key, ":\\s*(.+)$")
    matches <- grep(pattern, strsplit(yaml_text, "\n")[[1]], value = TRUE)
    if (length(matches) > 0) {
      gsub(paste0("^", key, ":\\s*"), "", matches[1])
    } else {
      NA
    }
  }
  
  manifest_tables <- as.numeric(extract_yaml_value(yaml_content, "tables"))
  manifest_records <- as.numeric(extract_yaml_value(yaml_content, "total_records"))
  manifest_size_mb <- as.numeric(extract_yaml_value(yaml_content, "size_mb"))
  
  # Check actual database
  db <- DBI::dbConnect(RSQLite::SQLite(), database_path)
  on.exit(DBI::dbDisconnect(db))
  
  actual_tables <- length(DBI::dbListTables(db))
  actual_records <- sum(sapply(DBI::dbListTables(db), function(t) {
    DBI::dbGetQuery(db, paste("SELECT COUNT(*) as count FROM", t))$count
  }))
  actual_size_mb <- round(file.info(database_path)$size / 1024 / 1024, 2)
  
  # Validate
  issues <- c()
  if (!is.na(manifest_tables) && manifest_tables != actual_tables) {
    issues <- c(issues, paste("Table count mismatch: manifest says", manifest_tables, "but database has", actual_tables))
  }
  if (!is.na(manifest_records) && abs(manifest_records - actual_records) > 10) {
    issues <- c(issues, paste("Record count mismatch: manifest says", manifest_records, "but database has", actual_records))
  }
  if (!is.na(manifest_size_mb) && abs(manifest_size_mb - actual_size_mb) > 0.1) {
    issues <- c(issues, paste("Size mismatch: manifest says", manifest_size_mb, "MB but database is", actual_size_mb, "MB"))
  }
  
  list(
    valid = length(issues) == 0,
    issues = issues,
    actual = list(tables = actual_tables, records = actual_records, size_mb = actual_size_mb)
  )
}

#' Validate all CACHE manifests in the project
validate_all_cache_manifests <- function() {
  
  cat("🔍 VALIDATING ALL CACHE MANIFESTS...\n")
  
  # Define manifest-database pairs
  pairs <- list(
    list(manifest = "ai/CACHE-MANIFEST-0.md", database = "data-private/derived/manipulation/SQLite/books-of-ukraine-0.sqlite"),
    list(manifest = "ai/CACHE-MANIFEST-1.md", database = "data-private/derived/manipulation/SQLite/books-of-ukraine-1.sqlite"),
    list(manifest = "ai/CACHE-MANIFEST-2.md", database = "data-private/derived/manipulation/SQLite/books-of-ukraine-2.sqlite"),
    list(manifest = "ai/CACHE-MANIFEST.md", database = "data-private/derived/manipulation/SQLite/books-of-ukraine.sqlite")
  )
  
  all_valid <- TRUE
  
  for (pair in pairs) {
    cat("📋 Validating", basename(pair$manifest), "...\n")
    
    result <- validate_cache_manifest(pair$manifest, pair$database)
    
    if (result$valid) {
      cat("   ✅ VALID\n")
    } else {
      cat("   ❌ ISSUES FOUND:\n")
      if (!is.null(result$error)) {
        cat("      •", result$error, "\n")
      }
      if (!is.null(result$issues)) {
        for (issue in result$issues) {
          cat("      •", issue, "\n")
        }
      }
      all_valid <- FALSE
    }
  }
  
  if (all_valid) {
    cat("🎉 ALL CACHE MANIFESTS ARE ACCURATE!\n")
  } else {
    cat("⚠️  SOME MANIFESTS NEED UPDATES\n")
  }
  
  return(all_valid)
}

# Load required packages quietly
suppressPackageStartupMessages({
  library(DBI)
  library(RSQLite)
})
