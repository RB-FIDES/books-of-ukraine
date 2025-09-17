# Ellis Script 2 - Extra/Custom Data Integration  
# This script integrates custom, user-contributed data with the core pipeline:
# 1. Imports Stage 1 database (from 1-ellis-ua-admin.R)
# 2. Processes additional custom data sources (configured in extra-data-config.R)
# 3. Creates Stage 2 database with extended analytics
# 4. Maintains separation between core stable data and custom contributions
#
# 🎯 USER-FRIENDLY: To add new custom data sources, see extra-data-config.R
# 📚 DOCUMENTATION: See guides/custom-data-guide.md for complete step-by-step guide

# Clear memory
rm(list = ls(all.names = TRUE))
cat("\014") # Clear console
cat("Working directory: ", getwd()) # Must be set to Project Directory

# ---- load-packages -----------------------------------------------------------
library(magrittr)
library(dplyr)     # data wrangling
library(tidyr)     # data wrangling
library(stringr)   # strings
library(purrr)     # functional programming
library(DBI)       # database interface
library(RSQLite)   # SQLite database
library(googlesheets4) # Google Sheets integration
library(janitor)   # tidy data

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
base::source("./scripts/operational-functions.R") # project-level

# Load modular extra data processing system
source("./manipulation/support/extra-data-config.R")      # Configuration for custom data sources  
source("./manipulation/support/extra-data-functions.R")   # Processing functions for different data types

# ---- declare-globals ---------------------------------------------------------
local_root <- "./manipulation/"
local_data <- paste0(local_root, "data-local/")
if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

data_private_derived <- "./data-private/derived/manipulation/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

# Database paths for stage 2
stage_1_db_path <- "data-private/derived/manipulation/SQLite/books-of-ukraine-1.sqlite"
stage_2_db_path <- "data-private/derived/manipulation/SQLite/books-of-ukraine-2.sqlite"

# 🎯 CUSTOM DATA SOURCES: Configured in extra-data-config.R
# Users can add new data sources there without modifying this script

# ---- declare-functions -------------------------------------------------------

# Function to safely convert numeric values (preserved from core pipeline)
safe_numeric_convert <- function(x) {
  # Remove Ukrainian thousands separators, handle decimals, convert to numeric
  cleaned <- str_replace_all(x, "[\\s,]", "")  # Remove spaces and commas
  cleaned <- str_replace(cleaned, ",", ".")    # Convert decimal separator
  as.numeric(cleaned)                          # Convert to numeric
}

# ---- establish-database-connections ------------------------------------------
# Connect to Stage 1 database (input)
stage_1_db <- dbConnect(RSQLite::SQLite(), stage_1_db_path)

# Create Stage 2 database (output)
stage_2_db <- dbConnect(RSQLite::SQLite(), stage_2_db_path)

# ---- copy-stage-1-data -------------------------------------------------------
cat("📋 COPYING STAGE 1 DATA TO STAGE 2...\n")

# Get all tables from Stage 1
stage_1_tables <- dbListTables(stage_1_db)

# Copy all tables to Stage 2
for (table_name in stage_1_tables) {
  cat("   📄 Copying table:", table_name, "\n")
  
  # Read table from Stage 1
  table_data <- dbReadTable(stage_1_db, table_name)
  
  # Write table to Stage 2
  dbWriteTable(stage_2_db, table_name, table_data, overwrite = TRUE)
  
  cat("   ✓ Copied:", nrow(table_data), "records\n")
}

cat("✅ STAGE 1 DATA COPIED TO STAGE 2\n\n")

# ------------------------------------------------------------------ EXTRA DATA PROCESSING ----------------------------------------------------------------------------------------------------------------------------------------------

# ---- load-extra-data ---------------------------------------------------------
cat("📊 LOADING EXTRA/CUSTOM DATA SOURCES...\n")

# Get active data sources from configuration
active_sources <- extra_data_sources[sapply(extra_data_sources, function(x) x$active)]

if (length(active_sources) == 0) {
  cat("   ℹ️  No active extra data sources found in configuration\n")
  cat("   💡 To add custom data, edit extra-data-config.R\n")
} else {
  cat("   📋 Found", length(active_sources), "active extra data source(s):\n")
  for (source_name in names(active_sources)) {
    source_info <- active_sources[[source_name]]
    cat("      •", source_info$name, "(", source_info$data_type, ")\n")
  }
}

cat("\n")

# ---- process-extra-sources --------------------------------------------------
cat("🔧 PROCESSING EXTRA DATA SOURCES...\n")

# Initialize list to store processed tables
processed_extra_tables <- list()

