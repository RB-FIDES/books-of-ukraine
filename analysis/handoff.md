# Data Analysis Handoff: From Manipulation to Analysis

## Purpose

This document serves as the formal handoff from the **manipulation stage** (data preparation) to the **analysis stage** (statistical modeling and research insights) following the FIDES framework for AI-augmented research analytics. 

As described in our [semiology framework](../philosophy/semiology.md), we embrace a division of labor where data preparers create analysis-ready rectangles, and analysts focus on statistical modeling and research insights using the prepared data.

## 🎯 Research Mission

**Epistemic Aim**: Investigate and understand publishing trends in Ukraine since 2005, with special attention to:
- **Year patterns**: Temporal trends and inflection points
- **Genre distribution**: Subject matter evolution over time  
- **Language dynamics**: Ukrainian vs Russian language publishing patterns
- **Regional differences**: Oblast and territorial variations in publishing

**Key Research Questions**:
1. How have publishing patterns changed since 2005?
2. What are the regional differences in publishing activity?
3. How has the use of Russian vs Ukrainian language evolved in published books?
4. What genre patterns emerge across different oblasts and time periods?

## 📊 Data Architecture Overview

The Ellis pipeline has created a **multi-stage data architecture** optimized for different analytical needs:

### Database Stages
- **Stage 0** (`books-of-ukraine-0.sqlite`): Core book publication data
- **Stage 1** (`books-of-ukraine-1.sqlite`): Core + Ukrainian administrative data  
- **Stage 2** (`books-of-ukraine-2.sqlite`): Complete dataset with custom additions
- **Main** (`books-of-ukraine.sqlite`): **→ YOUR PRIMARY ANALYTICAL DATABASE**

### Connection Management
```r
# Load database connection functions
source("./scripts/common-functions.R")

# Connect to primary analytical database
db <- connect_books_db("main")

# Read analytical tables
ds_year <- DBI::dbReadTable(db, "ds_year")
ds_language <- DBI::dbReadTable(db, "ds_language") 
ds_territory <- DBI::dbReadTable(db, "ds_territory")
ds_theme <- DBI::dbReadTable(db, "ds_theme")
ds_purpose <- DBI::dbReadTable(db, "ds_purpose")
ds_oblast <- DBI::dbReadTable(db, "ds_oblast")
ds_bookstores <- DBI::dbReadTable(db, "ds_bookstores")

# Always disconnect when done
DBI::dbDisconnect(db)

# Alternative connections for specific needs:
# stage1_db <- connect_books_db("stage_1")  # For enhanced territorial analysis
# stage2_db <- connect_books_db("stage_2")  # For comprehensive source data
```

## 🗃️ Core Analytical Tables

### Overview

All core data follows a **consistent long format** optimized for analysis:

**Books Chamber Data** (Publishing Statistics)
- `ds_year` - Annual publication trends (title_count & copy_count)
- `ds_language` - Language breakdown (Ukrainian, Russian, English, etc. - 37 total languages)
- `ds_territory` - Oblast/geographic distribution with oblast codes
- `ds_theme` - Genre/topic classification (publisher-defined)
- `ds_purpose` - Publication purpose classification (government-defined)

