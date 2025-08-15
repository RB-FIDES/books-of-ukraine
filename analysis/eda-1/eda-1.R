rm(list = ls(all.names = TRUE)) # Clear the memory
cat("\014") # Clear the console
cat("Working directory: ", getwd()) # Must be set to Project Directory

# Minimal cross-platform plot window function
show_plot_window <- function(plot_obj, width = 10, height = 6) {
  os_type <- Sys.info()["sysname"]
  if (os_type == "Windows") {
    windows(width = width, height = height)
  } else if (os_type == "Darwin") {
    x11(width = width, height = height)
  } else {
    x11(width = width, height = height)
  }
  print(plot_obj)
  invisible(plot_obj)
}

local_root <- "./analysis/eda-1/"
local_data <- paste0(local_root, "data-local/")

# ---- load-packages -----------------------------------------------------------
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
library(janitor)   # tidy data
library(testit)    # For asserting conditions meet expected patterns.
library(DBI)       # For database connection and operations
library(RSQLite)   # SQLite database
library(ggrepel)   # for text labels in ggplot2
library(gridExtra) # for combining plots

base::source("./scripts/common-functions.R")
base::source("./scripts/operational-functions.R")

# ---- declare-globals ---------------------------------------------------------
data_private_derived <- "./data-private/derived/eda-1/"
if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}
prints_folder <- paste0(local_root, "prints/")
if (!fs::dir_exists(prints_folder)) {fs::dir_create(prints_folder)}

# Data paths
data_manipulation_path <- "data-private/derived/manipulation/"


# ---- load-data ---------------------------------------------------------------

# ---- import fact_book_publications and transform to long format tables ----
# Prefer CSV, fallback to RDS if not found
fact_book_path_csv <- paste0(data_manipulation_path, "CSV/fact_book_publications.csv")
fact_book_path_rds <- paste0(data_manipulation_path, "fact_book_publications.rds")
if (file.exists(fact_book_path_csv)) {
  fact_book <- read.csv(fact_book_path_csv, stringsAsFactors = FALSE)
  cat("Loaded fact_book_publications from CSV\n")
} else if (file.exists(fact_book_path_rds)) {
  fact_book <- readRDS(fact_book_path_rds)
  cat("Loaded fact_book_publications from RDS\n")
} else {
  stop("fact_book_publications file not found. Please run manipulation/1-ellis.R first.")
}

# Transform fact_book into long-format tables
ds_year <- fact_book %>%
  filter(category_type == "total") %>%
  select(year, measure = measure_type, value)

ds_language <- fact_book %>%
  filter(category_type == "language") %>%
  select(year, language = category_value, measure = measure_type, value)

ds_genre <- fact_book %>%
  filter(category_type == "theme") %>%
  select(year, genre = category_value, measure = measure_type, value)

ds_pubtype <- fact_book %>%
  filter(category_type == "purpose") %>%
  select(year, pubtype = category_value, measure = measure_type, value)

ds_geography <- fact_book %>%
  filter(category_type == "territory") %>%
  select(year, geography = category_value, measure = measure_type, value)

# Optional: Connect to SQLite database for SQL queries
# books_db <- connect_to_db()

# ---- inspect-data-0 -----------------------------------------------------------
# Basic inspection of all datasets
cat("Dataset dimensions (long format):\n")
cat("ds_year:", dim(ds_year)[1], "rows x", dim(ds_year)[2], "columns\n")
cat("ds_language:", dim(ds_language)[1], "rows x", dim(ds_language)[2], "columns\n") 
cat("ds_genre:", dim(ds_genre)[1], "rows x", dim(ds_genre)[2], "columns\n")
cat("ds_pubtype:", dim(ds_pubtype)[1], "rows x", dim(ds_pubtype)[2], "columns\n")
cat("ds_geography:", dim(ds_geography)[1], "rows x", dim(ds_geography)[2], "columns\n")

# Show year range from long format data
cat("\nYear range in data:", min(ds_year$year), "-", max(ds_year$year), "\n")

# Show measure types available in long format
cat("\nMeasure types available:", paste(unique(ds_year$measure), collapse = ", "), "\n")

# Show structure of long format datasets
cat("\nStructure of long format datasets:\n")
str(ds_year)
cat("\nSample of ds_language:\n")
head(ds_language, 10)

