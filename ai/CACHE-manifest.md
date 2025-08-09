# CACHE Manifest - Books of Ukraine Enhanced Database

**Generated:** 2025-08-08 17:22:25.262773
**Database:** books-of-ukraine-enhanced.sqlite
**Total Tables:** 11

## 📊 Enhanced Star Schema Architecture

This database extends the core star schema with supplementary data sources.

### �️ Architecture Overview

```
CORE (from 0-ellis.R)          ENHANCED (from 1-ellis.R)
┌─────────────────────┐       ┌─────────────────────────┐
│ fact_book_publications │    │ fact_enhanced           │
│ dim_years              │ → │ ext_geography_*         │
│ dim_categories         │    │ ext_future_*            │
│ dim_measures           │    │ (preserves core intact) │
│ raw_*                  │    └─────────────────────────┘
└─────────────────────┘
```

### 🔗 Integration Strategy

**CORE TABLES** (unchanged from 0-ellis.R):
- `fact_book_publications`: Original publication data
- `dim_*`: Core dimension tables
- `raw_*`: Original source data

**EXTENSION TABLES** (added by 1-ellis.R):
- `ext_geography_publications`: Geographic/territorial data
- `fact_enhanced`: Integrated view combining core + extensions

**ANALYSIS RECOMMENDATION**: Use `fact_enhanced` for comprehensive analysis

---

## 📋 Table Catalog

### 📊 fact_book_publications

**FACT TABLE** - Core fact table from 0-ellis.R (publications only)

- **Records:** 3,180
- **Columns:** 5

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| year | INTEGER | Publication year (2005-2024) |
| category_type | TEXT | Category type (language, theme, territory, purpose, total) |
| category_value | TEXT | Specific category value |
| measure_type | TEXT | Measure type (title_count, copy_count) |
| value | REAL | Numeric value for the measure |

---

### 📊 fact_enhanced

**ENHANCED FACT TABLE** - Integrated fact table combining core publications with geographic and future extensions

- **Records:** 3,180
- **Columns:** 5

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| year | INTEGER | Publication year (2005-2024) |
| category_type | TEXT | Category type (language, theme, territory, purpose, total) |
| category_value | TEXT | Specific category value |
| measure_type | TEXT | Measure type (title_count, copy_count) |
| value | REAL | Numeric value for the measure |

---

### 📊 dim_categories

**DIMENSION TABLE** - Dimension table: categories

- **Records:** 91
- **Columns:** 3

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| category_type | TEXT | Category type (language, theme, territory, purpose, total) |
| category_value | TEXT | Specific category value |
| category_id | INTEGER | Dimension table identifier |

---

### 📊 dim_measures

**DIMENSION TABLE** - Dimension table: measures

- **Records:** 2
- **Columns:** 3

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| measure_type | TEXT | Measure type (title_count, copy_count) |
| measure_id | INTEGER | Dimension table identifier |
| measure_description | TEXT | Data field |

---

### 📊 dim_years

**DIMENSION TABLE** - Dimension table: years

- **Records:** 20
- **Columns:** 4

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| year | INTEGER | Publication year (2005-2024) |
| year_id | INTEGER | Dimension table identifier |
| decade | TEXT | Data field |
| period | TEXT | Data field |

---

### 📊 ext_geography_publications

**EXTENSION TABLE** - Geographic extension: publication counts by territory

- **Records:** 580
- **Columns:** 5

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| year | INTEGER | Publication year (2005-2024) |
| category_type | TEXT | Category type (language, theme, territory, purpose, total) |
| category_value | TEXT | Specific category value |
| measure_type | TEXT | Measure type (title_count, copy_count) |
| value | REAL | Numeric value for the measure |

---

### 📊 raw_language

**RAW DATA TABLE** - Original source data: language

- **Records:** 74
- **Columns:** 22

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| pokaznik | TEXT | Data field |
| mova | TEXT | Data field |
| x2005 | REAL | Data field |
| x2006 | REAL | Data field |
| x2007 | REAL | Data field |
| x2008 | REAL | Data field |
| x2009 | REAL | Data field |
| x2010 | REAL | Data field |
| x2011 | REAL | Data field |
| x2012 | REAL | Data field |
| x2013 | REAL | Data field |
| x2014 | REAL | Data field |
| x2015 | REAL | Data field |
| x2016 | REAL | Data field |
| x2017 | REAL | Data field |
| x2018 | REAL | Data field |
| x2019 | REAL | Data field |
| x2020 | REAL | Data field |
| x2021 | REAL | Data field |
| x2022 | REAL | Data field |
| x2023 | REAL | Data field |
| x2024 | REAL | Data field |

---

### 📊 raw_purpose

**RAW DATA TABLE** - Original source data: purpose

