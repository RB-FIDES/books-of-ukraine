cat("\014")                     # Clear console
rm(list = ls(all.names = TRUE)) # Clear the environment

# last-ellis.R - Create focused analytical database for human analysts
# 
# PURPOSE: Extract and transform data from the comprehensive Stage 2 database 
# into a streamlined, analysis-ready format optimized for human convenience.
#
# DESIGN PHILOSOPHY:
# - Stage 2 (books-of-ukraine-2.sqlite): Comprehensive data storage with all source data + custom/extra data
# - Final (books-of-ukraine.sqlite): Focused analytical convenience with clean, analysis-ready tables
# - When analysts need source data, they can always reach back to Stage 2 database

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # Modern database connection functions
base::source("./manipulation/support/ds_dictionary_en_ua.R") # Ukrainian-English dictionary

# ---- load-packages -----------------------------------------------------------
library(DBI)
library(RSQLite)
library(dplyr)
library(tidyr)     # for pivot_longer operations in oblast tables
library(stringr)   # for str_detect operations
library(fs)

# ---- declare-globals ---------------------------------------------------------
# Set up database paths and CSV export directory
enhanced_db_path <- get_db_path("stage_2")
final_db_path <- get_db_path("main")
csv_path <- "data-private/derived/manipulation/CSV/"

# ---- load-data ---------------------------------------------------------------
# Helper function to append table to final database
append_to_final_db <- function(table_data, table_name) {
	db_path <- get_db_path("main")
	con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
	DBI::dbWriteTable(con, table_name, table_data, overwrite = TRUE)
	DBI::dbDisconnect(con)
}

# Set up CSV export directory for analytical tables
if (!fs::dir_exists(csv_path)) {fs::dir_create(csv_path)}

cat("🔍 Importing from comprehensive Stage 2 database:", enhanced_db_path, "\n")
db <- connect_books_db("stage_2")

tables <- dbListTables(db)
cat("📊 Available source tables:\n")
print(tables)

cat("\n🎯 Creating focused analytical database at:", final_db_path, "\n")
cat("   Purpose: Clean, analysis-ready tables optimized for human analysts\n")
cat("   Note: Comprehensive source data remains available in Stage 2 database\n\n")

# Remove existing final database to start fresh
if (file.exists(final_db_path)) {
	file.remove(final_db_path)
}

# Read source data from Stage 2 database
if ("fact_book_publications" %in% tables) {
	fact_df <- dbReadTable(db, "fact_book_publications")
}
if ("ua_oblasts_aggregated" %in% tables) {
	ua_oblasts_df <- dbReadTable(db, "ua_oblasts_aggregated")
}
if ("ds_bookstores" %in% tables) {
	bookstores_df <- dbReadTable(db, "ds_bookstores")
}

# ---- create-focal-datasets ---------------------------------------------------
cat("📊 Creating focal datasets from source data...\n")

# Create ds_year from fact_book_publications (year, title_count, copy_count)
ds_year <- NULL
if (exists("fact_df")) {
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
		cat("   ✓ Created ds_year:", nrow(ds_year), "years\n")
	}
}

