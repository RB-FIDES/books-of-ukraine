library(DBI)
library(RSQLite)
library(dplyr)

# Connect to database
db <- dbConnect(RSQLite::SQLite(), "data-private/derived/manipulation/SQLite/books-of-ukraine-long.sqlite")

# Test query 1: Time series analysis
cat("=== TIME SERIES ANALYSIS ===\n")
time_series <- dbGetQuery(db, "
  SELECT year, SUM(value) as total_titles
  FROM fact_book_publications
  WHERE measure_type = 'title_count'
  GROUP BY year
  ORDER BY year
")
print(head(time_series, 10))

# Test query 2: Language distribution
cat("\n=== LANGUAGE DISTRIBUTION ===\n")
lang_dist <- dbGetQuery(db, "
  SELECT category_value as language, SUM(value) as total_titles
  FROM fact_book_publications
  WHERE category_type = 'language' AND measure_type = 'title_count'
  GROUP BY category_value
  ORDER BY total_titles DESC
  LIMIT 10
")
print(lang_dist)

# Test query 3: Territory analysis
cat("\n=== TOP TERRITORIES ===\n")
territory_dist <- dbGetQuery(db, "
  SELECT category_value as territory, SUM(value) as total_titles
  FROM fact_book_publications
  WHERE category_type = 'territory' AND measure_type = 'title_count'
  GROUP BY category_value
  ORDER BY total_titles DESC
  LIMIT 10
")
print(territory_dist)

# Test joins with dimension tables
cat("\n=== DECADE ANALYSIS ===\n")
decade_analysis <- dbGetQuery(db, "
  SELECT d.decade, SUM(f.value) as total_titles
  FROM fact_book_publications f
  JOIN dim_years d ON f.year = d.year
  WHERE f.measure_type = 'title_count'
  GROUP BY d.decade
  ORDER BY d.decade
")
print(decade_analysis)

dbDisconnect(db)
cat("\n✅ All queries executed successfully!\n")
