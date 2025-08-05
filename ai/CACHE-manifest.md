# CACHE Manifest

This document serves as a comprehensive guide to the data structure and organization of the CACHE for the Books of Ukraine project. It provides a reference for understanding the data sources, their relationships, and how they are utilized in research projects.

The CACHE is designed to support the mission of investigating publishing trends in Ukraine since 2005, understanding regional differences, and detecting patterns in Russian language usage in published books within the larger cultural, political, and economic context of Ukraine.

---

# CACHE Overview

## DATA FERRY PROCESS

The CACHE is populated through a ferry process implemented in `./manipulation/0-ellis.R` that extracts data from Google Sheets and transforms it into analysis-ready format.

- **Source**: Google Sheets containing Ukrainian publishing statistics (2005-2023)
- **Ferry Script**: `./manipulation/0-ellis.R`
- **Output Schema**: Long-format datasets optimized for time-series analysis
- **Last Updated**:  2025-08-01  ( 6  datasets)

## CACHE STRUCTURE

All datasets follow a consistent long-format structure optimized for temporal analysis and visualization:

| **Column** | **Type** | **Description** |
|------------|----------|-----------------|
| `year` | Integer | Year of observation (2005-2023) |
| `measure` | Character | Type of measurement (`title_count` or `copy_count`) |
| `[category]` | Character | Category variable (language, genre, geography, pubtype) |
| `value` | Numeric | Measured value for the year-measure-category combination |

---

## CACHE TABLES

### Ferry Load Tables (Analysis-Ready)

| **Table Name** | **Primary Key(s)** | **Purpose** | **Source Sheet** |
|----------------|-------------------|-------------|------------------|
| **`🆕 ds_year_long`** | `year + measure` | Annual aggregate publishing statistics | К-ть видань |
| **`🆕 ds_language_long`** | `year + measure + language` | Publications by language | мови народу світу |
| **`🆕 ds_genre_long`** | `year + measure + genre` | Publications by thematic genre | Тематичні розділи, Наклад тематич., Тематичні розділи 05-06 |
| **`🆕 ds_pubtype_long`** | `year + measure + pubtype` | Publications by publication type | Аркуш15, Цільові призначення |
| **`🆕 ds_geography_long`** | `year + measure + geography` | Publications by Ukrainian region | території, Терир. наклад |
| **`🆕 ds_ukr_rus_long`** | `year + measure + language` | Ukrainian vs Russian language publications | мови народу світу (derived) |

---

## Data Transformation Details

###  ds_year_long
- **Definition**:  Total publication counts across all categories by year
- **Primary Key**:  year + measure
- **File Size**:  0.4  KB
- **Last Modified**:  2025-08-01 11:50
- **File Path**: `data-private/derived/manipulation/ ds_year_long .rds`

###  ds_language_long
- **Definition**:  Language distribution of publications over time
- **Primary Key**:  year + measure + language
- **File Size**:  1.8  KB
- **Last Modified**:  2025-08-01 11:50
- **File Path**: `data-private/derived/manipulation/ ds_language_long .rds`

###  ds_genre_long
- **Definition**:  Genre/thematic classification of publications
- **Primary Key**:  year + measure + genre
- **File Size**:  5.8  KB
- **Last Modified**:  2025-08-01 11:50
- **File Path**: `data-private/derived/manipulation/ ds_genre_long .rds`

###  ds_pubtype_long
- **Definition**:  Publication type classification and analysis
- **Primary Key**:  year + measure + pubtype
- **File Size**:  2.8  KB
- **Last Modified**:  2025-08-01 11:50
- **File Path**: `data-private/derived/manipulation/ ds_pubtype_long .rds`

###  ds_geography_long
- **Definition**:  Regional distribution of publishing activity
- **Primary Key**:  year + measure + geography
- **File Size**:  3.9  KB
- **Last Modified**:  2025-08-01 11:50
- **File Path**: `data-private/derived/manipulation/ ds_geography_long .rds`

###  ds_ukr_rus_long
- **Definition**:  Comparative analysis of Ukrainian and Russian language publishing
- **Primary Key**:  year + measure + language
- **File Size**:  1  KB
- **Last Modified**:  2025-08-01 11:50
- **File Path**: `data-private/derived/manipulation/ ds_ukr_rus_long .rds`

---

## Detailed Column Specifications

### Column Schema Reference

All CACHE tables follow the standardized long-format schema. Here are the detailed specifications for each column type:

#### Core Columns (Present in All Tables)

