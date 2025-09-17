# test-config-db-connection.R
# Test script for configuration-driven database connections
# This script demonstrates the standardized approach to database access

# ---- load-packages -----------------------------------------------------------
library(dplyr)
library(DBI)
library(RSQLite)

# ---- load-sources ------------------------------------------------------------
source("scripts/common-functions.R")

# ---- test-connections --------------------------------------------------------
cat("=== Testing Config-Driven Database Connections ===\n\n")

# Test 1: Connect to default analytical database
cat("1. Testing default database connection...\n")
tryCatch({
  db_main <- connect_books_db("main")
  tables_main <- DBI::dbListTables(db_main)
  cat("   ✓ Connected to main database successfully\n")
  cat("   ✓ Found", length(tables_main), "tables:", paste(tables_main[1:3], collapse = ", "), "...\n")
  
  # Test reading a table
  if ("fact_book_publications" %in% tables_main) {
    row_count <- DBI::dbGetQuery(db_main, "SELECT COUNT(*) as n FROM fact_book_publications")$n
    cat("   ✓ fact_book_publications table contains", row_count, "rows\n")
  }
  
  DBI::dbDisconnect(db_main)
  cat("   ✓ Connection closed successfully\n\n")
}, error = function(e) {
  cat("   ✗ Error:", e$message, "\n\n")
})

# Test 2: Connect to Stage 1 database (with Ukrainian admin data)
cat("2. Testing Stage 1 database connection...\n")
tryCatch({
  db_stage1 <- connect_books_db("stage_1")
  tables_stage1 <- DBI::dbListTables(db_stage1)
  cat("   ✓ Connected to Stage 1 database successfully\n")
  cat("   ✓ Found", length(tables_stage1), "tables\n")
  
  # Check for Ukrainian admin tables
  ua_tables <- tables_stage1[grepl("^ua_|oblasts|hromadas", tables_stage1)]
  if (length(ua_tables) > 0) {
    cat("   ✓ Ukrainian admin tables found:", paste(ua_tables, collapse = ", "), "\n")
  }
  
  DBI::dbDisconnect(db_stage1)
  cat("   ✓ Connection closed successfully\n\n")
}, error = function(e) {
  cat("   ✗ Error:", e$message, "\n\n")
})

# Test 3: Test utility function for getting database paths
cat("3. Testing database path utility function...\n")
tryCatch({
  main_path <- get_db_path("main")
  stage1_path <- get_db_path("stage_1")
  stage0_path <- get_db_path("stage_0")
  
  cat("   ✓ Main database path:", main_path, "\n")
  cat("   ✓ Stage 1 database path:", stage1_path, "\n") 
  cat("   ✓ Stage 0 database path:", stage0_path, "\n")
  
  # Check file sizes
  if (file.exists(main_path)) {
    size_mb <- round(file.size(main_path) / 1024^2, 2)
    cat("   ✓ Main database size:", size_mb, "MB\n")
  }
  
}, error = function(e) {
  cat("   ✗ Error:", e$message, "\n")
})

cat("\n=== Configuration Test Complete ===\n")
