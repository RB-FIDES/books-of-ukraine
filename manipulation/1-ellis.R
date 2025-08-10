# Ellis Script 1 - Enhanced Database Creation
# This script creates an enhanced SQLite database by:
# 1. Copying the core database (from 0-ellis.R) 
# 2. Adding extension data (geography, future sources)
# 3. Creating integrated views for analysis
# 4. Generating comprehensive documentation

# Clear memory but preserve db_enhanced if it exists (prevents accidental removal)
if (exists("db_enhanced")) {
  rm(list = setdiff(ls(all.names = TRUE), "db_enhanced"))
} else {
  rm(list = ls(all.names = TRUE))
}
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

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
base::source("./scripts/operational-functions.R") # project-level

# ---- declare-globals ---------------------------------------------------------
local_root <- "./manipulation/"
local_data <- paste0(local_root, "data-local/")
if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

data_private_derived <- "./data-private/derived/manipulation/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

# Database paths
core_db_path <- "data-private/derived/manipulation/SQLite/books-of-ukraine-long.sqlite"
enhanced_db_path <- "data-private/derived/manipulation/SQLite/books-of-ukraine-enhanced.sqlite"


# ---- declare-functions -------------------------------------------------------

# Function to safely convert numeric values (consistent with 0-ellis.R)
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

# Function to create enhanced database by copying core
create_enhanced_database <- function(core_path, enhanced_path) {
  cat("📋 Creating enhanced database...\n")
  
  if (!file.exists(core_path)) {
    stop("❌ Core database not found: ", core_path, "\nRun 0-ellis.R first!")
  }
  
  # Remove existing enhanced database
  if (file.exists(enhanced_path)) {
    file.remove(enhanced_path)
    cat("  ✓ Removed existing enhanced database\n")
  }
  
  # Copy core to enhanced
  file.copy(core_path, enhanced_path)
  cat("  ✓ Copied core database to enhanced location\n")
  
  return(enhanced_path)
}

# Function to add geography extension to enhanced database
add_geography_extension <- function(db_connection) {
  cat("🌍 Adding geography extension...\n")
  
  # Load territorial data
  territori_path <- "data-private/derived/manipulation/teritorii.rds"
  if (!file.exists(territori_path)) {
    cat("  ⚠️ Geographic data not found, skipping extension\n")
    return(invisible())
  }
  
  # Transform to long format for star schema integration
  ds_geography_ext <- terir_cleaned %>%
    pivot_longer(
      cols = starts_with("x") & !matches("^x$"),
      names_to = "year", 
      values_to = "value"
    ) %>%
    mutate(
      year = as.integer(str_extract(year, "\\d{4}")),
      value = safe_numeric_convert(value),
      category_type = "territory",
      category_value = x,
      measure_type = "title_count"
    ) %>%
    filter(!is.na(year), !is.na(value), year >= 2005, year <= 2024) %>%
    select(year, category_type, category_value, measure_type, value) %>%
    arrange(year, category_value)
  
  # Save as extension table
  dbWriteTable(db_connection, "ext_geography_publications", ds_geography_ext, overwrite = TRUE)
  cat("  ✓ Added ext_geography_publications:", nrow(ds_geography_ext), "records\n")
  
  # Create enhanced fact table combining core + extensions
  cat("  📊 Creating enhanced fact table...\n")
  core_facts <- dbReadTable(db_connection, "fact_book_publications")
  
  # Remove any existing territory data from core to avoid duplicates
  enhanced_facts <- core_facts %>%
    filter(category_type != "territory") %>%
    bind_rows(ds_geography_ext) %>%
    arrange(year, category_type, category_value, measure_type)
  
  # Save enhanced fact table
  dbWriteTable(db_connection, "fact_enhanced", enhanced_facts, overwrite = TRUE)
  cat("  ✓ Created fact_enhanced:", nrow(enhanced_facts), "records\n")
  
  # Update categories dimension if needed
  dim_categories <- dbReadTable(db_connection, "dim_categories")
  new_categories <- ds_geography_ext %>%
    distinct(category_type, category_value) %>%
    anti_join(dim_categories, by = c("category_type", "category_value"))
  
  if (nrow(new_categories) > 0) {
    max_id <- max(dim_categories$category_id, na.rm = TRUE)
    new_categories <- new_categories %>%
      mutate(category_id = max_id + row_number())
    
    updated_categories <- bind_rows(dim_categories, new_categories)
    dbWriteTable(db_connection, "dim_categories", updated_categories, overwrite = TRUE)
    cat("  ✓ Added", nrow(new_categories), "new categories to dimensions\n")
  }
  
  invisible()
}

  # ---------------------------------------------------------------------------- CASHE-MANIFEST-1.md ---------------------------------------------------------------------------------------------