# ---- tweak-data-0 ------------------------------------------------------------
# Prepare data for analysis - add regional groupings for geography
# Note: Geography data is now in long format, so we need to work with it differently
ds_geography_enhanced <- ds_geography %>%
  mutate(
    region_group = case_when(
      # Північ (North)
      geography %in% c("м. Київ", "Київська область", "Чернігівська область", 
                      "Сумська область", "Житомирська область") ~ "Північ",
      
      # Південь (South) 
      geography %in% c("Одеська область", "Миколаївська область", "Херсонська область",
                      "Запорізька область", "Автономна Республіка Крим", "м. Севастополь") ~ "Південь",
      
      # Схід (East)
      geography %in% c("Харківська область", "Донецька область", "Луганська область",
                      "Дніпропетровська область") ~ "Схід",
      
      # Захід (West)
      geography %in% c("Львівська область", "Івано-Франківська область", "Тернопільська область",
                      "Закарпатська область", "Волинська область", "Рівненська область",
                      "Хмельницька область", "Чернівецька область") ~ "Захід",
      
      # Центр (Center)
      geography %in% c("Вінницька область", "Полтавська область", "Кіровоградська область",
                      "Черкаська область") ~ "Центр",
      
      TRUE ~ "Інше"
    )
  )

# Create summary tables for easier graphing
ds_year_summary <- ds_year %>%
  arrange(year, measure)

ds_language_summary <- ds_language %>%
  # Filter for main languages of interest
  filter(language %in% c("Українська", "Російська", "Англійська")) %>%
  arrange(year, measure, language)

# ---- analysis-functions ------------------------------------------------------
# Function to create time series plot
create_time_series <- function(data, value_col, title, subtitle = NULL, y_label = "Count") {
  data %>%
    ggplot(aes(x = year, y = !!sym(value_col))) +
    geom_line(linewidth = 1.2, color = "steelblue") +
    geom_point(size = 2, color = "steelblue") +
    labs(
      title = title,
      subtitle = subtitle,
      x = "Рік",
      y = y_label
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 12),
      axis.text = element_text(size = 10),
      axis.title = element_text(size = 11)
    ) +
    scale_x_continuous(breaks = seq(2005, 2023, 2)) +
    scale_y_continuous(labels = scales::comma)
}

# Function to create language comparison plot
create_language_comparison <- function(data, measure_type = "title_count") {
  data %>%
    filter(measure == measure_type, language %in% c("Українська", "Російська")) %>%
    ggplot(aes(x = year, y = value, color = language)) +
    geom_line(linewidth = 1.2) +
    geom_point(size = 2) +
    labs(
      title = if(measure_type == "title_count") "Кількість видань за мовами" else "Кількість копій за мовами",
      x = "Рік",
      y = if(measure_type == "title_count") "Кількість видань" else "Кількість копій",
      color = "Мова"
    ) +
    theme_minimal() +
    scale_color_manual(values = c("Українська" = "#005BBB", "Російська" = "#DC143C")) +
    scale_x_continuous(breaks = seq(2005, 2023, 2)) +
    scale_y_continuous(labels = scales::comma)
}

# Function to create regional comparison plot (designed for long format)
create_regional_comparison <- function(data, measure_type = "title_count") {
  data %>%
    filter(measure == measure_type) %>%
    group_by(year, region_group) %>%
    summarise(total = sum(value, na.rm = TRUE), .groups = "drop") %>%
    ggplot(aes(x = year, y = total, color = region_group)) +
    geom_line(linewidth = 1.2) +
    geom_point(size = 2) +
    labs(
      title = if(measure_type == "title_count") "Регіональні тенденції публікацій" else "Регіональні тенденції накладу",
      x = "Рік",
      y = if(measure_type == "title_count") "Кількість видань" else "Кількість копій",
      color = "Регіон"
    ) +
    theme_minimal() +
    scale_x_continuous(breaks = seq(2005, 2023, 2)) +
    scale_y_continuous(labels = scales::comma) +
    theme(legend.position = "bottom")
}

# Function to analyze long format data by any categorical variable
analyze_category_trends <- function(data, category_col, measure_type = "title_count", top_n = 5) {
  data %>%
    filter(measure == measure_type) %>%
    group_by(year, !!sym(category_col)) %>%
    summarise(total = sum(value, na.rm = TRUE), .groups = "drop") %>%
    group_by(!!sym(category_col)) %>%
    summarise(overall_total = sum(total, na.rm = TRUE), .groups = "drop") %>%
    slice_max(overall_total, n = top_n) %>%
    pull(!!sym(category_col)) -> top_categories
  
  data %>%
    filter(measure == measure_type, !!sym(category_col) %in% top_categories) %>%
    group_by(year, !!sym(category_col)) %>%
    summarise(total = sum(value, na.rm = TRUE), .groups = "drop") %>%
    ggplot(aes(x = year, y = total, color = !!sym(category_col))) +
    geom_line(linewidth = 1.2) +
    geom_point(size = 2) +
    labs(
      title = paste("Top", top_n, str_to_title(category_col), "Trends"),
      x = "Рік",
      y = if(measure_type == "title_count") "Кількість видань" else "Кількість копій",
      color = str_to_title(category_col)
    ) +
    theme_minimal() +
    scale_x_continuous(breaks = seq(2005, 2023, 2)) +
    scale_y_continuous(labels = scales::comma) +
    theme(legend.position = "bottom")
}

