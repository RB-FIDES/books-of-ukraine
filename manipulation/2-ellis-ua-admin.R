# Ellis Script - Ukrainian Administrative Data Import
# This script imports Ukrainian hromada-level data for oblast-level analysis
# Source: KSE Decentralization Reform project (full_dataset.csv)
# Format schema: hromada-level data with oblast identifiers for aggregation

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
library(DBI)       # For database connection and operations
library(RSQLite)   # SQLite database interface
library(ggrepel)   # improved text positioning
library(sf)        # spatial data handling
library(httr)      # HTTP requests for data download
library(readr)     # for reading CSV files
# -- 2.Import only certain functions of a package into the search path.
# import::from("magrittr", "%>%")
# -- 3. Verify these packages are available on the machine, but their functions need to be qualified
requireNamespace("openxlsx"  )# Excel operations
requireNamespace("fs"        )# file system operations

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
base::source("./scripts/operational-functions.R") # project-level

# ---- declare-globals ---------------------------------------------------------
local_root <- "./manipulation/"
local_data <- paste0(local_root, "data-local/") # for local outputs

if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

# Source URLs for Ukrainian administrative data
ua_admin_urls <- list(
  main_dataset = "https://raw.githubusercontent.com/kse-ua/KSE-Loc-Data-Hub/main/data/derived/full_dataset.csv",
  admin_hierarchy = "https://raw.githubusercontent.com/kse-ua/KSE-Loc-Data-Hub/main/data/derived/ua-admin-map-2020.csv",
  spatial_data = "https://raw.githubusercontent.com/kse-ua/KSE-Loc-Data-Hub/main/maps/terhromad_fin.geojson"
)

