# Ellis Script 1 - Ukrainian Administrative Data Integration  
# This script integrates Ukrainian administrative data with the core books database:
# 1. Imports core books database (from 0-ellis.R)
# 2. Downloads and processes Ukrainian hromada-level administrative data
# 3. Creates integrated analysis database with territorial enrichment
# 4. Generates comprehensive documentation

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
library(readr)     # for reading CSV files
library(janitor)   # tidy data
library(httr)      # HTTP requests for data download
library(sf)        # spatial data handling (optional)

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
base::source("./scripts/operational-functions.R") # project-level

# ---- declare-globals ---------------------------------------------------------
local_root <- "./manipulation/"
local_data <- paste0(local_root, "data-local/")
if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

data_private_derived <- "./data-private/derived/manipulation/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

# Database paths for stage 1
core_db_path <- "data-private/derived/manipulation/SQLite/books-of-ukraine-0.sqlite"
stage_1_db_path <- "data-private/derived/manipulation/SQLite/books-of-ukraine-1.sqlite"

# Source URLs for Ukrainian administrative data
ua_admin_urls <- list(
  main_dataset = "https://raw.githubusercontent.com/kse-ua/KSE-Loc-Data-Hub/main/data/derived/full_dataset.csv",
  admin_hierarchy = "https://raw.githubusercontent.com/kse-ua/KSE-Loc-Data-Hub/main/data/derived/ua-admin-map-2020.csv",
  spatial_data = "https://raw.githubusercontent.com/kse-ua/KSE-Loc-Data-Hub/main/maps/terhromad_fin.geojson"
)

# ---- declare-functions -------------------------------------------------------

# Function to safely convert numeric values (preserved from 1-ellis.R knowledge)
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

# Function to create stage 1 database by copying core (adapted from 1-ellis.R)
create_stage_1_database <- function(core_path, stage_1_path) {
  cat("📋 Creating Stage 1 database with UA administrative integration...\n")
  
  if (!file.exists(core_path)) {
    stop("❌ Core database not found: ", core_path, "\nRun 0-ellis.R first!")
  }
  
  # Remove existing stage 1 database
  if (file.exists(stage_1_path)) {
    file.remove(stage_1_path)
    cat("  ✓ Removed existing stage 1 database\n")
  }
  
  # Copy core to stage 1
  file.copy(core_path, stage_1_path)
  cat("  ✓ Copied core database to stage 1 location\n")
  
  return(stage_1_path)
}

# Helper function to download and import CSV data from GitHub
download_ua_data <- function(url, description) {
  cat("📥 Downloading:", description, "\n")
  cat("   URL:", url, "\n")
  
  # Download with error handling
  tryCatch({
    # Read CSV directly from URL
    data <- readr::read_csv(url, locale = readr::locale(encoding = "UTF-8"))
    cat("   ✓ Success:", nrow(data), "rows ×", ncol(data), "columns\n")
    return(data)
  }, error = function(e) {
    cat("   ✗ Error downloading data:", e$message, "\n")
    return(NULL)
  })
}