# ---- analysis-below -----------------------------------------------------------
# Ready for human analysts to create visualizations and conduct analysis
# All data is loaded and prepared for exploration

# ---- sample-analysis ----------------------------------------------------------
# Sample analysis demonstrating long format advantages

# Example 1: Multi-language trend analysis
sample_language_trends <- function() {
  ds_language %>%
    filter(measure == "title_count", 
           language %in% c("Українська", "Російська", "Англійська")) %>%
    ggplot(aes(x = year, y = value, color = language)) +
    geom_line(linewidth = 1.2) +
    geom_point(size = 2) +
    labs(title = "Publishing Trends by Language",
         x = "Year", y = "Number of Titles", color = "Language") +
    theme_minimal() +
    scale_color_manual(values = c("Українська" = "#005BBB", 
                                  "Російська" = "#DC143C",
                                  "Англійська" = "#228B22")) +
    scale_x_continuous(breaks = seq(2005, 2023, 2)) +
    scale_y_continuous(labels = scales::comma)
}

# Example 2: Regional analysis using enhanced geography data
sample_regional_analysis <- function() {
  ds_geography_enhanced %>%
    filter(measure == "title_count") %>%
    group_by(year, region_group) %>%
    summarise(total_titles = sum(value, na.rm = TRUE), .groups = "drop") %>%
    ggplot(aes(x = year, y = total_titles, fill = region_group)) +
    geom_area(position = "stack", alpha = 0.7) +
    labs(title = "Regional Distribution of Publications",
         x = "Year", y = "Number of Titles", fill = "Region") +
    theme_minimal()
}

# Example 3: Cross-dimensional analysis (language by region)  
sample_cross_analysis <- function() {
  # This would require joining datasets - demonstrating long format flexibility
}
# ----- q1 ---------------------------------------------------------
# How me how many books was publised every year since 2005?

