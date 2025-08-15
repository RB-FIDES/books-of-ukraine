
# CACHE Manifest – Books of Ukraine Analytical Tables (from last-ellis.R)

**Generated:** 2025-08-15
**Database:** BOOKS-OF-UKRAINE.sqlite
**Tables:** ds_year_wide, ds_language_wide, ds_territory_wide, ds_theme_wide, ds_purpose_wide, ds_year_long, ds_language_long, ds_territory_long, ds_theme_long, ds_purpose_long

---

# CACHE Overview

## FERRY LOAD PROCESS

The analytical CACHE is populated by the `last-ellis.R` script, which reads from the enhanced fact table and produces a set of wide and long-format tables for direct analysis.

- **Source System**: books-of-ukraine-enhanced.sqlite (fact_book_publications)
- **Ferry Script**: manipulation/last-ellis.R
- **Schema Organization**: Analytical wide/long tables (no star schema)
- **Output Format**: SQLite database (BOOKS-OF-UKRAINE.sqlite)

---

## CACHE STRUCTURE

### Schema Organization
- **Primary Schema**: BOOKS-OF-UKRAINE.sqlite (single schema)
- **Table Naming**: ds_* (wide/long analytical tables)
- **Key Structure**: Composite keys (year, measure_type, category_value as relevant)
- **Data Types**: Consistent across tables

### Table Types
- **Wide Tables**: One row per year (or year × measure_type), columns for each category value
- **Long Tables**: One row per year × category × measure_type

---

## CACHE TABLES

### Analytical Tables (Wide Format)

| **Table Name**         | **Key Columns**                | **Purpose**                                 |
|------------------------|--------------------------------|---------------------------------------------|
| **ds_year_wide**       | year                          | Yearly summary: columns for each measure    |
| **ds_language_wide**   | year, measure_type            | Language breakdown: columns for each language|
| **ds_territory_wide**  | year, measure_type            | Territory breakdown: columns for each region |
| **ds_theme_wide**      | year, measure_type            | Theme breakdown: columns for each theme      |
| **ds_purpose_wide**    | year, measure_type            | Purpose breakdown: columns for each purpose  |

### Analytical Tables (Long Format)

| **Table Name**         | **Key Columns**                | **Purpose**                                 |
|------------------------|--------------------------------|---------------------------------------------|
| **ds_year_long**       | year, category_type, category_value, measure_type | Yearly summary, long format                 |
| **ds_language_long**   | year, category_type, category_value, measure_type | Language breakdown, long format             |
| **ds_territory_long**  | year, category_type, category_value, measure_type | Territory breakdown, long format            |
| **ds_theme_long**      | year, category_type, category_value, measure_type | Theme breakdown, long format                |
| **ds_purpose_long**    | year, category_type, category_value, measure_type | Purpose breakdown, long format              |

---

## Data Transformation Details

All tables are derived from the `fact_book_publications` table in the enhanced database. Wide tables use `pivot_wider` to spread category values into columns; long tables retain a tidy, filterable structure.

### ds_year_wide
- **Definition**: One row per year, columns for each measure_type (e.g., title_count, copy_count)
- **Columns**: year, title_count, copy_count, ...
- **Use**: Time series and trend analysis at the aggregate level

### ds_language_wide
- **Definition**: One row per year × measure_type, columns for each language
- **Columns**: year, measure_type, [language columns...]
- **Use**: Language share and comparison by year and measure

### ds_territory_wide
- **Definition**: One row per year × measure_type, columns for each territory
- **Columns**: year, measure_type, [territory columns...]
- **Use**: Regional analysis by year and measure

### ds_theme_wide
- **Definition**: One row per year × measure_type, columns for each theme
- **Columns**: year, measure_type, [theme columns...]
- **Use**: Subject/theme analysis by year and measure

### ds_purpose_wide
- **Definition**: One row per year × measure_type, columns for each purpose
- **Columns**: year, measure_type, [purpose columns...]
- **Use**: Purpose/category analysis by year and measure

### ds_*_long tables
- **Definition**: One row per year × category × measure_type
- **Columns**: year, category_type, category_value, measure_type, value
- **Use**: Flexible filtering, faceting, and group-wise analysis

---

## Detailed Column Specifications

| **Column**      | **Data Type** | **Description**                                 |
|-----------------|--------------|-------------------------------------------------|
| year            | INTEGER      | Publication year (2005–2024)                    |
| category_type   | TEXT         | Category type (language, theme, territory, purpose, total) |
| category_value  | TEXT         | Specific category value                         |
| measure_type    | TEXT         | Measure type (title_count, copy_count)          |
| value           | REAL         | Numeric value for the measure                   |