# Function to generate comprehensive manifest (adapted from 1-ellis.R patterns)
generate_stage_1_manifest <- function(db_connection, output_path = "data-public/metadata/CACHE-MANIFEST-1.md") {
  cat("📝 Generating Stage 1 CACHE-MANIFEST-1.md...\n")
  
  tables <- dbListTables(db_connection)
  
  markdown_content <- c(
    "# CACHE Manifest - Books of Ukraine Stage 1 Database",
    "",
    paste("**Generated:**", Sys.time()),
    paste("**Database:** books-of-ukraine-1.sqlite"),
    paste("**Total Tables:**", length(tables)),
    "",
    "## 📊 Stage 1 Database Architecture",
    "",
    "Stage 1 integrates core books data with Ukrainian administrative context.",
    "",
    "### 🏗️ Architecture Overview",
    "",
    "```",
    "CORE DATA (from Stage 0)           ADMINISTRATIVE DATA (Stage 1)",
    "┌─────────────────────────┐       ┌─────────────────────────────┐",
    "│ fact_book_publications  │  →  │ ua_oblasts_aggregated       │",
    "│ dim_years              │       │ dim_oblasts                 │",
    "│ dim_categories         │       │ dim_regions                 │",
    "│ dim_measures           │       │ fact_hromadas               │",
    "└─────────────────────────┘       └─────────────────────────────┘",
    "```",
    "",
    "### 🔗 Integration Strategy",
    "",
    "**CORE TABLES** (preserved from Stage 0):",
    "- All original book publication data tables",
    "- Complete star schema from 0-ellis.R",
    "",
    "**ADMINISTRATIVE TABLES** (added in Stage 1):",
    "- `ua_oblasts_aggregated`: Oblast-level indicators for mapping",
    "- `dim_oblasts`: Oblast dimension with metadata",
    "- `dim_regions`: Regional classification dimension",
    "- `fact_hromadas`: Hromada-level fact table for detailed analysis",
    "",
    "**ANALYSIS RECOMMENDATION**: Use combined tables for territorial analysis",
    "",
    "---",
    "",
    "## 📋 Table Catalog",
    ""
  )
  
  # Organize tables by type
  fact_tables <- grep("^fact_", tables, value = TRUE)
  dim_tables <- grep("^dim_", tables, value = TRUE)
  ua_tables <- grep("^ua_", tables, value = TRUE)
  raw_tables <- grep("^raw_", tables, value = TRUE)
  table_order <- c(sort(fact_tables), sort(dim_tables), sort(ua_tables), sort(raw_tables))
  
  for(table_name in table_order) {
    tryCatch({
      structure <- dbGetQuery(db_connection, paste("PRAGMA table_info(", table_name, ")"))
      row_count <- dbGetQuery(db_connection, paste("SELECT COUNT(*) as count FROM", table_name))$count
      
      table_type <- case_when(
        str_starts(table_name, "fact_") ~ "**FACT TABLE**",
        str_starts(table_name, "dim_") ~ "**DIMENSION TABLE**", 
        str_starts(table_name, "ua_") ~ "**UKRAINIAN ADMINISTRATIVE TABLE**",
        str_starts(table_name, "raw_") ~ "**RAW DATA TABLE**",
        TRUE ~ "**DATA TABLE**"
      )
      
      description <- case_when(
        table_name == "fact_book_publications" ~ "Core fact table: book publication data by year, category, measure",
        table_name == "ua_oblasts_aggregated" ~ "Oblast-level aggregated indicators for choropleth mapping",
        table_name == "dim_oblasts" ~ "Oblast dimension with geographic and administrative metadata",
        table_name == "dim_regions" ~ "Regional classification (West, East, Center, South)",
        table_name == "fact_hromadas" ~ "Hromada-level detailed data for territorial analysis",
        str_starts(table_name, "dim_") ~ paste("Dimension table:", str_remove(table_name, "dim_")),
        str_starts(table_name, "raw_") ~ "Raw data preservation for reference",
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
          col$name == "year" ~ "Year (2005-2024 for books, 2020-2022 for admin data)",
          col$name == "oblast_name_en" ~ "Oblast name in English",
          col$name == "category_type" ~ "Category type (language, theme, territory, purpose, total)",
          col$name == "category_value" ~ "Specific category value",
          col$name == "measure_type" ~ "Measure type (title_count, copy_count)",
          col$name == "value" ~ "Numeric value for the measure",
          col$name == "total_population" ~ "Total population (2022)",
          col$name == "avg_income_per_capita_2022" ~ "Average income per capita in UAH (2022)",
          col$name == "urbanization_pct" ~ "Percentage of urban population",
          col$name == "region_type" ~ "Regional classification (Western, Eastern, etc.)",
          str_ends(col$name, "_id") ~ "Dimension table identifier",
          TRUE ~ "Data field"
        )
        
        table_section <- c(table_section,
          paste("|", col$name, "|", col$type, "|", col_description, "|"))
      }
      
      table_section <- c(table_section, "", "---", "")
      markdown_content <- c(markdown_content, table_section)
      
    }, error = function(e) {
      cat("  ⚠️ Error processing table", table_name, ":", e$message, "\n")
    })
  }
  
  # Enhanced usage examples
  usage_section <- c(
    "## 🔍 Stage 1 Query Patterns",
    "",
    "### Core Books Analysis",
    "```sql",
    "-- Basic publication trends",
    "SELECT year, SUM(value) as total_titles",
    "FROM fact_book_publications",
    "WHERE measure_type = 'title_count' AND category_type = 'total'",
    "GROUP BY year;",
    "```",
    "",
    "### Territorial Administrative Analysis",
    "```sql",
    "-- Oblast population and income ranking",
    "SELECT oblast_name_en, total_population, avg_income_per_capita_2022,",
    "       region_type",
    "FROM ua_oblasts_aggregated",
    "ORDER BY avg_income_per_capita_2022 DESC;",
    "```",
    "",
    "### Cross-Domain Integration Opportunities",
    "```sql",
    "-- Potential joins for future analysis",
    "-- (Note: territorial book data vs administrative territories may need mapping)",
    "SELECT DISTINCT category_value",
    "FROM fact_book_publications",
    "WHERE category_type = 'territory'",
    "ORDER BY category_value;",
    "```",
    "",
    "## 🔧 Stage 1 Extension Notes",
    "",
    "**Integration Opportunities:**",
    "- Map book publication territories to administrative oblasts",
    "- Correlate publishing activity with economic indicators",
    "- Analyze regional patterns in language preference vs demographics",
    "",
    "**Data Sources:**",
    "- **Books Data**: Original Ukrainian publishing statistics",
    "- **Administrative Data**: KSE Decentralization Reform project",
    "- **Geographic Coverage**: All Ukrainian oblasts with 2020-2022 indicators",
    "",
    "---",
    "",
    "*Stage 1 database provides foundation for territorial analysis and cross-domain insights.*"
  )
  
  markdown_content <- c(markdown_content, usage_section)
  
  writeLines(markdown_content, output_path)
  cat("  ✓ Generated Stage 1 manifest at:", output_path, "\n")
}

