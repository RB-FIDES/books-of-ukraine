# ----------------------------------------------------------------- IMPORT ------------------------------------------------------------------
# last-ellis.R - Create focused analytical database for human analysts
# 
# PURPOSE: Extract and transform data from the comprehensive Stage 1 database 
# into a streamlined, analysis-ready format optimized for human convenience.
#
# DESIGN PHILOSOPHY:
# - Stage 1 (books-of-ukraine-1.sqlite): Comprehensive data storage with all source data
# - Final (books-of-ukraine.sqlite): Focused analytical convenience with clean, analysis-ready tables
# - When analysts need source data, they can always reach back to Stage 1 database

library(DBI)
library(RSQLite)
library(dplyr)
library(fs)

# Import from comprehensive Stage 1 database
enhanced_db_path <- "data-private/derived/manipulation/SQLite/books-of-ukraine-1.sqlite"
final_db_path <- config::get("database")$books_of_ukraine$main

# Set up CSV export directory for analytical tables
csv_path <- "data-private/derived/manipulation/CSV/"
if (!fs::dir_exists(csv_path)) {fs::dir_create(csv_path)}

cat("🔍 Importing from comprehensive database:", enhanced_db_path, "\n")
db <- dbConnect(RSQLite::SQLite(), enhanced_db_path)

tables <- dbListTables(db)
cat("📊 Available source tables:\n")
print(tables)

cat("\n🎯 Creating focused analytical database at:", final_db_path, "\n")
cat("   Purpose: Clean, analysis-ready tables optimized for human analysts\n")
cat("   Note: Comprehensive source data remains available in Stage 1 database\n\n")

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
		BOOKS_OF_UKRAINE <- dbConnect(RSQLite::SQLite(), final_db_path)
		tryCatch({
			dbWriteTable(BOOKS_OF_UKRAINE, "ds_year_wide", ds_year_wide, overwrite = TRUE)
			cat(paste0("Created ds_year_wide in books-of-ukraine.sqlite (", nrow(ds_year_wide), " rows, ", ncol(ds_year_wide), " columns)\n"))
		}, error = function(e) {
			cat("Error writing ds_year_wide to books-of-ukraine.sqlite:", e$message, "\n")
		})
		dbDisconnect(BOOKS_OF_UKRAINE)
	} else {
		cat("ds_year_wide was not created due to previous errors.\n")
	}
} else {
	cat("Table fact_book_publications not found in source database.\n")
}


# Create ds_language_wide from fact_book_publications (wide format: year + measure_type as rows, category_value as columns, value as values)
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
		BOOKS_OF_UKRAINE_path <- final_db_path
		table_name <- "ds_language_wide"
		cat("\nWriting ", table_name, " to: ", BOOKS_OF_UKRAINE_path, "\n", sep = "")
		BOOKS_OF_UKRAINE <- dbConnect(RSQLite::SQLite(), BOOKS_OF_UKRAINE_path)
		tryCatch({
			dbWriteTable(BOOKS_OF_UKRAINE, table_name, ds_language_wide, overwrite = TRUE)
			cat(paste0("Created ", table_name, " in books-of-ukraine.sqlite (", nrow(ds_language_wide), " rows, ", ncol(ds_language_wide), " columns)\n"))
		}, error = function(e) {
			cat("Error writing ", table_name, " to books-of-ukraine.sqlite: ", e$message, "\n")
		})
		dbDisconnect(BOOKS_OF_UKRAINE)
	}
}