# Process each active data source
for (source_name in names(active_sources)) {
  source_config <- active_sources[[source_name]]
  
  cat("🔗 Processing data source:", source_config$name, "\n")
  cat("   URL:", source_config$url, "\n")
  cat("   Type:", source_config$data_type, "\n")
  
  # Connect to Google Sheets
  tryCatch({
    sheet_info <- googlesheets4::gs4_get(source_config$url)
    available_sheets <- sheet_info$sheets$name
    
    cat("   📊 Available sheets:", paste(available_sheets, collapse = ", "), "\n")
    
    # Process each expected sheet for this data source
    expected_sheets <- source_config$processing_notes$expected_sheets %||% available_sheets
    
    for (sheet_name in expected_sheets) {
      if (!sheet_name %in% available_sheets) {
        cat("   ⚠️  Sheet", sheet_name, "not found. Skipping.\n")
        next
      }
      
      cat("   📥 Loading sheet:", sheet_name, "\n")
      
      # Load sheet data
      sheet_data <- googlesheets4::read_sheet(source_config$url, sheet = sheet_name)
      cat("      ✓ Loaded:", nrow(sheet_data), "rows ×", ncol(sheet_data), "columns\n")
      
      # Determine table key (use mapping if provided, otherwise use source name)
      table_key <- if (!is.null(source_config$processing_notes$sheet_mapping) &&
                      sheet_name %in% names(source_config$processing_notes$sheet_mapping)) {
        source_config$processing_notes$sheet_mapping[[sheet_name]]
      } else {
        source_name
      }
      
      # Process the sheet data using modular functions
      processed_data <- process_sheet_data(sheet_data, source_config, sheet_name, table_key)
      
      if (!is.null(processed_data) && nrow(processed_data) > 0) {
        processed_extra_tables[[table_key]] <- processed_data
        cat("      ✅ Processed:", nrow(processed_data), "records for table:", table_key, "\n")
      } else {
        cat("      ❌ Failed to process sheet:", sheet_name, "\n")
      }
    }
    
  }, error = function(e) {
    cat("   ❌ Error processing data source", source_name, ":", e$message, "\n")
  })
  
  cat("\n")
}

if (length(processed_extra_tables) == 0) {
  cat("⚠️  No extra data processed. Stage 2 will be identical to Stage 1.\n")
} else {
  cat("✅ EXTRA DATA PROCESSING COMPLETE\n")
  cat("   📊 Processed", length(processed_extra_tables), "extra table(s):", 
      paste(names(processed_extra_tables), collapse = ", "), "\n")
}

cat("\n")

# ---- save-extra-tables-to-database ------------------------------------------
cat("💾 SAVING EXTRA TABLES TO STAGE 2 DATABASE...\n")

# Save each processed extra table to the database
for (table_name in names(processed_extra_tables)) {
  table_data <- processed_extra_tables[[table_name]]
  
  if (nrow(table_data) > 0) {
    # Write to database with systematic naming: ds_[table_key]
    db_table_name <- paste0("ds_", table_name)
    
    cat("💾 Saving table:", db_table_name, "\n")
    dbWriteTable(stage_2_db, db_table_name, table_data, overwrite = TRUE)
    cat("   ✓ Saved:", nrow(table_data), "records to", db_table_name, "\n")
  }
}

if (length(processed_extra_tables) > 0) {
  cat("✅ EXTRA TABLES SAVED TO DATABASE\n")
} else {
  cat("   ℹ️  No extra tables to save\n")
}

cat("\n")

# ---- database-documentation --------------------------------------------------
cat("📋 STAGE 2 DATABASE DOCUMENTATION:\n")

# List all tables in the Stage 2 database
stage_2_tables <- dbListTables(stage_2_db)
cat("📊 Tables in Stage 2 database:\n")

total_records <- 0
for (table_name in stage_2_tables) {
  record_count <- dbGetQuery(stage_2_db, paste("SELECT COUNT(*) as count FROM", table_name))$count
  total_records <- total_records + record_count
  
  # Mark extra/custom tables
  is_extra_table <- str_detect(table_name, "^ds_") && 
                   str_replace(table_name, "^ds_", "") %in% names(processed_extra_tables)
  table_type <- ifelse(is_extra_table, " [EXTRA/CUSTOM]", " [CORE]")
  cat(sprintf("  📄 %-25s %8d records%s\n", table_name, record_count, table_type))
}

cat(sprintf("\n📊 TOTAL RECORDS IN STAGE 2 DATABASE: %d\n", total_records))

# Show database file size
db_size <- file.info(stage_2_db_path)$size / (1024^2)  # Convert to MB
cat(sprintf("💾 STAGE 2 DATABASE SIZE: %.2f MB\n", db_size))

# ---- user-guidance -----------------------------------------------------------
cat("\n🎯 USER GUIDANCE:\n")
cat("================\n")