- **Records:** 28
- **Columns:** 22

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| pokaznik | TEXT | Data field |
| priznacenna | TEXT | Data field |
| x2005 | REAL | Data field |
| x2006 | REAL | Data field |
| x2007 | REAL | Data field |
| x2008 | REAL | Data field |
| x2009 | REAL | Data field |
| x2010 | REAL | Data field |
| x2011 | REAL | Data field |
| x2012 | REAL | Data field |
| x2013 | REAL | Data field |
| x2014 | REAL | Data field |
| x2015 | REAL | Data field |
| x2016 | REAL | Data field |
| x2017 | REAL | Data field |
| x2018 | REAL | Data field |
| x2019 | REAL | Data field |
| x2020 | REAL | Data field |
| x2021 | REAL | Data field |
| x2022 | REAL | Data field |
| x2023 | REAL | Data field |
| x2024 | REAL | Data field |

---

### 📊 raw_territory

**RAW DATA TABLE** - Original source data: territory

- **Records:** 52
- **Columns:** 22

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| pokaznik | TEXT | Data field |
| teritoria | TEXT | Data field |
| x2005 | REAL | Data field |
| x2006 | REAL | Data field |
| x2007 | REAL | Data field |
| x2008 | REAL | Data field |
| x2009 | REAL | Data field |
| x2010 | REAL | Data field |
| x2011 | REAL | Data field |
| x2012 | REAL | Data field |
| x2013 | REAL | Data field |
| x2014 | REAL | Data field |
| x2015 | REAL | Data field |
| x2016 | REAL | Data field |
| x2017 | REAL | Data field |
| x2018 | REAL | Data field |
| x2019 | REAL | Data field |
| x2020 | REAL | Data field |
| x2021 | REAL | Data field |
| x2022 | REAL | Data field |
| x2023 | REAL | Data field |
| x2024 | REAL | Data field |

---

### 📊 raw_theme

**RAW DATA TABLE** - Original source data: theme

- **Records:** 26
- **Columns:** 22

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| pokaznik | TEXT | Data field |
| tema | TEXT | Data field |
| x2005 | REAL | Data field |
| x2006 | REAL | Data field |
| x2007 | REAL | Data field |
| x2008 | REAL | Data field |
| x2009 | REAL | Data field |
| x2010 | REAL | Data field |
| x2011 | REAL | Data field |
| x2012 | REAL | Data field |
| x2013 | REAL | Data field |
| x2014 | REAL | Data field |
| x2015 | REAL | Data field |
| x2016 | REAL | Data field |
| x2017 | REAL | Data field |
| x2018 | REAL | Data field |
| x2019 | REAL | Data field |
| x2020 | REAL | Data field |
| x2021 | REAL | Data field |
| x2022 | REAL | Data field |
| x2023 | REAL | Data field |
| x2024 | REAL | Data field |

---

### 📊 raw_year

**RAW DATA TABLE** - Original source data: year

- **Records:** 2
- **Columns:** 21

#### Column Structure

| Column | Type | Description |
|--------|------|-------------|
| pokaznik | TEXT | Data field |
| x2005 | REAL | Data field |
| x2006 | REAL | Data field |
| x2007 | REAL | Data field |
| x2008 | REAL | Data field |
| x2009 | REAL | Data field |
| x2010 | REAL | Data field |
| x2011 | REAL | Data field |
| x2012 | REAL | Data field |
| x2013 | REAL | Data field |
| x2014 | REAL | Data field |
| x2015 | REAL | Data field |
| x2016 | REAL | Data field |
| x2017 | REAL | Data field |
| x2018 | REAL | Data field |
| x2019 | REAL | Data field |
| x2020 | REAL | Data field |
| x2021 | REAL | Data field |
| x2022 | REAL | Data field |
| x2023 | REAL | Data field |
| x2024 | REAL | Data field |

---

## 🔍 Enhanced Query Patterns

### Core vs Enhanced Analysis
```sql
-- Core publications only
SELECT year, SUM(value) as core_titles
FROM fact_book_publications
WHERE measure_type = 'title_count'
GROUP BY year;

-- Enhanced with geographic data
SELECT year, SUM(value) as enhanced_titles
FROM fact_enhanced
WHERE measure_type = 'title_count'
GROUP BY year;
```

### Multi-Source Geographic Analysis
```sql
-- Territory breakdown from extensions
SELECT category_value as territory, SUM(value) as total_publications
FROM fact_enhanced
WHERE category_type = 'territory' AND measure_type = 'title_count'
GROUP BY category_value
ORDER BY total_publications DESC;
```

### Extension Data Quality
```sql
-- Compare core vs extension coverage
SELECT 'core' as source, COUNT(*) as records
FROM fact_book_publications
UNION ALL
SELECT 'enhanced' as source, COUNT(*) as records
FROM fact_enhanced;
```

## 🔧 Extension Development Guide

To add new data sources to the enhanced database:

1. **Create extension table**: `ext_[source_name]`
2. **Standardize schema**: Match fact table structure (year, category_type, category_value, measure_type, value)
3. **Update fact_enhanced**: Combine new extension with existing data
4. **Extend dimensions**: Add new categories/measures as needed
5. **Document**: Update this manifest

### Extension Naming Convention
- `ext_geography_*`: Geographic/territorial data
- `ext_economic_*`: Economic indicators
- `ext_cultural_*`: Cultural events/metrics
- `ext_institutional_*`: Institutional data

---

*Enhanced database maintains backward compatibility while enabling multi-source analysis.*