| **Column** | **Data Type** | **Range/Values** | **Description** | **Analysis Use** |
|------------|---------------|------------------|-----------------|------------------|
| `year` | Integer | 2005-2023 | Publication year - complete annual coverage with no gaps | Time series analysis, trend detection |
| `measure` | Character | `"title_count"`, `"copy_count"` | Type of measurement: unique titles vs. total copies printed | Volume vs. reach analysis |
| `value` | Numeric | 0 to 50,000+ | Measured count for the specific year-measure-category combination | Quantitative analysis, aggregations |

#### Category-Specific Columns

| **Column** | **Data Type** | **Tables Present** | **Unique Values** | **Description** |
|------------|---------------|-------------------|-------------------|-----------------|
| `language` | Character | `ds_language_long`, `ds_ukr_rus_long` | ~15-20 languages | Publication language in Ukrainian spelling |
| `genre` | Character | `ds_genre_long` | ~25-30 categories | Thematic/subject classification based on library systems |
| `pubtype` | Character | `ds_pubtype_long` | ~10-15 types | Publication format and intended audience |
| `geography` | Character | `ds_geography_long` | 26 regions | Ukrainian administrative regions (oblasts + cities) |

---

## Comprehensive Table Documentation

### ds_year_long - Annual Aggregates
**Purpose**: Provides high-level publishing statistics aggregated across all categories  
**Dimensions**: 19 years × 2 measures = 38 total observations  
**Key Use Cases**: Overall industry trends, baseline comparisons, growth rate calculations

| **Column** | **Specification** | **Example Values** | **Notes** |
|------------|-------------------|-------------------|-----------|
| `year` | Integer (2005-2023) | `2005`, `2015`, `2023` | Complete coverage, no missing years |
| `measure` | Factor (2 levels) | `"title_count"`, `"copy_count"` | Titles = diversity, Copies = volume |
| `value` | Numeric (0-50000) | `12450`, `890000`, `0` | Sum across all other categories |

**Data Quality**: Complete time series, no missing values, values represent totals

---

### ds_language_long - Language Distribution
**Purpose**: Tracks linguistic diversity and language preferences in Ukrainian publishing  
**Dimensions**: 19 years × 2 measures × ~18 languages = ~684 observations  
**Key Use Cases**: Language policy analysis, Russian vs Ukrainian trends, minority language tracking

| **Column** | **Specification** | **Example Values** | **Analysis Notes** |
|------------|-------------------|-------------------|-------------------|
| `year` | Integer (2005-2023) | `2010`, `2014`, `2022` | Critical years for language policy |
| `measure` | Character | `"title_count"`, `"copy_count"` | Title diversity vs circulation volume |
| `language` | Character (Ukrainian) | `"українська"`, `"російська"`, `"англійська"` | Names in Ukrainian orthography |
| `value` | Numeric (0-30000) | `15680`, `8420`, `45` | Zero indicates no publications that year |

**Language Categories Include**: Ukrainian, Russian, English, German, French, Polish, Hebrew, Yiddish, Crimean Tatar, and others  
**Special Considerations**: 2014+ data reflects geopolitical changes, some languages show sporadic publication patterns

---

### ds_genre_long - Thematic Classification  
**Purpose**: Subject matter analysis for understanding intellectual and cultural publishing trends  
**Dimensions**: 19 years × 2 measures × ~28 genres = ~1,064 observations  
**Key Use Cases**: Academic vs popular publishing, educational material trends, cultural interest shifts

| **Column** | **Specification** | **Example Values** | **Classification Notes** |
|------------|-------------------|-------------------|-------------------------|
| `year` | Integer (2005-2023) | `2008`, `2016`, `2021` | Full temporal coverage |
| `measure` | Character | `"title_count"`, `"copy_count"` | Diversity vs market demand |
| `genre` | Character (Ukrainian) | `"художня література"`, `"підручники"`, `"наукова література"` | Based on library classification |
| `value` | Numeric (0-8000) | `3250`, `1180`, `95` | Subject-specific publication counts |

**Genre Categories**: Fiction, textbooks, scientific literature, children's books, religious texts, technical manuals, reference works, poetry, drama, and specialized academic fields  
**Educational Focus**: Strong representation of textbooks and educational materials reflects Ukraine's publishing priorities

---

### ds_pubtype_long - Publication Format Analysis
**Purpose**: Understanding format preferences and publication strategies  
**Dimensions**: 19 years × 2 measures × ~12 types = ~456 observations  
**Key Use Cases**: Format trend analysis, educational vs commercial publishing, digital transition studies

