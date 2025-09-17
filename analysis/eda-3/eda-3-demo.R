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
# Optional: httpgd convenience notes
# - The script uses the httpgd namespace (httpgd::hgd()) so attaching the package
#   is not required. If you prefer calling functions without the `httpgd::` prefix,
#   you can attach the package in an interactive session by uncommenting the
#   following line or running it manually in your R console before sourcing this file:
#
#   # In R interactive session only
#   # if (interactive()) suppressPackageStartupMessages(library(httpgd, quietly = TRUE))
#
# - To force automatic httpgd start when VS Code does not set VSCODE_PID, set
#   the environment variable for your session: Sys.setenv(FORCE_HTTPGD = 'TRUE')
#   or set the option: options(books_of_ukraine.force_httpgd = TRUE)
#
# Start httpgd only for interactive VS Code sessions. This avoids attempting
# to start a server during non-interactive Quarto/CI renders.
#
# If you are in an interactive R session but VS Code does not expose
# VSCODE_PID, you can force starting httpgd for this session by either:
#  - setting the environment variable: Sys.setenv(FORCE_HTTPGD = 'TRUE')
#  - or setting the option: options(books_of_ukraine.force_httpgd = TRUE)
force_httpgd_env <- tolower(Sys.getenv("FORCE_HTTPGD", unset = ""))
force_httpgd <- nzchar(force_httpgd_env) && force_httpgd_env %in% c("1", "true", "yes")
force_httpgd <- force_httpgd || isTRUE(getOption("books_of_ukraine.force_httpgd", FALSE))

if (interactive() && (nzchar(Sys.getenv("VSCODE_PID")) || force_httpgd)) {
  if (requireNamespace("httpgd", quietly = TRUE)) {
    tryCatch({
      # prefer hgd(); older versions may expose httpgd()
      # Optionally attach httpgd for convenience in interactive sessions
      if (interactive()) {
        try(suppressPackageStartupMessages(library(httpgd, quietly = TRUE)), silent = TRUE)
      }
      if (is.function(httpgd::hgd)) {
        httpgd::hgd()
      } else if (is.function(httpgd::httpgd)) {
        httpgd::httpgd()
      }
      message("httpgd started for interactive VS Code session. Use the VS Code Plot pane or httpgd::hgd_browse() to view plots.")
    }, error = function(e) {
      message("httpgd detected but failed to start: ", conditionMessage(e))
    })
  } else {
    message("httpgd not installed. To enable interactive plotting in VS Code, install httpgd: install.packages('httpgd')")
  }
} else {
  if (interactive() && !nzchar(Sys.getenv("VSCODE_PID")) && !force_httpgd) {
    message("Interactive R session detected but no VS Code PID found; httpgd was not started automatically. To force it in this session set FORCE_HTTPGD=TRUE or options(books_of_ukraine.force_httpgd = TRUE).")
  }
  # Non-interactive contexts (Quarto / CI): do nothing; static devices will be used.
}

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
base::source("./scripts/operational-functions.R") # project-level

# ---- declare-globals ---------------------------------------------------------

local_root <- "./analysis/eda-3/"
local_data <- paste0(local_root, "data-local/") # for local outputs

if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

data_private_derived <- "./data-private/derived/eda-3/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

prints_folder <- paste0(local_root, "prints/")
if (!fs::dir_exists(prints_folder)) {fs::dir_create(prints_folder)}


# ---- declare-functions -------------------------------------------------------
# base::source(paste0(local_root,"local-functions.R")) # project-level

# Generate data dictionary in local analysis folder
generate_local_data_dictionary <- function() {
  source("./scripts/generate-data-dictionary.R")
  generate_long_datasets_dictionary(analysis_folder = local_root)
  cat("Data dictionary generated in:", file.path(local_root, "data-dictionary-long-datasets.md"), "\n")
}

# ---- load-data --------------------------------------

# Connect to the default Books of Ukraine database using custom functions
# Note: Using 'main' database which contains analysis-ready tables created by Ellis pipeline
# Note: The complete optimized database (books + ua admin + extra) 
# Note: wide tables (those with a _wide suffix) are good for getting to know the data, but tables (without _wide suffix) are better for analysis.
db <- connect_books_db("main")  # connects to the final analytical database
# now let's inspect what data tables are available in the database
db_tables_all <- DBI::dbListTables(db)

# Keep only tables that do NOT end with the `_wide` suffix (we'll import these)
# db_tables <- db_tables_all[!grepl("_wide$", db_tables_all)]
db_tables <- db_tables_all

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
  cat("Loaded tables (name: rows x cols):\n")