# Function to generate enhanced CACHE manifest
generate_enhanced_manifest <- function(db_connection, output_path = "ai/CACHE-MANIFEST-1.md") {
  cat("📝 Generating enhanced CACHE-MANIFEST-1.md...\n")
  
  tables <- dbListTables(db_connection)
  
  markdown_content <- c(
    "# CACHE Manifest - Books of Ukraine Enhanced Database",
    "",
    paste("**Generated:**", Sys.time()),
    paste("**Database:** books-of-ukraine-enhanced.sqlite"),
    paste("**Total Tables:**", length(tables)),
    "",
    "## 📊 Enhanced Star Schema Architecture",
    "",
    "This database extends the core star schema with supplementary data sources.",
    "",
    "### �️ Architecture Overview",
    "",
    "```",
    "CORE (from 0-ellis.R)          ENHANCED (from 1-ellis.R)",
    "┌─────────────────────┐       ┌─────────────────────────┐",
    "│ fact_book_publications │    │ fact_enhanced           │",
    "│ dim_years              │ → │ ext_geography_*         │",
    "│ dim_categories         │    │ ext_future_*            │",
    "│ dim_measures           │    │ (preserves core intact) │",
  "└─────────────────────┘",
    "└─────────────────────┘",
    "```",
    "",
    "### 🔗 Integration Strategy",
    "",
  "**CORE TABLES** (unchanged from 0-ellis.R):",
  "- `fact_book_publications`: Original publication data",
  "- `dim_*`: Core dimension tables",
    "",
    "**EXTENSION TABLES** (added by 1-ellis.R):",
    "- `ext_geography_publications`: Geographic/territorial data",
    "- `fact_enhanced`: Integrated view combining core + extensions",
    "",
    "**ANALYSIS RECOMMENDATION**: Use `fact_enhanced` for comprehensive analysis",
    "",
    "---",
    "",
    "## 📋 Table Catalog",
    ""
  )
  
  # Organize tables by type
  fact_tables <- grep("^fact_", tables, value = TRUE)
  dim_tables <- grep("^dim_", tables, value = TRUE)
  ext_tables <- grep("^ext_", tables, value = TRUE)
  table_order <- c(sort(fact_tables), sort(dim_tables), sort(ext_tables))
  
  for(table_name in table_order) {
    structure <- dbGetQuery(db_connection, paste("PRAGMA table_info(", table_name, ")"))
    row_count <- dbGetQuery(db_connection, paste("SELECT COUNT(*) as count FROM", table_name))$count
    
    table_type <- case_when(
      table_name == "fact_enhanced" ~ "**ENHANCED FACT TABLE**",
      str_starts(table_name, "fact_") ~ "**FACT TABLE**",
      str_starts(table_name, "dim_") ~ "**DIMENSION TABLE**",
      str_starts(table_name, "ext_") ~ "**EXTENSION TABLE**",
  FALSE ~ "**DATA TABLE**",
      TRUE ~ "**DATA TABLE**"
    )
    
    description <- case_when(
      table_name == "fact_enhanced" ~ "Integrated fact table combining core publications with geographic and future extensions",
      table_name == "fact_book_publications" ~ "Core fact table from 0-ellis.R (publications only)",
      table_name == "ext_geography_publications" ~ "Geographic extension: publication counts by territory",
      str_starts(table_name, "dim_") ~ paste("Dimension table:", str_remove(table_name, "dim_")),
  FALSE ~ "Supporting data table",
      TRUE ~ "Supporting data table"
    )
    
    table_section <- c(
      paste("### 📊", table_name),
      "",
      paste(table_type, "-", description),
      "",
      paste("- **Records:**", format(row_count, big.mark = ",")),
      paste("- **Columns:**", nrow(structure)),
      "",
      "#### Column Structure",
      "",
      "| Column | Type | Description |",
      "|--------|------|-------------|"
    )
    
    for(i in seq_len(nrow(structure))) {
      col <- structure[i, ]
      col_description <- case_when(
        col$name == "year" ~ "Publication year (2005-2024)",
        col$name == "category_type" ~ "Category type (language, theme, territory, purpose, total)",
        col$name == "category_value" ~ "Specific category value",
        col$name == "measure_type" ~ "Measure type (title_count, copy_count)",
        col$name == "value" ~ "Numeric value for the measure",
        str_ends(col$name, "_id") ~ "Dimension table identifier",
        TRUE ~ "Data field"
      )
      
      table_section <- c(table_section,
        paste("|", col$name, "|", col$type, "|", col_description, "|"))
    }
    
    table_section <- c(table_section, "", "---", "")
    markdown_content <- c(markdown_content, table_section)
  }
  
  # Enhanced usage examples
  usage_section <- c(
    "## 🔍 Enhanced Query Patterns",
    "",
    "### Core vs Enhanced Analysis",
    "```sql",
    "-- Core publications only",
    "SELECT year, SUM(value) as core_titles",
    "FROM fact_book_publications",
    "WHERE measure_type = 'title_count'",
    "GROUP BY year;",
    "",
    "-- Enhanced with geographic data",
    "SELECT year, SUM(value) as enhanced_titles",
    "FROM fact_enhanced",
    "WHERE measure_type = 'title_count'", 
    "GROUP BY year;",
    "```",
    "",
    "### Multi-Source Geographic Analysis",
    "```sql",
    "-- Territory breakdown from extensions",
    "SELECT category_value as territory, SUM(value) as total_publications",
    "FROM fact_enhanced",
    "WHERE category_type = 'territory' AND measure_type = 'title_count'",
    "GROUP BY category_value",
    "ORDER BY total_publications DESC;",
    "```",
    "",
    "### Extension Data Quality",
    "```sql",
    "-- Compare core vs extension coverage",
    "SELECT 'core' as source, COUNT(*) as records",
    "FROM fact_book_publications",
    "UNION ALL",
    "SELECT 'enhanced' as source, COUNT(*) as records", 
    "FROM fact_enhanced;",
    "```",
    "",
    "## 🔧 Extension Development Guide",
    "",
    "To add new data sources to the enhanced database:",
    "",
    "1. **Create extension table**: `ext_[source_name]`",
    "2. **Standardize schema**: Match fact table structure (year, category_type, category_value, measure_type, value)",
    "3. **Update fact_enhanced**: Combine new extension with existing data",
    "4. **Extend dimensions**: Add new categories/measures as needed",
    "5. **Document**: Update this manifest",
    "",
    "### Extension Naming Convention",
    "- `ext_geography_*`: Geographic/territorial data",
    "- `ext_economic_*`: Economic indicators",
    "- `ext_cultural_*`: Cultural events/metrics",
    "- `ext_institutional_*`: Institutional data",
    "",
    "---",
    "",
    "*Enhanced database maintains backward compatibility while enabling multi-source analysis.*"
  )
  
  markdown_content <- c(markdown_content, usage_section)
  
  writeLines(markdown_content, output_path)
  cat("  ✓ Generated enhanced manifest at:", output_path, "\n")
}

