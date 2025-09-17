# Minimal oblast map with leaflet
suppressPackageStartupMessages({
  library(tidyverse)
  library(sf)
  library(leaflet)
  library(readr)
  library(janitor)
})

geojson_path <- file.path("analysis", "map-guide", "data", "terhromad_fin.geojson")
example_data_path <- file.path("analysis", "map-guide", "data", "example_oblast_values.csv")

hromadas <- st_read(geojson_path, quiet = TRUE) %>% clean_names()
oblasts <- hromadas %>%
  group_by(admin_1) %>%
  summarise(geometry = sf::st_union(geometry), .groups = "drop") %>%
  rename(oblast_name_en = admin_1)

if (file.exists(example_data_path)) {
  values <- read_csv(example_data_path, show_col_types = FALSE)
} else {
  values <- tibble(
    oblast_name_en = unique(oblasts$oblast_name_en),
    value = runif(n = dplyr::n_distinct(oblasts$oblast_name_en), 0, 100)
  )
}

map_data <- left_join(oblasts, values, by = "oblast_name_en")

pal <- colorNumeric("magma", domain = map_data$value)

leaflet(map_data) %>%
  addTiles() %>%
  addPolygons(
    fillColor = ~pal(value),
    color = "#444444", weight = 0.6, opacity = 1,
    fillOpacity = 0.7,
    label = ~paste0(oblast_name_en, ": ", round(value,1))
  ) %>%
  addLegend(pal = pal, values = ~value, title = "Value")
