# CACHE Manifest - Books of Ukraine Stage 1 Database

**Generated:** 2025-08-19 05:39:26.843557
**Database:** books-of-ukraine-1.sqlite
**Total Tables:** 9

## 📊 Stage 1 Database Architecture

Stage 1 integrates core books data with Ukrainian administrative context.

### 🏗️ Architecture Overview

```
CORE DATA (from Stage 0)           ADMINISTRATIVE DATA (Stage 1)
┌─────────────────────────┐       ┌─────────────────────────────┐
│ fact_book_publications  │  →  │ ua_oblasts_aggregated       │
│ dim_years              │       │ dim_oblasts                 │
│ dim_categories         │       │ dim_regions                 │
│ dim_measures           │       │ fact_hromadas               │
└─────────────────────────┘       └─────────────────────────────┘
```

### 🔗 Integration Strategy

**CORE TABLES** (preserved from Stage 0):
- All original book publication data tables
- Complete star schema from 0-ellis.R

**ADMINISTRATIVE TABLES** (added in Stage 1):
- `ua_oblasts_aggregated`: Oblast-level indicators for mapping
- `dim_oblasts`: Oblast dimension with metadata
- `dim_regions`: Regional classification dimension
- `fact_hromadas`: Hromada-level fact table for detailed analysis

**ANALYSIS RECOMMENDATION**: Use combined tables for territorial analysis

---

## 📋 Table Catalog

### 📊 fact_book_publications

**FACT TABLE** - Core fact table: book publication data by year, category, measure

- **Records:** 3,663
- **Columns:** 5

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| year | INTEGER | Year (2005-2024 for books, 2020-2022 for admin data) |
| category_type | TEXT | Category type (language, theme, territory, purpose, total) |
| category_value | TEXT | Specific category value |
| measure_type | TEXT | Measure type (title_count, copy_count) |
| value | REAL | Numeric value for the measure |

---

### 📊 fact_hromadas

**FACT TABLE** - Hromada-level detailed data for territorial analysis

- **Records:** 1,438
- **Columns:** 16

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| hromada_code | TEXT | Data field |
| hromada_name | TEXT | Data field |
| oblast_code | TEXT | Data field |
| oblast_name_en | TEXT | Oblast name in English |
| raion_name | TEXT | Data field |
| type | TEXT | Data field |
| total_popultaion_2022 | REAL | Data field |
| square | REAL | Data field |
| population_density | REAL | Data field |
| income_per_capita_2021 | REAL | Data field |
| income_per_capita_2022 | REAL | Data field |
| income_change_pct | REAL | Data field |
| lat_center | REAL | Data field |
| lon_center | REAL | Data field |
| travel_time | REAL | Data field |
| oblast_id | INTEGER | Dimension table identifier |

---

### 📊 dim_categories

**DIMENSION TABLE** - Dimension table: categories

- **Records:** 205
- **Columns:** 4

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| category_type | TEXT | Category type (language, theme, territory, purpose, total) |
| category_value | TEXT | Specific category value |
| measure | TEXT | Data field |
| category_id | INTEGER | Dimension table identifier |

---

### 📊 dim_measures

**DIMENSION TABLE** - Dimension table: measures

- **Records:** 3
- **Columns:** 3

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| measure_type | TEXT | Measure type (title_count, copy_count) |
| measure_id | INTEGER | Dimension table identifier |
| measure_description | TEXT | Data field |

---

### 📊 dim_oblasts

**DIMENSION TABLE** - Oblast dimension with geographic and administrative metadata

- **Records:** 24
- **Columns:** 7

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| oblast_code | TEXT | Data field |
| oblast_name_en | TEXT | Oblast name in English |
| region_en | TEXT | Data field |
| region_type | TEXT | Regional classification (Western, Eastern, etc.) |
| oblast_id | INTEGER | Dimension table identifier |
| is_capital_region | INTEGER | Data field |
| is_border_oblast | INTEGER | Data field |

---

### 📊 dim_regions

**DIMENSION TABLE** - Regional classification (West, East, Center, South)

- **Records:** 5
- **Columns:** 3

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| region_en | TEXT | Data field |
| region_type | TEXT | Regional classification (Western, Eastern, etc.) |
| region_id | INTEGER | Dimension table identifier |

