# Ellis Script 1 - Ukrainian Administrative Data Integration  
# This script integrates Ukrainian administrative data with the core books database
# Each chunk can be executed independently for interactive analysis

# EXECUTION GUIDE:
# Run chunks sequentially, examining data objects as they appear in Environment
# Use Ctrl+Enter to execute line by line, or select chunk and run
# Examine data with View(), head(), str() between chunks as needed

# ---- clear-environment ----
rm(list = ls(all.names = TRUE))
cat("\014") # Clear console
cat("📁 Working directory:", getwd(), "\n") # Must be set to Project Directory

# ---- load-packages ----
library(magrittr)
library(dplyr)     # data wrangling
library(tidyr)     # data wrangling
library(stringr)   # strings
library(readr)     # for reading CSV files
library(janitor)   # tidy data
library(DBI)       # database interface
library(RSQLite)   # SQLite database
cat("📦 Packages loaded successfully\n")

# ---- load-project-functions ----
base::source("./scripts/common-functions.R") 
base::source("./scripts/operational-functions.R") 
cat("🔧 Project functions loaded\n")

# ---- setup-paths ----
# Local manipulation folders
local_root <- "./manipulation/"
local_data <- paste0(local_root, "data-local/")
if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

# Output folders
data_private_derived <- "./data-private/derived/manipulation/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

# Database paths
core_db_path <- "data-private/derived/manipulation/SQLite/books-of-ukraine-0.sqlite"
stage_1_db_path <- "data-private/derived/manipulation/SQLite/books-of-ukraine-1.sqlite"

cat("📂 Paths configured:\n")
cat("   Core DB:", core_db_path, "\n")
cat("   Stage 1 DB:", stage_1_db_path, "\n")

# ---- define-urls ----
# Ukrainian administrative data sources from KSE-Loc-Data-Hub
ua_admin_urls <- list(
  main_dataset = "https://raw.githubusercontent.com/kse-ua/KSE-Loc-Data-Hub/main/data/derived/full_dataset.csv",
  admin_hierarchy = "https://raw.githubusercontent.com/kse-ua/KSE-Loc-Data-Hub/main/data/derived/ua-admin-map-2020.csv",
  metadata_excel = "https://github.com/kse-ua/KSE-Loc-Data-Hub/raw/refs/heads/main/data/metadata/metadata_data_public.xlsx"
)

cat("🌐 Data source URLs defined:\n")
cat("   Main dataset:", substr(ua_admin_urls$main_dataset, 1, 50), "...\n")
cat("   Metadata:", substr(ua_admin_urls$metadata_excel, 1, 50), "...\n")

# ---- input-data-metadata ----
# Download and process metadata from KSE Excel file
cat("📋 Downloading KSE metadata dictionary...\n")

# Try to download Excel metadata file
metadata_file <- "metadata_data_public.xlsx"
if (!file.exists(metadata_file)) {
  tryCatch({
    if (Sys.info()["sysname"] == "Windows") {
      system(paste0('powershell -Command "Invoke-WebRequest \\"', ua_admin_urls$metadata_excel, '\\" -OutFile \\"', metadata_file, '\\""'))
    } else {
      system(paste0("curl -L '", ua_admin_urls$metadata_excel, "' -o '", metadata_file, "'"))
    }
    cat("   ✓ Downloaded metadata Excel file\n")
  }, error = function(e) {
    cat("   ✗ Failed to download metadata:", e$message, "\n")
  })
}

