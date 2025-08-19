# `manipulation/` Directory

This directory contains the **Ellis Pipeline** - a multi-stage data processing system for Ukrainian book publication data.

## 📊 Pipeline Architecture

The Ellis Pipeline processes data through 3 distinct stages:

### **Stage 0**: Core Data Processing (`0-ellis.R`)
- **Input**: Main Google Sheets document with 5 core data sheets
  - Рік (Years), Мова (Language), Тема (Theme), Територія (Territory), Призначення (Purpose)
- **Output**: `books-of-ukraine-0.sqlite` (Core book publication data)
- **Purpose**: Stable, featured content processing

### **Stage 1**: Ukrainian Administrative Data (`1-ellis-ua-admin.R`)
- **Input**: Stage 0 database + Ukrainian administrative datasets
- **Output**: `books-of-ukraine-1.sqlite` (Core + Administrative data)  
- **Purpose**: Territorial enrichment with hromada-level data

### **Stage 2**: Extra/Custom Data (`2-ellis-extra.R`)
- **Input**: Stage 1 database + Custom data sources (configured in `extra-data-config.R`)
  - Currently processes: Книгарні (Bookstores) data
  - **User-friendly**: Add new sources via configuration, no code changes needed
- **Output**: `books-of-ukraine-2.sqlite` (Complete dataset)  
- **Purpose**: User-contributed and post-hoc custom tables

### **Final Stage**: Analytical Tables (`last-ellis.R`)
- **Input**: Stage 2 database
- **Output**: `books-of-ukraine.sqlite` (Clean analytical tables) + CSV exports
- **Purpose**: Analysis-ready tables optimized for human analysts

## 🗂️ Data Architecture Separation

**Core Stable Data** (Stages 0-1):
- Maintained, featured content
- Consistent schema and validation
- Foundation for all analyses

**Custom/Extra Data** (Stage 2):  
- User contributions
- Post-hoc additions
- Flexible schema for new data sources

## 📁 Database Outputs

- `books-of-ukraine-0.sqlite`: Core publication data (Stage 0)
- `books-of-ukraine-1.sqlite`: Core + Ukrainian admin data (Stage 1)  
- `books-of-ukraine-2.sqlite`: Complete dataset with custom data (Stage 2)
- `books-of-ukraine.sqlite`: Final analytical tables
- `CSV/`: All analytical tables exported for external tools

## 🎯 Adding Custom Data

**Easy Configuration-Based Approach**: No R coding required!

1. **Edit Configuration**: `manipulation/extra-data-config.R`
2. **Add Data Source**: Copy a template and modify it  
3. **Activate**: Set `active = TRUE`
4. **Run**: `Rscript manipulation/2-ellis-extra.R`

**📚 Complete Guide**: See `guides/custom-data-guide.md` for:
- Supported data types (categorical time series, lookup tables, fact tables)
- Step-by-step examples  
- Google Sheets formatting requirements
- Troubleshooting tips

**🔧 Modular Architecture**: 
- `extra-data-config.R`: User-friendly configuration
- `extra-data-functions.R`: Automatic data type detection and processing
- Built-in validation and helpful error messages

## 🚀 Usage

**Complete Pipeline**:
```r
# Stage 0: Core data
source("manipulation/0-ellis.R")

# Stage 1: Add Ukrainian administrative data  
source("manipulation/1-ellis-ua-admin.R")

# Stage 2: Add custom/extra data
source("manipulation/2-ellis-extra.R")

# Final: Create analytical tables
source("manipulation/last-ellis.R")
```

**Add Custom Data Only**:
```r  
# 1. Edit configuration
file.edit("manipulation/extra-data-config.R")

# 2. Process new data  
source("manipulation/2-ellis-extra.R")
source("manipulation/last-ellis.R")
```

They typically intake raw data from `./data-public/raw` and/or `./data-private/raw` and transform them into tidy objects, which would be convenient to place into literate scripts (e.g. `.Rmd` or `.qmd`) for exploration and annotation. For example, consider a simple project described in [RAnalysisSkeleton](https://github.com/wibeasley/RAnalysisSkeleton), featuring the ubiquitous `cars` data set:

![](images/flow-skeleton-car.png)

The script `./manipulation/car-ellis.R` digests a raw `.csv` file from `./data-public/raw` and creates a clean data object `car.rds`, so-called *analysis-ready rectangle*. This object becomes the starting point for the literate script `./analysis/car-report-1/car-report-1.Rmd` which renders a self-contained document `car-report-1.hmtl` , the deliverable in this simple project. In this case, the [ellis and scribe patterns](https://ouhscbbmc.github.io/data-science-practices-1/patterns.html) are combined in the single script.

Please follow these [instructions](https://github.com/wibeasley/RAnalysisSkeleton#establishing-a-workstation-for-analysis) to execute the entire pipline of the RAnalysisSkeleton repo and examine `./analysis/car-report-1/car-report-1.html` for examples of code syntax for most basic tasks in data analysis. This template is useful for simple, one-off projects, like a straightforward information request with a quick turn-over.

However, a more realistic project involves multiple data sources and may call for separate tidy data sets to accommodate the specific requirement of a given task (e.g. feed into a statistical model vs serve as a data source for a dashboard). Consider the following example in which 20 children who live across three different counties are measured each year for 10 years on some physical and cognitive abilities to study their growth and to estimate how county characteristics (which are also measured each year) influence children's physical and mental growth.

![](images/flow-skeleton-02.png)

We may want to explore county-level characteristics (`te.rds`) separtely from person-level characteristics (`mlm.rds`), hence two different rectangles, optimized for each task.

The resulting "derived" datasets produce less friction when analyzing. By centralizing most (and ideally all) of the manipulation code in one place, it's easier to determine how the data was changed before analyzing. It also reduces duplication of manipulation code, so analyses in different files are more consistent and understandable.

# GOA example 

It might be easier to think in terms of an example more relevant to our substantive focus:

![](images/flow-skeleton.png)