---

## Cohort Definitions and Data Transformations

### BASE Cohort
- **Definition**: All book publications in Ukraine, 2005–2024, as recorded in the enhanced fact table
- **Inclusion Logic**: All records meeting basic data quality and completeness criteria
- **Usage**: Foundation for all subsequent analytical tables

### Analytical Cohorts
- **Definition**: Subsets by language, territory, theme, or purpose
- **Filters Applied**: Data quality, temporal boundaries, category-based selection

---

## Data Storage and Access

| **Format**   | **Location**                                                        | **Purpose**                  |
|--------------|---------------------------------------------------------------------|------------------------------|
| Database     | data-private/derived/manipulation/SQLite/BOOKS-OF-UKRAINE.sqlite    | Primary storage for analysis |
| CSV          | [optional export]                                                   | Universal format for sharing |
| RDS          | [optional export]                                                   | R-native format for analysis |

---

## Usage Guidelines and Best Practices

### Quick Start Tips
1. Load and validate: `glimpse(ds); validate_cache_data(ds)`
2. Check completeness: `ds %>% summarise_all(~sum(is.na(.)))`
3. Start with ds_year_wide or ds_year_long for overall trends
4. Use *_wide tables for cross-sectional comparisons; *_long tables for flexible filtering

```r
# Essential validation function
validate_cache_data <- function(ds) {
	list(
		missing_keys = sum(is.na(ds$year)),
		duplicates = ds %>% group_by_all() %>% filter(n() > 1) %>% nrow(),
		value_range = if("value" %in% names(ds)) range(ds$value, na.rm = TRUE) else NULL
	)
}
```

### Table-Specific Usage

#### **ds_year_wide** – Aggregate Trends
**Tip**: Use for time series plots of total publications/copies
```r
ds_year_wide %>% pivot_longer(-year, names_to = "measure_type", values_to = "value") %>%
	ggplot(aes(x = year, y = value, color = measure_type)) + geom_line()
```

#### **ds_language_wide** – Language Shares
**Tip**: Compare language columns by year and measure
```r
ds_language_wide %>% filter(measure_type == "title_count") %>%
	pivot_longer(-c(year, measure_type), names_to = "language", values_to = "value") %>%
	ggplot(aes(x = year, y = value, color = language)) + geom_line()
```

#### **ds_*_long** – Flexible Filtering
**Tip**: Filter by category_type and category_value for detailed analysis
```r
ds_language_long %>% filter(category_value == "russian") %>%
	ggplot(aes(x = year, y = value)) + geom_line()
```

---

## Key Research Applications

1. **Trend Analysis**: Publication and copy trends over time
2. **Language Analysis**: Russian vs. Ukrainian and other language shares
3. **Regional Analysis**: Territorial patterns and changes
4. **Thematic Analysis**: Subject/theme trends
5. **Purpose Analysis**: Changes in publication purpose

---

## Data Lineage and Provenance

- **Original Source**: books-of-ukraine-enhanced.sqlite (fact_book_publications)
- **Ferry Script**: manipulation/last-ellis.R
- **Processing Steps**: Data extraction, wide/long transformation, SQLite export
- **Version Control**: All processing steps tracked in Git

---

## Glossary of Terms

- **Wide Table**: Table with one row per year (or year × measure_type), columns for each category value
- **Long Table**: Table with one row per year × category × measure_type
- **Category**: Categorical variable (e.g., language, theme, territory, purpose)
- **Measure**: Quantitative variable (e.g., title_count, copy_count)

---

## Summary

**What's Available:** Book publication counts by year, language, territory, theme, and purpose, in both wide and long formats, ready for direct analysis.

**Key Capabilities:** Time series, cross-sectional, categorical, and group-wise analysis; language and regional segmentation; trend and cohort studies.

**Data Format and Structure:** Analytical wide/long tables, tidy format, analysis-ready.

**Update Status:**
- **Last Updated:** 2025-08-15
- **Coverage:** 2005–2024 (publications)
- **Quality:** Cleaned, validated, no missing core variables

**Getting Started:**
1. Start with ds_year_wide or ds_year_long for overall trends
2. Use *_wide tables for cross-sectional or group comparisons
3. Use *_long tables for flexible filtering and faceting
4. Validate findings across multiple perspectives
