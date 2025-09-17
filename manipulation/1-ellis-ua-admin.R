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
library(sf)

# Install and load tmap if needed
if (!requireNamespace("tmap", quietly = TRUE)) {
  cat("📦 Installing tmap package...\n")
  install.packages("tmap", repos = "https://cran.rstudio.com", dependencies = TRUE)
}
library(tmap)
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

# ---- load-data ---------------------------------------------------------------

## 1. Metadata dictionary
# Download and process metadata from KSE Excel file
cat("📋 Downloading KSE metadata dictionary...\n")

# Ensure raw data directory exists
raw_data_dir <- "./data-private/raw/"
if (!fs::dir_exists(raw_data_dir)) {fs::dir_create(raw_data_dir)}

# Download Excel metadata file to raw data folder
metadata_file <- paste0(raw_data_dir, "metadata_data_public.xlsx")
if (!file.exists(metadata_file)) {
  cat("   📥 Downloading metadata Excel file...\n")
  tryCatch({
    if (Sys.info()["sysname"] == "Windows") {
      system(paste0('powershell -Command "Invoke-WebRequest \\"', ua_admin_urls$metadata_excel, '\\" -OutFile \\"', metadata_file, '\\""'))
    } else {
      system(paste0("curl -L '", ua_admin_urls$metadata_excel, "' -o '", metadata_file, "'"))
    }
    
    if (file.exists(metadata_file)) {
      cat("   ✓ Downloaded metadata Excel file\n")
    } else {
      stop("Download failed - file not created")
    }
  }, error = function(e) {
    stop("Failed to download metadata Excel file: ", e$message)
  })
} else {
  cat("   ✓ Metadata file already exists\n")
}

# Read metadata from Excel file
tryCatch({
  if (requireNamespace("readxl", quietly = TRUE)) {
    sheets <- readxl::excel_sheets(metadata_file)
    if (!"main" %in% sheets) {
      stop("Required 'main' sheet not found in Excel file. Available sheets: ", paste(sheets, collapse = ", "))
    }
    ua_metadata <- readxl::read_excel(metadata_file)
    cat("   ✓ Read Excel file with", nrow(ua_metadata), "rows from 'main' sheet\n")
 
  } else {
    stop("readxl package not available - cannot read Excel file")
  }
}, error = function(e) {
  stop("Failed to read metadata Excel file: ", e$message)
})

cat("📊 Metadata loaded:", nrow(ua_metadata), "rows ×", ncol(ua_metadata), "columns\n")
ua_metadata %>% glimpse()


## 2. Main data table 
# Download main Ukrainian hromada dataset from KSE
cat("📥 Downloading Ukrainian hromada dataset...\n")

ua_main_data <- NULL
tryCatch({
  ua_main_data <- 
    readr::read_csv(ua_admin_urls$main_dataset, locale = readr::locale(encoding = "UTF-8")) %>% 
    janitor::clean_names() %>% 
    rename(
      urban_popultaion_2022 = urban_popultaion_2022_x 
    ) %>% 
    select(
      -urban_popultaion_2022_y
    )
  cat("   ✓ Success:", nrow(ua_main_data), "rows ×", ncol(ua_main_data), "columns\n")
}, error = function(e) {
  cat("   ✗ Error downloading data:", e$message, "\n")
})

# Display data structure for inspection
cat("📊 Main data structure:\n")
ua_main_data %>% glimpse()


## 3. Administrative Hierarchy
cat("📍 Downloading Ukrainian administrative hierarchy...\n")

ua_admin_hierarchy <- NULL
tryCatch({
  ua_admin_hierarchy <- readr::read_csv(ua_admin_urls$admin_hierarchy, locale = readr::locale(encoding = "UTF-8"))
  cat("   ✓ Success:", nrow(ua_admin_hierarchy), "rows ×", ncol(ua_admin_hierarchy), "columns\n")
}, error = function(e) {
  cat("   ✗ Error downloading hierarchy data:", e$message, "\n")

})

# Display hierarchy structure
cat("📊 Hierarchy data structure:\n")
ua_admin_hierarchy %>% glimpse()


# ----- inspect-data -----------------------------------------------------------
ua_metadata %>% glimpse()
ua_main_data %>% glimpse()
ua_admin_hierarchy %>% glimpse()