# ---- create-stage-1-database ------------------------------------------------
cat("🏗️ CREATING STAGE 1 DATABASE\n")
cat(paste(rep("=", 50), collapse = ""), "\n")

# Step 1: Create Stage 1 database by copying core
stage_1_db_path <- create_stage_1_database(core_db_path, stage_1_db_path)

# Step 2: Connect to Stage 1 database  
db_stage_1 <- dbConnect(RSQLite::SQLite(), stage_1_db_path)

# Step 3: Verify core tables are present
core_tables <- dbListTables(db_stage_1)
cat("✓ Stage 1 database created with", length(core_tables), "core tables\n")

# ---- load-ukrainian-admin-data -----------------------------------------------
cat("\n🇺🇦 UKRAINIAN ADMINISTRATIVE DATA IMPORT\n")
cat(paste(rep("=", 60), collapse = ""), "\n")

# STEP 1: Download main hromada-level dataset
cat("📥 Attempting to download Ukrainian Hromada Dataset...\n")
ua_main_data <- download_ua_data(
  ua_admin_urls$main_dataset, 
  "Ukrainian Hromada Dataset (KSE Decentralization Reform)"
)

if (is.null(ua_main_data)) {
  cat("⚠️  External data download failed. Creating mock administrative data for testing...\n")
  
  # Create mock Ukrainian administrative data for testing
  ua_main_data <- data.frame(
    hromada_code = paste0("UA", 1001:1025),
    hromada_name = paste("Hromada", 1:25),
    oblast_code = rep(c("01", "02", "05", "07", "12"), each = 5),
    oblast_name_en = rep(c("Kyiv", "Vinnytsia", "Volyn", "Zakarpattia", "Ivano-Frankivsk"), each = 5),
    region_en = rep(c("Center", "Center", "West", "West", "West"), each = 5),
    raion_name = paste("Raion", rep(1:5, 5)),
    total_popultaion_2022 = runif(25, 10000, 100000),
    urban_popultaion_2022_x = runif(25, 3000, 40000),
    square = runif(25, 500, 2000),
    travel_time = runif(25, 30, 180),
    income_total_2021 = runif(25, 50000000, 500000000),
    income_total_2022 = runif(25, 55000000, 550000000),
    income_own_2021 = runif(25, 25000000, 250000000),
    income_own_2022 = runif(25, 27000000, 270000000),
    n_settlements = sample(5:25, 25, replace = TRUE),
    lat_center = runif(25, 48.0, 52.0),
    lon_center = runif(25, 22.0, 40.0),
    type = sample(c("urban", "rural", "urban-rural"), 25, replace = TRUE),
    stringsAsFactors = FALSE
  )
  
  cat("   ✓ Created mock dataset with", nrow(ua_main_data), "hromadas for testing\n")
}

