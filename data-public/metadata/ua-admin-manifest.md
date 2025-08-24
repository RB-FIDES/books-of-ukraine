# UA Admin – Oblast Aggregates (ua_oblasts_aggregated)

Purpose: A compact, join-ready dataset with one row per oblast capturing population, economy, and geography derived from the KSE Decentralization project. Use it to enrich Books of Ukraine analyses with oblast-level context.

## Data Contract
- Grain: 1 row per oblast (including Kyiv; Crimea/Sevastopol coverage depends on source updates)
- Primary keys: oblast_code, oblast_name_en
- Refresh: Run manipulation/1-ellis-ua-admin.R
- Sources: 
  - Hromada data: kse-ua/KSE-Loc-Data-Hub (full_dataset.csv)
  - Admin hierarchy: ua-admin-map-2020.csv (optional)
  - Spatial polygons (optional): terhromad_fin.geojson
  - **Field metadata**: metadata_data_public.xlsx ("main" sheet)
- Outputs/locations:
  - SQLite: data-private/derived/manipulation/SQLite/books-of-ukraine-1.sqlite (table: ua_oblasts_aggregated)
  - CSV: data-private/derived/manipulation/CSV/ua_oblasts_aggregated.csv
  - Metadata: data-private/derived/manipulation/CSV/ua_metadata.csv

## Data Sources and Field Descriptions

This manifest now uses field descriptions from the official KSE metadata dictionary (`metadata_data_public.xlsx`, "main" sheet). All field definitions come directly from the KSE-Loc-Data-Hub project documentation.

### Metadata Integration
- **Source**: KSE Decentralization Reform project official metadata
- **Download URL**: https://github.com/kse-ua/KSE-Loc-Data-Hub/raw/refs/heads/main/data/metadata/metadata_data_public.xlsx
- **Processing**: Automated import during pipeline execution in 1-ellis-ua-admin.R
- **Storage**: Available in both SQLite (ua_metadata table) and CSV (ua_metadata.csv)

## Columns (schema with KSE-verified descriptions)

**Note**: Column descriptions below are aggregated from hromada-level data as documented in the KSE metadata. Where multiple hromadas exist per oblast, values are summed (for counts/totals) or population-weighted averaged (for rates/percentages).

### Administrative Identifiers
- **oblast_code**: character – Official administrative code for the oblast
- **oblast_name_en**: character – Oblast name in English (standardized)
- **region_en**: character – Macro-region classification from KSE source

### Demographic Indicators
- **total_population**: numeric – Sum of total_popultaion_2022 across all hromadas in oblast
- **urban_population**: numeric – Sum of urban population 2022 across hromadas
- **n_hromadas**: integer – Count of hromadas (territorial communities) in oblast
- **n_settlements**: integer – Total number of settlements (sum across hromadas)
- **urbanization_pct**: numeric – (urban_population / total_population) × 100
- **avg_population_density**: numeric – Population-weighted average density (people per km²)

### Geographic Indicators  
- **total_area**: numeric – Sum of area (square km) across all hromadas
- **oblast_population_density**: numeric – total_population / total_area
- **avg_travel_time**: numeric – Population-weighted average travel time to oblast center (minutes)

### Economic Indicators
- **total_income_2021**: numeric – Sum of total income 2021 (UAH) across hromadas
- **total_income_2022**: numeric – Sum of total income 2022 (UAH) across hromadas  
- **avg_income_per_capita_2021**: numeric – Population-weighted average income per capita 2021
- **avg_income_per_capita_2022**: numeric – Population-weighted average income per capita 2022
- **income_growth_pct**: numeric – ((total_income_2022 - total_income_2021) / total_income_2021) × 100

### Derived Classifications
- **region_type**: character – Human-friendly region grouping (Western Ukraine, Eastern Ukraine, etc.)
- **population_category**: character – Size classification (Large >2M, Medium 1-2M, Small 0.5-1M, Very Small <0.5M)
- **income_category**: character – Income classification based on avg_income_per_capita_2022

### Security Context (if available)
- **pct_war_affected**: numeric – Percentage of hromadas flagged as war zones (0-100), computed from war_zone_27_04_2022 if present in source data

## Field Validation

All field definitions are cross-referenced with:
1. **KSE official metadata** (metadata_data_public.xlsx, "main" sheet)
2. **Source data structure** (full_dataset.csv column names and types)
3. **Administrative hierarchy** (ua-admin-map-2020.csv for territorial mappings)

## Intended Joins (Books of Ukraine)

**Goal**: Enrich book publication metrics with verified administrative context.

### Recommended Join Keys
- **Primary**: oblast_code (most reliable)
- **Alternative**: oblast_name_en (requires name normalization)

### Name Normalization
Ukrainian → English oblast name mappings verified against KSE admin hierarchy:
- Дніпропетровська → Driproptrovska
- Львівська → Lviv  
- Харківська → Kharkiv
- Одеська → Odesa
- Київська → Kyiv

## Quick-start Examples (R)

### Read metadata for field reference
```r
library(DBI)
con <- dbConnect(RSQLite::SQLite(), "data-private/derived/manipulation/SQLite/books-of-ukraine-1.sqlite")
metadata <- dbReadTable(con, "ua_metadata")
ua_oblasts <- dbReadTable(con, "ua_oblasts_aggregated")
dbDisconnect(con)

# View field descriptions by category
metadata %>% filter(category == "demographics") %>% select(field_name, description)
```

### Oblast-enriched analysis
```r
library(dplyr)
# Join with Books of Ukraine data (example)
books_enriched <- books_by_oblast %>%
  left_join(ua_oblasts %>% select(oblast_name_en, region_type, total_population, 
                                 avg_income_per_capita_2022, urbanization_pct, population_category),
            by = "oblast_name_en") %>%
  # Add metadata context
  mutate(data_source = "KSE-Loc-Data-Hub verified")
```

## Data Quality and Provenance

### Validation
- **Source authority**: Kyiv School of Economics Decentralization Reform project
- **Field definitions**: Official KSE metadata dictionary
- **Update frequency**: Matches KSE-Loc-Data-Hub repository updates
- **Coverage**: All Ukrainian oblasts with 2020-2022 administrative data

### Caveats
- Population data reflects 2022 status, may not include wartime displacement
- War-related indicators depend on availability in source data
- Income data in UAH nominal terms (not inflation-adjusted)

## Refresh Procedure
1. Run `manipulation/1-ellis-ua-admin.R` (includes automatic metadata download)
2. Validate metadata table creation: check `ua_metadata` table for field descriptions
3. Cross-reference with KSE source: ensure consistency with upstream changes
4. Inspect aggregated metrics in final ua_oblasts_aggregated table

## Changelog
- **2025-08-24**: Enhanced with KSE official metadata integration, "main" sheet focus
- **2025-08-10**: Initial manifest authored, aligned with 2-ellis-ua-admin.R outputs
