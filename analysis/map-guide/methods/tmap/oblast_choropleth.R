# Minimal oblast choropleth with tmap
suppressPackageStartupMessages({
  library(tidyverse)
  library(sf)
  library(tmap)
  library(readr)
  library(janitor)
})

# Paths within map-guide
geojson_path <- file.path("analysis", "map-guide", "data", "terhromad_fin.geojson")
# Example data placeholder: expects a CSV with columns: oblast_name_en, value
example_data_path <- file.path("analysis", "map-guide", "data", "example_oblast_values.csv")

# Load polygons (hromada geometries) and build oblast polygons
hromadas <- st_read(geojson_path, quiet = TRUE) %>% clean_names()
# admin_1 holds oblast English names in KSE data
oblasts <- hromadas %>%
  group_by(admin_1) %>%
  summarise(geometry = sf::st_union(geometry), .groups = "drop") %>%
  rename(oblast_name_en = admin_1)

# Load example oblast values or create dummy data
if (file.exists(example_data_path)) {
  values <- read_csv(example_data_path, show_col_types = FALSE)
} else {
  values <- tibble(
    oblast_name_en = unique(oblasts$oblast_name_en),
    value = runif(n = dplyr::n_distinct(oblasts$oblast_name_en), 0, 100)
  )
}

map_data <- left_join(oblasts, values, by = "oblast_name_en")

# Plot: static
tmap_mode("plot")
g_static <- tm_shape(map_data) +
  tm_polygons("value", palette = "viridis", title = "Value") +
  tm_borders("grey40", lwd = 0.6)
print(g_static)

# Plot: interactive
tmap_mode("view")
print(g_static)