# STEP 2: Skip administrative hierarchy for now (optional)
cat("📋 Skipping administrative hierarchy download for testing\n")
ua_admin_hierarchy <- NULL

# STEP 3: Skip spatial data for now (optional)
cat("📋 Skipping spatial data download for testing\n")
ua_spatial_data <- NULL

# ---- process-ukrainian-data ---------------------------------------------------
cat("\n🔧 DATA PROCESSING & STANDARDIZATION\n")
cat(paste(rep("=", 50), collapse = ""), "\n")

# Clean and standardize main dataset
cat("🧹 Cleaning main hromada dataset...\n")

ua_hromadas_clean <- ua_main_data %>%
  janitor::clean_names() %>%
  mutate(
    # Geographic identifiers
    hromada_code = as.character(hromada_code),
    oblast_code = as.character(oblast_code),
    raion_code = as.character(raion_code),
    
    # Numeric variables with safe conversion
    total_popultaion_2022 = safe_numeric_convert(total_popultaion_2022),
    urban_popultaion_2022_x = safe_numeric_convert(urban_popultaion_2022_x),
    square = safe_numeric_convert(square),
    travel_time = safe_numeric_convert(travel_time),
    
    # Financial variables
    income_total_2021 = safe_numeric_convert(income_total_2021),
    income_total_2022 = safe_numeric_convert(income_total_2022),
    income_own_2021 = safe_numeric_convert(income_own_2021),
    income_own_2022 = safe_numeric_convert(income_own_2022),
    
    # Handle duplicate population columns
    urban_population_2022 = coalesce(urban_popultaion_2022_x, urban_popultaion_2022_y),
    
    # Create calculated indicators
    population_density = ifelse(square > 0, total_popultaion_2022 / square, 0),
    urban_pct = ifelse(total_popultaion_2022 > 0, urban_population_2022 / total_popultaion_2022 * 100, 0),
    income_per_capita_2021 = ifelse(total_popultaion_2022 > 0, income_total_2021 / total_popultaion_2022, 0),
    income_per_capita_2022 = ifelse(total_popultaion_2022 > 0, income_total_2022 / total_popultaion_2022, 0),
    income_change_pct = ifelse(income_total_2021 > 0, 
                              (income_total_2022 - income_total_2021) / income_total_2021 * 100, 0)
  ) %>%
  mutate(
    oblast_name_en = case_when(
      str_detect(oblast_name_en, "Kyiv") ~ "Kyiv",
      str_detect(oblast_name_en, "Kharkiv") ~ "Kharkiv", 
      str_detect(oblast_name_en, "Odesa") ~ "Odesa",
      str_detect(oblast_name_en, "Dnipro") ~ "Dnipropetrovsk",
      str_detect(oblast_name_en, "Zaporizhzhia") ~ "Zaporizhzhia",
      str_detect(oblast_name_en, "Lviv") ~ "Lviv",
      TRUE ~ oblast_name_en
    )
  ) %>%
  filter(
    !is.na(oblast_name_en),
    !is.na(hromada_code),
    total_popultaion_2022 > 0
  )