| **Column** | **Specification** | **Example Values** | **Format Notes** |
|------------|-------------------|-------------------|------------------|
| `year` | Integer (2005-2023) | `2012`, `2018`, `2023` | Format evolution over time |
| `measure` | Character | `"title_count"`, `"copy_count"` | Format diversity vs production volume |
| `pubtype` | Character (Ukrainian) | `"книги"`, `"брошури"`, `"періодичні видання"` | Standard publishing categories |
| `value` | Numeric (0-25000) | `18500`, `2340`, `120` | Format-specific counts |

**Publication Types**: Books, brochures, periodical publications, educational materials, official documents, maps, sheet music, and specialized formats  
**Trend Indicators**: Shifts between formats may indicate market changes or technology adoption

---

### ds_geography_long - Regional Distribution
**Purpose**: Spatial analysis of publishing activity across Ukrainian administrative regions  
**Dimensions**: 19 years × 2 measures × 26 regions = ~988 observations  
**Key Use Cases**: Regional inequality analysis, cultural center identification, decentralization trends

| **Column** | **Specification** | **Example Values** | **Geographic Notes** |
|------------|-------------------|-------------------|---------------------|
| `year` | Integer (2005-2023) | `2009`, `2017`, `2022` | Regional time series |
| `measure` | Character | `"title_count"`, `"copy_count"` | Regional diversity vs production |
| `geography` | Character (Ukrainian) | `"м. Київ"`, `"Львівська область"`, `"Харківська область"` | Official administrative names |
| `value` | Numeric (0-18000) | `12800`, `450`, `0` | Regional publication counts |

**Geographic Coverage**: 24 oblasts, AR Crimea, Kyiv city, Sevastopol (historical data)  
**Political Considerations**: Post-2014 data excludes occupied territories, regional patterns may reflect political and economic changes

---

### ds_ukr_rus_long - Ukrainian-Russian Language Focus
**Purpose**: Detailed comparative analysis of the two most significant languages in Ukrainian publishing  
**Dimensions**: 19 years × 2 measures × 2 languages = 76 observations  
**Key Use Cases**: Language policy impact assessment, cultural shift analysis, political correlation studies

| **Column** | **Specification** | **Example Values** | **Analytical Focus** |
|------------|-------------------|-------------------|---------------------|
| `year` | Integer (2005-2023) | `2013`, `2014`, `2015` | Critical transition periods |
| `measure` | Character | `"title_count"`, `"copy_count"` | Language diversity vs circulation |
| `language` | Character (2 values) | `"українська"`, `"російська"` | Only Ukrainian and Russian |
| `value` | Numeric (0-30000) | `24680`, `6420`, `180` | Comparative language metrics |

**Derived Dataset**: Filtered subset of `ds_language_long` focusing on the two dominant languages  
**Historical Significance**: 2013-2014 represents critical period for language policy changes, data reflects cultural and political shifts in language preferences

---

## SQLite Database

All datasets are also stored in a SQLite database for efficient querying:

- **Database**: `data-private/derived/manipulation/books-of-ukraine.sqlite`
- **Tables**: All `ds_*_long` datasets with identical structure
- **Connection**: Use `DBI::dbConnect(RSQLite::SQLite(), "path/to/database")`

**Database last updated**:  2025-08-01

---

## Tips and Advice

### Quick Start Tips

**First Steps Checklist:**
1. **Load and validate**: `glimpse(ds); validate_cache_data(ds)`
2. **Check completeness**: `ds %>% summarise_all(~sum(is.na(.)))`
3. **Start with `ds_year_long`** - always begin here for overall trends
4. **Join strategically** - use `year + measure` as primary linkage keys

```r
# Essential validation function for Ukrainian publishing data
validate_cache_data <- function(ds) {
  list(
    missing_years = setdiff(2005:2023, unique(ds$year)),
    missing_measures = setdiff(c("title_count", "copy_count"), unique(ds$measure)),
    negative_values = sum(ds$value < 0, na.rm = TRUE),
    zero_vs_na = sum(is.na(ds$value)) # Should be 0 - explicit zeros used
  )
}
```

### Table-Specific Usage

#### **ds_year_long** - Start Here
**Tip**: Baseline for all trend analysis
```r
ds_year_long %>% 
  ggplot(aes(x = year, y = value, color = measure)) + geom_line() + scale_y_log10()
```

#### **ds_language_long** - Core Analysis
**Tip**: Focus on Ukrainian vs Russian dynamics, especially 2013-2014 transition
```r
ds_language_long %>% 
  filter(language %in% c("українська", "російська")) %>%
  group_by(year, measure) %>% mutate(share = value / sum(value))
```