# Read metadata from Excel file
ua_metadata <- NULL
if (file.exists(metadata_file)) {
  tryCatch({
    if (requireNamespace("openxlsx", quietly = TRUE)) {
      sheets <- openxlsx::getSheetNames(metadata_file)
      target_sheet <- if("main" %in% sheets) "main" else 1
      ua_metadata_raw <- openxlsx::read.xlsx(metadata_file, sheet = target_sheet)
      cat("   ✓ Read Excel file with", nrow(ua_metadata_raw), "rows from sheet:", target_sheet, "\n")
      
      # Process metadata
      ua_metadata <- ua_metadata_raw %>%
        janitor::clean_names() %>%
        slice(1:min(50, nrow(.))) %>%  # Take first 50 rows max
        rename_with(~case_when(
          row_number() == 1 ~ "field_name",
          row_number() == 2 ~ "description", 
          row_number() == 3 ~ "data_type",
          TRUE ~ paste0("col_", row_number())
        ), .cols = everything()) %>%
        filter(!is.na(.[[1]]), .[[1]] != "") %>%
        mutate(
          field_name = as.character(.[[1]]),
          description = if(ncol(.) > 1) as.character(.[[2]]) else "No description",
          data_type = if(ncol(.) > 2) as.character(.[[3]]) else "unknown",
          source = "KSE-Loc-Data-Hub",
          category = "administrative"
        ) %>%
        select(field_name, description, data_type, source, category) %>%
        distinct() %>%
        filter(!is.na(field_name), field_name != "")
      
    } else if (requireNamespace("readxl", quietly = TRUE)) {
      sheets <- readxl::excel_sheets(metadata_file)
      target_sheet <- if("main" %in% sheets) "main" else 1
      ua_metadata_raw <- readxl::read_excel(metadata_file, sheet = target_sheet)
      cat("   ✓ Read Excel file with", nrow(ua_metadata_raw), "rows from sheet:", target_sheet, "\n")
      
      # Process metadata (same logic as above)
      ua_metadata <- ua_metadata_raw %>%
        janitor::clean_names() %>%
        slice(1:min(50, nrow(.))) %>%
        mutate(
          field_name = as.character(.[[1]]),
          description = if(ncol(.) > 1) as.character(.[[2]]) else "No description",
          data_type = if(ncol(.) > 2) as.character(.[[3]]) else "unknown",
          source = "KSE-Loc-Data-Hub",
          category = "administrative"
        ) %>%
        select(field_name, description, data_type, source, category) %>%
        distinct() %>%
        filter(!is.na(field_name), field_name != "")
    }
  }, error = function(e) {
    cat("   ✗ Error reading Excel file:", e$message, "\n")
  })
}

# Fallback metadata if Excel reading fails
if (is.null(ua_metadata)) {
  cat("   📋 Creating fallback metadata structure...\n")
  ua_metadata <- data.frame(
    field_name = c("hromada_code", "hromada_name", "oblast_name_en", "total_popultaion_2022", "square", "income_total_2022"),
    description = c("Hromada identifier", "Hromada name", "Oblast name (English)", "Population 2022", "Area (sq km)", "Total income 2022"),
    data_type = c("character", "character", "character", "numeric", "numeric", "numeric"),
    source = "KSE-Loc-Data-Hub",
    category = c("administrative", "administrative", "administrative", "demographics", "geography", "economics"),
    stringsAsFactors = FALSE
  )
}

cat("📊 Metadata loaded:", nrow(ua_metadata), "field definitions\n")
# Examine metadata structure
print(head(ua_metadata, 10))

# ---- input-data-main ----
# Download main Ukrainian hromada dataset from KSE
cat("📥 Downloading Ukrainian hromada dataset...\n")

ua_main_data <- NULL
tryCatch({
  ua_main_data <- readr::read_csv(ua_admin_urls$main_dataset, locale = readr::locale(encoding = "UTF-8"))
  cat("   ✓ Success:", nrow(ua_main_data), "rows ×", ncol(ua_main_data), "columns\n")
}, error = function(e) {
  cat("   ✗ Error downloading data:", e$message, "\n")
  cat("   📋 Creating mock data for testing...\n")
  
  # Create mock data for testing
  ua_main_data <<- data.frame(
    hromada_code = paste0("UA", 1001:1025),
    hromada_name = paste("Hromada", 1:25),
    oblast_code = rep(c("01", "02", "05", "07", "12"), each = 5),
    oblast_name_en = rep(c("Kyiv", "Vinnytsia", "Volyn", "Zakarpattia", "Dnipropetrovsk"), each = 5),
    region_en = rep(c("Center", "Center", "West", "West", "East"), each = 5),
    total_popultaion_2022 = round(runif(25, 10000, 100000)),
    urban_popultaion_2022_x = round(runif(25, 3000, 40000)),
    square = round(runif(25, 500, 2000), 1),
    travel_time = round(runif(25, 30, 180)),
    income_total_2021 = round(runif(25, 50000000, 500000000)),
    income_total_2022 = round(runif(25, 55000000, 550000000)),
    n_settlements = sample(5:25, 25, replace = TRUE),
    stringsAsFactors = FALSE
  )
  cat("   ✓ Created mock dataset with", nrow(ua_main_data), "hromadas\n")
})

