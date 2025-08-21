# CACHE Manifest - Books of Ukraine Stage 2 Database

**Generated:** 2025-08-21 09:32:48.332771
**Database:** books-of-ukraine-2.sqlite
**Pipeline Stage:** Modular Custom Data Integration
**Total Tables:** 10

## 📊 Stage 2 Database Architecture

Stage 2 adds modular custom data sources with **bilingual Ukrainian/English support** to the comprehensive pipeline.

### 🌍 Bilingual Data Integration

- **Input Flexibility**: Accepts Ukrainian OR English column names
- **Standardized Output**: All data converted to English for pipeline consistency
- **Automatic Translation**: Ukrainian terms like 'Показник' → 'pokaznik', 'Територія' → 'teritoria'
- **User-Friendly**: No manual translation required by data contributors

### 🏗️ Architecture Overview

```
STAGE 1 DATABASE (All tables)     CUSTOM DATA SOURCES
┌─────────────────────────────┐   ┌─────────────────────┐
│ fact_book_publications      │   │ Google Sheets       │
│ dim_* (years, categories)   │ + │ (Ukrainian/English) │
│ fact_hromadas              │   │ Configuration-driven │
│ ua_oblasts_aggregated      │   │ User-contributed    │
└─────────────────────────────┘   └─────────────────────┘
                    ↓
            STAGE 2 DATABASE
        (Complete + Custom Data)
```

### 🔗 Integration Strategy

**PRESERVED TABLES** (from Stage 1):
- All core book publication data
- Ukrainian administrative data
- Complete dimensional structure

**CUSTOM TABLES** (added in Stage 2):
- Prefix: `ds_` (dataset)
- Bilingual input support
- Configuration-driven processing
- User-friendly validation

## 📋 Custom Data Tables

- **ds_bookstores**: 23 records