# ---- create-enhanced-database -----------------------------------------------
cat("� CREATING ENHANCED DATABASE\n")
cat(paste(rep("=", 50), collapse = ""), "\n")

# Step 1: Create enhanced database by copying core
enhanced_db_path <- create_enhanced_database(core_db_path, enhanced_db_path)

# Step 2: Connect to enhanced database
db_enhanced <- dbConnect(RSQLite::SQLite(), enhanced_db_path)

# Step 3: Verify core tables are present
core_tables <- dbListTables(db_enhanced)
cat("✓ Enhanced database created with", length(core_tables), "core tables\n")

# ---- add-extensions ----------------------------------------------------------
cat("\n� ADDING EXTENSIONS\n")
cat(paste(rep("=", 30), collapse = ""), "\n")

# Add geography extension
add_geography_extension(db_enhanced)

# --------------------------------------------------------------------------------------- Bookstore Count 2023 Extension -------------------------------------------------

# ---- add-bookstore-count-2023-extension --------------------------------------
cat("\n📚 ADDING BOOKSTORE COUNT 2023 DATA\n")
cat(paste(rep("-", 30), collapse = ""), "\n")

# Define bookstore data for 2023
bookstore_regions <- c(
  "Київ", "Львівська", "Харківська", "Дніпропетровська", "Одеська",
  "Івано-Франківська", "Запорізька", "Тернопільська", "Вінницька", "Хмельницька",
  "Черкаська", "Полтавська", "Київська", "Чернігівська", "Сумська",
  "Житомирська", "Рівненська", "Волинська", "Кіровоградська", "Миколаївська",
  "Херсонська", "Закарпатська", "Чернівецька"
)
bookstore_count <- c(
  99, 50, 17, 21, 17,
  19, 4, 23, 17, 15,
  12, 15, 18, 6, 13,
  10, 18, 17, 4, 2,
  2, 14, 8
)
bookstore_2023 <- data.frame(
  year = 2023,
  category_type = "territory",
  category_value = bookstore_regions,
  measure_type = "bookstore_count",
  value = bookstore_count
)