# ---- declare-functions -------------------------------------------------------
# Helper function for robust numeric conversion (preserve from 0-ellis.R)
safe_numeric_convert <- function(x) {
  # Handle various formats and clean the data
  cleaned <- as.character(x)
  # Remove all non-numeric characters except dots, minus signs, and spaces
  cleaned <- gsub("[^0-9.\\s-]", "", cleaned)
  # Remove extra spaces
  cleaned <- gsub("\\s+", "", cleaned)
  # Replace empty strings, lone dashes, and various null representations with zero
  cleaned[cleaned == "" | cleaned == "-" | cleaned == "NULL" | 
          cleaned == "NA" | cleaned == "n/a" | is.na(cleaned)] <- "0"
  # Handle cases where we might have multiple dots
  cleaned <- gsub("\\.{2,}", ".", cleaned)
  # Convert to numeric
  result <- suppressWarnings(as.numeric(cleaned))
  # Replace any remaining NAs with 0
  result[is.na(result)] <- 0
  return(result)
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

# ---- create-directories ------------------------------------------------------
data_private_derived <- "data-private/derived/manipulation/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

data_private_derived_sqlite <- "data-private/derived/manipulation/SQLite/"
if (!fs::dir_exists(data_private_derived_sqlite)) {fs::dir_create(data_private_derived_sqlite)}

data_private_derived_csv <- "data-private/derived/manipulation/CSV/"
if (!fs::dir_exists(data_private_derived_csv)) {fs::dir_create(data_private_derived_csv)}

# ---- establish-database-connection -------------------------------------------
db_ua_admin <- dbConnect(RSQLite::SQLite(), "data-private/derived/manipulation/SQLite/ua-admin-analysis.sqlite")

# ---- load-data ---------------------------------------------------------------
cat("\n🇺🇦 UKRAINIAN ADMINISTRATIVE DATA IMPORT\n")
cat(paste(rep("=", 60), collapse = ""), "\n")

# STEP 1: Download main hromada-level dataset
# This contains comprehensive data on all 1,469 hromadas (territorial communities)
# with economic, social, political, geographic, and war-related indicators
ua_main_data <- download_ua_data(
  ua_admin_urls$main_dataset, 
  "Ukrainian Hromada Dataset (KSE Decentralization Reform)"
)

if (is.null(ua_main_data)) {
  stop("❌ Failed to download main dataset. Cannot proceed.")
}

# STEP 2: Download administrative hierarchy mapping
# This provides the relationship structure: settlement → rada → hromada → raion → oblast → region
ua_admin_hierarchy <- download_ua_data(
  ua_admin_urls$admin_hierarchy,
  "Ukrainian Administrative Hierarchy (2020)"
)

if (is.null(ua_admin_hierarchy)) {
  cat("⚠️  Warning: Could not download administrative hierarchy. Proceeding with main dataset only.\n")
}

# STEP 3: Attempt to download spatial data (optional for this analysis)
cat("📥 Downloading: Ukrainian Spatial Boundaries (GeoJSON)\n")
cat("   URL:", ua_admin_urls$spatial_data, "\n")

ua_spatial_data <- tryCatch({
  # Note: This is a large file and may take time
  sf::st_read(ua_admin_urls$spatial_data, quiet = TRUE)
}, error = function(e) {
  cat("   ⚠️  Could not download spatial data:", e$message, "\n")
  cat("   📋 Proceeding without spatial boundaries (can be added later)\n")
  return(NULL)
})

if (!is.null(ua_spatial_data)) {
  cat("   ✓ Success:", nrow(ua_spatial_data), "spatial features loaded\n")
}

cat("\n📊 DATA LOADING COMPLETE\n\n")

# ---- inspect-data-0 ----------------------------------------------------------
cat("🔍 DATASET OVERVIEW:\n")
cat(paste(rep("=", 50), collapse = ""), "\n")

# Main dataset structure
cat("\n📄 MAIN DATASET (Hromada-level):\n")
cat("   Dimensions:", nrow(ua_main_data), "×", ncol(ua_main_data), "\n")
cat("   Columns (first 10):", paste(names(ua_main_data)[1:min(10, ncol(ua_main_data))], collapse = ", "), "\n")
if (ncol(ua_main_data) > 10) cat("   ... and", ncol(ua_main_data) - 10, "more columns\n")

# Check administrative levels available
if ("oblast_name_en" %in% names(ua_main_data)) {
  n_oblasts <- ua_main_data %>% distinct(oblast_name_en) %>% nrow()
  cat("   ✓ Contains", n_oblasts, "oblasts\n")
}

if ("raion_name" %in% names(ua_main_data)) {
  n_raions <- ua_main_data %>% distinct(raion_name) %>% nrow()
  cat("   ✓ Contains", n_raions, "raions\n")
}

# Administrative hierarchy structure (if available)
if (!is.null(ua_admin_hierarchy)) {
  cat("\n📄 ADMINISTRATIVE HIERARCHY:\n")
  cat("   Dimensions:", nrow(ua_admin_hierarchy), "×", ncol(ua_admin_hierarchy), "\n")
  cat("   Levels: settlement → rada → hromada → raion → oblast → region\n")
}

# Spatial data structure (if available)
if (!is.null(ua_spatial_data)) {
  cat("\n📄 SPATIAL DATA:\n")
  cat("   Features:", nrow(ua_spatial_data), "\n")
  cat("   Geometry type:", class(ua_spatial_data$geometry)[1], "\n")
}

# ---- tweak-data-0 ------------------------------------------------------------
cat("\n🔧 DATA PROCESSING & STANDARDIZATION:\n")
cat(paste(rep("=", 50), collapse = ""), "\n")

# =============================================================================
# UKRAINIAN ADMINISTRATIVE DATA STRUCTURE FOR OBLAST-LEVEL ANALYSIS
# =============================================================================
# Primary focus: Aggregate hromada-level data to oblast level for mapping
# Target: Create oblast-level indicators suitable for choropleth maps
# Data grain: One record per oblast per indicator
# =============================================================================

# STEP 1: Clean and standardize main dataset
cat("🧹 Cleaning main hromada dataset...\n")

ua_hromadas_clean <- ua_main_data %>%
  # COLUMN NAME STANDARDIZATION: Use janitor for consistent naming
  janitor::clean_names() %>%
  
  # DATA TYPE CORRECTIONS: Ensure proper types for key variables
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
    
    # Handle duplicate population columns (common data issue)
    urban_population_2022 = coalesce(urban_popultaion_2022_x, urban_popultaion_2022_y),
    
    # Create calculated indicators for oblast aggregation
    population_density = ifelse(square > 0, total_popultaion_2022 / square, 0),
    urban_pct = ifelse(total_popultaion_2022 > 0, urban_population_2022 / total_popultaion_2022 * 100, 0),
    income_per_capita_2021 = ifelse(total_popultaion_2022 > 0, income_total_2021 / total_popultaion_2022, 0),
    income_per_capita_2022 = ifelse(total_popultaion_2022 > 0, income_total_2022 / total_popultaion_2022, 0),
    income_change_pct = ifelse(income_total_2021 > 0, 
                              (income_total_2022 - income_total_2021) / income_total_2021 * 100, 0)
  ) %>%
  
  # STANDARDIZE OBLAST NAMES: Ensure consistent English names for mapping
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
  
  # QUALITY FILTERS: Remove records with critical missing data
  filter(
    !is.na(oblast_name_en),
    !is.na(hromada_code),
    total_popultaion_2022 > 0  # Remove empty/invalid hromadas
  )

