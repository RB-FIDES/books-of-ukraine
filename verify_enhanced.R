library(DBI)
library(RSQLite)
library(dplyr)

# Connect to enhanced database
db <- dbConnect(RSQLite::SQLite(), "data-private/derived/manipulation/SQLite/books-of-ukraine-enhanced.sqlite")

cat("Enhanced Database Tables:\n")
tables <- dbListTables(db)
for(table in sort(tables)) {
  count <- dbGetQuery(db, paste("SELECT COUNT(*) as count FROM", table))[["count"]]
  cat("  ", table, ":", format(count, big.mark=","), "records\n")
}

cat("\nQuick test queries:\n")
cat("Core vs Enhanced comparison:\n")
core_count <- dbGetQuery(db, "SELECT COUNT(*) as count FROM fact_book_publications")[["count"]]
enhanced_count <- dbGetQuery(db, "SELECT COUNT(*) as count FROM fact_enhanced")[["count"]]
cat("  Core fact table:", format(core_count, big.mark=","), "records\n")
cat("  Enhanced fact table:", format(enhanced_count, big.mark=","), "records\n")

cat("\nGeographic territories available:\n")
territories <- dbGetQuery(db, "
  SELECT DISTINCT category_value 
  FROM fact_enhanced 
  WHERE category_type = 'territory' 
  ORDER BY category_value 
  LIMIT 10
")
for(i in 1:nrow(territories)) {
  cat("  ", territories[i,1], "\n")
}

cat("\nExtension table sample:\n")
ext_sample <- dbGetQuery(db, "
  SELECT year, category_value, value 
  FROM ext_geography_publications 
  WHERE year = 2023 
  ORDER BY value DESC 
  LIMIT 5
")
print(ext_sample)

dbDisconnect(db)
cat("\n✅ Enhanced database verification complete!\n")