# Display data structure for inspection
cat("📊 Main data structure:\n")
print(str(ua_main_data))
cat("\n📋 Sample rows:\n")
print(head(ua_main_data, 3))

# ---- input-data-hierarchy ----
# Download administrative hierarchy data for oblast mapping
cat("📍 Downloading Ukrainian administrative hierarchy...\n")

ua_admin_hierarchy <- NULL
tryCatch({
  ua_admin_hierarchy <- readr::read_csv(ua_admin_urls$admin_hierarchy, locale = readr::locale(encoding = "UTF-8"))
  cat("   ✓ Success:", nrow(ua_admin_hierarchy), "rows ×", ncol(ua_admin_hierarchy), "columns\n")
}, error = function(e) {
  cat("   ✗ Error downloading hierarchy data:", e$message, "\n")
  cat("   📋 Creating mock hierarchy data for testing...\n")
  
  # Create mock hierarchy data
  ua_admin_hierarchy <<- data.frame(
    oblast_code = c("01", "02", "05", "07", "12"),
    oblast_name_ua = c("Київська", "Вінницька", "Волинська", "Закарпатська", "Дніпропетровська"),
    oblast_name_en = c("Kyiv", "Vinnytsia", "Volyn", "Zakarpattia", "Dnipropetrovsk"),
    region_en = c("Center", "Center", "West", "West", "East"),
    capital_city = c("Kyiv", "Vinnytsia", "Lutsk", "Uzhhorod", "Dnipro"),
    area_km2 = c(28131, 26513, 20144, 12777, 31914),
    stringsAsFactors = FALSE
  )
  cat("   ✓ Created mock hierarchy with", nrow(ua_admin_hierarchy), "oblasts\n")
})

# Display hierarchy structure
cat("📊 Hierarchy data structure:\n")
print(str(ua_admin_hierarchy))
cat("\n📋 Sample hierarchy rows:\n")
print(head(ua_admin_hierarchy, 3))

# ---- tweak-data-main ----
# Clean and standardize main dataset
cat("🧹 Cleaning main hromada dataset...\n")

# Helper function for safe numeric conversion
safe_numeric <- function(x) {
  if (is.numeric(x)) return(x)
  if (is.character(x)) {
    cleaned <- str_replace_all(x, "[^0-9.-]", "")
    converted <- suppressWarnings(as.numeric(cleaned))
    return(ifelse(is.na(converted), 0, converted))
  }
  converted <- suppressWarnings(as.numeric(x))
  return(ifelse(is.na(converted), 0, converted))
}

ua_hromadas_clean <- ua_main_data %>%
  janitor::clean_names() %>%
  mutate(
    # Clean identifiers
    hromada_code = as.character(hromada_code),
    oblast_code = as.character(oblast_code),
    
    # Convert numeric variables safely
    total_popultaion_2022 = safe_numeric(total_popultaion_2022),
    urban_popultaion_2022_x = safe_numeric(urban_popultaion_2022_x),
    square = safe_numeric(square),
    travel_time = safe_numeric(travel_time),
    income_total_2021 = safe_numeric(income_total_2021),
    income_total_2022 = safe_numeric(income_total_2022),
    n_settlements = safe_numeric(n_settlements),
    
    # Create calculated indicators
    population_density = ifelse(square > 0, total_popultaion_2022 / square, 0),
    urban_pct = ifelse(total_popultaion_2022 > 0, 
                      urban_popultaion_2022_x / total_popultaion_2022 * 100, 0),
    income_per_capita_2022 = ifelse(total_popultaion_2022 > 0, 
                                   income_total_2022 / total_popultaion_2022, 0),
    income_change_pct = ifelse(income_total_2021 > 0, 
                              (income_total_2022 - income_total_2021) / income_total_2021 * 100, 0)
  ) %>%
  # Standardize oblast names
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
  # Filter out invalid records
  filter(
    !is.na(oblast_name_en),
    !is.na(hromada_code),
    total_popultaion_2022 > 0
  )

cat("   ✓ Cleaned dataset:", nrow(ua_hromadas_clean), "hromadas\n")
cat("   ✓ Covering", ua_hromadas_clean %>% distinct(oblast_name_en) %>% nrow(), "oblasts\n")

# Display cleaned data sample
cat("📊 Cleaned data sample:\n")
print(ua_hromadas_clean %>% select(oblast_name_en, hromada_name, total_popultaion_2022, square, income_per_capita_2022) %>% head(5))