cat("   ✓ Cleaned dataset:", nrow(ua_hromadas_clean), "hromadas\n")
cat("   ✓ Covering", ua_hromadas_clean %>% distinct(oblast_name_en) %>% nrow(), "oblasts\n")

# STEP 2: Create oblast-level aggregated data for mapping
cat("🗺️  Creating oblast-level aggregations...\n")

# AGGREGATION STRATEGY: Different methods for different indicator types
# - SUMS: Population, area, financial totals
# - MEANS: Rates, percentages, per-capita measures  
# - COUNTS: Number of hromadas, settlements
ua_oblasts_aggregated <- ua_hromadas_clean %>%
  group_by(oblast_name_en, oblast_code, region_en) %>%
  summarise(
    # ADMINISTRATIVE COUNTS
    n_hromadas = n(),
    n_settlements = sum(n_settlements, na.rm = TRUE),
    
    # POPULATION INDICATORS
    total_population = sum(total_popultaion_2022, na.rm = TRUE),
    urban_population = sum(urban_population_2022, na.rm = TRUE),
    avg_population_density = ifelse(sum(total_popultaion_2022, na.rm = TRUE) > 0,
                                   weighted.mean(population_density, total_popultaion_2022, na.rm = TRUE),
                                   0),
    urbanization_pct = ifelse(total_population > 0, urban_population / total_population * 100, 0),
    
    # GEOGRAPHIC INDICATORS  
    total_area = sum(square, na.rm = TRUE),
    avg_travel_time = ifelse(sum(total_popultaion_2022, na.rm = TRUE) > 0,
                            weighted.mean(travel_time, total_popultaion_2022, na.rm = TRUE),
                            NA_real_),
    
    # ECONOMIC INDICATORS (population-weighted averages for rates)
    total_income_2021 = sum(income_total_2021, na.rm = TRUE),
    total_income_2022 = sum(income_total_2022, na.rm = TRUE),
    avg_income_per_capita_2021 = ifelse(sum(total_popultaion_2022, na.rm = TRUE) > 0,
                                       weighted.mean(income_per_capita_2021, total_popultaion_2022, na.rm = TRUE),
                                       0),
    avg_income_per_capita_2022 = ifelse(sum(total_popultaion_2022, na.rm = TRUE) > 0,
                                       weighted.mean(income_per_capita_2022, total_popultaion_2022, na.rm = TRUE),
                                       0),
    
    # WAR-RELATED INDICATORS (if available)
    pct_war_affected = if("war_zone_27_04_2022" %in% names(ua_hromadas_clean)) {
      sum(war_zone_27_04_2022 %in% c(1, "1", "Yes", "Так"), na.rm = TRUE) / n() * 100
    } else { NA_real_ },
    
    .groups = "drop"
  ) %>%
  
  # CALCULATED OBLAST-LEVEL INDICATORS
  mutate(
    # Overall population density at oblast level
    oblast_population_density = ifelse(total_area > 0, total_population / total_area, 0),
    
    # Income change rate
    income_growth_pct = ifelse(total_income_2021 > 0, 
                              (total_income_2022 - total_income_2021) / total_income_2021 * 100, 0),
    
    # Administrative efficiency (population per hromada)
    avg_hromada_size = total_population / n_hromadas,
    
    # Regional classification for analysis
    region_type = case_when(
      region_en == "West" ~ "Western Ukraine",
      region_en == "Center" ~ "Central Ukraine", 
      region_en == "East" ~ "Eastern Ukraine",
      region_en == "South" ~ "Southern Ukraine",
      TRUE ~ "Other"
    )
  ) %>%
  
  # SORT BY POPULATION (largest oblasts first)
  arrange(desc(total_population))