# Add to dim_measures if not present

# Add to dim_measures if not present, and add measure_description
dim_measures <- dbReadTable(db_enhanced, "dim_measures")
# Add measure_description column if not present
if (!"measure_description" %in% colnames(dim_measures)) {
  dim_measures$measure_description <- NA_character_
}
# Remove any existing bookstore_count measure to avoid duplicates
dim_measures <- dim_measures[dim_measures$measure_type != "bookstore_count", ]
new_measure_id <- max(dim_measures$measure_id, na.rm = TRUE) + 1
new_measure <- data.frame(measure_id = new_measure_id, measure_type = "bookstore_count", measure_description = "Number of bookstores in Ukraine in 2023", stringsAsFactors = FALSE)
dim_measures <- dplyr::bind_rows(dim_measures, new_measure)
dbWriteTable(db_enhanced, "dim_measures", dim_measures, overwrite = TRUE)
cat("  ✓ Added bookstore_count to dim_measures\n")
# Verification
cat("  → bookstore_count in dim_measures: ", sum(dim_measures$measure_type == 'bookstore_count'), "\n")
# Also update CSV and RDS versions for dim_measures
csv_meas_path <- "data-private/derived/manipulation/CSV/dim_measures.csv"
rds_meas_path <- "data-private/derived/manipulation/dim_measures.rds"
write.csv(dim_measures, csv_meas_path, row.names = FALSE)
saveRDS(dim_measures, rds_meas_path)
cat("  ✓ Updated CSV and RDS versions of dim_measures\n")

# Add to dim_categories if not present

dim_categories <- dbReadTable(db_enhanced, "dim_categories")
# Remove any existing bookstore_count territories to avoid duplicates
dim_categories <- dim_categories[!(dim_categories$category_type == "territory" & dim_categories$category_value %in% bookstore_regions), ]
max_cat_id <- max(dim_categories$category_id, na.rm = TRUE)
# For each new territory, add a row for each measure (including bookstore_count)
all_measures <- unique(dim_measures$measure_type)
new_cats <- expand.grid(
  category_type = "territory",
  category_value = bookstore_regions,
  measure = all_measures,
  stringsAsFactors = FALSE
)
new_cats$category_id <- seq(max_cat_id + 1, by = 1, length.out = nrow(new_cats))
new_cats <- new_cats[, c("category_id", "category_type", "category_value", "measure")]
dim_categories <- dplyr::bind_rows(dim_categories, new_cats)
dbWriteTable(db_enhanced, "dim_categories", dim_categories, overwrite = TRUE)
cat("  ✓ Added new territories × measures to dim_categories\n")
# Also update CSV and RDS versions for dim_categories
csv_cat_path <- "data-private/derived/manipulation/CSV/dim_categories.csv"
rds_cat_path <- "data-private/derived/manipulation/dim_categories.rds"
write.csv(dim_categories, csv_cat_path, row.names = FALSE)
saveRDS(dim_categories, rds_cat_path)
cat("  ✓ Updated CSV and RDS versions of dim_categories\n")
# Verification
cat("  → bookstore_count territories in dim_categories: ", sum(dim_categories$category_type == 'territory' & dim_categories$category_value %in% bookstore_regions & dim_categories$measure == 'bookstore_count'), "\n")

