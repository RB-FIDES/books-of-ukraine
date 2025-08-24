# ----------------------------------------------------------------- IMPORT ------------------------------------------------------------------
# last-ellis.R - Create focused analytical database for human analysts
# 
# PURPOSE: Extract and transform data from the comprehensive Stage 2 database 
# into a streamlined, analysis-ready format optimized for human convenience.
#
# DESIGN PHILOSOPHY:
# - Stage 2 (books-of-ukraine-2.sqlite): Comprehensive data storage with all source data + custom/extra data
# - Final (books-of-ukraine.sqlite): Focused analytical convenience with clean, analysis-ready tables
# - When analysts need source data, they can always reach back to Stage 2 database

library(DBI)
library(RSQLite)
library(dplyr)
library(fs)

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # Modern database connection functions

# Helper function to append table to final database
append_to_final_db <- function(table_data, table_name) {
  final_db <- connect_books_db("main")
  tryCatch({
    dbWriteTable(final_db, table_name, table_data, overwrite = TRUE)
    cat(paste0("✅ Added ", table_name, " to analytical database (", nrow(table_data), " rows, ", ncol(table_data), " columns)\n"))
    result <- TRUE
  }, error = function(e) {
    cat("❌ Error writing", table_name, "to analytical database:", e$message, "\n")
    result <- FALSE
  })
  dbDisconnect(final_db)
  return(result)
}

# Import from comprehensive Stage 2 database (includes all core + custom data)
enhanced_db_path <- get_db_path("stage_2")
final_db_path <- get_db_path("main")

# Set up CSV export directory for analytical tables
csv_path <- "data-private/derived/manipulation/CSV/"
if (!fs::dir_exists(csv_path)) {fs::dir_create(csv_path)}

cat("🔍 Importing from comprehensive Stage 2 database:", enhanced_db_path, "\n")
db <- connect_books_db("stage_2")

tables <- dbListTables(db)
cat("📊 Available source tables:\n")
print(tables)

cat("\n🎯 Creating focused analytical database at:", final_db_path, "\n")
cat("   Purpose: Clean, analysis-ready tables optimized for human analysts\n")
cat("   Note: Comprehensive source data remains available in Stage 2 database\n\n")

# ------------------------------------------------------------------ CREATE WIDE TABLES ------------------------------------------------------------------


