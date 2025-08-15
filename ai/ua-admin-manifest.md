# UA Admin – Oblast Aggregates (ua_oblasts_aggregated)

Purpose: A compact, join-ready dataset with one row per oblast capturing population, economy, and geography derived from the KSE Decentralization project. Use it to enrich Books of Ukraine analyses with oblast-level context.

## Data Contract
- Grain: 1 row per oblast (including Kyiv; Crimea/Sevastopol coverage depends on source updates)
- Primary keys: oblast_code, oblast_name_en
- Refresh: Run manipulation/2-ellis-ua-admin.R
- Sources: 
  - Hromada data: kse-ua/KSE-Loc-Data-Hub (full_dataset.csv)
  - Admin hierarchy: ua-admin-map-2020.csv (optional)
  - Spatial polygons (optional): terhromad_fin.geojson
- Outputs/locations:
  - SQLite: data-private/derived/manipulation/SQLite/ua-admin-analysis.sqlite (table: ua_oblasts_aggregated)
  - CSV: data-private/derived/manipulation/CSV/ua_oblasts_aggregated.csv
  - RDS: data-private/derived/manipulation/ua_oblasts_aggregated.rds

## Columns (schema)
- oblast_code: character – Administrative code
- oblast_name_en: character – Oblast name (standardized, e.g., Kyiv, Odesa, Lviv)
- region_en: character – Macro-region label from source (West/Center/East/South/etc.)
- n_hromadas: integer – Number of hromadas in oblast
- n_settlements: integer – Number of settlements (sum over hromadas)
- total_population: numeric – Sum of total_popultaion_2022
- urban_population: numeric – Sum of urban_population_2022
- avg_population_density: numeric – Population-weighted average density over hromadas
- urbanization_pct: numeric – urban_population / total_population * 100
- total_area: numeric – Sum of square (km²)
- avg_travel_time: numeric – Population-weighted average travel_time to oblast center (minutes)
- total_income_2021: numeric – Sum of income_total_2021 (UAH)
- total_income_2022: numeric – Sum of income_total_2022 (UAH)
- avg_income_per_capita_2021: numeric – Pop-weighted average income per capita 2021
- avg_income_per_capita_2022: numeric – Pop-weighted average income per capita 2022
- pct_war_affected: numeric? – Share of hromadas flagged as war_zone_27_04_2022 (0–100), if present
- oblast_population_density: numeric – total_population / total_area
- income_growth_pct: numeric – (total_income_2022 - total_income_2021) / total_income_2021 * 100
- avg_hromada_size: numeric – total_population / n_hromadas
- region_type: character – Human-friendly region grouping derived from region_en

Notes
- Per-capita and percentage fields are safe for ranking and choropleths.
- All sums/averages computed in manipulation/2-ellis-ua-admin.R; revisit there to change methods.

## Intended Joins (Books of Ukraine)
Goal: Enrich publication metrics with oblast context.

Recommended keys
- Preferred: oblast_code
- Alternative: oblast_name_en (ensure normalization of names)

Name normalization (fallback)
- Trim spaces; fix common variants (e.g., Dnipropetrovsk vs Dnipro/Dnipropetrovsk, Zaporizhzhia vs Zaporizhia, Kyiv City → Kyiv)

## Quick-start examples (R)

Read from SQLite

```r
library(DBI)
con <- dbConnect(RSQLite::SQLite(), "data-private/derived/manipulation/SQLite/ua-admin-analysis.sqlite")
ua_oblasts <- dbReadTable(con, "ua_oblasts_aggregated")
dbDisconnect(con)
```

Read from CSV

```r
ua_oblasts <- read.csv("data-private/derived/manipulation/CSV/ua_oblasts_aggregated.csv")
```

Join with Books of Ukraine totals by oblast (example)

```r
library(dplyr)
# Suppose you have a books dataset aggregated to oblast: books_by_oblast
# with columns: oblast_name_en, year, measure_type, value
books_enriched <- books_by_oblast %>%
  left_join(ua_oblasts %>% select(oblast_name_en, region_type, total_population, avg_income_per_capita_2022, urbanization_pct),
            by = "oblast_name_en")
```

Create an oblast choropleth (no polygons required – tabular example)

```r
library(ggplot2)
ua_oblasts %>%
  ggplot(aes(reorder(oblast_name_en, avg_income_per_capita_2022), avg_income_per_capita_2022, fill = region_type)) +
  geom_col() + coord_flip() +
  labs(x = NULL, y = "Income per capita (2022)", title = "Oblast incomes per capita") +
  theme_minimal()
```

Optional spatial join
- GeoJSON saved (if available): data-private/derived/manipulation/ua_hromada_boundaries.geojson (hromada level)
- For oblast boundaries, use a trusted external source or aggregate polygons from hromada-level geometry.

## Data Quality and Caveats
- Population fields are 2022-based and may exclude migration effects during 2022.
- pct_war_affected depends on availability of war_zone columns in source.
- Some name variants may require normalization for reliable joins; prefer oblast_code when available.

## Refresh Procedure
1) Run manipulation/2-ellis-ua-admin.R
2) Validate row count equals expected number of oblasts
3) Inspect top metrics (script prints quick validation tables)

## Changelog
- 2025-08-10: Initial manifest authored; aligned with 2-ellis-ua-admin.R outputs.
