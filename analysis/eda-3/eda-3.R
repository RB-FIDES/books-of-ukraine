rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
cat("\014") # Clear the console
# verify root location
cat("Working directory: ", getwd()) # Must be set to Project Directory
# Project Directory should be the root by default unless overwritten

# ---- load-packages -----------------------------------------------------------
# Choose to be greedy: load only what's needed
# Three ways, from least (1) to most(3) greedy:
# -- 1.Attach these packages so their functions don't need to be qualified: 
# http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr)
library(ggplot2)   # graphs
library(forcats)   # factors
library(stringr)   # strings
library(lubridate) # dates
library(labelled)  # labels
library(dplyr)     # data wrangling
library(tidyr)     # data wrangling
library(scales)    # format
library(broom)     # for model
library(emmeans)   # for interpreting model results
library(ggalluvial)
library(janitor)  # tidy data
library(testit)   # For asserting conditions meet expected patterns.

# ---- httpgd (VS Code interactive plots) ------------------------------------
# If the httpgd package is installed, try to start it so VS Code R extension
# can display interactive plots. This is optional and wrapped in tryCatch so
# the script still runs when httpgd is absent or fails to start.
if (requireNamespace("httpgd", quietly = TRUE)) {
	tryCatch({
		# Attempt to start httpgd server (API may vary by version); quiet on success
		if (is.function(httpgd::hgd)) {
			httpgd::hgd()
		} else if (is.function(httpgd::httpgd)) {
			httpgd::httpgd()
		} else {
			# Generic call attempt; will be caught if function not found
			httpgd::hgd()
		}
		message("httpgd started (if available). Configure your VS Code R extension to use it for plots.")
	}, error = function(e) {
		message("httpgd detected but failed to start: ", conditionMessage(e))
	})
} else {
	message("httpgd not installed. To enable interactive plotting in VS Code, install httpgd (binary recommended on Windows) or use other devices (svg/png).")
}

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
base::source("./scripts/operational-functions.R") # project-level

# ---- declare-globals ---------------------------------------------------------

local_root <- "./analysis/eda-1/"
local_data <- paste0(local_root, "data-local/") # for local outputs

if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

data_private_derived <- "./data-private/derived/eda-1/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

prints_folder <- paste0(local_root, "prints/")
if (!fs::dir_exists(prints_folder)) {fs::dir_create(prints_folder)}


# ---- declare-functions -------------------------------------------------------
# base::source(paste0(local_root,"local-functions.R")) # project-level

# ---- load-data ---------------------------------------------------------------

# Connect to the default Books of Ukraine database using modern functions
# Note: Using 'main' database which contains analysis-ready tables created by Ellis pipeline
# Note: wide tables (those with a _wide suffix) are good for getting to know the data, but tables (without _wide suffix) are better for analysis.
db <- connect_books_db("main")  # connects to the final analytical database
# now let's inspect what data tables are available in the database
db_tables_all <- DBI::dbListTables(db)

# Keep only tables that do NOT end with the `_wide` suffix (we'll import these)
db_tables <- db_tables_all[!grepl("_wide$", db_tables_all)]

# Read selected tables into a named list (tbls) and also assign sanitized names
# into the global environment for convenience. This keeps the connection open
# while we read data, then disconnects.
message("Reading ", length(db_tables), " non-_wide tables from DB: ", paste(db_tables, collapse = ", "))
tbls <- lapply(db_tables, function(t) {
	message(" - ", t)
	DBI::dbReadTable(db, t)
})
names(tbls) <- db_tables

# helper to convert table names into safe R object names
sanitize_name <- function(x) {
	nm <- gsub("[^A-Za-z0-9_]+", "_", x)
	nm <- gsub("^([0-9])", "_\\1", nm)
	nm
}

# assign into global env using sanitized names
for (nm in db_tables) {
	obj_name <- sanitize_name(nm)
	assign(obj_name, tbls[[nm]], envir = .GlobalEnv)
}
# Close the database connection
DBI::dbDisconnect(db)

# Print concise summary of loaded tables
cat("📊 Loaded tables (name: rows):\n")
for (nm in db_tables) {
	df <- tbls[[nm]]
	rows <- if (is.data.frame(df)) nrow(df) else NA
	cat("   -", nm, ":", rows, "rows\n")
}

# ---- tweak-data-0 -------------------------------------

# ---- inspect-data-0 -------------------------------------

# ---- inspect-data-1 -------------------------------------

# ---- inspect-data-2 -------------------------------------

# ---- analysis-below -------------------------------------

# ----- g1 ---------------------------------------------
# let's create a plot to show the volume of unique books published each year

g1_df <- fact_book_publications %>%
  dplyr::filter(measure_type == "title_count", category_type == "total", category_value == "all_books") %>%
  dplyr::mutate(year = as.integer(year)) %>%
  dplyr::arrange(year)

# If no rows found, provide a helpful message and create an empty plot frame
if (nrow(g1_df) == 0) {
  message("No rows found in fact_book_publications for title_count / all_books. g1 will be empty.")
  g1 <- ggplot2::ggplot() +
    ggplot2::labs(title = "Unique book titles published per year", x = "Year", y = "Unique titles") +
    ggplot2::theme_minimal()
} else {
  g1 <- ggplot2::ggplot(g1_df, ggplot2::aes(x = year, y = value)) +
    ggplot2::geom_col(fill = "#2b8cbe", alpha = 0.9) +
    ggplot2::geom_line(color = "#08519c", size = 0.8) +
    ggplot2::geom_point(color = "#08306b", size = 2) +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::scale_x_continuous(breaks = g1_df$year) +
    ggplot2::labs(
      title = "Unique book titles published per year",
      subtitle = "Number of unique titles (title_count) — all books",
      x = "Year",
      y = "Unique titles"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 14, face = "bold"),
      plot.subtitle = ggplot2::element_text(size = 11),
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
    )
}

# Save to prints folder if available
if (exists("prints_folder") && fs::dir_exists(prints_folder)) {
  out_path <- file.path(prints_folder, "g1_unique_titles_by_year.png")
  ggplot2::ggsave(filename = out_path, plot = g1, width = 9, height = 5, dpi = 300)
  message("Saved plot to: ", out_path)
} else {
  message("prints_folder not found; plot not saved to disk.")
}

# return plot object
g1