# Create ds_territory_wide from fact_book_publications (wide format: year + measure_type as rows, category_value as columns, value as values)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	terr_df <- fact_df %>%
		filter(category_type == "territory") %>%
		select(year, measure_type, category_value, value)
	ds_territory_wide <- tryCatch({
		tidyr::pivot_wider(terr_df, id_cols = c(category_value, measure_type), names_from = year, values_from = value)
	}, error = function(e) {
		cat("Error in pivot_wider for ds_territory_wide:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_territory_wide)) {
		BOOKS_OF_UKRAINE_path <- final_db_path
		table_name <- "ds_territory_wide"
		cat("\nWriting ", table_name, " to: ", BOOKS_OF_UKRAINE_path, "\n", sep = "")
		BOOKS_OF_UKRAINE <- dbConnect(RSQLite::SQLite(), BOOKS_OF_UKRAINE_path)
		tryCatch({
			dbWriteTable(BOOKS_OF_UKRAINE, table_name, ds_territory_wide, overwrite = TRUE)
			cat(paste0("Created ", table_name, " in books-of-ukraine.sqlite (", nrow(ds_territory_wide), " rows, ", ncol(ds_territory_wide), " columns)\n"))
		}, error = function(e) {
			cat("Error writing ", table_name, " to books-of-ukraine.sqlite: ", e$message, "\n")
		})
		dbDisconnect(BOOKS_OF_UKRAINE)
	}
}

# Create ds_theme_wide from fact_book_publications (wide format: year + measure_type as rows, category_value as columns, value as values)
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
		BOOKS_OF_UKRAINE_path <- final_db_path
		table_name <- "ds_theme_wide"
		cat("\nWriting ", table_name, " to: ", BOOKS_OF_UKRAINE_path, "\n", sep = "")
		BOOKS_OF_UKRAINE <- dbConnect(RSQLite::SQLite(), BOOKS_OF_UKRAINE_path)
		tryCatch({
			dbWriteTable(BOOKS_OF_UKRAINE, table_name, ds_theme_wide, overwrite = TRUE)
			cat(paste0("Created ", table_name, " in books-of-ukraine.sqlite (", nrow(ds_theme_wide), " rows, ", ncol(ds_theme_wide), " columns)\n"))
		}, error = function(e) {
			cat("Error writing ", table_name, " to books-of-ukraine.sqlite: ", e$message, "\n")
		})
		dbDisconnect(BOOKS_OF_UKRAINE)
	}
}

# Create ds_purpose_wide from fact_book_publications (wide format: year + measure_type as rows, category_value as columns, value as values)
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
		BOOKS_OF_UKRAINE_path <- final_db_path
		table_name <- "ds_purpose_wide"
		cat("\nWriting ", table_name, " to: ", BOOKS_OF_UKRAINE_path, "\n", sep = "")
		BOOKS_OF_UKRAINE <- dbConnect(RSQLite::SQLite(), BOOKS_OF_UKRAINE_path)
		tryCatch({
			dbWriteTable(BOOKS_OF_UKRAINE, table_name, ds_purpose_wide, overwrite = TRUE)
			cat(paste0("Created ", table_name, " in books-of-ukraine.sqlite (", nrow(ds_purpose_wide), " rows, ", ncol(ds_purpose_wide), " columns)\n"))
		}, error = function(e) {
			cat("Error writing ", table_name, " to books-of-ukraine.sqlite: ", e$message, "\n")
		})
		dbDisconnect(BOOKS_OF_UKRAINE)
	}
}

# Create ds_bookstores_wide from fact_book_publications (wide format: year + measure_type as rows, category_value as columns, value as values)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	bookstores_df <- fact_df %>%
		filter(category_type == "bookstores") %>%
		select(year, measure_type, category_value, value)
	ds_bookstores_wide <- tryCatch({
		tidyr::pivot_wider(bookstores_df, id_cols = c(category_value, measure_type), names_from = year, values_from = value)
	}, error = function(e) {
		cat("Error in pivot_wider for ds_bookstores_wide:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_bookstores_wide)) {
		BOOKS_OF_UKRAINE_path <- final_db_path
		table_name <- "ds_bookstores_wide"
		cat("\nWriting ", table_name, " to: ", BOOKS_OF_UKRAINE_path, "\n", sep = "")
		BOOKS_OF_UKRAINE <- dbConnect(RSQLite::SQLite(), BOOKS_OF_UKRAINE_path)
		tryCatch({
			dbWriteTable(BOOKS_OF_UKRAINE, table_name, ds_bookstores_wide, overwrite = TRUE)
			cat(paste0("Created ", table_name, " in books-of-ukraine.sqlite (", nrow(ds_bookstores_wide), " rows, ", ncol(ds_bookstores_wide), " columns)\n"))
		}, error = function(e) {
			cat("Error writing ", table_name, " to books-of-ukraine.sqlite: ", e$message, "\n")
		})
		dbDisconnect(BOOKS_OF_UKRAINE)
	}
}

# ------------------------------------------------------------------ CREATE LONG TABLES ------------------------------------------------------------------

# Create ds_year from fact_book_publications (long format: year, category_type, category_value, measure_type, value)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	ds_year <- fact_df %>%
		filter(category_type == "total",
					 category_value == "all_books") %>%
		select(year, category_type, category_value, measure_type, value)
	BOOKS_OF_UKRAINE_path <- final_db_path
	cat("\nWriting ds_year to:", BOOKS_OF_UKRAINE_path, "\n")
	BOOKS_OF_UKRAINE <- dbConnect(RSQLite::SQLite(), BOOKS_OF_UKRAINE_path)
	tryCatch({
		dbWriteTable(BOOKS_OF_UKRAINE, "ds_year", ds_year, overwrite = TRUE)
		cat(paste0("Created ds_year in books-of-ukraine.sqlite (", nrow(ds_year), " rows, ", ncol(ds_year), " columns)\n"))
	}, error = function(e) {
		cat("Error writing ds_year to books-of-ukraine.sqlite:", e$message, "\n")
	})
	dbDisconnect(BOOKS_OF_UKRAINE)
}