# Create ds_language from fact_book_publications (year, language_ua, title_count, copy_count)
ds_language <- NULL
if (exists("fact_df")) {
	lang_df <- fact_df %>%
		filter(category_type == "language") %>%
		rename(language_ua = category_value) %>%
		select(year, language_ua, measure, value)
	ds_language <- tryCatch({
		tidyr::pivot_wider(lang_df, id_cols = c(year, language_ua), names_from = measure, values_from = value, values_fill = 0)
	}, error = function(e) {
		cat("Error creating ds_language:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_language)) {
		cat("   ✓ Created ds_language:", nrow(ds_language), "language-year combinations\n")
	}
}

# Create ds_territory from fact_book_publications (year, territory_ua, title_count, copy_count)
ds_territory <- NULL
if (exists("fact_df")) {
	territory_df <- fact_df %>%
		filter(category_type == "territory") %>%
		rename(territory_ua = category_value) %>%
		select(year, territory_ua, measure, value)
	ds_territory <- tryCatch({
		tidyr::pivot_wider(territory_df, id_cols = c(year, territory_ua), names_from = measure, values_from = value, values_fill = 0)
	}, error = function(e) {
		cat("Error creating ds_territory:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_territory)) {
		cat("   ✓ Created ds_territory:", nrow(ds_territory), "territory-year combinations\n")
	}
}

# Create ds_theme from fact_book_publications (year, theme_ua, title_count, copy_count)
ds_theme <- NULL
if (exists("fact_df")) {
	theme_df <- fact_df %>%
		filter(category_type == "theme") %>%
		rename(theme_ua = category_value) %>%
		select(year, theme_ua, measure, value)
	ds_theme <- tryCatch({
		tidyr::pivot_wider(theme_df, id_cols = c(year, theme_ua), names_from = measure, values_from = value, values_fill = 0)
	}, error = function(e) {
		cat("Error creating ds_theme:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_theme)) {
		cat("   ✓ Created ds_theme:", nrow(ds_theme), "theme-year combinations\n")
	}
}

# Create ds_purpose from fact_book_publications (year, purpose_ua, title_count, copy_count)
ds_purpose <- NULL
if (exists("fact_df")) {
	purpose_df <- fact_df %>%
		filter(category_type == "purpose") %>%
		rename(purpose_ua = category_value) %>%
		select(year, purpose_ua, measure, value)
	ds_purpose <- tryCatch({
		tidyr::pivot_wider(purpose_df, id_cols = c(year, purpose_ua), names_from = measure, values_from = value, values_fill = 0)
	}, error = function(e) {
		cat("Error creating ds_purpose:", e$message, "\n")
		NULL
	})
	if (!is.null(ds_purpose)) {
		cat("   ✓ Created ds_purpose:", nrow(ds_purpose), "purpose-year combinations\n")
	}
}

# Create ds_oblast from ua_oblasts_aggregated (oblast administrative data)
ds_oblast <- NULL
if (exists("ua_oblasts_df")) {
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
	cat("   ✓ Created ds_oblast:", nrow(ds_oblast), "oblasts\n")
}

# Create ds_bookstores from bookstores data
ds_bookstores <- NULL
if (exists("bookstores_df")) {
	ds_bookstores <- bookstores_df
	cat("   ✓ Created ds_bookstores:", nrow(ds_bookstores), "records\n")
}

# ---- tweak-data-1 ------------------------------------------------------------
cat("🔧 Adding English translations and preparing final datasets...\n")

# Add English translations to ds_language using dictionary
if (!is.null(ds_language)) {
	lang_dict <- ds_dictionary_en_ua %>% filter(source == "language") %>% select(term_ua, term_en)
	ds_language <- ds_language %>%
		left_join(lang_dict, by = c("language_ua" = "term_ua")) %>%
		rename(language = term_en) %>%
		select(year, language_ua, language, title_count, copy_count) %>%
		relocate(-language_ua)
	cat("   ✓ Added English translations to ds_language\n")
}

# Add English translations to ds_theme using dictionary
if (!is.null(ds_theme)) {
	theme_dict <- ds_dictionary_en_ua %>% filter(source == "theme") %>% select(term_ua, term_en)
	ds_theme <- ds_theme %>%
		left_join(theme_dict, by = c("theme_ua" = "term_ua")) %>%
		rename(theme = term_en) %>%
		select(year, theme_ua, theme, title_count, copy_count) %>%
		relocate(-theme_ua)
	cat("   ✓ Added English translations to ds_theme\n")
}

# Add English translations to ds_purpose using dictionary
if (!is.null(ds_purpose)) {
	purpose_dict <- ds_dictionary_en_ua %>% filter(source == "purpose") %>% select(term_ua, term_en)
	ds_purpose <- ds_purpose %>%
		left_join(purpose_dict, by = c("purpose_ua" = "term_ua")) %>%
		rename(purpose = term_en) %>%
		select(year, purpose_ua, purpose, title_count, copy_count) %>%
		relocate(-purpose_ua)
	cat("   ✓ Added English translations to ds_purpose\n")
}

# Add English translations to ds_territory using oblast code dictionary
if (!is.null(ds_territory)) {
	ds_territory <- ds_territory %>%
		left_join(ds_oblast_code, by = c("territory_ua" = "oblast_name_ua")) %>%
		rename(territory = oblast_name_en) %>%
		select(year, territory_ua, territory, oblast_code, title_count, copy_count) %>%
		relocate(-territory_ua)
	cat("   ✓ Added English translations and oblast codes to ds_territory\n")
}
# ---- inspect-data ------------------------------------------------------------
cat("\n👀 DATASETS READY FOR INSPECTION:\n")
cat("   Use View() in RStudio or print() to examine datasets before saving\n\n")

# Show sample of each dataset for human inspection
if (!is.null(ds_year)) {
	cat("ds_year structure (", nrow(ds_year), "rows):\n")
	print(head(ds_year, 3))
	cat("\n")
}

if (!is.null(ds_language)) {
	cat("ds_language structure (", nrow(ds_language), "rows):\n")
	print(head(ds_language, 3))
	cat("\n")
}

if (!is.null(ds_theme)) {
	cat("ds_theme structure (", nrow(ds_theme), "rows):\n")
	print(head(ds_theme, 3))
	cat("\n")
}

if (!is.null(ds_purpose)) {
	cat("ds_purpose structure (", nrow(ds_purpose), "rows):\n")
	print(head(ds_purpose, 3))
	cat("\n")
}

if (!is.null(ds_territory)) {
	cat("ds_territory structure (", nrow(ds_territory), "rows):\n")
	print(head(ds_territory, 3))
	cat("\n")
}

if (!is.null(ds_oblast)) {
	cat("ds_oblast structure (", nrow(ds_oblast), "rows):\n")
	print(head(ds_oblast, 3))
	cat("\n")
}

if (!is.null(ds_bookstores)) {
	cat("ds_bookstores structure (", nrow(ds_bookstores), "rows):\n")
	print(head(ds_bookstores, 3))
	cat("\n")
}

# ---- save-to-disk ------------------------------------------------------------
cat("💾 Saving datasets to main database...\n")

# Save each dataset to the main database
if (!is.null(ds_year)) {
	append_to_final_db(ds_year, "ds_year")
	cat("   ✓ Saved ds_year to database\n")
}

if (!is.null(ds_language)) {
	append_to_final_db(ds_language, "ds_language")
	cat("   ✓ Saved ds_language to database\n")
}

if (!is.null(ds_theme)) {
	append_to_final_db(ds_theme, "ds_theme")
	cat("   ✓ Saved ds_theme to database\n")
}

if (!is.null(ds_purpose)) {
	append_to_final_db(ds_purpose, "ds_purpose")
	cat("   ✓ Saved ds_purpose to database\n")
}

if (!is.null(ds_territory)) {
	append_to_final_db(ds_territory, "ds_territory")
	cat("   ✓ Saved ds_territory to database\n")
}

if (!is.null(ds_oblast)) {
	append_to_final_db(ds_oblast, "ds_oblast")
	cat("   ✓ Saved ds_oblast to database\n")
}

if (!is.null(ds_bookstores)) {
	append_to_final_db(ds_bookstores, "ds_bookstores")
	cat("   ✓ Saved ds_bookstores to database\n")
}

# Close source database connection
dbDisconnect(db)

# ---- export-manifest ---------------------------------------------------------
cat("� Creating data manifest...\n")

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
	"  - ds_language: Publishing by language (year, language_ua, language, title_count, copy_count)", 
	"  - ds_territory: Publishing by territory (year, territory_ua, territory, oblast_code, title_count, copy_count)",
	"  - ds_theme: Publishing by theme (year, theme_ua, theme, title_count, copy_count)",
	"  - ds_purpose: Publishing by purpose (year, purpose_ua, purpose, title_count, copy_count)",
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
	"- Tables contain both Ukrainian (*_ua) and English terms for human convenience", 
	"- All tables use measures as columns format for analytical convenience", 
	"- Source data remains available in the comprehensive Stage 2 database",
	""
)
writeLines(manifest_lines, output_path)
cat("   ✓ Updated manifest:", output_path, "\n")

# ---- export-csv --------------------------------------------------------------
cat("💾 Exporting analytical tables to CSV...\n")

# Export all analytical tables to CSV
db_final <- connect_books_db("main")
all_tables <- dbListTables(db_final)

for (table_name in all_tables) {
  table_data <- dbReadTable(db_final, table_name)
  csv_file_path <- paste0(csv_path, table_name, ".csv")
  write.csv(table_data, csv_file_path, row.names = FALSE)
  cat(paste0("   ✓ Exported ", table_name, " (", nrow(table_data), " rows) to CSV\n"))
}
dbDisconnect(db_final)
cat("   ✓ All analytical tables exported to:", csv_path, "\n")

cat("\n🎉 ANALYTICAL DATABASE CREATION COMPLETE!\n")
cat("📁 Final database location:", final_db_path, "\n")
cat("📊 Generated tables with Ukrainian + English terms:\n")
cat("   - Publishing data: ds_year, ds_language, ds_territory, ds_theme, ds_purpose\n")
cat("   - Administrative data: ds_oblast\n") 
cat("   - Custom data: ds_bookstores\n")
cat("\n✅ Script completed successfully!\n")
cat("💡 Next steps: Use analysis/eda-* scripts to explore the streamlined data\n")
cat("📊 Database ready for analysis with bilingual, focused table structure\n")
