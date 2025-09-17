rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
cat("\014") # Clear the console
# verify root location
cat("Working directory: ", getwd()) # Must be set to Project Directory
# Project Directory should be the root by default unless overwritten
# The purpose of this script is to facilitate learning about data assets created by ETL pipeline and to provide a handoff point for analysis.
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
base::source("./scripts/silent-mini-eda.R") # project-level

# ---- declare-globals ---------------------------------------------------------

local_root <- "./manipulation/"
local_data <- paste0(local_root, "data-local/") # for local outputs

if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

data_private_derived <- "./data-private/derived/eda-3/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

prints_folder <- paste0(local_root, "prints/")
if (!fs::dir_exists(prints_folder)) {fs::dir_create(prints_folder)}


# ---- declare-functions -------------------------------------------------------
# base::source(paste0(local_root,"local-functions.R")) # project-level

# ---- load-data --------------------------------------

# Connect to the default Books of Ukraine database using custom functions
# Note: Using 'main' database which contains analysis-ready tables created by Ellis pipeline
# Note: The complete optimized database (books + ua admin + extra) 
# Note: wide tables (those with a _wide suffix) are good for getting to know the data, but tables (without _wide suffix) are better for analysis.
db <- connect_books_db("main")  # connects to the final analytical database

# Books of Ukraine database tables
ds_year <- DBI::dbReadTable(db, "ds_year") %>% as_tibble()
ds_language <- DBI::dbReadTable(db, "ds_language") %>% as_tibble()
ds_theme <- DBI::dbReadTable(db, "ds_theme") %>% as_tibble()
ds_purpose <- DBI::dbReadTable(db, "ds_purpose") %>% as_tibble()
ds_territory <- DBI::dbReadTable(db, "ds_territory") %>% as_tibble()

# Regional statistics and administrative data 
ds_oblast <- DBI::dbReadTable(db, "ds_oblast") %>% as_tibble()

# Custom user-contributed data 
ds_bookstores <- DBI::dbReadTable(db, "ds_bookstores") %>% as_tibble()


#lets' load raw_ua_admin_heirarchy from the stage_1 database
stage1_db <- connect_books_db("stage_1")
# list tables in stage_1_db
DBI::dbListTables(stage1_db)
ds_ua_admin <- DBI::dbReadTable(stage1_db, "raw_ua_admin_hierarchy") %>% as_tibble()
ds_ua_admin %>% glimpse()

# ---- inspect-data -------------------------------------
ds_year
ds_language
ds_theme
ds_purpose
ds_territory
ds_oblast
ds_bookstores


# ---- tweak-data-0 -------------------------------------

# ---- inspect-data-0 -------------------------------------

# ---- inspect-data-1 -------------------------------------

# ---- inspect-data-2 -------------------------------------

# ---- g1 -----------------------------------------------------
# We would like to understand how  publishing books in ukraine very by language and time.  
silent_mini_eda("ds_language")
silent_mini_eda("year")

# ds_language_plop_prep <- smart_plot("ds_language","dynamics of publishing by language and year") # this appears to be less useful at this moment. 