---

### 📊 dim_years

**DIMENSION TABLE** - Dimension table: years

- **Records:** 20
- **Columns:** 4

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| year | INTEGER | Year (2005-2024 for books, 2020-2022 for admin data) |
| year_id | INTEGER | Dimension table identifier |
| decade | TEXT | Data field |
| period | TEXT | Data field |

---

### 📊 ua_oblasts_aggregated

**UKRAINIAN ADMINISTRATIVE TABLE** - Oblast-level aggregated indicators for choropleth mapping

- **Records:** 24
- **Columns:** 20

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| oblast_name_en | TEXT | Oblast name in English |
| oblast_code | TEXT | Data field |
| region_en | TEXT | Data field |
| n_hromadas | INTEGER | Data field |
| n_settlements | REAL | Data field |
| total_population | REAL | Total population (2022) |
| urban_population | REAL | Data field |
| avg_population_density | REAL | Data field |
| urbanization_pct | REAL | Percentage of urban population |
| total_area | REAL | Data field |
| avg_travel_time | REAL | Data field |
| total_income_2021 | REAL | Data field |
| total_income_2022 | REAL | Data field |
| avg_income_per_capita_2021 | REAL | Data field |
| avg_income_per_capita_2022 | REAL | Average income per capita in UAH (2022) |
| pct_war_affected | REAL | Data field |
| oblast_population_density | REAL | Data field |
| income_growth_pct | REAL | Data field |
| avg_hromada_size | REAL | Data field |
| region_type | TEXT | Regional classification (Western, Eastern, etc.) |

---

### 📊 raw_ua_hromadas

**RAW DATA TABLE** - Raw data preservation for reference