# Create ds_language from fact_book_publications (long format: year, category_type, category_value, measure_type, value)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	ds_language <- fact_df %>%
		filter(category_type == "language") %>%
		select(year, category_type, category_value, measure_type, value)
	BOOKS_OF_UKRAINE_path <- final_db_path
	cat("\nWriting ds_language to:", BOOKS_OF_UKRAINE_path, "\n")
	BOOKS_OF_UKRAINE <- dbConnect(RSQLite::SQLite(), BOOKS_OF_UKRAINE_path)
	tryCatch({
		dbWriteTable(BOOKS_OF_UKRAINE, "ds_language", ds_language, overwrite = TRUE)
		cat(paste0("Created ds_language in books-of-ukraine.sqlite (", nrow(ds_language), " rows, ", ncol(ds_language), " columns)\n"))
	}, error = function(e) {
		cat("Error writing ds_language to books-of-ukraine.sqlite:", e$message, "\n")
	})
	dbDisconnect(BOOKS_OF_UKRAINE)
}



# Create ds_territory from fact_book_publications (long format: year, category_type, category_value, measure_type, value)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	ds_territory <- fact_df %>%
		filter(category_type == "territory") %>%
		select(year, category_type, category_value, measure_type, value)
	BOOKS_OF_UKRAINE_path <- final_db_path
	cat("\nWriting ds_territory to:", BOOKS_OF_UKRAINE_path, "\n")
	BOOKS_OF_UKRAINE <- dbConnect(RSQLite::SQLite(), BOOKS_OF_UKRAINE_path)
	tryCatch({
		dbWriteTable(BOOKS_OF_UKRAINE, "ds_territory", ds_territory, overwrite = TRUE)
		cat(paste0("Created ds_territory in books-of-ukraine.sqlite (", nrow(ds_territory), " rows, ", ncol(ds_territory), " columns)\n"))
	}, error = function(e) {
		cat("Error writing ds_territory to books-of-ukraine.sqlite:", e$message, "\n")
	})
	dbDisconnect(BOOKS_OF_UKRAINE)
}


# Create ds_theme from fact_book_publications (long format: year, category_type, category_value, measure_type, value)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	ds_theme <- fact_df %>%
		filter(category_type == "theme") %>%
		select(year, category_type, category_value, measure_type, value)
	BOOKS_OF_UKRAINE_path <- final_db_path
	cat("\nWriting ds_theme to:", BOOKS_OF_UKRAINE_path, "\n")
	BOOKS_OF_UKRAINE <- dbConnect(RSQLite::SQLite(), BOOKS_OF_UKRAINE_path)
	tryCatch({
		dbWriteTable(BOOKS_OF_UKRAINE, "ds_theme", ds_theme, overwrite = TRUE)
		cat(paste0("Created ds_theme in books-of-ukraine.sqlite (", nrow(ds_theme), " rows, ", ncol(ds_theme), " columns)\n"))
	}, error = function(e) {
		cat("Error writing ds_theme to books-of-ukraine.sqlite:", e$message, "\n")
	})
	dbDisconnect(BOOKS_OF_UKRAINE)
}