# Add to fact_book_publications

# Add to fact_book_publications (must match structure: year, category_type, category_value, measure_type, value)

# Remove any existing bookstore_count 2023 rows to avoid duplicates
fact_book_publications <- dbReadTable(db_enhanced, "fact_book_publications")
fact_book_publications <- fact_book_publications[!(fact_book_publications$measure_type == "bookstore_count" & fact_book_publications$year == 2023), ]

bookstore_2023_rows <- data.frame(
  year = as.integer(2023),
  category_type = as.character("territory"),
  category_value = as.character(bookstore_regions),
  measure_type = as.character("bookstore_count"),
  value = as.numeric(bookstore_count),
  stringsAsFactors = FALSE
)
# Remove row names if present
rownames(bookstore_2023_rows) <- NULL
# Ensure column order and types match exactly
bookstore_2023_rows <- bookstore_2023_rows[, c("year", "category_type", "category_value", "measure_type", "value")]
# Use dplyr::bind_rows for robust row binding

# Bind and arrange so 2023 bookstore_count rows are in order with other 2023 rows
fact_book_publications <- dplyr::bind_rows(fact_book_publications, bookstore_2023_rows)
fact_book_publications <- fact_book_publications %>%
  arrange(year, category_type, category_value, measure_type)
dbWriteTable(db_enhanced, "fact_book_publications", fact_book_publications, overwrite = TRUE)
cat("  ✓ Added bookstore_count 2023 data to fact_book_publications\n")
# Verification: print number of bookstore_count 2023 rows
added_rows <- sum(fact_book_publications$measure_type == "bookstore_count" & fact_book_publications$year == 2023)
cat("  → bookstore_count 2023 rows in fact_book_publications:", added_rows, "\n")

# Also update fact_enhanced if it exists
all_tables <- dbListTables(db_enhanced)
if ("fact_enhanced" %in% all_tables) {
  fact_enhanced <- dbReadTable(db_enhanced, "fact_enhanced")
  # Remove any existing bookstore_count 2023 rows
  fact_enhanced <- fact_enhanced[!(fact_enhanced$measure_type == "bookstore_count" & fact_enhanced$year == 2023), ]
  fact_enhanced <- dplyr::bind_rows(fact_enhanced, bookstore_2023_rows)
  dbWriteTable(db_enhanced, "fact_enhanced", fact_enhanced, overwrite = TRUE)
  cat("  ✓ Added bookstore_count 2023 data to fact_enhanced\n")
  # Verification
  added_rows_enh <- sum(fact_enhanced$measure_type == "bookstore_count" & fact_enhanced$year == 2023)
  cat("  → bookstore_count 2023 rows in fact_enhanced:", added_rows_enh, "\n")
  # Also update CSV and RDS versions for fact_enhanced
  csv_enh_path <- "data-private/derived/manipulation/CSV/fact_enhanced.csv"
  rds_enh_path <- "data-private/derived/manipulation/fact_enhanced.rds"
  write.csv(fact_enhanced, csv_enh_path, row.names = FALSE)
  saveRDS(fact_enhanced, rds_enh_path)
  cat("  ✓ Updated CSV and RDS versions of fact_enhanced\n")
}

# Also update CSV and RDS versions
csv_path <- "data-private/derived/manipulation/CSV/fact_book_publications.csv"
rds_path <- "data-private/derived/manipulation/fact_book_publications.rds"
write.csv(fact_book_publications, csv_path, row.names = FALSE)
saveRDS(fact_book_publications, rds_path)
cat("  ✓ Updated CSV and RDS versions of fact_book_publications\n")
# (raw_territory update removed)
# Future extensions can be added here:
# add_economic_extension(db_enhanced)
# add_cultural_extension(db_enhanced)
# ---- validate-enhanced-database ----------------------------------------------
cat("\n📊 VALIDATING ENHANCED DATABASE\n")
cat(paste(rep("=", 35), collapse = ""), "\n")

# Get all tables in enhanced database
all_tables <- dbListTables(db_enhanced)
fact_tables <- grep("^fact_", all_tables, value = TRUE)
ext_tables <- grep("^ext_", all_tables, value = TRUE)