# ---- tweak-data-1 --------------------------------------------------------------
# ua_metadata %>% OuhscMunge::column_rename_headstart()
ua_metadata_tweak1 <- 
  ua_metadata %>% 
  dplyr::select(    # `dplyr::select()` drops columns not included.
    source                           = `source`,
    variable_name                    = `variable_name`,
    variable_label                   = `variable_label`,
    variable_label_ua                = `variable_label_ua`,
  )

# ua_main_data %>% OuhscMunge::column_rename_headstart()
ua_hromadas_tweak1 <-
  ua_main_data %>%
  dplyr::select(
    # `dplyr::select()` drops columns not included.
    hromada_code                                         = `hromada_code`,
    hromada_name                                         = `hromada_name`,
    raion_code                                           = `raion_code`,
    raion_name                                           = `raion_name`,
    oblast_code                                          = `oblast_code`,
    oblast_name                                          = `oblast_name`,
    type                                                 = `type`,
    hromada_full_name                                    = `hromada_full_name`,
    oblast_center                                        = `oblast_center`,
    hromada_center_code                                  = `hromada_center_code`,
    hromada_center                                       = `hromada_center`,
    # lat_center                                           = `lat_center`,
    # lon_center                                           = `lon_center`,
    travel_time                                          = `travel_time`,
    n_settlements                                        = `n_settlements`,
    square_area                                          = `square`,
    # distance_to_russia_belarus                           = `distance_to_russia_belarus`,
    distance_to_russia                                   = `distance_to_russia`,
    distance_to_eu                                       = `distance_to_eu`,
    # mountain_hromada                                     = `mountain_hromada`,
    # near_seas                                            = `near_seas`,
    # bordering_hromadas                                   = `bordering_hromadas`,
    # hromadas_30km_from_border                            = `hromadas_30km_from_border`,
    # hromadas_30km_russia_belarus                         = `hromadas_30km_russia_belarus`,
    # buffer_nat_15km                                      = `buffer_nat_15km`,
    # buffer_int_15km                                      = `buffer_int_15km`,
    # occipied_before_2022                                 = `occipied_before_2022`,
    total_popultaion_2022                                = `total_popultaion_2022`,
    urban_popultaion_2022                                = `urban_popultaion_2022`,
    urban_pct                                            = `urban_pct`,
    # budget_code                                          = `budget_code`,
    # budget_name                                          = `budget_name`,
    oblast_name_en                                       = `oblast_name_en`,
    region_en                                            = `region_en`,
    region_code_en                                       = `region_code_en`,
    income_total_2021                                    = `income_total_2021`,
    # income_transfert_2021                                = `income_transfert_2021`,
    # income_military_2021                                 = `income_military_2021`,
    # income_pdfo_2021                                     = `income_pdfo_2021`,
    # income_unified_tax_2021                              = `income_unified_tax_2021`,
    # income_property_tax_2021                             = `income_property_tax_2021`,
    # income_excise_duty_2021                              = `income_excise_duty_2021`,
    # income_own_2021                                      = `income_own_2021`,
    # own_income_prop_2021                                 = `own_income_prop_2021`,
    # transfert_prop_2021                                  = `transfert_prop_2021`,
    # military_tax_prop_2021                               = `military_tax_prop_2021`,
    # pdfo_prop_2021                                       = `pdfo_prop_2021`,
    # unified_tax_prop_2021                                = `unified_tax_prop_2021`,
    # property_tax_prop_2021                               = `property_tax_prop_2021`,
    # excise_duty_prop_2021                                = `excise_duty_prop_2021`,
    # own_income_change                                    = `own_income_change`,
    # own_prop_change                                      = `own_prop_change`,
    # total_income_change                                  = `total_income_change`,
    # income_own_2022                                      = `income_own_2022`,
    income_total_2022                                    = `income_total_2022`,
    # income_transfert_2022                                = `income_transfert_2022`,
    # own_income_no_mil_change_yo_y_jan_feb                = `own_income_no_mil_change_yo_y_jan_feb`,
    # own_income_no_mil_change_yo_y_jun_aug                = `own_income_no_mil_change_yo_y_jun_aug`,
    # own_income_no_mil_change_yo_y_mar_may                = `own_income_no_mil_change_yo_y_mar_may`,
    # own_income_no_mil_change_yo_y_adapt                  = `own_income_no_mil_change_yo_y_adapt`,
    # dfrr_executed                                        = `dfrr_executed`,
    turnout_2020                                         = `turnout_2020`,
    sex_head                                             = `sex_head`,
    age_head                                             = `age_head`,
    education_head                                       = `education_head`,
    incumbent                                            = `incumbent`,
    # rda                                                  = `rda`,
    # not_from_here                                        = `not_from_here`,
    # party                                                = `party`,
    # enterpreuner                                         = `enterpreuner`,
    # unemployed                                           = `unemployed`,
    # priv_work                                            = `priv_work`,
    # polit_work                                           = `polit_work`,
    # communal_work                                        = `communal_work`,
    # ngo_work                                             = `ngo_work`,
    # party_national_winner                                = `party_national_winner`,
    # no_party                                             = `no_party`,
    # male                                                 = `male`,
    # high_educ                                            = `high_educ`,
    # sum_osbb_2020                                        = `sum_osbb_2020`,
    # edem_total                                           = `edem_total`,
    # edem_petitions                                       = `edem_petitions`,
    # edem_consultations                                   = `edem_consultations`,
    # edem_participatory_budget                            = `edem_participatory_budget`,
    # edem_open_hromada                                    = `edem_open_hromada`,
    # youth_councils                                       = `youth_councils`,
    # youth_centers                                        = `youth_centers`,
    # business_support_centers                             = `business_support_centers`,
    # creation_date                                        = `creation_date`,
    # creation_year                                        = `creation_year`,
    # time_before_24th                                     = `time_before_24th`,
    # voluntary                                            = `voluntary`,
    # war_zone_27_04_2022                                  = `war_zone_27_04_2022`,
    # war_zone_20_06_2022                                  = `war_zone_20_06_2022`,
    # war_zone_23_08_2022                                  = `war_zone_23_08_2022`,
    # war_zone_10_10_2022                                  = `war_zone_10_10_2022`,
    # passangers_2021                                      = `passangers_2021`,
    # total_declarations                                   = `total_declarations`,
    # female_declarations                                  = `female_declarations`,
    # male_declarations                                    = `male_declarations`,
    # female_pct_declarations                              = `female_pct_declarations`,
    # male_pct_declarations                                = `male_pct_declarations`,
    # urban_declarations                                   = `urban_declarations`,
    # rural_declarations                                   = `rural_declarations`,
    # urban_pct_declarations                               = `urban_pct_declarations`,
    # rural_pct_declarations                               = `rural_pct_declarations`,
    # youth_declarations                                   = `youth_declarations`,
    # youth_pct_declarations                               = `youth_pct_declarations`,
    # working_age_total_declarations                       = `working_age_total_declarations`,
    # working_age_pct_declarations                         = `working_age_pct_declarations`,
    # declarations_pct                                     = `declarations_pct`,
    # urban_declarations_pct                               = `urban_declarations_pct`,
    # train_station                                        = `train_station`,
  ) %>% 
  mutate(
    population_density = ifelse(square_area > 0, total_popultaion_2022 / square_area, 0)
    ,income_per_capita_2022 = ifelse(total_popultaion_2022 > 0, income_total_2022 / total_popultaion_2022, 0)
  )