# Create ds_purpose from fact_book_publications (long format: year, category_type, category_value, measure_type, value)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	ds_purpose <- fact_df %>%
		filter(category_type == "purpose") %>%
		select(year, category_type, category_value, measure_type, value)
	BOOKS_OF_UKRAINE_path <- final_db_path
	cat("\nWriting ds_purpose to:", BOOKS_OF_UKRAINE_path, "\n")
	BOOKS_OF_UKRAINE <- dbConnect(RSQLite::SQLite(), BOOKS_OF_UKRAINE_path)
	tryCatch({
		dbWriteTable(BOOKS_OF_UKRAINE, "ds_purpose", ds_purpose, overwrite = TRUE)
		cat(paste0("Created ds_purpose in books-of-ukraine.sqlite (", nrow(ds_purpose), " rows, ", ncol(ds_purpose), " columns)\n"))
	}, error = function(e) {
		cat("Error writing ds_purpose to books-of-ukraine.sqlite:", e$message, "\n")
	})
	dbDisconnect(BOOKS_OF_UKRAINE)
}

# Create ds_bookstores from fact_book_publications (long format: year, category_type, category_value, measure_type, value)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	ds_bookstores <- fact_df %>%
		filter(category_type == "bookstores") %>%
		select(year, category_type, category_value, measure_type, value)
	BOOKS_OF_UKRAINE_path <- final_db_path
	cat("\nWriting ds_bookstores to:", BOOKS_OF_UKRAINE_path, "\n")
	BOOKS_OF_UKRAINE <- dbConnect(RSQLite::SQLite(), BOOKS_OF_UKRAINE_path)
	tryCatch({
		dbWriteTable(BOOKS_OF_UKRAINE, "ds_bookstores", ds_bookstores, overwrite = TRUE)
		cat(paste0("Created ds_bookstores in books-of-ukraine.sqlite (", nrow(ds_bookstores), " rows, ", ncol(ds_bookstores), " columns)\n"))
	}, error = function(e) {
		cat("Error writing ds_bookstores to books-of-ukraine.sqlite:", e$message, "\n")
	})
	dbDisconnect(BOOKS_OF_UKRAINE)
}


# ------------------------------------------------------------------------ DISCONNECT ------------------------------------------------------------------------
dbDisconnect(db)

# Write a manifest that describes the actual data, using the example only for format inspiration
output_path <- "ai/CACHE-MANIFEST-USE.md"
sqlite_dir <- "data-private/derived/manipulation/SQLite"
sqlite_files <- list.files(sqlite_dir, pattern = "^BOOKS-OF-.*\\.sqlite$", full.names = TRUE)
manifest_lines <- c(
  "# CACHE Manifest (Auto-Generated)",
  "",
  "This manifest describes the actual contents of all BOOKS-OF-*.sqlite files generated by the ETL process.",
  "",
  "---",
  "",
  "## Detailed Column Specifications",
  "",
  "### Column Schema Reference",
  "",
  "All CACHE tables follow standardized schema patterns. Here are detailed specifications for common column types:",
  "",
  "#### Core Columns (Present in Most Tables)",
  "",
  "| **Column** | **Data Type** | **Range/Values** | **Description** | **Analysis Use** |",
  "|------------|---------------|------------------|-----------------|------------------|",
  "| `entity_id` | Character/Integer | Unique identifier | Primary entity identification key | Linking, aggregation, filtering |",
  "| `sequence_var` | Integer/Date | Sequential values | Temporal or logical ordering | Time series, trajectory analysis |",
  "| `measure_type` | Character | Categorical values | Type of measurement or observation | Faceting, comparison, aggregation |",
  "| `value` | Numeric | Domain-specific range | Measured quantity or count | Quantitative analysis, modeling |",
  "",
  "#### Category-Specific Columns",
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
db_final <- dbConnect(RSQLite::SQLite(), final_db_path)
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
