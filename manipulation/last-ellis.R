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

# Create ds_bookstores_wide (if custom bookstore data exists)
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
	} else {
		cat("ds_bookstores_wide was not created due to previous errors.\n")
	}
}

# ------------------------------------------------------------------ CREATE LONG TABLES ------------------------------------------------------------------

# Copy key long-format tables for analysis convenience
long_tables_to_copy <- c("fact_book_publications", "dim_years", "dim_categories", "dim_measures")

for (table_name in long_tables_to_copy) {
	if (table_name %in% tables) {
		table_data <- dbReadTable(db, table_name)
		append_to_final_db(table_data, table_name)
	}
}

# Copy Ukrainian administrative data if available
if ("admin_ua" %in% tables) {
	admin_data <- dbReadTable(db, "admin_ua")
	append_to_final_db(admin_data, "admin_ua")
}

# Copy any custom data tables
custom_tables <- tables[grepl("custom|extra", tables, ignore.case = TRUE)]
for (table_name in custom_tables) {
	table_data <- dbReadTable(db, table_name)
	append_to_final_db(table_data, table_name)
}

# Close source database connection
dbDisconnect(db)

cat("\n🎉 ANALYTICAL DATABASE CREATION COMPLETE!\n")
cat("📁 Final database location:", final_db_path, "\n")

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
