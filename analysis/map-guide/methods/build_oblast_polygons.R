# Helper: build oblast polygons from hromada geojson
suppressPackageStartupMessages({
  library(sf)
  library(dplyr)
  library(janitor)
})

# Input and output paths
in_geojson <- file.path("analysis", 'map-guide', "data", "terhromad_fin.geojson")
out_rds <- file.path("analysis", 'map-guide', "data", "ua_oblast_polygons.rds")
out_geojson <- file.path("analysis", 'map-guide',"data", "ua_oblast_polygons.geojson")

hromadas <- st_read(in_geojson, quiet = TRUE) %>% clean_names()
## Repair invalid geometries before grouping
hromadas <- hromadas %>%
  mutate(geometry = sf::st_make_valid(geometry))

oblasts <- hromadas %>%
  group_by(admin_1) %>%
  summarise(geometry = sf::st_union(geometry), .groups = "drop") %>%
  rename(oblast_name_en = admin_1)

saveRDS(oblasts, out_rds)
message("Saved RDS: ", out_rds)

# Also write a GeoJSON for direct use in JS/Leaflet or other tools
sf::st_write(oblasts, out_geojson, delete_dsn = TRUE, quiet = TRUE)
message("Saved GeoJSON: ", out_geojson)