- **Records:** 1,469
- **Columns:** 114

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| hromada_code | TEXT | Data field |
| hromada_name | TEXT | Data field |
| raion_code | TEXT | Data field |
| raion_name | TEXT | Data field |
| oblast_code | TEXT | Data field |
| oblast_name | TEXT | Data field |
| type | TEXT | Data field |
| hromada_full_name | TEXT | Data field |
| oblast_center | REAL | Data field |
| hromada_center_code | TEXT | Data field |
| hromada_center | TEXT | Data field |
| lat_center | REAL | Data field |
| lon_center | REAL | Data field |
| travel_time | REAL | Data field |
| n_settlements | REAL | Data field |
| square | REAL | Data field |
| distance_to_russia_belarus | REAL | Data field |
| distance_to_russia | REAL | Data field |
| distance_to_eu | REAL | Data field |
| mountain_hromada | REAL | Data field |
| near_seas | REAL | Data field |
| bordering_hromadas | REAL | Data field |
| hromadas_30km_from_border | REAL | Data field |
| hromadas_30km_russia_belarus | REAL | Data field |
| buffer_nat_15km | REAL | Data field |
| buffer_int_15km | REAL | Data field |
| occipied_before_2022 | REAL | Data field |
| total_popultaion_2022 | REAL | Data field |
| urban_popultaion_2022.x | REAL | Data field |
| urban_pct | REAL | Data field |
| budget_code | REAL | Data field |
| budget_name | TEXT | Data field |
| oblast_name_en | TEXT | Oblast name in English |
| region_en | TEXT | Data field |
| region_code_en | TEXT | Data field |
| income_total_2021 | REAL | Data field |
| income_transfert_2021 | REAL | Data field |
| income_military_2021 | REAL | Data field |
| income_pdfo_2021 | REAL | Data field |
| income_unified_tax_2021 | REAL | Data field |
| income_property_tax_2021 | REAL | Data field |
| income_excise_duty_2021 | REAL | Data field |
| income_own_2021 | REAL | Data field |
| own_income_prop_2021 | REAL | Data field |
| transfert_prop_2021 | REAL | Data field |
| military_tax_prop_2021 | REAL | Data field |
| pdfo_prop_2021 | REAL | Data field |
| unified_tax_prop_2021 | REAL | Data field |
| property_tax_prop_2021 | REAL | Data field |
| excise_duty_prop_2021 | REAL | Data field |
| own_income_change | REAL | Data field |
| own_prop_change | REAL | Data field |
| total_income_change | REAL | Data field |
| income_own_2022 | REAL | Data field |
| income_total_2022 | REAL | Data field |
| income_transfert_2022 | REAL | Data field |
| own_income_no_mil_change_YoY_jan_feb | REAL | Data field |
| own_income_no_mil_change_YoY_jun_aug | REAL | Data field |
| own_income_no_mil_change_YoY_mar_may | REAL | Data field |
| own_income_no_mil_change_YoY_adapt | REAL | Data field |
| dfrr_executed | REAL | Data field |
| turnout_2020 | REAL | Data field |
| sex_head | TEXT | Data field |
| age_head | REAL | Data field |
| education_head | TEXT | Data field |
| incumbent | REAL | Data field |
| rda | REAL | Data field |
| not_from_here | REAL | Data field |
| party | TEXT | Data field |
| enterpreuner | REAL | Data field |
| unemployed | REAL | Data field |
| priv_work | REAL | Data field |
| polit_work | REAL | Data field |
| communal_work | REAL | Data field |
| ngo_work | REAL | Data field |
| party_national_winner | REAL | Data field |
| no_party | REAL | Data field |
| male | REAL | Data field |
| high_educ | REAL | Data field |
| sum_osbb_2020 | REAL | Data field |
| edem_total | REAL | Data field |
| edem_petitions | REAL | Data field |
| edem_consultations | REAL | Data field |
| edem_participatory_budget | REAL | Data field |
| edem_open_hromada | REAL | Data field |
| youth_councils | REAL | Data field |
| youth_centers | REAL | Data field |
| business_support_centers | REAL | Data field |
| creation_date | REAL | Data field |
| creation_year | REAL | Data field |
| time_before_24th | REAL | Data field |
| voluntary | REAL | Data field |
| war_zone_27_04_2022 | REAL | Data field |
| war_zone_20_06_2022 | REAL | Data field |
| war_zone_23_08_2022 | REAL | Data field |
| war_zone_10_10_2022 | REAL | Data field |
| passangers_2021 | REAL | Data field |
| total_declarations | REAL | Data field |
| female_declarations | REAL | Data field |
| male_declarations | REAL | Data field |
| female_pct_declarations | REAL | Data field |
| male_pct_declarations | REAL | Data field |
| urban_declarations | REAL | Data field |
| rural_declarations | REAL | Data field |
| urban_pct_declarations | REAL | Data field |
| rural_pct_declarations | REAL | Data field |
| youth_declarations | REAL | Data field |
| youth_pct_declarations | REAL | Data field |
| working_age_total_declarations | REAL | Data field |
| working_age_pct_declarations | REAL | Data field |
| urban_popultaion_2022.y | REAL | Data field |
| declarations_pct | REAL | Data field |
| urban_declarations_pct | REAL | Data field |
| train_station | REAL | Data field |

---

## 🔍 Stage 1 Query Patterns

### Core Books Analysis
```sql
-- Basic publication trends
SELECT year, SUM(value) as total_titles
FROM fact_book_publications
WHERE measure_type = 'title_count' AND category_type = 'total'
GROUP BY year;
```

### Territorial Administrative Analysis
```sql
-- Oblast population and income ranking
SELECT oblast_name_en, total_population, avg_income_per_capita_2022,
       region_type
FROM ua_oblasts_aggregated
ORDER BY avg_income_per_capita_2022 DESC;
```

### Cross-Domain Integration Opportunities
```sql
-- Potential joins for future analysis
-- (Note: territorial book data vs administrative territories may need mapping)
SELECT DISTINCT category_value
FROM fact_book_publications
WHERE category_type = 'territory'
ORDER BY category_value;
```

## 🔧 Stage 1 Extension Notes

**Integration Opportunities:**
- Map book publication territories to administrative oblasts
- Correlate publishing activity with economic indicators
- Analyze regional patterns in language preference vs demographics

**Data Sources:**
- **Books Data**: Original Ukrainian publishing statistics
- **Administrative Data**: KSE Decentralization Reform project
- **Geographic Coverage**: All Ukrainian oblasts with 2020-2022 indicators

---

*Stage 1 database provides foundation for territorial analysis and cross-domain insights.*
