# Helper: join oblast-level values to polygons
suppressPackageStartupMessages({
  library(sf)
  library(dplyr)
  library(readr)
})

polygons_rds <- file.path("..", "data", "ua_oblast_polygons.rds")
values_csv <- file.path("..", "data", "example_oblast_values.csv")

oblasts <- readRDS(polygons_rds)
values <- read_csv(values_csv, show_col_types = FALSE)

map_data <- left_join(oblasts, values, by = "oblast_name_en")

print(map_data)
