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
- **Final** (`books-of-ukraine.sqlite`): **→ YOUR PRIMARY ANALYTICAL DATABASE**

### Connection Management
```r
# Load database connection functions
source("./scripts/common-functions.R")

# Connect to primary analytical database
books_db <- connect_books_db("main")

# Alternative connections for specific needs:
# books_db <- connect_books_db("stage_1")  # For territorial analysis
# books_db <- connect_books_db("stage_2")  # For comprehensive data
```

## 🗃️ Core Analytical Tables

### Overview

**Books Chamber**
 - year
 - language
 - territory
 - theme 
 - purpose

**UA Admin**
- ds_oblast
- dim_oblasts
- dim_regions

**Extra** 
- ds_bookstores

### Primary Analysis Tables (Long Format)

All core data is available in **long format** for flexible analysis:

#### 1. **`ds_year`** - Overall Publication Trends
```r
# Examine overall trends by year
head(ds_year)
str(ds_year)

# Quick exploration commands:
table(ds_year$measure)
range(ds_year$year)
summary(ds_year$value)
```

**Columns**: `year`, `measure`, `value`  
**Use for**: Time series analysis, overall publication volume trends

#### 2. **`ds_language`** - Language Analysis 🇺🇦🇷🇺
```r
# Examine language patterns
head(ds_language)
table(ds_language$language)

# Language distribution by year
ds_language %>% 
  filter(measure == "title_count") %>%
  group_by(year, language) %>%
  summarise(total_titles = sum(value), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = language, values_from = total_titles)
```

**Columns**: `year`, `language`, `measure`, `value`  
**Key Languages**: "Українська", "Російська", "Англійська", others  
**Use for**: Language dominance analysis, cultural trend investigation

#### 3. **`ds_genre`** - Subject Matter Analysis
```r
# Examine genre/subject patterns  
head(ds_genre)
table(ds_genre$genre)

# Top genres by publication volume
ds_genre %>%
  filter(measure == "title_count") %>%
  group_by(genre) %>%
  summarise(total_titles = sum(value, na.rm = TRUE)) %>%
  arrange(desc(total_titles)) %>%
  head(10)
```

**Columns**: `year`, `genre`, `measure`, `value`  
**Use for**: Academic subject trends, genre popularity over time

#### 4. **`ds_geography`** - Regional Analysis 🗺️
```r
# Examine territorial/oblast patterns
head(ds_geography)
table(ds_geography$geography)

# Regional publishing activity
ds_geography %>%
  filter(measure == "title_count") %>%
  group_by(geography) %>%
  summarise(total_titles = sum(value, na.rm = TRUE)) %>%
  arrange(desc(total_titles)) %>%
  head(15)
```

**Columns**: `year`, `geography`, `measure`, `value`  
**Key Territories**: Oblasts, cities (е.g., "м. Київ", "Київська область")  
**Use for**: Regional inequality analysis, geographic publishing patterns

### Enhanced Geographic Data (Stage 1+)

For deeper territorial analysis, connect to Stage 1 database:

```r
# Access enhanced geographic data with administrative hierarchy
stage1_db <- connect_books_db("stage_1")

# Examine oblast-level aggregations with demographic data
oblast_data <- DBI::dbReadTable(stage1_db, "ds_oblast")
head(oblast_data)

# Regional classifications
regions <- DBI::dbReadTable(stage1_db, "dim_regions") 
table(regions$region_en)  # West/East/Center/South classifications
```

## 🔍 Recommended Data Exploration Workflow

### 1. Initial Data Inspection
```r
# Load and connect
source("./scripts/common-functions.R")
library(dplyr)
library(ggplot2)

# Import long-format tables (see analysis/eda-1/eda-1.R for full example)
fact_book <- read.csv("data-private/derived/manipulation/CSV/fact_book_publications.csv")

# Transform to analysis-friendly long format
ds_year <- fact_book %>%
  filter(category_type == "total") %>%
  select(year, measure = measure_type, value)

ds_language <- fact_book %>%
  filter(category_type == "language") %>%
  select(year, language = category_value, measure = measure_type, value)

# ... (continue for ds_genre, ds_geography)
```