cat("   ✓ Created oblast aggregations:", nrow(ua_oblasts_aggregated), "oblasts\n")

# STEP 3: Create dimension tables for analysis context
cat("📊 Creating dimension tables...\n")

# Oblast dimension with metadata
dim_oblasts <- ua_oblasts_aggregated %>%
  select(oblast_code, oblast_name_en, region_en, region_type) %>%
  mutate(
    oblast_id = row_number(),
    # Add useful metadata for mapping
    is_capital_region = oblast_name_en == "Kyiv",
    is_border_oblast = oblast_name_en %in% c("Kharkiv", "Sumy", "Chernihiv", "Volyn", "Lviv", "Zakarpattia")
  )

# Regional dimension
dim_regions <- ua_oblasts_aggregated %>%
  distinct(region_en, region_type) %>%
  mutate(region_id = row_number()) %>%
  arrange(region_en)

# Hromada-level fact table (for detailed analysis when needed)
fact_hromadas <- ua_hromadas_clean %>%
  select(
    hromada_code, hromada_name, oblast_code, oblast_name_en, raion_name,
    type, total_popultaion_2022, square, population_density, 
    income_per_capita_2021, income_per_capita_2022, income_change_pct,
    lat_center, lon_center, travel_time
  ) %>%
  # Add foreign keys for star schema
  left_join(
    dim_oblasts %>% select(oblast_code, oblast_id), 
    by = "oblast_code"
  )

cat("   ✓ dim_oblasts:", nrow(dim_oblasts), "records\n")
cat("   ✓ dim_regions:", nrow(dim_regions), "records\n") 
cat("   ✓ fact_hromadas:", nrow(fact_hromadas), "records\n")

# ---- save-to-disk ------------------------------------------------------------
cat("\n💾 SAVING TO DATABASE AND FILES:\n")

# Save all tables to SQLite database
dbWriteTable(db_ua_admin, "ua_oblasts_aggregated", ua_oblasts_aggregated, overwrite = TRUE)
dbWriteTable(db_ua_admin, "dim_oblasts", dim_oblasts, overwrite = TRUE)
dbWriteTable(db_ua_admin, "dim_regions", dim_regions, overwrite = TRUE)
dbWriteTable(db_ua_admin, "fact_hromadas", fact_hromadas, overwrite = TRUE)

# Save raw data for reference
dbWriteTable(db_ua_admin, "raw_ua_hromadas", ua_main_data, overwrite = TRUE)
if (!is.null(ua_admin_hierarchy)) {
  dbWriteTable(db_ua_admin, "raw_ua_admin_hierarchy", ua_admin_hierarchy, overwrite = TRUE)
}

# Save spatial data if available
if (!is.null(ua_spatial_data)) {
  # Note: Spatial data requires special handling for SQLite
  tryCatch({
    sf::st_write(ua_spatial_data, "data-private/derived/manipulation/ua_hromada_boundaries.geojson", 
                 delete_dsn = TRUE, quiet = TRUE)
    cat("   ✓ Saved spatial data to GeoJSON\n")
  }, error = function(e) {
    cat("   ⚠️  Could not save spatial data:", e$message, "\n")
  })
}

# Save to CSV files for external access
write.csv(ua_oblasts_aggregated, paste0(data_private_derived_csv, "ua_oblasts_aggregated.csv"), row.names = FALSE)
write.csv(dim_oblasts, paste0(data_private_derived_csv, "dim_oblasts.csv"), row.names = FALSE)
write.csv(dim_regions, paste0(data_private_derived_csv, "dim_regions.csv"), row.names = FALSE)
write.csv(fact_hromadas, paste0(data_private_derived_csv, "fact_hromadas.csv"), row.names = FALSE)