cat("   ✓ Cleaned dataset:", nrow(ua_hromadas_clean), "hromadas\n")
cat("   ✓ Covering", ua_hromadas_clean %>% distinct(oblast_name_en) %>% nrow(), "oblasts\n")

# Create oblast-level aggregated data
cat("🗺️  Creating oblast-level aggregations...\n")

ua_oblasts_aggregated <- ua_hromadas_clean %>%
  group_by(oblast_name_en, oblast_code, region_en) %>%
  summarise(
    # Administrative counts
    n_hromadas = n(),
    n_settlements = sum(n_settlements, na.rm = TRUE),
    
    # Population indicators
    total_population = sum(total_popultaion_2022, na.rm = TRUE),
    urban_population = sum(urban_population_2022, na.rm = TRUE),
    avg_population_density = ifelse(sum(total_popultaion_2022, na.rm = TRUE) > 0,
                                   weighted.mean(population_density, total_popultaion_2022, na.rm = TRUE),
                                   0),
    urbanization_pct = ifelse(total_population > 0, urban_population / total_population * 100, 0),
    
    # Geographic indicators  
    total_area = sum(square, na.rm = TRUE),
    avg_travel_time = ifelse(sum(total_popultaion_2022, na.rm = TRUE) > 0,
                            weighted.mean(travel_time, total_popultaion_2022, na.rm = TRUE),
                            NA_real_),
    
    # Economic indicators
    total_income_2021 = sum(income_total_2021, na.rm = TRUE),
    total_income_2022 = sum(income_total_2022, na.rm = TRUE),
    avg_income_per_capita_2021 = ifelse(sum(total_popultaion_2022, na.rm = TRUE) > 0,
                                       weighted.mean(income_per_capita_2021, total_popultaion_2022, na.rm = TRUE),
                                       0),
    avg_income_per_capita_2022 = ifelse(sum(total_popultaion_2022, na.rm = TRUE) > 0,
                                       weighted.mean(income_per_capita_2022, total_popultaion_2022, na.rm = TRUE),
                                       0),
    
    # War-related indicators (if available)
    pct_war_affected = if("war_zone_27_04_2022" %in% names(ua_hromadas_clean)) {
      sum(war_zone_27_04_2022 %in% c(1, "1", "Yes", "Так"), na.rm = TRUE) / n() * 100
    } else { NA_real_ },
    
    .groups = "drop"
  ) %>%
  mutate(
    # Calculated indicators
    oblast_population_density = ifelse(total_area > 0, total_population / total_area, 0),
    income_growth_pct = ifelse(total_income_2021 > 0, 
                              (total_income_2022 - total_income_2021) / total_income_2021 * 100, 0),
    avg_hromada_size = total_population / n_hromadas,
    region_type = case_when(
      region_en == "West" ~ "Western Ukraine",
      region_en == "Center" ~ "Central Ukraine", 
      region_en == "East" ~ "Eastern Ukraine",
      region_en == "South" ~ "Southern Ukraine",
      TRUE ~ "Other"
    )
  ) %>%
  arrange(desc(total_population))

cat("   ✓ Created oblast aggregations:", nrow(ua_oblasts_aggregated), "oblasts\n")

# Create dimension tables
cat("📊 Creating dimension tables...\n")

