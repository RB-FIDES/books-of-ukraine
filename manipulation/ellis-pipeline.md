This directory contains the **Ellis Pipeline** - a multi-stage data processing system for Ukrainian book publication data.

## 📊 Pipeline Architecture

The Ellis Pipeline processes data through 4 distinct stages:

### **Stage 0**: Core Data Processing (`0-ellis.R`)
- **Input**: Main Google Sheets document with 5 core data sheets
  - Рік (Years), Мова (Language), Тема (Theme), Територія (Territory), Призначення (Purpose)
- **Output**: `books-of-ukraine-0.sqlite` (Core book publication data)
- **Purpose**: Stable, featured content processing

### **Stage 1**: Ukrainian Administrative Data (`1-ellis-ua-admin.R`)
- **Input**: Stage 0 database + Ukrainian administrative datasets
- **Output**: `books-of-ukraine-1.sqlite` (Core + Administrative data)  
- **Purpose**: Territorial enrichment with hromada-level data

### **Stage 2**: Modular Custom Data (`2-ellis-extra.R`)
- **Input**: Stage 1 database + Custom data sources (configured in `extra-data-config.R`)
  - **Bilingual Support**: Accepts Ukrainian or English column names, standardizes to English
  - Currently processes: Книгарні (Bookstores) data with Ukrainian column headers
  - **User-friendly**: Add new sources via configuration, no code changes needed
- **Output**: `books-of-ukraine-2.sqlite` (Complete dataset)  
- **Purpose**: User-contributed and post-hoc custom tables with automatic language handling

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

**🌍 Bilingual Support**: Input data can use Ukrainian or English column names:
- **Ukrainian**: "Показник", "Територія", "Область" (natural for Ukrainian users)
- **English**: "Measure", "Territory", "Oblast" (for standardization)
- **Automatic**: All inputs are standardized to English internally for pipeline consistency

**📚 Complete Guide**: See `guides/custom-data-guide.md` for:
- Supported data types (categorical time series, lookup tables, fact tables)
- Step-by-step examples with bilingual column examples  
- Google Sheets formatting requirements
- Troubleshooting tips

**🔧 Modular Architecture**: 
- `extra-data-config.R`: User-friendly configuration
- `extra-data-functions.R`: Automatic data type detection, language standardization, and processing
- Built-in validation with helpful error messages in both languages

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