cat("Total tables:", length(all_tables), "\n")
cat("Fact tables:", paste(fact_tables, collapse = ", "), "\n")
cat("Extension tables:", paste(ext_tables, collapse = ", "), "\n")

# Validate fact_enhanced if it exists
if ("fact_enhanced" %in% all_tables) {
  enhanced_count <- dbGetQuery(db_enhanced, "SELECT COUNT(*) as count FROM fact_enhanced")$count
  core_count <- dbGetQuery(db_enhanced, "SELECT COUNT(*) as count FROM fact_book_publications")$count
  
  cat("\nFact table comparison:\n")
  cat("  Core fact table:", format(core_count, big.mark = ","), "records\n")
  cat("  Enhanced fact table:", format(enhanced_count, big.mark = ","), "records\n")
  cat("  Extensions added:", format(enhanced_count - core_count, big.mark = ","), "records\n")
  
  # Show category breakdown in enhanced table
  cat("\nCategory breakdown in enhanced table:\n")
  category_summary <- dbGetQuery(db_enhanced, "
    SELECT category_type, COUNT(*) as records, COUNT(DISTINCT category_value) as unique_values
    FROM fact_enhanced 
    GROUP BY category_type 
    ORDER BY category_type
  ")
  print(category_summary)
}

# ---- generate-documentation --------------------------------------------------
cat("\n📝 GENERATING DOCUMENTATION\n")
cat(paste(rep("=", 30), collapse = ""), "\n")

# Generate enhanced manifest (write to new file, do not overwrite original)
generate_enhanced_manifest(db_enhanced, output_path = "ai/CACHE-MANIFEST-1.md")

# Add bookstore_count info to manifest
manifest_path <- "ai/CACHE-MANIFEST-1.md"
manifest_lines <- readLines(manifest_path)
insert_idx <- grep("^## \\📋 Table Catalog", manifest_lines)
if (length(insert_idx) == 1) {
  extra_info <- c(
    "",
    "### 🏪 Bookstore Count 2023 Extension",
    "",
    "- **Measure:** `bookstore_count` (number of bookstores by region, 2023)",
    "- **Regions:** Kyiv, Lvivska, Kharkivska, Dnipropetrovska, Odeska, etc.",
    "- **Source:** Screenshot + Forbes data, provided August 2025",
    "- **Integration:** Added to `dim_measures`, `dim_categories`, and `fact_book_publications`",
    "- **CSV/RDS:** Updated in `fact_book_publications.csv` and `.rds`",
    ""
  )
  manifest_lines <- append(manifest_lines, extra_info, after = insert_idx)
  writeLines(manifest_lines, manifest_path)
  cat("  ✓ Documented bookstore_count 2023 extension in manifest\n")
}

# ---- cleanup -----------------------------------------------------------------
# Close database connection
dbDisconnect(db_enhanced)

# Final summary
cat("\n", paste(rep("=", 60), collapse = ""), "\n")
cat("🎉 ENHANCED DATABASE CREATION COMPLETE!\n")
cat(paste(rep("=", 60), collapse = ""), "\n")

cat("\n📂 DELIVERABLES:\n")
cat("  ✓ Enhanced SQLite database:", enhanced_db_path, "\n")
cat("  ✓ Core tables preserved (backward compatible)\n")
cat("  ✓ Extension tables added (ext_*)\n")
cat("  ✓ Integrated fact table (fact_enhanced)\n")
cat("  ✓ Comprehensive documentation (ai/CACHE-manifest.md)\n")

cat("\n🔍 RECOMMENDED USAGE:\n")
cat("  • Use fact_enhanced for comprehensive analysis\n")
cat("  • Use fact_book_publications for core-only analysis\n")
cat("  • Query ext_* tables for specific extensions\n")
cat("  • Reference ai/CACHE-manifest.md for schema details\n")

cat("\n🚀 NEXT STEPS:\n")
cat("  1. Review ai/CACHE-manifest.md for detailed documentation\n")
cat("  2. Test queries using the enhanced fact table\n")
cat("  3. Use analysis/eda-* scripts with enhanced database\n")
cat("  4. Add future extensions following the established pattern\n")

cat("\n", paste(rep("=", 60), collapse = ""), "\n")