g1 <- 
  ds_year %>%
  filter(measure == "title_count") %>%
  group_by(year) %>%
  summarise(total_titles = sum(value, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(x = year, y = total_titles)) +
  geom_line(linewidth = 1.2, color = "steelblue") +
  geom_point(size = 2, color = "steelblue") +
  labs(title = "Total Book Publications in Ukraine",
       x = "Year", y = "Number of Titles") +
  theme_minimal() +
  scale_x_continuous(breaks = seq(2005, 2023, 2)) +
  scale_y_continuous(labels = scales::comma)

# Display the plot in separate window
show_plot_window(g1)  # Opens plot in separate window

# now save the plot
ggsave(
  filename = paste0(prints_folder, "total_book_publications.png")
  , plot = g1, width = 10, height = 6, dpi = 300
)

# number of books can mean different things: number of unique titles and total copies published.
# Note: copy_count is in thousands, so we multiply by 1000 to get actual copies
g2 <- 
  ds_year %>%
  filter(measure %in% c("title_count", "copy_count")) %>%
  mutate(
    # Convert copy_count from thousands to actual numbers
    actual_value = case_when(
      measure == "copy_count" ~ value * 1000,  # Convert from thousands to actual copies
      TRUE ~ value
    )
  ) %>%
  ggplot(aes(x = year)) +
  geom_line(data = . %>% filter(measure == "title_count"), 
            aes(y = actual_value), color = "#005BBB", linewidth = 1.2) +
  geom_point(data = . %>% filter(measure == "title_count"), 
             aes(y = actual_value), color = "#005BBB", size = 2) +
  geom_line(data = . %>% filter(measure == "copy_count"), 
            aes(y = actual_value / max(actual_value, na.rm = TRUE) * max(ds_year$value[ds_year$measure == "title_count"], na.rm = TRUE)), 
            color = "#DC143C", linewidth = 1.2) +
  geom_point(data = . %>% filter(measure == "copy_count"), 
             aes(y = actual_value / max(actual_value, na.rm = TRUE) * max(ds_year$value[ds_year$measure == "title_count"], na.rm = TRUE)), 
             color = "#DC143C", size = 2) +
  scale_y_continuous(
    name = "Number of Titles",
    labels = scales::comma,
    sec.axis = sec_axis(~ . / max(ds_year$value[ds_year$measure == "title_count"], na.rm = TRUE) * 
                        max(ds_year$value[ds_year$measure == "copy_count"] * 1000, na.rm = TRUE),
                        name = "Number of Copies", 
                        labels = scales::comma)
  ) +
  labs(title = "Book Publications in Ukraine: Titles vs Copies",
       subtitle = "Note: Copy counts (red) are scaled on right axis, stored as thousands in data",
       x = "Year") +
  theme_minimal() +
  scale_x_continuous(breaks = seq(2005, 2023, 2)) +
  theme(
    axis.title.y.left = element_text(color = "#005BBB"),
    axis.title.y.right = element_text(color = "#DC143C")
  )
show_plot_window(g2)  # Opens plot in separate window

# save the plot
ggsave(
  filename = paste0(prints_folder, "book_publications_titles_vs_copies.png"),
  plot = g2, width = 10, height = 6, dpi = 300
)

# now let's facet this plot (g2) by a large unit of geography (not oblast, but larger)
# Create g2 faceted by regional groups (Північ, Південь, Схід, Захід, Центр)
g2_regional <- 
  ds_geography_enhanced %>%
  filter(measure %in% c("title_count", "copy_count")) %>%
  group_by(year, measure, region_group) %>%
  summarise(value = sum(value, na.rm = TRUE), .groups = "drop") %>%
  mutate(
    # Convert copy_count from thousands to actual numbers
    actual_value = case_when(
      measure == "copy_count" ~ value * 1000,  # Convert from thousands to actual copies
      TRUE ~ value
    )
  ) %>%
  # Calculate scaling factors for each region separately
  group_by(region_group) %>%
  mutate(
    title_max = max(actual_value[measure == "title_count"], na.rm = TRUE),
    copy_max = max(actual_value[measure == "copy_count"], na.rm = TRUE),
    # Scale copy values to fit with title scale for dual axis
    scaled_copy = case_when(
      measure == "copy_count" ~ actual_value / copy_max * title_max,
      TRUE ~ actual_value
    )
  ) %>%
  ungroup() %>%
  ggplot(aes(x = year)) +
  geom_line(data = . %>% filter(measure == "title_count"), 
            aes(y = scaled_copy), color = "#005BBB", linewidth = 1.0) +
  geom_point(data = . %>% filter(measure == "title_count"), 
             aes(y = scaled_copy), color = "#005BBB", size = 1.5) +
  geom_line(data = . %>% filter(measure == "copy_count"), 
            aes(y = scaled_copy), color = "#DC143C", linewidth = 1.0) +
  geom_point(data = . %>% filter(measure == "copy_count"), 
             aes(y = scaled_copy), color = "#DC143C", size = 1.5) +
  facet_wrap(~ region_group, scales = "free_y", ncol = 3) +
  labs(title = "Book Publications by Region: Titles vs Copies",
       subtitle = "Blue = Number of Titles, Red = Number of Copies (scaled independently per region)\nNote: Copy counts stored as thousands in data",
       x = "Year",
       y = "Scaled Values") +
  theme_minimal() +
  scale_x_continuous(breaks = seq(2005, 2023, 4)) +
  theme(
    strip.text = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )
show_plot_window(g2_regional, width = 12, height = 8)  # Opens plot in separate window with custom size

# save the plot
ggsave(
  filename = paste0(prints_folder, "book_publications_by_region_faceted.png"),
  plot = g2_regional, width = 12, height = 8, dpi = 300
)

# -------- Sasha -------------------------------------------------  
# How many numbers of titles were published for one bookstore across the places in Ukraine?
g3 <- 
  ds_geography %>%
  filter(measure == "title_count") %>%
  group_by(year, geography) %>%
  summarise(total_titles = sum(value, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(x = year, y = total_titles)) +
  geom_line(linewidth = 1.2, color = "#005BBB") +
  geom_point(size = 2, color = "#005BBB") +
  labs(title = "Book Publications by Geography",
       x = "Year", y = "Number of Titles") +
  theme_minimal() +
  scale_x_continuous(breaks = seq(2005, 2023, 1)) +
  scale_y_continuous(labels = scales::comma) +
  facet_wrap(~ geography, scales = "free_y")

print(g3)  # Print the plot to console

# Pause to keep plot windows open
readline("Press [Enter] to exit and close all plot windows...")