### 2. Temporal Patterns (Year Focus)
```r
# Overall publishing trends
ds_year %>%
  filter(measure == "title_count") %>%
  ggplot(aes(x = year, y = value)) +
  geom_line() +
  geom_point() +
  labs(title = "Total Book Publications by Year", 
       x = "Year", y = "Number of Titles") +
  theme_minimal()

# Check for structural breaks or policy changes
summary(lm(value ~ year, data = filter(ds_year, measure == "title_count")))
```

### 3. Language Dynamics Analysis 🇺🇦🇷🇺
```r
# Language trends over time
ds_language %>%
  filter(measure == "title_count", 
         language %in% c("Українська", "Російська")) %>%
  ggplot(aes(x = year, y = value, color = language)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  labs(title = "Publishing Trends: Ukrainian vs Russian Language",
       x = "Year", y = "Number of Titles", color = "Language") +
  scale_color_manual(values = c("Українська" = "#005BBB", "Російська" = "#DC143C"))

# Calculate language proportion over time
ds_language %>%
  filter(measure == "title_count") %>%
  group_by(year) %>%
  mutate(prop = value / sum(value, na.rm = TRUE)) %>%
  filter(language %in% c("Українська", "Російська"))
```

### 4. Regional Analysis (Oblast/Territory Focus) 🗺️
```r
# Regional publishing inequality
ds_geography %>%
  filter(measure == "title_count") %>%
  group_by(geography) %>%
  summarise(total_titles = sum(value, na.rm = TRUE),
            avg_per_year = mean(value, na.rm = TRUE)) %>%
  arrange(desc(total_titles))

# For enhanced analysis with administrative data:
stage1_db <- connect_books_db("stage_1")
oblast_enhanced <- DBI::dbReadTable(stage1_db, "ds_oblast_wide")
# Examine population, income, urbanization correlates
```

### 5. Genre/Subject Analysis
```r
# Genre evolution over time
top_genres <- ds_genre %>%
  filter(measure == "title_count") %>%
  group_by(genre) %>%
  summarise(total = sum(value, na.rm = TRUE)) %>%
  slice_max(total, n = 8) %>%
  pull(genre)

ds_genre %>%
  filter(measure == "title_count", genre %in% top_genres) %>%
  ggplot(aes(x = year, y = value, color = genre)) +
  geom_line() +
  facet_wrap(~genre, scales = "free_y") +
  theme_minimal()
```

## 📈 Available Measures

Each analytical table includes multiple **measure types**:

- **`title_count`**: Number of published titles
- **`naklad`**: Print run/circulation figures
- **`other_measures`**: Additional publishing metrics

**Always filter by measure type** for meaningful analysis:
```r
# Correct approach
ds_language %>% filter(measure == "title_count") %>% ...

# Check available measures
table(ds_language$measure)
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
- **`category_type`**: "language", "theme", "territory", "total", "purpose"  
- **`category_value`**: Specific category (e.g., "Українська", "м. Київ")
- **`measure_type`**: "title_count", "naklad", others
- **`value`**: Numeric value for the measure

### Administrative Enhancement (Stage 1+)
- **`oblast_name_en`**: English oblast names
- **`region_en`**: Regional groupings (Central/Eastern/Western/Southern)
- **`total_population`**: Demographic data for per-capita analysis
- **`avg_income_per_capita_2022`**: Economic indicators

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

**Remember**: You are working with analysis-ready data. The manipulation stage has handled data cleaning, transformation, and preparation. Your focus should be on **statistical modeling**, **pattern discovery**, and **research insight generation**.

---

*This handoff document bridges the manipulation and analysis stages following the FIDES framework. The data is prepared and waiting for your analytical expertise.*