if (length(active_sources) == 0) {
  cat("💡 TO ADD CUSTOM DATA:\n")
  cat("   1. Edit 'manipulation/support/extra-data-config.R'\n")
  cat("   2. Add your data source configuration\n") 
  cat("   3. Set active = TRUE for your data source\n")
  cat("   4. Re-run this script (2-ellis-extra.R)\n")
} else {
  cat("✅ CUSTOM DATA SOURCES ACTIVE:\n")
  for (source_name in names(active_sources)) {
    source_info <- active_sources[[source_name]]
    records <- if (source_name %in% names(processed_extra_tables)) {
      nrow(processed_extra_tables[[source_name]])
    } else {
      0
    }
    cat(sprintf("   • %-15s: %4d records (%s)\n", source_name, records, source_info$data_type))
  }
}

cat("\n📚 DOCUMENTATION:\n")
cat("   • Configuration: manipulation/support/extra-data-config.R\n")
cat("   • Functions: manipulation/support/extra-data-functions.R\n")
cat("   • Complete guide: guides/custom-data-guide.md\n")
cat("   • Pipeline guide: manipulation/README.md\n")

# ---- generate-cache-manifest-2 ----------------------------------------------
cat("\n📝 GENERATING STAGE 2 CACHE MANIFEST...\n")

# Generate CACHE-MANIFEST-2.md
manifest_content <- paste0(
  "# CACHE Manifest - Books of Ukraine Stage 2 Database\n\n",
  "**Generated:** ", Sys.time(), "\n",
  "**Database:** books-of-ukraine-2.sqlite\n",
  "**Pipeline Stage:** Modular Custom Data Integration\n",
  "**Total Tables:** ", length(dbListTables(stage_2_db)), "\n\n",
  "## 📊 Stage 2 Database Architecture\n\n",
  "Stage 2 adds modular custom data sources with **bilingual Ukrainian/English support** to the comprehensive pipeline.\n\n",
  "### 🌍 Bilingual Data Integration\n\n",
  "- **Input Flexibility**: Accepts Ukrainian OR English column names\n",
  "- **Standardized Output**: All data converted to English for pipeline consistency\n",
  "- **Automatic Translation**: Ukrainian terms like 'Показник' → 'pokaznik', 'Територія' → 'teritoria'\n",
  "- **User-Friendly**: No manual translation required by data contributors\n\n",
  "### 🏗️ Architecture Overview\n\n",
  "```\n",
  "STAGE 1 DATABASE (All tables)     CUSTOM DATA SOURCES\n",
  "┌─────────────────────────────┐   ┌─────────────────────┐\n",
  "│ fact_book_publications      │   │ Google Sheets       │\n",
  "│ dim_* (years, categories)   │ + │ (Ukrainian/English) │\n",
  "│ fact_hromadas              │   │ Configuration-driven │\n",
  "│ ua_oblasts_aggregated      │   │ User-contributed    │\n",
  "└─────────────────────────────┘   └─────────────────────┘\n",
  "                    ↓\n",
  "            STAGE 2 DATABASE\n",
  "        (Complete + Custom Data)\n",
  "```\n\n",
  "### 🔗 Integration Strategy\n\n",
  "**PRESERVED TABLES** (from Stage 1):\n",
  "- All core book publication data\n",
  "- Ukrainian administrative data\n",
  "- Complete dimensional structure\n\n",
  "**CUSTOM TABLES** (added in Stage 2):\n",
  "- Prefix: `ds_` (dataset)\n",
  "- Bilingual input support\n",
  "- Configuration-driven processing\n",
  "- User-friendly validation\n\n"
)

# Get custom tables info
custom_tables <- dbListTables(stage_2_db)[grepl("^ds_", dbListTables(stage_2_db))]
if (length(custom_tables) > 0) {
  manifest_content <- paste0(manifest_content, "## 📋 Custom Data Tables\n\n")
  for (table in custom_tables) {
    record_count <- dbGetQuery(stage_2_db, paste("SELECT COUNT(*) as count FROM", table))$count
    manifest_content <- paste0(manifest_content, "- **", table, "**: ", record_count, " records\n")
  }
  manifest_content <- paste0(manifest_content, "\n")
}

# Write manifest
writeLines(manifest_content, "data-public/metadata/CACHE-MANIFEST-2.md")
cat("   ✓ Generated Stage 2 manifest at: data-public/metadata/CACHE-MANIFEST-2.md\n")

# ---- cleanup -----------------------------------------------------------------
# Close database connections
dbDisconnect(stage_1_db)
dbDisconnect(stage_2_db)

cat("\n✅ ELLIS SCRIPT 2 (EXTRA DATA INTEGRATION) COMPLETE\n")
cat("🎯 Stage 2 database ready for analytical processing in last-ellis.R\n")
cat("💡 To add more custom data sources, edit extra-data-config.R and re-run this script\n")