#### **ds_genre_long** - Cultural Insights  
**Tip**: Group similar genres, watch for educational publishing patterns
```r
ds_genre_long %>% 
  mutate(decade = 10 * (year %/% 10)) %>%
  group_by(decade, genre) %>% summarise(total = sum(value))
```

#### **ds_geography_long** - Regional Analysis
**Tip**: Account for post-2014 territorial changes, calculate concentration indices
```r
ds_geography_long %>% 
  group_by(year, measure) %>% 
  mutate(regional_share = value / sum(value))
```

### Essential Analysis Patterns

**Recommended workflow:**
1. **Overall trends** - Use `ds_year_long` for baseline understanding
2. **Language dynamics** - Use `ds_language_long` and `ds_ukr_rus_long` for policy analysis
3. **Specific domains** - Choose genre, geography, or pubtype based on research focus
4. **Cross-validation** - Compare patterns across multiple tables

**Critical time periods to examine:**
- **2013-2014**: Political transition and language policy changes
- **2022+**: War impact on publishing industry
- **Pre/post 2014**: Compare periods for structural breaks

### Quality Control Recommendations

**Key validation checks:**
- **Temporal coverage**: All years 2005-2023 should be present
- **Measure consistency**: Both title_count and copy_count for comparisons
- **Zero handling**: Explicit zeros used (no missing values)
- **Regional boundaries**: Post-2014 geographic changes affect comparability

```r
# Quick quality assessment
check_ukrainian_data <- function(ds) {
  cat("Years covered:", range(ds$year), "\n")
  cat("Measures:", unique(ds$measure), "\n")
  cat("Missing values:", sum(is.na(ds$value)), "\n")
  if("language" %in% names(ds)) {
    cat("Key languages:", sum(ds$language %in% c("українська", "російська")), "of", nrow(ds), "\n")
  }
}
```

### Visualization and Analysis Tips

**Performance recommendations:**
- **Time series**: Always include both measures for comparison
- **Language analysis**: Focus on Ukrainian-Russian dynamics first
- **Regional data**: Use maps for geographic patterns
- **Genre analysis**: Group related categories for cleaner visualization

**Common analytical approaches:**
```r
# Trend analysis with political context
ds_language_long %>%
  filter(language %in% c("українська", "російська")) %>%
  ggplot(aes(x = year, y = value, color = language)) + 
  geom_line() + 
  geom_vline(xintercept = c(2014, 2022), linetype = "dashed") # Key political events

# Regional concentration analysis
ds_geography_long %>%
  group_by(year, measure) %>%
  mutate(share = value / sum(value)) %>%
  summarise(hhi = sum(share^2)) %>% # Herfindahl-Hirschman Index
  ggplot(aes(x = year, y = hhi, color = measure)) + geom_line()
```

---

## Summary

### Data Overview
**What's Available:** Ukrainian publishing statistics (2005-2023) tracking titles and copies by language, genre, geography, and publication type in standardized long-format tables optimized for temporal analysis.

**Key Capabilities:** Language policy analysis, regional publishing patterns, genre trend analysis, Ukrainian-Russian dynamics, and political-economic impact studies.

### Data Format and Structure
**Table Types:** ds_year_long (baseline), ds_language_long (core analysis), ds_genre_long (cultural trends), ds_geography_long (regional), ds_pubtype_long (formats), ds_ukr_rus_long (political focus)

**Available Formats:** SQLite Database, R Native (RDS), High-Performance (Parquet), Universal (CSV)

**Schema:** Year-measure-category structure, consistent 2005-2023 coverage, optimized for time-series and cross-category analysis

### Update Status
- **Last Updated:** 2025-08-01
- **Coverage:** 2005-2023 complete annual series
- **Quality:** Validated, explicit zeros, no missing core variables
- **Refresh:** Annual updates following official statistics release

### Technical Specs
**Integration:** R/RStudio, Python, SQL, ggplot2, specialized for Ukrainian text encoding
**Performance:** Indexed on year+measure, 6 analysis-ready tables, ~3,000 total observations
**Critical Periods:** 2013-2014 (political transition), 2022+ (war impact)

### Getting Started
1. Start with ds_year_long for overall publishing trends
2. Analyze ds_language_long for Ukrainian-Russian dynamics
3. Explore ds_geography_long for regional patterns
4. Use ds_genre_long for cultural/educational analysis
5. Focus on critical periods: 2014 and 2022+ transitions