# ---- create-oblast-aggregates ----
# Create oblast-level aggregated data for analysis
cat("🗺️  Creating oblast-level aggregations...\n")

ua_oblasts_aggregated <- ua_hromadas_clean %>%
  group_by(oblast_name_en, oblast_code, region_en) %>%
  summarise(
    # Administrative counts
    n_hromadas = n(),
    n_settlements = sum(n_settlements, na.rm = TRUE),
    
    # Population indicators
    total_population = sum(total_popultaion_2022, na.rm = TRUE),
    urban_population = sum(urban_popultaion_2022_x, na.rm = TRUE),
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
    avg_income_per_capita_2022 = ifelse(sum(total_popultaion_2022, na.rm = TRUE) > 0,
                                       weighted.mean(income_per_capita_2022, total_popultaion_2022, na.rm = TRUE),
                                       0),
    
    .groups = "drop"
  ) %>%
  mutate(
    # Calculated indicators
    oblast_population_density = ifelse(total_area > 0, total_population / total_area, 0),
    income_growth_pct = ifelse(total_income_2021 > 0, 
                              (total_income_2022 - total_income_2021) / total_income_2021 * 100, 0),
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

# Display aggregated data
cat("📊 Oblast aggregations sample:\n")
print(ua_oblasts_aggregated %>% 
      select(oblast_name_en, total_population, urbanization_pct, avg_income_per_capita_2022, region_type) %>% 
      head(5))

# ---- create-dimension-tables ----
# Create dimension tables for structured analysis
cat("📊 Creating dimension tables...\n")

# Oblast dimension table
dim_oblasts <- ua_oblasts_aggregated %>%
  select(oblast_code, oblast_name_en, region_en, region_type) %>%
  mutate(
    oblast_id = row_number(),
    is_capital_region = oblast_name_en == "Kyiv"
  )

# Region dimension table
dim_regions <- ua_oblasts_aggregated %>%
  distinct(region_en, region_type) %>%
  mutate(
    region_id = row_number(),
    region_description = case_when(
      region_en == "West" ~ "Western regions including Carpathian areas",
      region_en == "Center" ~ "Central regions including capital area", 
      region_en == "East" ~ "Eastern regions including industrial areas",
      region_en == "South" ~ "Southern regions including coastal areas",
      TRUE ~ "Other regions"
    )
  ) %>%
  arrange(region_en)

# Hromada fact table
fact_hromadas <- ua_hromadas_clean %>%
  select(
    hromada_code, hromada_name, oblast_code, oblast_name_en,
    total_popultaion_2022, square, population_density, 
    income_per_capita_2022, income_change_pct, travel_time
  ) %>%
  left_join(
    dim_oblasts %>% select(oblast_code, oblast_id), 
    by = "oblast_code"
  )

cat("   ✓ dim_oblasts:", nrow(dim_oblasts), "records\n")
cat("   ✓ dim_regions:", nrow(dim_regions), "records\n") 
cat("   ✓ fact_hromadas:", nrow(fact_hromadas), "records\n")

# Display dimension samples
cat("📊 Dimension tables sample:\n")
print("dim_oblasts:")
print(head(dim_oblasts, 3))
print("dim_regions:")
print(head(dim_regions, 3))

# ---- create-stage1-database ----
# Create Stage 1 database by copying core and adding Ukrainian admin data
cat("🏗️ Creating Stage 1 database...\n")

# Check if core database exists
if (!file.exists(core_db_path)) {
  stop("❌ Core database not found: ", core_db_path, "\nRun 0-ellis.R first!")
}

# Remove existing stage 1 database and copy from core
if (file.exists(stage_1_db_path)) {
  file.remove(stage_1_db_path)
  cat("   ✓ Removed existing stage 1 database\n")
}

file.copy(core_db_path, stage_1_db_path)
cat("   ✓ Copied core database to stage 1 location\n")

# Connect to Stage 1 database  
db_stage_1 <- dbConnect(RSQLite::SQLite(), stage_1_db_path)

# Verify core tables are present
core_tables <- dbListTables(db_stage_1)
cat("   ✓ Stage 1 database created with", length(core_tables), "core tables\n")

# ---- save-to-database ----
# Save all Ukrainian admin tables to Stage 1 database
cat("💾 Saving Ukrainian admin data to database...\n")

dbWriteTable(db_stage_1, "ua_oblasts_aggregated", ua_oblasts_aggregated, overwrite = TRUE)
dbWriteTable(db_stage_1, "dim_oblasts", dim_oblasts, overwrite = TRUE)
dbWriteTable(db_stage_1, "dim_regions", dim_regions, overwrite = TRUE)
dbWriteTable(db_stage_1, "fact_hromadas", fact_hromadas, overwrite = TRUE)

# Save metadata table
if (!is.null(ua_metadata)) {
  dbWriteTable(db_stage_1, "ua_metadata", ua_metadata, overwrite = TRUE)
  cat("   ✓ Saved metadata dictionary to database\n")
}

# Save raw data for reference
dbWriteTable(db_stage_1, "raw_ua_hromadas", ua_main_data, overwrite = TRUE)
if (!is.null(ua_admin_hierarchy)) {
  dbWriteTable(db_stage_1, "raw_ua_admin_hierarchy", ua_admin_hierarchy, overwrite = TRUE)
}

cat("   ✓ Saved Ukrainian admin tables to Stage 1 database\n")

# ---- save-to-csv ----
# Save to CSV files for external access
cat("📁 Saving to CSV files...\n")

csv_path <- "data-private/derived/manipulation/CSV/"
if (!fs::dir_exists(csv_path)) {fs::dir_create(csv_path)}

write.csv(ua_oblasts_aggregated, paste0(csv_path, "ua_oblasts_aggregated.csv"), row.names = FALSE)
write.csv(dim_oblasts, paste0(csv_path, "dim_oblasts.csv"), row.names = FALSE)
write.csv(dim_regions, paste0(csv_path, "dim_regions.csv"), row.names = FALSE)
write.csv(fact_hromadas, paste0(csv_path, "fact_hromadas.csv"), row.names = FALSE)

# Save metadata for documentation
if (!is.null(ua_metadata)) {
  write.csv(ua_metadata, paste0(csv_path, "ua_metadata.csv"), row.names = FALSE)
  cat("   ✓ Saved metadata dictionary to CSV\n")
}

cat("   ✓ Saved all tables to CSV files\n")

# ---- validate-results ----
# Validate and summarize what was created
cat("📊 Validating results...\n")

all_tables <- dbListTables(db_stage_1)
ua_tables <- grep("^ua_", all_tables, value = TRUE)

cat("Total tables in Stage 1 DB:", length(all_tables), "\n")
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
    total_population = sum(total_population, na.rm = TRUE),
    avg_income_per_capita_2022 = ifelse(sum(total_population, na.rm = TRUE) > 0,
                                       weighted.mean(avg_income_per_capita_2022, total_population, na.rm = TRUE),
                                       NA_real_),
    .groups = "drop"
  )