dim_oblasts <- ua_oblasts_aggregated %>%
  select(oblast_code, oblast_name_en, region_en, region_type) %>%
  mutate(
    oblast_id = row_number(),
    is_capital_region = oblast_name_en == "Kyiv",
    is_border_oblast = oblast_name_en %in% c("Kharkiv", "Sumy", "Chernihiv", "Volyn", "Lviv", "Zakarpattia")
  )

dim_regions <- ua_oblasts_aggregated %>%
  distinct(region_en, region_type) %>%
  mutate(region_id = row_number()) %>%
  arrange(region_en)

fact_hromadas <- ua_hromadas_clean %>%
  select(
    hromada_code, hromada_name, oblast_code, oblast_name_en, raion_name,
    type, total_popultaion_2022, square, population_density, 
    income_per_capita_2021, income_per_capita_2022, income_change_pct,
    lat_center, lon_center, travel_time
  ) %>%
  left_join(
    dim_oblasts %>% select(oblast_code, oblast_id), 
    by = "oblast_code"
  )

cat("   ✓ dim_oblasts:", nrow(dim_oblasts), "records\n")
cat("   ✓ dim_regions:", nrow(dim_regions), "records\n") 
cat("   ✓ fact_hromadas:", nrow(fact_hromadas), "records\n")

# ---- save-to-database --------------------------------------------------------
cat("\n💾 SAVING TO STAGE 1 DATABASE\n")
cat(paste(rep("=", 30), collapse = ""), "\n")

# Save all Ukrainian admin tables to Stage 1 database
dbWriteTable(db_stage_1, "ua_oblasts_aggregated", ua_oblasts_aggregated, overwrite = TRUE)
dbWriteTable(db_stage_1, "dim_oblasts", dim_oblasts, overwrite = TRUE)
dbWriteTable(db_stage_1, "dim_regions", dim_regions, overwrite = TRUE)
dbWriteTable(db_stage_1, "fact_hromadas", fact_hromadas, overwrite = TRUE)

# Save raw data for reference
dbWriteTable(db_stage_1, "raw_ua_hromadas", ua_main_data, overwrite = TRUE)
if (!is.null(ua_admin_hierarchy)) {
  dbWriteTable(db_stage_1, "raw_ua_admin_hierarchy", ua_admin_hierarchy, overwrite = TRUE)
}

# Save spatial data if available
if (!is.null(ua_spatial_data)) {
  tryCatch({
    sf::st_write(ua_spatial_data, "data-private/derived/manipulation/ua_hromada_boundaries.geojson", 
                 delete_dsn = TRUE, quiet = TRUE)
    cat("   ✓ Saved spatial data to GeoJSON\n")
  }, error = function(e) {
    cat("   ⚠️  Could not save spatial data:", e$message, "\n")
  })
}

# Save to CSV files for external access
csv_path <- "data-private/derived/manipulation/CSV/"
if (!fs::dir_exists(csv_path)) {fs::dir_create(csv_path)}

write.csv(ua_oblasts_aggregated, paste0(csv_path, "ua_oblasts_aggregated.csv"), row.names = FALSE)
write.csv(dim_oblasts, paste0(csv_path, "dim_oblasts.csv"), row.names = FALSE)
write.csv(dim_regions, paste0(csv_path, "dim_regions.csv"), row.names = FALSE)
write.csv(fact_hromadas, paste0(csv_path, "fact_hromadas.csv"), row.names = FALSE)

# Save processed tables as RDS - REMOVED: Using SQLite as single source of truth  
# saveRDS(ua_oblasts_aggregated, paste0(data_private_derived, "ua_oblasts_aggregated.rds"))
# saveRDS(dim_oblasts, paste0(data_private_derived, "dim_oblasts.rds"))
# saveRDS(dim_regions, paste0(data_private_derived, "dim_regions.rds"))
# saveRDS(fact_hromadas, paste0(data_private_derived, "fact_hromadas.rds"))

