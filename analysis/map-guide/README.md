# Oblast Map Guide for Books of Ukraine

This guide distills mapping practices from the ua-de-center project and provides everything needed to make oblast-level maps for publishing data.

## What’s included
- Reusable methods (tmap and leaflet) with minimal examples
- A small data bundle with oblast polygons built from hromada geojson
- Helper scripts to aggregate data to oblast level and join to polygons
- Recommendations for choosing a method in Books of Ukraine

## Quick start
1) Ensure R packages: sf, tmap, leaflet, tidyverse, janitor, readr
2) Run methods/tmap/oblast_choropleth.R for a static/interactive choropleth
3) Run methods/leaflet/oblast_leaflet.R for an interactive leaflet map

## Data sources used here
- Hromada polygons: terhromad_fin.geojson (from ua-de-center/maps)
- Oblast polygons: built by grouping hromada polygons by admin_1

## Choosing an approach
- tmap: Best for static figures in Quarto/knitr and quick faceted outputs
- leaflet: Best for interactive exploration, dashboards, and Shiny

## Notes
- Name harmonization: oblast_name_en must match between your data and polygons
- For Books of Ukraine, join your oblast-level dataset on oblast_name_en or code