for (nm in db_tables) {
  df <- tbls[[nm]]
  if (is.data.frame(df) || is.matrix(df)) {
    rows <- nrow(df)
    cols <- ncol(df)
  } else {
    rows <- NA
    cols <- NA
  }
  cat("   -", nm, ":", rows, "rows and", cols, "columns\n")
}

# ---- tweak-data-0 -------------------------------------

# ---- inspect-data-0 -------------------------------------

# ---- inspect-data-1 -------------------------------------
# Let's explore the structure and content of our key datasets
ds_year %>% glimpse()
ds_language %>% glimpse()
ds_territory %>% glimpse()
ds_theme %>% glimpse()
ds_purpose %>% glimpse()
ds_oblast %>% glimpse()


# ---- inspect-data-2 -------------------------------------

# ---- analysis-below -------------------------------------



# ----- g2 ------------------------------------------------
# Now let's create a plot to show the dynamics of book publishing by language over time. Let's focus on title count first (we'll think about copy count later).
d1 <- ds_language %>% as_tibble()
ds_language %>% class()
d1 %>% class()

ds_language
d1 

d1 %>% glimpse()

d1 %>% 
  group_by(measure) %>% 
  summarize(n = n())


d1 %>% 
  filter(measure == "copy_count") %>% 
  filter(value>0L) %>%
  group_by(year) %>% 
  summarize(
    # langauge_count = n_distinct(category_value)
    langauge_count = n_distinct(category_value)
  )
  
d2 <- 
  d1 %>% 
  filter(measure == "copy_count") %>% 
  filter(year > 2017) %>% 
  filter(
    category_value  %in% c(
      "Українська","Російська","Кількома мовами народів світу"
      )
    )
# these languages dwarf others, lets remove them from analaysi
d2 %>% count(category_value)
g2 <- 
   d2 %>% 
   ggplot(mapping = aes(x=year, y = value)) +
  geom_col(alpha = .8) +
  facet_wrap(facets = "category_value", ncol=1,scales="fixed")
g2

d3 <- 
  d1 %>% 
  filter(measure == "copy_count") %>% 
  filter(
    ! category_value  %in% c(
      "Українська"
      ,"Російська"
      ,"Кількома мовами народів світу"
      ,"Англійська"
    )
  ) %>% 
  group_by(category_type, category_value, measure) %>%
  # group_by(category_value, measure) %>%
  summarize(
    total_copy_count_over_years = sum(value)
  ) %>% 
  ungroup()


d3 %>% head()

  
g3 <- 
  d3 %>% 
  # filter(category_value == "Іврит") %>% 
  ggplot(
    aes(
      y     = category_value
      ,x    = total_copy_count_over_years
    )
  )+
  geom_col()
g3


# let' make a tile graph where 
# y = langauge
# x = year
# geom = tile
# the numbe in the tile shows total copy count that year
# the fill of the the tile shows c(0, 1-100, 100+)
d2

g4 <- 
  d1%>% 
  filter(measure == "copy_count") %>% 
  filter(year > 2017) %>% 
  mutate(
    group_size = case_when(
      value >= 1000 ~ "1M+",
      value >= 100 & value < 1000 ~ "100K-1M",
      value >= 1 & value < 100 ~ "1K-99K",
      value <1 & value > 0 ~ "<1",
      value == 0L ~ "Zero",
      TRUE ~ NA_character_
    ) 
  )%>% 
  ggplot(
    aes(
      y = category_value
      ,x = year
      ,fill = group_size
      
    )
  )+
  geom_tile(color = "white")#+
  # geom_text(aes(label = value))


# let's create a table in which each row is a language (category_value)
# coun tof years in which copy_count was non-zero

g5 <- 
  d1%>% 
  filter(measure == "copy_count") %>% 
  filter(year > 2017) %>%
  # filter(category_value %in% c("Іврит","Азербайджанська")) %>% 
  mutate(
    group_size = case_when(
      value >= 1000 ~ "1M+",
      value >= 100 & value < 1000 ~ "100K-1M",
      value >= 1 & value < 100 ~ "1K-99K",
      value <1 & value > 0 ~ "<1",
      value == 0L ~ "Zero",
      TRUE ~ NA_character_
    )
    ,year_non_zero = case_when(
      value > 0L ~ TRUE,
      TRUE ~ NA
    )
  ) %>% arrange(category_value) %>% 
  group_by(category_value) %>% 
  mutate(
    year_nz_count = sum(year_non_zero,na.rm = T)
  ) %>% 
  ungroup() %>% 
  filter(year_nz_count == 1) %>% 
  ggplot(
    aes(
      y = category_value
      ,x = year
      ,fill = group_size
      
    )
  )+
  geom_tile(color = "white")+
  geom_text(aes(label = value))








