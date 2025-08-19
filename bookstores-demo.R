# Bookstores Data Integration Demo
# This script demonstrates how to work with the newly integrated bookstores data

library(dplyr)
library(ggplot2)

# Load helper functions for config-driven database connections
source("scripts/common-functions.R")

cat("📚 BOOKSTORES DATA INTEGRATION DEMO\n")
cat("====================================\n\n")

# Connect to the final analytical database
db <- connect_books_db("main")

cat("🔗 Connected to main analytical database\n\n")

# 1. Show available tables
tables <- DBI::dbListTables(db)
bookstore_tables <- tables[grepl("bookstores", tables)]
cat("📊 Bookstores tables available:\n")
for (table in bookstore_tables) {
  cat("   -", table, "\n")
}

# 2. Explore bookstores data structure
cat("\n📈 Bookstores Data Summary:\n")
summary_data <- DBI::dbGetQuery(db, "
  SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT category_value) as regions_count,
    SUM(value) as total_bookstores,
    MAX(value) as max_bookstores,
    MIN(value) as min_bookstores
  FROM ds_bookstores_long
")
print(summary_data)

# 3. Top regions by bookstore count
cat("\n🏆 Top 10 Regions by Bookstore Count (2023):\n")
top_regions <- DBI::dbGetQuery(db, "
  SELECT 
    category_value as region,
    value as bookstores
  FROM ds_bookstores_long 
  ORDER BY value DESC 
  LIMIT 10
")
print(top_regions)

# 4. Compare with book publishing data
cat("\n📖 Correlation with Book Publishing:\n")
# Get 2022 territory data (closest to 2023 bookstores data)
publishing_2022 <- DBI::dbGetQuery(db, "
  SELECT 
    category_value as region,
    SUM(value) as total_publications_2022
  FROM ds_territory_long 
  WHERE year = 2022 AND measure_type = 'title_count'
  GROUP BY category_value
")

# Join with bookstores data
comparison <- DBI::dbGetQuery(db, "
  SELECT 
    b.category_value as region,
    b.value as bookstores_2023,
    p.total_publications as publications_2022
  FROM ds_bookstores_long b
  LEFT JOIN (
    SELECT 
      category_value,
      SUM(value) as total_publications 
    FROM ds_territory_long 
    WHERE year = 2022 AND measure_type = 'title_count'
    GROUP BY category_value
  ) p ON b.category_value = p.category_value
  ORDER BY b.value DESC
  LIMIT 8
")

cat("📊 Bookstores vs Publishing Activity:\n")
print(comparison)

# 5. Wide format demo
cat("\n📋 Bookstores Wide Format (useful for analysis):\n")
wide_sample <- DBI::dbGetQuery(db, "SELECT * FROM ds_bookstores_wide LIMIT 1")
cat("   Structure: 1 row with", ncol(wide_sample), "columns (year, measure_type + all regions)\n")
cat("   Year:", wide_sample$year, "\n")
cat("   Measure:", wide_sample$measure_type, "\n")
cat("   Sample regions: Київ =", wide_sample$Київ, ", Львівська =", wide_sample$Львівська, "\n")

# Close connection
DBI::dbDisconnect(db)
cat("\n✅ Demo complete! Bookstores data is now fully integrated into the pipeline.\n")
cat("\n💡 Next Steps:\n")
cat("   - Use ds_bookstores_long for detailed analysis\n")
cat("   - Use ds_bookstores_wide for statistical modeling\n") 
cat("   - Correlate with publishing data using territory dimensions\n")
cat("   - Create visualizations using analysis scripts\n")