ua_admin_hierarchy %>% OuhscMunge::column_rename_headstart()

ua_admin_hierarchy_tweak1 <-
  ua_admin_hierarchy %>%
  dplyr::select(    # `dplyr::select()` drops columns not included.
    settlement_code                    = `settlement_code`,
    settlement_name                    = `settlement_name`,
    settlement_type                    = `settlement_type`,
    hromada_code                       = `hromada_code`,
    hromada_name                       = `hromada_name`,
    raion_code                         = `raion_code`,
    raion_name                         = `raion_name`,
    oblast_code                        = `oblast_code`,
    oblast_name                        = `oblast_name`,
    type                               = `type`,
    region_en                          = `region_en`,
    region_ua                          = `region_ua`,
    oblast_name_en                     = `oblast_name_en`,
    oblast_code_en                     = `oblast_code_en`,
    region_code_en                     = `region_code_en`,
    map_position                       = `map_position`,
    map_position2                      = `map_position2`,
    oblast_center                      = `oblast_center`,
    oblast_center_code                 = `oblast_center_code`,
    oblast_name_display                = `oblast_name_display`,
    settlement_code_old                = `settlement_code_old`,
    rada_name                          = `rada_name`,
    rada_code                          = `rada_code`,
    budget_code                        = `budget_code`,
    budget_name                        = `budget_name`,
    full_name                          = `full_name`,
  )




# ---- create-oblast-aggregates ----
# Create oblast-level aggregated data for analysis
cat("🗺️  Creating oblast-level aggregations...\n")