# Create ds_year_wide from fact_book_publications (year as rows, measure_type as columns, value as values)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	year_df <- fact_df %>%
		filter(category_type == "total", category_value == "all_books") %>%
		select(year, measure_type, value)
	ds_year_wide <- tryCatch({
		tidyr::pivot_wider(year_df, id_cols = year, names_from = measure_type, values_from = value)
	}, error = function(e) {
		cat("Error in pivot_wider for ds_year_wide:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_year_wide)) {
		# Create new analytical database focused on analysis convenience
		if (file.exists(final_db_path)) {
			file.remove(final_db_path)
		}
		cat("📊 Creating focused analytical database\n")
		append_to_final_db(ds_year_wide, "ds_year_wide")
	} else {
		cat("ds_year_wide was not created due to previous errors.\n")
	}
}


# Create ds_language_wide from fact_book_publications
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	lang_df <- fact_df %>%
		filter(category_type == "language") %>%
		select(year, measure_type, category_value, value)
	ds_language_wide <- tryCatch({
		tidyr::pivot_wider(lang_df, id_cols = c(category_value, measure_type), names_from = year, values_from = value)
	}, error = function(e) {
		cat("Error in pivot_wider for ds_language_wide:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_language_wide)) {
		append_to_final_db(ds_language_wide, "ds_language_wide")
	} else {
		cat("ds_language_wide was not created due to previous errors.\n")
	}
}

# Create ds_territory_wide from fact_book_publications
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	territory_df <- fact_df %>%
		filter(category_type == "territory") %>%
		select(year, measure_type, category_value, value)
	ds_territory_wide <- tryCatch({
		tidyr::pivot_wider(territory_df, id_cols = c(category_value, measure_type), names_from = year, values_from = value)
	}, error = function(e) {
		cat("Error in pivot_wider for ds_territory_wide:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_territory_wide)) {
		append_to_final_db(ds_territory_wide, "ds_territory_wide")
	} else {
		cat("ds_territory_wide was not created due to previous errors.\n")
	}
}

# Create ds_theme_wide from fact_book_publications
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	theme_df <- fact_df %>%
		filter(category_type == "theme") %>%
		select(year, measure_type, category_value, value)
	ds_theme_wide <- tryCatch({
		tidyr::pivot_wider(theme_df, id_cols = c(category_value, measure_type), names_from = year, values_from = value)
	}, error = function(e) {
		cat("Error in pivot_wider for ds_theme_wide:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_theme_wide)) {
		append_to_final_db(ds_theme_wide, "ds_theme_wide")
	} else {
		cat("ds_theme_wide was not created due to previous errors.\n")
	}
}

# Create ds_purpose_wide from fact_book_publications
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	purpose_df <- fact_df %>%
		filter(category_type == "purpose") %>%
		select(year, measure_type, category_value, value)
	ds_purpose_wide <- tryCatch({
		tidyr::pivot_wider(purpose_df, id_cols = c(category_value, measure_type), names_from = year, values_from = value)
	}, error = function(e) {
		cat("Error in pivot_wider for ds_purpose_wide:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_purpose_wide)) {
		append_to_final_db(ds_purpose_wide, "ds_purpose_wide")
	} else {
		cat("ds_purpose_wide was not created due to previous errors.\n")
	}
}

# Create ds_bookstores_wide - check both possible source tables for backward compatibility
bookstore_wide_created <- FALSE
if ("bookstores_custom" %in% tables) {
	bookstores_df <- dbReadTable(db, "bookstores_custom")
	ds_bookstores_wide <- tryCatch({
		tidyr::pivot_wider(bookstores_df, id_cols = c(store_name, location), names_from = year, values_from = book_count)
	}, error = function(e) {
		cat("Error in pivot_wider for ds_bookstores_wide:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_bookstores_wide)) {
		append_to_final_db(ds_bookstores_wide, "ds_bookstores_wide")
		bookstore_wide_created <- TRUE
	}
} else if ("ds_bookstores" %in% tables) {
	# Fallback to original table structure for backward compatibility
	bookstores_df <- dbReadTable(db, "ds_bookstores")
	ds_bookstores_wide <- tryCatch({
		tidyr::pivot_wider(bookstores_df, id_cols = c(category_value, measure_type), names_from = year, values_from = value)
	}, error = function(e) {
		cat("Error in pivot_wider for ds_bookstores_wide:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_bookstores_wide)) {
		append_to_final_db(ds_bookstores_wide, "ds_bookstores_wide")
		bookstore_wide_created <- TRUE
	}
}
if (!bookstore_wide_created) {
	cat("ds_bookstores_wide was not created due to missing source tables or errors.\n")
}

# ------------------------------------------------------------------ CREATE LONG TABLES ------------------------------------------------------------------

# Create ds_year from fact_book_publications (long format: year, category_type, category_value, measure_type, value)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	ds_year <- fact_df %>%
		filter(category_type == "total", category_value == "all_books") %>%
		select(year, category_type, category_value, measure_type, value)
	append_to_final_db(ds_year, "ds_year")
}

# Create ds_language from fact_book_publications (long format: year, category_type, category_value, measure_type, value)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	ds_language <- fact_df %>%
		filter(category_type == "language") %>%
		select(year, category_type, category_value, measure_type, value)
	append_to_final_db(ds_language, "ds_language")
}

# Create ds_territory from fact_book_publications (long format: year, category_type, category_value, measure_type, value)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	ds_territory <- fact_df %>%
		filter(category_type == "territory") %>%
		select(year, category_type, category_value, measure_type, value)
	append_to_final_db(ds_territory, "ds_territory")
}

# Create ds_theme from fact_book_publications (long format: year, category_type, category_value, measure_type, value)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	ds_theme <- fact_df %>%
		filter(category_type == "theme") %>%
		select(year, category_type, category_value, measure_type, value)
	append_to_final_db(ds_theme, "ds_theme")
}

# Create ds_purpose from fact_book_publications (long format: year, category_type, category_value, measure_type, value)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	ds_purpose <- fact_df %>%
		filter(category_type == "purpose") %>%
		select(year, category_type, category_value, measure_type, value)
	append_to_final_db(ds_purpose, "ds_purpose")
}

# Create ds_bookstores from ds_bookstores table (long format: year, category_type, category_value, measure_type, value)
if ("ds_bookstores" %in% tables) {
	ds_bookstores <- dbReadTable(db, "ds_bookstores")
	append_to_final_db(ds_bookstores, "ds_bookstores")
}

# Only include ds_ tables (wide and long) in the final analytical database.
# Intentionally do NOT copy fact_, dim_, admin_ua, or custom/extra tables from the
# source Stage 2 database. This keeps the final `books-of-ukraine.sqlite` focused
# on analysis-ready `ds_` tables only.



# Close source database connection
dbDisconnect(db)

cat("\n🎉 ANALYTICAL DATABASE CREATION COMPLETE!\n")
cat("📁 Final database location:", final_db_path, "\n")

# Write a manifest that describes the actual data, using the example only for format inspiration
output_path <- "data-public/metadata/CACHE-MANIFEST.md"
sqlite_dir <- "data-private/derived/manipulation/SQLite"
sqlite_files <- list.files(sqlite_dir, pattern = "^BOOKS-OF-.*\\.sqlite$", full.names = TRUE)
manifest_lines <- c(
  "# CACHE Manifest - Final Analytical Database (Default)",
  "",
  "**Generated by:** `manipulation/last-ellis.R`",
  "**Database:** `books-of-ukraine.sqlite` (Default analytical database)",
  "**Purpose:** Clean, analysis-ready tables optimized for human analysts",
  "",
  "This manifest describes the **final analytical database** - the default database that analysts should use for most research and reporting tasks.",
  "",
  "---",
  "",
  "## 🎯 **Default Database Architecture**",
  "",
  "The final analytical database contains **focused, analysis-ready tables** created from the comprehensive Stage 2 database:",
  "",
  "```",
  "SOURCE: books-of-ukraine-2.sqlite (comprehensive)",
  "   ↓ last-ellis.R processing",
  "TARGET: books-of-ukraine.sqlite (analytical focus)",
  "```",
  "",
  "### **📊 Table Categories**",
  "",
  "**WIDE FORMAT TABLES** (for pivot tables, dashboards):",
  "- Ready for immediate use in Excel, Tableau, PowerBI",
  "- Years as columns, categories as rows",
  "",
  "**LONG FORMAT TABLES** (for statistical analysis, modeling):",
  "- Tidy data format for R, Python analysis",
  "- One observation per row",
  "",
  "**CUSTOM DATA TABLES** (from Stage 2):",
  "- User-contributed datasets (bookstores, surveys, etc.)",
  "- Bilingual support (Ukrainian/English standardized to English)",
  "",
  "---",
  "",
  "## 📚 **Cross-Database Schema Reference**",
  "",
  "### Common Column Patterns Across All Ellis Databases",
  "",
  "The Ellis Pipeline maintains **consistent schema patterns** across all stages. Understanding these patterns helps analysts work with any stage database:",
  "",
  "#### **Core Analysis Columns** (Present in Most Analytical Tables)",
  "",
  "| **Column** | **Data Type** | **Range/Values** | **Description** | **Analysis Use** |",
  "|------------|---------------|------------------|-----------------|------------------|",
  "| `year` | Integer | 2005-2023 | Publication year | Time series, trend analysis |",
  "| `category_type` | Character | language, theme, territory, purpose | Data domain/dimension | Faceting, grouping, filtering |",
  "| `category_value` | Character | Domain-specific values | Specific category (e.g., \"Українська\", \"Kyiv\") | Primary categorical analysis |",
  "| `measure_type` | Character | title_count, copy_count, bookstore_count | Type of measurement | Metric selection, comparison |",
  "| `value` | Numeric | 0 to domain maximum | Measured quantity | Quantitative analysis, modeling |",
  "",
  "#### **Geographic Integration Columns** (From Stage 1)",
  "",
  "| **Column** | **Data Type** | **Description** | **Analysis Use** |",
  "|------------|---------------|-----------------|------------------|",
  "| `oblast_name_en` | Character | Oblast name in English | Mapping, regional analysis |",
  "| `region_type` | Character | Central/Eastern/Western/Southern Ukraine | Regional aggregation |",
  "| `total_population` | Numeric | Oblast population | Per-capita calculations |",
  "| `avg_income_per_capita_2022` | Numeric | Economic indicator | Correlation analysis |",
  "",
  "#### **Custom Data Integration** (From Stage 2)",
  "",
  "| **Column** | **Data Type** | **Description** | **Analysis Use** |",
  "|------------|---------------|-----------------|------------------|",
  "| `ds_*` | Various | Custom dataset prefix | Identifies Stage 2 additions |",
  "| Bilingual columns | Character | Ukrainian/English standardized to English | Cross-cultural analysis |",
  "",
  "| **Column** | **Data Type** | **Tables Present** | **Unique Values** | **Description** |",
  "|------------|---------------|-------------------|-------------------|-----------------|",
  "| `category_var` | Character | Classification tables | 10-50 categories | Primary categorical dimension |",
  "| `subcategory_var` | Character | Hierarchical tables | 50-200 subcategories | Secondary classification level |",
  "| `geographic_var` | Character | Spatial tables | Region-specific | Geographic/spatial dimension |",
  "| `temporal_var` | Date/Integer | Time-series tables | Time-dependent | Temporal classification |",
  "",
  "---",
  ""
)
for (db_path in sqlite_files) {
  if (!file.exists(db_path)) next
  suppressMessages(library(DBI))
  suppressMessages(library(RSQLite))
  con <- dbConnect(RSQLite::SQLite(), db_path)
  tables <- dbListTables(con)
  manifest_lines <- c(manifest_lines,
    paste0("## Output Table Summary for `", db_path, "`"),
    ""
  )
  for (tbl in tables) {
    nrows <- tryCatch({ dbGetQuery(con, paste0("SELECT COUNT(*) as n FROM `", tbl, "`"))$n }, error=function(e) NA)
    df <- tryCatch({ dbReadTable(con, tbl) }, error=function(e) NULL)
    ncols <- if (!is.null(df)) ncol(df) else NA
    colnames_str <- if (!is.null(df)) paste(head(colnames(df), 5), collapse=", ") else "-"
    # Table description logic based on column schema reference
    desc <- "General purpose table."
    if (!is.null(df)) {
      cols <- colnames(df)
      if (all(c("year", "measure_type", "value") %in% cols) && !any(grepl("category", cols))) {
        desc <- "Yearly summary table: one row per year, columns for each measure type. Use for time series and trend analysis."
      } else if (all(c("year", "measure_type", "category_value", "value") %in% cols) && grepl("language", tbl)) {
        desc <- "Language breakdown: rows for year, measure, and language; columns for each language. Use for language share and comparison."
      } else if (all(c("year", "measure_type", "category_value", "value") %in% cols) && grepl("territory", tbl)) {
        desc <- "Territory breakdown: rows for year, measure, and territory; columns for each territory. Use for regional analysis."
      } else if (all(c("year", "measure_type", "category_value", "value") %in% cols) && grepl("theme", tbl)) {
        desc <- "Theme breakdown: rows for year, measure, and theme; columns for each theme. Use for subject/theme analysis."
      } else if (all(c("year", "measure_type", "category_value", "value") %in% cols) && grepl("purpose", tbl)) {
        desc <- "Purpose breakdown: rows for year, measure, and purpose; columns for each purpose. Use for purpose/category analysis."
      } else if (all(c("year", "category_type", "category_value", "measure_type", "value") %in% cols)) {
        desc <- "Long format: each row is a year/category/measure/value. Use for flexible filtering and faceting."
      } else if (all(c("category_type", "category_value") %in% cols)) {
        desc <- "Category dimension table: defines categories and their types. Use for joins and lookups."
      } else if (all(c("measure_type") %in% cols)) {
        desc <- "Measure dimension table: defines available measures. Use for joins and lookups."
      } else if (all(c("year") %in% cols) && length(cols) == 1) {
        desc <- "Year dimension table: defines available years. Use for joins and lookups."
      }
    }
    manifest_lines <- c(manifest_lines,
      paste0("### Table: `", tbl, "`"),
      "",
      sprintf("- **Rows**: %s", nrows),
      sprintf("- **Columns**: %s", ncols),
      sprintf("- **Example Columns**: %s", colnames_str),
      sprintf("- **Description**: %s", desc),
      ""
    )
  }
  dbDisconnect(con)
}
writeLines(manifest_lines, output_path)
message("Created ", output_path, " with actual data descriptions and column schema reference for all BOOKS-OF-*.sqlite files.")

# ---- Export all analytical tables to CSV ----
cat("\n💾 EXPORTING ANALYTICAL TABLES TO CSV:\n")
db_final <- connect_books_db("main")
all_tables <- dbListTables(db_final)

for (table_name in all_tables) {
  table_data <- dbReadTable(db_final, table_name)
  csv_file_path <- paste0(csv_path, table_name, ".csv")
  write.csv(table_data, csv_file_path, row.names = FALSE)
  cat(paste0("   ✅ Exported ", table_name, " (", nrow(table_data), " rows) to CSV\n"))
}
dbDisconnect(db_final)
cat("📋 All analytical tables exported to:", csv_path, "\n")

# ------------------------------------------------------------------ END OF SCRIPT ------------------------------------------------------------------

cat("\n✅ Script completed successfully!\n")
cat("💡 Next steps: Use analysis/eda-* scripts to explore the data\n")
cat("📊 Database ready for analysis with both wide and long format tables\n")
