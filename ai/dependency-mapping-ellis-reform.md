# Dependency Mapping for Ellis Pipeline Reform

*Generated: 2025-08-17*  
*Purpose: Complete mapping of files requiring updates for database renaming*

---

## 🗄️ **Current Database Chain**
```
0-ellis.R → books-of-ukraine-long.sqlite
1-ellis.R → books-of-ukraine-enhanced.sqlite (copies from books-of-ukraine-long.sqlite)
last-ellis.R → BOOKS-OF-UKRAINE.sqlite (reads from books-of-ukraine-enhanced.sqlite)
```

## 🎯 **Target Database Chain**
```
0-ellis.R → books-of-ukraine-0.sqlite
1-ellis-ua-admin.R → books-of-ukraine-1.sqlite
last-ellis.R → books-of-ukraine.sqlite (reads from books-of-ukraine-1.sqlite)
```

---

## 📋 **Files Requiring Updates**

### **1. Core Manipulation Scripts**

#### `manipulation/0-ellis.R`
- **Current**: `"books-of-ukraine-long.sqlite"`
- **Target**: `"books-of-ukraine-0.sqlite"`
- **Lines to Update**: Database connection paths, output paths, documentation strings

#### `manipulation/last-ellis.R`
- **Current Input**: `"books-of-ukraine-enhanced.sqlite"`
- **Target Input**: `"books-of-ukraine-1.sqlite"`
- **Current Output**: `"BOOKS-OF-UKRAINE.sqlite"`
- **Target Output**: `"books-of-ukraine.sqlite"`
- **Multiple References**: 20+ references to BOOKS-OF-UKRAINE.sqlite throughout file

### **2. Infrastructure Scripts**

#### `project-status.ps1`
- **Current**: References `"books-of-ukraine-long.sqlite"`
- **Target**: Update to `"books-of-ukraine-0.sqlite"` (core) and `"books-of-ukraine.sqlite"` (default)
- **Purpose**: Database validation and status checking

### **3. Documentation Files**

#### `pipeline.md`
- **Current**: References `books-of-ukraine.sqlite` as primary analytical database
- **Target**: Document the numbered database system and default database paradigm

#### `ai/CACHE-MANIFEST-*.md`
- **Files**: `CACHE-manifest-0.md`, `CACHE-MANIFEST-1.md`, `CACHE-manifest-analytical.md`
- **Updates Needed**: Database name references, schema documentation

#### Current Manifest Files to Update:
- `CACHE-manifest-0.md` → Update for `books-of-ukraine-0.sqlite`
- `CACHE-MANIFEST-1.md` → Will be replaced by new ua-admin manifest
- `CACHE-manifest-analytical.md` → Update default database references

### **4. Configuration System (NEW)**

#### `config.yml`
- **Add Section**:
```yaml
database:
  books_of_ukraine:
    main: "data-private/derived/manipulation/SQLite/books-of-ukraine.sqlite"
    intermediate:
      core: "data-private/derived/manipulation/SQLite/books-of-ukraine-0.sqlite"
      admin: "data-private/derived/manipulation/SQLite/books-of-ukraine-1.sqlite"
```

### **5. Analysis Scripts (Future Update)**

#### Path Pattern to Add:
```r
# Standard config-based database connection
library(yaml)
config <- yaml::read_yaml("config.yml")
db_path <- config$database$books_of_ukraine$main
db <- dbConnect(RSQLite::SQLite(), db_path)
```

#### Scripts in `analysis/` Directory:
- All subdirectories: `eda-1/`, `eda-2/`, `map-guide/`, `Data-visualization/`, `analysis-templatization/`
- **Action**: Update import patterns to use config-based paths (not immediate testing)

---

## 🔄 **Update Sequence & Dependencies**

### **Critical Path**:
1. **First**: Create config.yml database section
2. **Second**: Update 0-ellis.R output path 
3. **Third**: Create 1-ellis-ua-admin.R with correct input/output paths
4. **Fourth**: Update last-ellis.R input path
5. **Fifth**: Update infrastructure and documentation

### **Dependencies**:
- `last-ellis.R` depends on output from `1-ellis-ua-admin.R`
- `project-status.ps1` depends on knowing which databases should exist
- Analysis scripts depend on config.yml having correct default path
- Documentation depends on understanding new architecture

---

## 🚨 **Critical Considerations**

### **File System Structure**:
- All databases in: `data-private/derived/manipulation/SQLite/`
- Maintain existing directory structure
- No changes to CSV/RDS output patterns

### **Backward Compatibility**:
- Old database files will be overwritten by updated scripts
- No migration needed - databases are reproducible from scripts
- Historical references in `ai/log/` and `ai/memory-*` will remain unchanged

### **Testing Requirements**:
- Verify complete pipeline: 0-ellis → 1-ellis-ua-admin → last-ellis
- Validate database schemas match expected format
- Ensure manifest generation works correctly
- Test config.yml integration with analysis script pattern

---

## 📊 **Files Summary**

| **Category** | **Files** | **Update Type** |
|--------------|-----------|-----------------|
| Core Scripts | `0-ellis.R`, `last-ellis.R` | Database path changes |
| New Scripts | `1-ellis-ua-admin.R` | Create from 2-ellis-ua-admin.R |
| Infrastructure | `project-status.ps1` | Database validation paths |
| Configuration | `config.yml` | Add database section |
| Documentation | `pipeline.md`, manifests | Architecture updates |
| Analysis Scripts | All in `./analysis/` | Config-based imports (future) |

---

*Dependency mapping complete - ready for Phase 2 implementation.*
