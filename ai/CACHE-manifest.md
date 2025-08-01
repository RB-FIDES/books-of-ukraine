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
| `yr` | Integer | Year of observation (2005-2023) |
| `measure` | Character | Type of measurement (`title_count` or `copy_count`) |
| `[category]` | Character | Category variable (language, genre, geography, pubtype) |
| `value` | Numeric | Measured value for the year-measure-category combination |

---

## CACHE TABLES

### Ferry Load Tables (Analysis-Ready)

| **Table Name** | **Primary Key(s)** | **Purpose** | **Source Sheet** |
|----------------|-------------------|-------------|------------------|
| **`🆕 ds_year_long`** | `yr + measure` | Annual aggregate publishing statistics | К-ть видань |
| **`🆕 ds_language_long`** | `yr + measure + language` | Publications by language | мови народу світу |
| **`🆕 ds_genre_long`** | `yr + measure + genre` | Publications by thematic genre | Тематичні розділи, Наклад тематич., Тематичні розділи 05-06 |
| **`🆕 ds_pubtype_long`** | `yr + measure + pubtype` | Publications by publication type | Аркуш15, Цільові призначення |
| **`🆕 ds_geography_long`** | `yr + measure + geography` | Publications by Ukrainian region | території, Терир. наклад |
| **`🆕 ds_ukr_rus_long`** | `yr + measure + language` | Ukrainian vs Russian language publications | мови народу світу (derived) |

---

## Data Transformation Details

###  ds_year_long
- **Definition**:  Total publication counts across all categories by year
- **Primary Key**:  yr + measure
- **File Size**:  0.4  KB
- **Last Modified**:  2025-08-01 11:50
- **File Path**: `data-private/derived/manipulation/ ds_year_long .rds`

###  ds_language_long
- **Definition**:  Language distribution of publications over time
- **Primary Key**:  yr + measure + language
- **File Size**:  1.8  KB
- **Last Modified**:  2025-08-01 11:50
- **File Path**: `data-private/derived/manipulation/ ds_language_long .rds`

###  ds_genre_long
- **Definition**:  Genre/thematic classification of publications
- **Primary Key**:  yr + measure + genre
- **File Size**:  5.8  KB
- **Last Modified**:  2025-08-01 11:50
- **File Path**: `data-private/derived/manipulation/ ds_genre_long .rds`

###  ds_pubtype_long
- **Definition**:  Publication type classification and analysis
- **Primary Key**:  yr + measure + pubtype
- **File Size**:  2.8  KB
- **Last Modified**:  2025-08-01 11:50
- **File Path**: `data-private/derived/manipulation/ ds_pubtype_long .rds`

###  ds_geography_long
- **Definition**:  Regional distribution of publishing activity
- **Primary Key**:  yr + measure + geography
- **File Size**:  3.9  KB
- **Last Modified**:  2025-08-01 11:50
- **File Path**: `data-private/derived/manipulation/ ds_geography_long .rds`

###  ds_ukr_rus_long
- **Definition**:  Comparative analysis of Ukrainian and Russian language publishing
- **Primary Key**:  yr + measure + language
- **File Size**:  1  KB
- **Last Modified**:  2025-08-01 11:50
- **File Path**: `data-private/derived/manipulation/ ds_ukr_rus_long .rds`

---

## SQLite Database

All datasets are also stored in a SQLite database for efficient querying:

- **Database**: `data-private/derived/manipulation/books-of-ukraine.sqlite`
- **Tables**: All `ds_*_long` datasets with identical structure
- **Connection**: Use `DBI::dbConnect(RSQLite::SQLite(), "path/to/database")`

**Database last updated**:  2025-08-01
