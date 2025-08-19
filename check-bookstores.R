# Check bookstores data integration
source('scripts/common-functions.R')
library(DBI)

# Connect to Stage 0 database
db <- connect_books_db('stage_0')

# Check if bookstores data exists
bookstores_summary <- DBI::dbGetQuery(db, "
  SELECT category_type, measure_type, COUNT(*) as record_count, 
         MIN(year) as min_year, MAX(year) as max_year
  FROM fact_book_publications 
  WHERE category_type = 'bookstores'
  GROUP BY category_type, measure_type
")

cat("📚 Bookstores Data Summary:\n")
if (nrow(bookstores_summary) > 0) {
  print(bookstores_summary)
  
  # Show some sample records
  cat("\n📄 Sample Bookstores Records:\n")
  sample_records <- DBI::dbGetQuery(db, "
    SELECT year, category_value, measure_type, value
    FROM fact_book_publications 
    WHERE category_type = 'bookstores'
    ORDER BY value DESC
    LIMIT 5
  ")
  print(sample_records)
  
} else {
  cat("⚠️  No bookstores data found in database.\n")
}

# Check all category types
cat("\n📊 All Category Types in Database:\n")
all_categories <- DBI::dbGetQuery(db, "
  SELECT category_type, COUNT(*) as count
  FROM fact_book_publications 
  GROUP BY category_type
  ORDER BY count DESC
")
print(all_categories)

DBI::dbDisconnect(db)
cat("\n✅ Database check complete!\n")