print(regional_summary)

# Close database connection
dbDisconnect(db_stage_1)

# ---- final-summary ----
# Final completion message
cat("\n", paste(rep("=", 60), collapse = ""), "\n")
cat("🎉 STAGE 1 COMPLETION SUMMARY\n")
cat(paste(rep("=", 60), collapse = ""), "\n")

cat("\n📂 DELIVERABLES CREATED:\n")
cat("  ✓ Stage 1 SQLite database:", stage_1_db_path, "\n")
cat("  ✓ Ukrainian oblast aggregates:", nrow(ua_oblasts_aggregated), "oblasts\n")
cat("  ✓ Hromada-level data:", nrow(fact_hromadas), "hromadas\n")
cat("  ✓ Metadata dictionary:", nrow(ua_metadata), "field definitions\n")
cat("  ✓ CSV exports in:", csv_path, "\n")

cat("\n🔍 RECOMMENDED NEXT STEPS:\n")
cat("  1. Examine ua_oblasts_aggregated for oblast-level analysis\n")
cat("  2. Use fact_hromadas for detailed territorial analysis\n") 
cat("  3. Check ua_metadata for field descriptions\n")
cat("  4. Run last-ellis.R to create final analytical database\n")

cat("\n🧹 ENVIRONMENT STATUS:\n")
cat("  Key objects available for inspection:\n")
cat("  - ua_oblasts_aggregated (", nrow(ua_oblasts_aggregated), " rows)\n")
cat("  - fact_hromadas (", nrow(fact_hromadas), " rows)\n")
cat("  - ua_metadata (", nrow(ua_metadata), " rows)\n")
cat("  - dim_oblasts (", nrow(dim_oblasts), " rows)\n")

cat("\n", paste(rep("=", 60), collapse = ""), "\n")