ua_oblasts_aggregated <- ua_hromadas_tweak1 %>%
  group_by(oblast_name_en, oblast_code, region_en) %>%
  summarise(
    # Administrative counts
    n_hromadas = n(),
    n_settlements = sum(n_settlements, na.rm = TRUE),
    
    # Population indicators
    total_population = sum(total_popultaion_2022, na.rm = TRUE),
    urban_population = sum(urban_popultaion_2022, na.rm = TRUE),
    urbanization_pct = ifelse(sum(total_popultaion_2022, na.rm = TRUE) > 0, 
                             sum(urban_popultaion_2022, na.rm = TRUE) / sum(total_popultaion_2022, na.rm = TRUE) * 100, 
                             0),
    
    # Geographic indicators  
    total_area = sum(square_area, na.rm = TRUE),
    avg_travel_time = ifelse(sum(total_popultaion_2022, na.rm = TRUE) > 0,
                            weighted.mean(travel_time, total_popultaion_2022, na.rm = TRUE),
                            NA_real_),
    
    # Economic indicators
    total_income_2021 = sum(income_total_2021, na.rm = TRUE),
    total_income_2022 = sum(income_total_2022, na.rm = TRUE),
    
    .groups = "drop"
  ) %>%
  mutate(
    # AI COMPUTED: Calculate per-capita income from totals and population
    avg_income_per_capita_2022 = ifelse(total_population > 0, 
                                       total_income_2022 / total_population * 1000,  # Convert to per capita (in thousands)
                                       0),
    # AI COMPUTED: Calculate population density from population and area
    oblast_population_density = ifelse(total_area > 0, total_population / total_area, 0),
    # AI COMPUTED: Calculate income growth from 2021 to 2022
    income_growth_pct = ifelse(total_income_2021 > 0, 
                              (total_income_2022 - total_income_2021) / total_income_2021 * 100, 0)
  ) %>%
  filter(!is.na(oblast_name_en))

ua_oblasts_aggregated %>% glimpse()

cat("   ✓ Created oblast aggregations:", nrow(ua_oblasts_aggregated), "oblasts\n")

# Display aggregated data
cat("📊 Oblast aggregations sample:\n")
print(ua_oblasts_aggregated %>% 
      select(oblast_name_en, total_population, urbanization_pct, avg_income_per_capita_2022, region_en) %>% 
      head(5))

# ---- create-dimension-tables ----
# Create dimension tables for structured analysis
cat("📊 Creating dimension tables...\n")

# Oblast dimension table
dim_oblasts <- ua_oblasts_aggregated %>%
  select(oblast_code, oblast_name_en, region_en, region_en) %>%
  mutate(
    oblast_id = row_number(),
    is_capital_region = oblast_name_en == "Kyiv"
  )

ua_oblasts_aggregated %>% count(region_en)

# Region dimension table
dim_regions <- ua_oblasts_aggregated %>%
  distinct(region_en, region_en) %>%
  mutate(
    region_id = row_number()
  ) %>%
  arrange(region_en)

