# Helper: join oblast-level values to polygons
suppressPackageStartupMessages({
  library(sf)
  library(dplyr)
  library(readr)
})

polygons_rds <- file.path("analysis", 'map-guide', "data", "ua_oblast_polygons.rds")
values_csv <- file.path("analysis", 'map-guide',"data", "example_oblast_values.csv")


ua_to_en <- c(
  "Івано-Франківська область" = "Ivano-Frankivsk",
  "Автономна Республіка Крим" = "Crimea",
  "Волинська область" = "Volyn",
  "Вінницька область" = "Vinnytsia",
  "Дніпропетровська область" = "Dnipropetrovska",
  "Донецька область" = "Donetsk",
  "Житомирська область" = "Zhytomyr",
  "Закарпатська область" = "Zakarpattia",
  "Запорізька область" = "Zaporizhzhia",
  "Київська область" = "Kyiv",
  "Кіровоградська область" = "Kirovohrad",
  "Луганська область" = "Luhansk",
  "Львівська область" = "Lviv",
  "Миколаївська область" = "Mykolaiv",
  "Одеська область" = "Odesa",
  "Полтавська область" = "Poltava",
  "Рівненська область" = "Rivne",
  "Сумська область" = "Sumy",
  "Тернопільська область" = "Ternopil",
  "Харківська область" = "Kharkiv",
  "Херсонська область" = "Kherson",
  "Хмельницька область" = "Khmelnytskyi",
  "Черкаська область" = "Cherkasy",
  "Чернівецька область" = "Chernivtsi",
  "Чернігівська область" = "Chernihiv"
)

oblasts <- readRDS(polygons_rds)
# Rename admin_1 to English using ua_to_en mapping
oblasts$oblast_name_en <- ua_to_en
# Optionally, remove oblast_name_en if it exists to avoid confusion
oblasts$id <- seq_len(nrow(oblasts))
print(oblasts, n = nrow(oblasts))


values <- read_csv(values_csv, show_col_types = FALSE)
print(values, n = nrow(values))

map_data <- left_join(oblasts, values, by = "oblast_name_en")

map_data %>% print(n = nrow(.)) # Print the joined data for verification
