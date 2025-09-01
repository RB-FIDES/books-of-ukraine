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
library(tidyr)     # for pivot_longer operations in oblast tables
library(stringr)   # for str_detect operations
library(fs)

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # Modern database connection functions

# Helper function to append table to final database
append_to_final_db <- function(table_data, table_name) {
	db_path <- get_db_path("main")
	con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
	DBI::dbWriteTable(con, table_name, table_data, overwrite = TRUE)
	DBI::dbDisconnect(con)
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

# ------------------------------------------------------------------ CREATE PUBLISHING DATA TABLES ------------------------------------------------------------------

# Section 1: Publishing data from Book Chamber (using *_long format with measures as columns)

# Create ds_year from fact_book_publications (year, title_count, copy_count)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	year_df <- fact_df %>%
		filter(category_type == "total", category_value == "all_books") %>%
		select(year, measure, value)
	ds_year <- tryCatch({
		tidyr::pivot_wider(year_df, id_cols = year, names_from = measure, values_from = value, values_fill = 0)
	}, error = function(e) {
		cat("Error creating ds_year:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_year)) {
		# Create new analytical database focused on analysis convenience
		if (file.exists(final_db_path)) {
			file.remove(final_db_path)
		}
		cat("📊 Creating focused analytical database\n")
		append_to_final_db(ds_year, "ds_year")
		cat("   ✓ Created ds_year:", nrow(ds_year), "years\n")
	} else {
		cat("ds_year was not created due to previous errors.\n")
	}
}

# Create ds_language from fact_book_publications (year, language, title_count, copy_count)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	lang_df <- fact_df %>%
		filter(category_type == "language") %>%
		rename(language = category_value) %>%
		select(year, language, measure, value)
	ds_language <- tryCatch({
		tidyr::pivot_wider(lang_df, id_cols = c(year, language), names_from = measure, values_from = value, values_fill = 0)
	}, error = function(e) {
		cat("Error creating ds_language:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_language)) {
		append_to_final_db(ds_language, "ds_language")
		cat("   ✓ Created ds_language:", nrow(ds_language), "language-year combinations\n")
	} else {
		cat("ds_language was not created due to previous errors.\n")
	}
}

# Create ds_territory from fact_book_publications (year, territory, title_count, copy_count)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	territory_df <- fact_df %>%
		filter(category_type == "territory") %>%
		rename(territory = category_value) %>%
		select(year, territory, measure, value)
	ds_territory <- tryCatch({
		tidyr::pivot_wider(territory_df, id_cols = c(year, territory), names_from = measure, values_from = value, values_fill = 0)
	}, error = function(e) {
		cat("Error creating ds_territory:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_territory)) {
		append_to_final_db(ds_territory, "ds_territory")
		cat("   ✓ Created ds_territory:", nrow(ds_territory), "territory-year combinations\n")
	} else {
		cat("ds_territory was not created due to previous errors.\n")
	}
}

# Create ds_theme from fact_book_publications (year, theme, title_count, copy_count)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	theme_df <- fact_df %>%
		filter(category_type == "theme") %>%
		rename(theme = category_value) %>%
		select(year, theme, measure, value)
	ds_theme <- tryCatch({
		tidyr::pivot_wider(theme_df, id_cols = c(year, theme), names_from = measure, values_from = value, values_fill = 0)
	}, error = function(e) {
		cat("Error creating ds_theme:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_theme)) {
		append_to_final_db(ds_theme, "ds_theme")
		cat("   ✓ Created ds_theme:", nrow(ds_theme), "theme-year combinations\n")
	} else {
		cat("ds_theme was not created due to previous errors.\n")
	}
}

# Create ds_purpose from fact_book_publications (year, purpose, title_count, copy_count)
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
	purpose_df <- fact_df %>%
		filter(category_type == "purpose") %>%
		rename(purpose = category_value) %>%
		select(year, purpose, measure, value)
	ds_purpose <- tryCatch({
		tidyr::pivot_wider(purpose_df, id_cols = c(year, purpose), names_from = measure, values_from = value, values_fill = 0)
	}, error = function(e) {
		cat("Error creating ds_purpose:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_purpose)) {
		append_to_final_db(ds_purpose, "ds_purpose")
		cat("   ✓ Created ds_purpose:", nrow(ds_purpose), "purpose-year combinations\n")
	} else {
		cat("ds_purpose was not created due to previous errors.\n")
	}
}

# ------------------------------------------------------------------ CREATE ADMINISTRATIVE DATA TABLES ------------------------------------------------------------------

# Section 2: Administrative data from KSE (oblast data)

# Create ds_oblast from ua_oblasts_aggregated (oblast administrative data)
if ("ua_oblasts_aggregated" %in% tables) {
	cat("🏛️  Creating oblast administrative table...\n")
	
	ua_oblasts_df <- dbReadTable(db, "ua_oblasts_aggregated")
	
	# Use the wide format structure as the main ds_oblast table
	ds_oblast <- ua_oblasts_df %>%
		select(
			oblast_name_en, oblast_code, region_en,
			total_population, n_hromadas, total_area,
			avg_income_per_capita_2022, income_growth_pct, 
			oblast_population_density, urbanization_pct
		) %>%
		mutate(
			income_category = case_when(
				avg_income_per_capita_2022 >= 30000 ~ "High Income",
				avg_income_per_capita_2022 >= 20000 ~ "Medium Income",
				avg_income_per_capita_2022 >= 15000 ~ "Low Income",
				TRUE ~ "Very Low Income"
			)
		)
	
	append_to_final_db(ds_oblast, "ds_oblast")
	cat("   ✓ Created ds_oblast:", nrow(ds_oblast), "oblasts\n")
}

# ------------------------------------------------------------------ CREATE CUSTOM DATA TABLES ------------------------------------------------------------------

# Section 3: Custom tables (bookstores data)

# Create ds_bookstores from ds_bookstores table 
if ("ds_bookstores" %in% tables) {
	ds_bookstores <- dbReadTable(db, "ds_bookstores")
	append_to_final_db(ds_bookstores, "ds_bookstores")
	cat("   ✓ Created ds_bookstores:", nrow(ds_bookstores), "records\n")
}

# Close source database connection
dbDisconnect(db)

cat("\n🎉 ANALYTICAL DATABASE CREATION COMPLETE!\n")
cat("📁 Final database location:", final_db_path, "\n")
cat("📊 Generated tables:\n")
cat("   Section 1 - Publishing data: ds_year, ds_language, ds_territory, ds_theme, ds_purpose\n")
cat("   Section 2 - Administrative data: ds_oblast\n") 
cat("   Section 3 - Custom data: ds_bookstores\n")

# Write a manifest that describes the actual data
output_path <- "data-public/metadata/CACHE-MANIFEST.md"
manifest_lines <- c(
	"# CACHE Manifest",
	"",
	"This file describes the current state of cached data files in the project.",
	"",
	"## SQLite Databases",
	"",
	sprintf("- **books-of-ukraine.sqlite** (Analysis database) - %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
	"  - ds_year: Annual publishing totals (year, title_count, copy_count)",
	"  - ds_language: Publishing by language (year, language, title_count, copy_count)", 
	"  - ds_territory: Publishing by territory (year, territory, title_count, copy_count)",
	"  - ds_theme: Publishing by theme (year, theme, title_count, copy_count)",
	"  - ds_purpose: Publishing by purpose (year, purpose, title_count, copy_count)",
	"  - ds_oblast: Administrative data for Ukrainian oblasts",
	"  - ds_bookstores: Custom bookstore data",
	"",
	sprintf("- **books-of-ukraine-2.sqlite** (Comprehensive database) - %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
	"  - Contains all source tables plus administrative and custom data",
	"  - Use for accessing raw/source data when needed",
	"",
	"## Usage Notes",
	"",
	"- Analysis scripts should use the main database (books-of-ukraine.sqlite)",
	"- All tables use measures as columns format for analytical convenience", 
	"- Source data remains available in the comprehensive Stage 2 database",
	""
)
writeLines(manifest_lines, output_path)
cat("📋 Updated manifest:", output_path, "\n")

# Export all analytical tables to CSV
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

cat("\n✅ Script completed successfully!\n")
cat("💡 Next steps: Use analysis/eda-* scripts to explore the streamlined data\n")
cat("📊 Database ready for analysis with clean, focused table structure\n")