# Hromada fact table
fact_hromadas <- ua_hromadas_tweak1 %>%
  select(
    hromada_code, hromada_name, oblast_code, oblast_name_en,
    total_popultaion_2022, square_area, population_density, 
    income_per_capita_2022
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

# ---- prepare-oblast-polygons ----
# Extract and prepare Ukrainian oblast polygons for mapping
cat("🗺️ Preparing Ukrainian oblast polygons for mapping...\n")

# Create mapping assets folder
mapping_assets_path <- "data-private/derived/manipulation/mapping/"
if (!fs::dir_exists(mapping_assets_path)) {fs::dir_create(mapping_assets_path)}

# Download hromada polygons from KSE-Loc-Data-Hub
hromada_geojson_url <- "https://raw.githubusercontent.com/kse-ua/KSE-Loc-Data-Hub/main/maps/terhromad_fin.geojson"
hromada_geojson_path <- paste0(mapping_assets_path, "terhromad_fin.geojson")

if (!file.exists(hromada_geojson_path)) {
  cat("   📥 Downloading hromada polygons...\n")
  tryCatch({
    if (Sys.info()["sysname"] == "Windows") {
      system(paste0('powershell -Command "Invoke-WebRequest \\"', hromada_geojson_url, '\\" -OutFile \\"', hromada_geojson_path, '\\""'))
    } else {
      system(paste0("curl -L '", hromada_geojson_url, "' -o '", hromada_geojson_path, "'"))
    }
    
    if (file.exists(hromada_geojson_path)) {
      cat("   ✓ Downloaded hromada polygons\n")
    } else {
      stop("Download failed - hromada polygons file not created")
    }
  }, error = function(e) {
    cat("   ⚠️  Warning: Failed to download hromada polygons:", e$message, "\n")
    cat("   💡 Manual download from:", hromada_geojson_url, "\n")
    hromada_geojson_path <- NULL
  })
} else {
  cat("   ✓ Hromada polygons file already exists\n")
}

# Build oblast polygons from hromada data if sf package is available
oblast_polygons <- NULL
if (!is.null(hromada_geojson_path) && requireNamespace("sf", quietly = TRUE)) {
  tryCatch({
    cat("   🔧 Building oblast polygons from hromada data...\n")
    
    # Load and clean hromada polygons
    hromadas_sf <- sf::st_read(hromada_geojson_path, quiet = TRUE) %>%
      janitor::clean_names()
    
    # Repair invalid geometries before grouping
    hromadas_sf <- hromadas_sf %>%
      mutate(geometry = sf::st_make_valid(geometry))
    
    # Create oblast name mapping from hierarchy data
    oblast_name_map <- ua_admin_hierarchy %>%
      select(oblast_name, oblast_name_en) %>%
      distinct() %>%
      # Handle the " область" suffix in polygon data
      mutate(
        polygon_name = case_when(
          oblast_name == "Автономна Республіка Крим" ~ "Автономна Республіка Крим",
          TRUE ~ paste0(oblast_name, " область")
        )
      )
    
    # Group hromadas into oblasts by admin_1 field and apply name mapping
    oblast_polygons <- hromadas_sf %>%
      group_by(admin_1) %>%
      summarise(geometry = sf::st_union(geometry), .groups = "drop") %>%
      rename(polygon_name = admin_1) %>%
      # Join with name mapping to get English names
      left_join(oblast_name_map, by = "polygon_name") %>%
      select(oblast_name_en, oblast_name, geometry)
    
    # Save oblast polygons in multiple formats
    oblast_rds_path <- paste0(mapping_assets_path, "ua_oblast_polygons.rds")
    oblast_geojson_path <- paste0(mapping_assets_path, "ua_oblast_polygons.geojson")
    
    # Save as RDS for fast R access
    saveRDS(oblast_polygons, oblast_rds_path)
    cat("   ✓ Saved oblast polygons as RDS:", oblast_rds_path, "\n")
    
    # Save as GeoJSON for broader compatibility
    sf::st_write(oblast_polygons, oblast_geojson_path, delete_dsn = TRUE, quiet = TRUE)
    cat("   ✓ Saved oblast polygons as GeoJSON:", oblast_geojson_path, "\n")
    
    # Create name harmonization lookup - now they should match!
    polygon_names <- sort(unique(oblast_polygons$oblast_name_en))
    data_names <- sort(unique(ua_oblasts_aggregated$oblast_name_en))
    
    # Create a proper mapping table showing Ukrainian and English names
    harmonization_check <- oblast_name_map %>%
      arrange(oblast_name_en) %>%
      select(ukrainian_name = oblast_name, english_name = oblast_name_en, polygon_name)
    
    write.csv(harmonization_check, paste0(mapping_assets_path, "name_harmonization_check.csv"), 
              row.names = FALSE, na = "")
    cat("   ✓ Created name harmonization mapping file\n")
    
    # Report summary with improved matching
    cat("   📊 Oblast polygons summary:\n")
    cat("      - Total oblasts in polygons:", nrow(oblast_polygons), "\n")
    cat("      - Total oblasts in data:", nrow(ua_oblasts_aggregated), "\n")
    
    # Check name matching (should be much better now!)
    matched_names <- intersect(polygon_names, data_names)
    cat("      - Matched names:", length(matched_names), "/", length(data_names), "\n")
    
    if (length(matched_names) < length(data_names)) {
      unmatched_data <- setdiff(data_names, polygon_names)
      unmatched_polygons <- setdiff(polygon_names, data_names)
      cat("      ⚠️  Unmatched data names:", paste(unmatched_data, collapse = ", "), "\n")
      cat("      ⚠️  Unmatched polygon names:", paste(unmatched_polygons, collapse = ", "), "\n")
    } else {
      cat("      ✅ Perfect name matching achieved!\n")
    }
    
  }, error = function(e) {
    cat("   ❌ Failed to build oblast polygons:", e$message, "\n")
    oblast_polygons <- NULL
  })
} else {
  if (is.null(hromada_geojson_path)) {
    cat("   ⚠️  Skipping polygon processing - hromada data not available\n")
  } else {
    cat("   ⚠️  Skipping polygon processing - sf package not installed\n")
    cat("   💡 Install sf package: install.packages('sf')\n")
  }
}

# Create mapping guide reference
mapping_readme_path <- paste0(mapping_assets_path, "README.md")
mapping_readme_content <- paste0(
  "# Ukrainian Oblast Mapping Assets\n\n",
  "**Generated:** ", Sys.time(), "\n",
  "**Source:** KSE-Loc-Data-Hub\n\n",
  "## Files\n\n",
  "- `terhromad_fin.geojson` - Hromada-level polygons (source data)\n",
  "- `ua_oblast_polygons.rds` - Oblast polygons for R (fast loading)\n", 
  "- `ua_oblast_polygons.geojson` - Oblast polygons (universal format)\n",
  "- `name_harmonization_check.csv` - Name matching between polygons and data\n\n",
  "## Usage\n\n",
  "```r\n",
  "# Load oblast polygons\n",
  "library(sf)\n",
  "oblasts <- readRDS('data-private/derived/manipulation/mapping/ua_oblast_polygons.rds')\n",
  "\n",
  "# Join with your data\n",
  "oblasts_with_data <- oblasts %>%\n",
  "  left_join(your_data, by = 'oblast_name_en')\n",
  "```\n\n",
  "## Reference\n\n",
  "See `analysis/map-guide/` for complete mapping examples using tmap and leaflet.\n"
)

writeLines(mapping_readme_content, mapping_readme_path)
cat("   ✓ Created mapping assets README\n")

cat("✅ Oblast polygons preparation complete!\n")
cat("   📁 Assets saved to:", mapping_assets_path, "\n\n")

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
if (!is.null(ua_metadata_tweak1)) {
  dbWriteTable(db_stage_1, "ua_metadata", ua_metadata_tweak1, overwrite = TRUE)
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
if (!is.null(ua_metadata_tweak1)) {
  write.csv(ua_metadata_tweak1, paste0(csv_path, "ua_metadata.csv"), row.names = FALSE)
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

ua_oblasts_aggregated %>% glimpse()
regional_summary <- ua_oblasts_aggregated %>%
  group_by(region_en) %>%
  summarise(
    n_oblasts = n(),
    # Compute weighted mean BEFORE we assign total_population (to avoid name shadowing)
    avg_income_per_capita_2022 = ifelse(sum(total_population, na.rm = TRUE) > 0,
                                        weighted.mean(avg_income_per_capita_2022, total_population, na.rm = TRUE),
                                        NA_real_),
    total_population = sum(total_population, na.rm = TRUE),
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
cat("  ✓ Metadata dictionary:", nrow(ua_metadata_tweak1), "field definitions\n")
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
cat("  - ua_metadata_tweak1 (", nrow(ua_metadata_tweak1), " rows)\n")
cat("  - dim_oblasts (", nrow(dim_oblasts), " rows)\n")

cat("\n", paste(rep("=", 60), collapse = ""), "\n")

# Here's an example of a ukrainian map with oblasts mapped to population density
if (requireNamespace("sf", quietly = TRUE) && requireNamespace("tmap", quietly = TRUE)) {
  cat("🗺️ Generating example map of oblast population density...\n")
  mapping_assets_path <- "data-private/derived/manipulation/mapping/"
  # Load oblast polygons
  oblasts <- readRDS(paste0(mapping_assets_path, "ua_oblast_polygons.rds"))
  
  # Join with aggregated data
  oblasts_map <- oblasts %>%
    left_join(ua_oblasts_aggregated, by = "oblast_name_en")
  
  # Create a simple thematic map using tmap
  map <- tmap::tm_shape(oblasts_map) +
    tmap::tm_polygons("oblast_population_density", 
                      title = "Population Density (per sq km)", 
                      palette = "Blues", 
                      style = "quantile") +
    tmap::tm_layout(title = "Ukrainian Oblast Population Density",
                    legend.outside = TRUE)
  
  # Save map to file
  map_file <- paste0(mapping_assets_path, "oblast_population_density_map.png")
  tmap::tmap_save(map, filename = map_file, width = 800, height = 600)
  
  cat("   ✓ Map saved to:", map_file, "\n")
} else {
  cat("⚠️ Skipping map generation - sf or tmap package not installed\n")
}