# Save processed tables as RDS for R analysis
saveRDS(ua_oblasts_aggregated, paste0(data_private_derived, "ua_oblasts_aggregated.rds"))
saveRDS(dim_oblasts, paste0(data_private_derived, "dim_oblasts.rds"))
saveRDS(dim_regions, paste0(data_private_derived, "dim_regions.rds"))
saveRDS(fact_hromadas, paste0(data_private_derived, "fact_hromadas.rds"))

cat("   ✓ Saved to SQLite database\n")
cat("   ✓ Saved to CSV files\n")
cat("   ✓ Saved to RDS files\n")

# ---- analysis-below ----------------------------------------------------------
# Quick validation and summary statistics
cat("\n📊 QUICK VALIDATION & SUMMARY:\n")

# Show oblast rankings by key indicators
cat("\n🏆 TOP 5 OBLASTS BY POPULATION:\n")
top_population <- ua_oblasts_aggregated %>%
  select(oblast_name_en, total_population, n_hromadas) %>%
  head(5)
print(top_population)

cat("\n💰 TOP 5 OBLASTS BY INCOME PER CAPITA (2022):\n")
top_income <- ua_oblasts_aggregated %>%
  arrange(desc(avg_income_per_capita_2022)) %>%
  select(oblast_name_en, avg_income_per_capita_2022, region_type) %>%
  head(5)
print(top_income)

cat("\n🌆 MOST URBANIZED OBLASTS:\n")
top_urban <- ua_oblasts_aggregated %>%
  arrange(desc(urbanization_pct)) %>%
  select(oblast_name_en, urbanization_pct, region_type) %>%
  head(5)
print(top_urban)

# Regional summary
cat("\n🗺️  SUMMARY BY REGION:\n")
regional_summary <- ua_oblasts_aggregated %>%
  group_by(region_type) %>%
  summarise(
    n_oblasts = n(),
    sum_population = sum(total_population, na.rm = TRUE),
    avg_income_per_capita_2022 = ifelse(sum(total_population, na.rm = TRUE) > 0,
                                       weighted.mean(avg_income_per_capita_2022, total_population, na.rm = TRUE),
                                       NA_real_),
    avg_urbanization = ifelse(sum(total_population, na.rm = TRUE) > 0,
                             weighted.mean(urbanization_pct, total_population, na.rm = TRUE),
                             NA_real_),
    .groups = "drop"
  ) %>%
  dplyr::rename(total_population = sum_population)
print(regional_summary)

# Database verification
cat("\n🔍 DATABASE VERIFICATION:\n")
tables <- c("ua_oblasts_aggregated", "dim_oblasts", "dim_regions", "fact_hromadas")
for (table in tables) {
  count <- dbGetQuery(db_ua_admin, paste("SELECT COUNT(*) as count FROM", table))$count
  cat("   ✓", table, ":", count, "records\n")
}

# Close database connection
dbDisconnect(db_ua_admin)

cat("\n✅ UKRAINIAN ADMINISTRATIVE DATA PROCESSING COMPLETE!\n")
cat("🎯 Ready for oblast-level mapping and analysis\n")
cat("📁 Database location: data-private/derived/manipulation/SQLite/ua-admin-analysis.sqlite\n")
cat("💡 Next steps: Create oblast-level maps using ua_oblasts_aggregated table\n")

# ---- cleanup-environment -----------------------------------------------------
# Remove temporary objects, keep processed data for further analysis
objects_to_keep <- c("ua_oblasts_aggregated", "dim_oblasts", "fact_hromadas", "safe_numeric_convert")
objects_to_remove <- setdiff(ls(), objects_to_keep)
rm(list = objects_to_remove)

cat("\n🧹 Environment cleaned - kept key Ukrainian administrative datasets\n")
cat("📊 Available for analysis: ua_oblasts_aggregated, dim_oblasts, fact_hromadas\n")