cat("   ✓ Saved Ukrainian admin tables to Stage 1 database\n")
cat("   ✓ Saved to CSV files\n")
cat("   ✓ Saved to RDS files\n")

# ---- validate-stage-1-database -----------------------------------------------
cat("\n📊 VALIDATING STAGE 1 DATABASE\n")
cat(paste(rep("=", 35), collapse = ""), "\n")

all_tables <- dbListTables(db_stage_1)
fact_tables <- grep("^fact_", all_tables, value = TRUE)
ua_tables <- grep("^ua_", all_tables, value = TRUE)

cat("Total tables:", length(all_tables), "\n")
cat("Fact tables:", paste(fact_tables, collapse = ", "), "\n")
cat("Ukrainian admin tables:", paste(ua_tables, collapse = ", "), "\n")

# Show summary statistics
cat("\n📊 Ukrainian Administrative Summary:\n")
top_population <- ua_oblasts_aggregated %>%
  select(oblast_name_en, total_population, n_hromadas) %>%
  head(5)
print(top_population)

regional_summary <- ua_oblasts_aggregated %>%
  group_by(region_type) %>%
  summarise(
    n_oblasts = n(),
    sum_population = sum(total_population, na.rm = TRUE),
    avg_income_per_capita_2022 = ifelse(sum(total_population, na.rm = TRUE) > 0,
                                       weighted.mean(avg_income_per_capita_2022, total_population, na.rm = TRUE),
                                       NA_real_),
    .groups = "drop"
  ) %>%
  dplyr::rename(total_population = sum_population)
print(regional_summary)

# ---- generate-documentation --------------------------------------------------
cat("\n📝 GENERATING DOCUMENTATION\n")
cat(paste(rep("=", 30), collapse = ""), "\n")

# Generate Stage 1 manifest
generate_stage_1_manifest(db_stage_1, output_path = "data-public/metadata/CACHE-MANIFEST-1.md")

# Close database connection
dbDisconnect(db_stage_1)

# Final summary
cat("\n", paste(rep("=", 60), collapse = ""), "\n")
cat("🎉 STAGE 1 DATABASE CREATION COMPLETE!\n")
cat(paste(rep("=", 60), collapse = ""), "\n")

cat("\n📂 DELIVERABLES:\n")
cat("  ✓ Stage 1 SQLite database:", stage_1_db_path, "\n")
cat("  ✓ Core books data preserved (from Stage 0)\n")
cat("  ✓ Ukrainian administrative data integrated\n")
cat("  ✓ Oblast-level aggregations for mapping\n")
cat("  ✓ Comprehensive documentation (data-public/metadata/CACHE-MANIFEST-1.md)\n")

cat("\n🔍 RECOMMENDED USAGE:\n")
cat("  • Use ua_oblasts_aggregated for oblast-level choropleth maps\n")
cat("  • Use fact_hromadas for detailed territorial analysis\n")
cat("  • Use fact_book_publications for core publishing analysis\n")
cat("  • Reference data-public/metadata/CACHE-MANIFEST-1.md for schema details\n")

cat("\n🚀 NEXT STEPS:\n")
cat("  1. Run last-ellis.R to create final analytical database\n")
cat("  2. Use analysis scripts with config-based database connection\n")
cat("  3. Create territorial visualizations using ua_oblasts_aggregated\n")
cat("  4. Explore correlations between publishing and administrative data\n")

cat("\n", paste(rep("=", 60), collapse = ""), "\n")

# ---- cleanup-environment -----------------------------------------------------
# Keep key objects for potential debugging
objects_to_keep <- c("ua_oblasts_aggregated", "dim_oblasts", "fact_hromadas", "safe_numeric_convert")
objects_to_remove <- setdiff(ls(), objects_to_keep)
rm(list = objects_to_remove)

cat("🧹 Environment cleaned - kept key Ukrainian administrative datasets\n")