**Ukrainian Administrative Data** (Geographic Context)
- `ds_oblast` - Oblast features (area, population, income, regional classification) sourced and adapted from [KSE-Loc-Data-Hub](https://github.com/kse-ua/KSE-Loc-Data-Hub)

**User-Contributed Data** (Custom Additions)
- `ds_bookstores` - Bookstore counts by oblast (2023) - *Example of user-contributed data*


### Primary Analysis Tables (Wide Format)

All core data is available in **wide format** with measures as columns for convenient analysis:

#### 1. **`ds_year`** - Overall Publication Trends
```r
# Examine overall trends by year
head(ds_year)
str(ds_year)

# Quick exploration commands:
range(ds_year$year)
summary(ds_year$title_count)
summary(ds_year$copy_count)
```

**Columns**: `year`, `title_count`, `copy_count`  
**Use for**: Time series analysis, overall publication volume trends

#### 2. **`ds_language`** - Language Analysis 🇺🇦🇷🇺
```r
# Examine language patterns
head(ds_language)
table(ds_language$language)

# Language distribution by year - Ukrainian vs Russian
ds_language %>% 
  filter(language %in% c("Ukrainian", "Russian")) %>%
  select(year, language, title_count) %>%
  tidyr::pivot_wider(names_from = language, values_from = title_count)
```

**Columns**: `year`, `language`, `title_count`, `copy_count`, `language_ua`  
**Key Languages**: "Ukrainian", "Russian", "English", others (37 total languages)  
**Use for**: Language dominance analysis, cultural trend investigation

#### 3. **`ds_theme`** - Subject Matter Analysis
```r
# Examine theme/subject patterns  
head(ds_theme)
table(ds_theme$theme)

# Top themes by publication volume
ds_theme %>%
  group_by(theme) %>%
  summarise(total_titles = sum(title_count, na.rm = TRUE)) %>%
  arrange(desc(total_titles)) %>%
  head(10)
```

**Columns**: `year`, `theme`, `title_count`, `copy_count`, `theme_ua`  
**Use for**: Academic subject trends, topic popularity over time

#### 4. **`ds_territory`** - Regional Analysis 🗺️
```r
# Examine territorial/oblast patterns
head(ds_territory)
table(ds_territory$territory)

# Regional publishing activity
ds_territory %>%
  group_by(territory) %>%
  summarise(total_titles = sum(title_count, na.rm = TRUE)) %>%
  arrange(desc(total_titles)) %>%
  head(15)
```

**Columns**: `year`, `territory`, `oblast_code`, `title_count`, `copy_count`, `territory_ua`  
**Key Territories**: Oblasts and regions (e.g., "Kyiv", "Kharkiv", "Lviv")  
**Use for**: Regional inequality analysis, geographic publishing patterns

#### 5. **`ds_purpose`** - Purpose Classification Analysis
```r
# Examine purpose/classification patterns
head(ds_purpose)
table(ds_purpose$purpose)

# Purpose distribution over time
ds_purpose %>%
  group_by(purpose) %>%
  summarise(total_titles = sum(title_count, na.rm = TRUE)) %>%
  arrange(desc(total_titles))
```

**Columns**: `year`, `purpose`, `title_count`, `copy_count`, `purpose_ua`  
**Use for**: Government classification trends, publication purpose analysis

### Enhanced Geographic Data (Stage 1+)

For deeper territorial analysis, connect to Stage 1 database:

```r
# Access enhanced geographic data with administrative hierarchy
stage1_db <- connect_books_db("stage_1")

# Examine oblast-level aggregations with demographic data
ua_oblasts <- DBI::dbReadTable(stage1_db, "ua_oblasts_aggregated")
head(ua_oblasts)

# Regional classifications
regions <- DBI::dbReadTable(stage1_db, "dim_regions") 
table(regions$region_en)  # Center/North/West/South classifications

# Dimensional tables for lookups
dim_oblasts <- DBI::dbReadTable(stage1_db, "dim_oblasts")
DBI::dbDisconnect(stage1_db)
```

## 🔍 Recommended Data Exploration Workflow

### 1. Initial Data Inspection
```r
# Load and connect
source("./scripts/common-functions.R")
library(dplyr)
library(ggplot2)

# Connect to analysis database and import tables
db <- connect_books_db("main")
ds_year <- DBI::dbReadTable(db, "ds_year")
ds_language <- DBI::dbReadTable(db, "ds_language")
ds_theme <- DBI::dbReadTable(db, "ds_theme")
ds_purpose <- DBI::dbReadTable(db, "ds_purpose")
ds_territory <- DBI::dbReadTable(db, "ds_territory")
ds_oblast <- DBI::dbReadTable(db, "ds_oblast")
DBI::dbDisconnect(db)

# Overall publication trends
ds_year %>%
  ggplot(aes(x = year, y = title_count)) +
  geom_line() +
  geom_point() +
  labs(title = "Total Book Publications by Year", 
       x = "Year", y = "Number of Titles") +
  theme_minimal()

# Check for structural breaks or policy changes
summary(lm(title_count ~ year, data = ds_year))
```

### 3. Language Dynamics Analysis 🇺🇦🇷🇺
```r
# Language trends over time
ds_language %>%
  filter(language %in% c("Ukrainian", "Russian")) %>%
  ggplot(aes(x = year, y = title_count, color = language)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  labs(title = "Publishing Trends: Ukrainian vs Russian Language",
       x = "Year", y = "Number of Titles", color = "Language") +
  scale_color_manual(values = c("Ukrainian" = "#005BBB", "Russian" = "#DC143C"))

# Calculate language proportion over time
ds_language %>%
  group_by(year) %>%
  mutate(prop = title_count / sum(title_count, na.rm = TRUE)) %>%
  filter(language %in% c("Ukrainian", "Russian")) %>%
  select(year, language, title_count, prop)
```

### 4. Regional Analysis (Oblast/Territory Focus) 🗺️
```r
# Regional publishing inequality
ds_territory %>%
  group_by(territory) %>%
  summarise(total_titles = sum(title_count, na.rm = TRUE),
            avg_per_year = mean(title_count, na.rm = TRUE),
            total_copies = sum(copy_count, na.rm = TRUE)) %>%
  arrange(desc(total_titles))

# Enhanced analysis with administrative data
ds_oblast %>%
  select(oblast_name_en, total_population, avg_income_per_capita_2022, 
         region_en, income_category) %>%
  arrange(desc(total_population))
```

### 5. Genre/Subject Analysis
```r
# Theme evolution over time
top_themes <- ds_theme %>%
  group_by(theme) %>%
  summarise(total = sum(title_count, na.rm = TRUE)) %>%
  slice_max(total, n = 8) %>%
  pull(theme)

ds_theme %>%
  filter(theme %in% top_themes) %>%
  ggplot(aes(x = year, y = title_count, color = theme)) +
  geom_line() +
  facet_wrap(~theme, scales = "free_y") +
  theme_minimal()

# Purpose classification analysis  
ds_purpose %>%
  group_by(purpose) %>%
  summarise(total_titles = sum(title_count, na.rm = TRUE)) %>%
  arrange(desc(total_titles))
```

## 📈 Available Measures

Each analytical table includes multiple **measure columns**:

- **`title_count`**: Number of published titles
- **`copy_count`**: Print run/circulation figures (equivalent to "naklad")

**Direct column access** for analysis:
```r
# Direct access to measures as columns
ds_language %>% select(year, language, title_count, copy_count) %>% ...

# Check column structure
names(ds_language)
str(ds_language)
```

## 🎨 Analytical Philosophy: Dialectical Data Expression

Following our [semiology framework](../philosophy/semiology.md), approach your analysis as **translation across data dialects**:

- **Tabular**: Raw numeric patterns in the long-format tables
- **Algebraic**: Statistical models capturing relationships  
- **Graphical**: Visualizations revealing trends and patterns
- **Semantic**: Narrative interpretation connecting to Ukrainian cultural context

Your role as analyst is to **conduct meaning** across these modes, using the prepared data as your foundation while the AI assists with technical execution.

## 🗄️ Database Schema Reference

### Common Column Patterns
- **`year`**: Integer, 2005-2023 range
- **`title_count`**: Number of published titles (numeric)
- **`copy_count`**: Print run/circulation figures (numeric)
- **`*_ua`**: Ukrainian language terms (e.g., `language_ua`, `theme_ua`)
- **`*`**: English translations (e.g., `language`, `theme`, `territory`)

### Table-Specific Columns
- **`ds_language`**: `language`, `language_ua` 
- **`ds_theme`**: `theme`, `theme_ua`
- **`ds_purpose`**: `purpose`, `purpose_ua`
- **`ds_territory`**: `territory`, `territory_ua`, `oblast_code`

### Administrative Data (ds_oblast)
- **`oblast_name_en`**: English oblast names
- **`region_en`**: Regional groupings (Center/North/West/South)
- **`total_population`**: Demographic data for per-capita analysis
- **`avg_income_per_capita_2022`**: Economic indicators
- **`income_category`**: Categorical income classification

## 🚀 Next Steps for Analysis

1. **Start with temporal patterns** using `ds_year` 
2. **Examine language dynamics** with `ds_language` (focus on Ukrainian vs Russian)
3. **Investigate regional differences** using `ds_geography` and Stage 1 oblast data
4. **Explore genre patterns** across time and regions using `ds_genre`
5. **Cross-dimensional analysis**: How do language patterns vary by region and time?

## 📚 Reference Materials

- **Manipulation pipeline**: See `./manipulation/README.md` for data creation process
- **Analysis examples**: `./analysis/eda-1/eda-1.R` demonstrates data loading and basic analysis
- **Philosophical framework**: `./philosophy/semiology.md` for analytical approach
- **FIDES methodology**: `./ai/mission.md` for research objectives

## 💡 Analytical Opportunities

**High-Priority Research Questions**:
1. **Language shift patterns**: How has Russian vs Ukrainian publishing changed since 2014?
2. **Regional inequality**: Which oblasts dominate publishing, and how has this changed?
3. **Cultural-political correlation**: Do language patterns correlate with political events?
4. **Subject matter evolution**: How have academic and literary genres shifted over time?

## ⚠️ Important: Data Format Update

**The current database uses WIDE FORMAT tables** where measures (`title_count`, `copy_count`) are **columns**, not a single `measure` column with `value`. This provides:

- **Direct column access**: `ds_language$title_count` instead of filtering by measure
- **Convenient analysis**: No need to pivot or filter by measure type
- **Bilingual support**: Both Ukrainian (`*_ua`) and English terms included
- **Ready for visualization**: Direct plotting without data transformation

**Remember**: You are working with analysis-ready data. The manipulation stage has handled data cleaning, transformation, and preparation. Your focus should be on **statistical modeling**, **pattern discovery**, and **research insight generation**.

---

*This handoff document bridges the manipulation and analysis stages following the FIDES framework. The data is prepared and waiting for your analytical expertise.*