


library(tidyr)
library(dplyr)
library(ggplot2)
library(tidyverse)

fact_book_publications <- read.csv("data-private/derived/manipulation/CSV/fact_book_publications.csv")

# ds_year_wide: year x measure (wide)
ds_year_wide <- fact_book_publications %>%
  rename(measure = measure_type) %>%
  group_by(year, measure) %>%
  summarise(value = sum(value, na.rm = TRUE), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = measure, values_from = value)

# ds_pubtype_wide: year x pubtype (wide by purpose)
ds_pubtype_wide <- fact_book_publications %>%
  filter(category_type == "purpose") %>%
  rename(measure = measure_type) %>%
  group_by(year, pubtype = category_value, measure) %>%
  summarise(value = sum(value, na.rm = TRUE), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = pubtype, values_from = value)

# ds_language_wide: year x language (wide by language)
ds_language_wide <- fact_book_publications %>%
  filter(category_type == "language") %>%
  rename(measure = measure_type) %>%
  group_by(year, language = category_value, measure) %>%
  summarise(value = sum(value, na.rm = TRUE), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = language, values_from = value)

# ds_genre_wide: year x genre (wide by theme)
ds_genre_wide <- fact_book_publications %>%
  filter(category_type == "theme") %>%
  rename(measure = measure_type) %>%
  group_by(year, genre = category_value, measure) %>%
  summarise(value = sum(value, na.rm = TRUE), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = genre, values_from = value)

# ds_geography_wide: year x territory (wide by territory)
ds_geography_wide <- fact_book_publications %>%
  filter(category_type == "territory") %>%
  rename(measure = measure_type) %>%
  group_by(year, territory = category_value, measure) %>%
  summarise(value = sum(value, na.rm = TRUE), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = territory, values_from = value)

# ----------------------------------------- DS_YEAR -------------------------------------------------------------
# in this table we can observe the number of titles and the number of copies for each year from 2005
ds1 <-  ds_year_wide 

years_all <- seq(min(ds1$year), max(ds1$year))

g_year_copy <- ds1 %>% 
  ggplot(aes(x = year, y = copy_count)) +
  geom_point() +
  geom_line() +
  scale_x_continuous(breaks = years_all) +             # Show all yearsS
  scale_y_continuous(breaks = seq(0, 80000, by = 10000), limits = c(0, 80000)) +  # Tick every 15,000
  labs(
    title = "Number of Copies by Year"
    , x = "The year"
    , y = "Number of copies (ths.)"
  )+
  theme_minimal() +
  theme(panel.grid.minor = element_blank()) 

g_year_title <- ds1 %>% 
  ggplot(aes(x = year, y = title_count)) +
  geom_point() +
  geom_line() +
  scale_x_continuous(breaks = years_all) +
  scale_y_continuous(breaks = seq(0, 27500, by = 5000), limits = c(7500, 27500)) +
  theme_minimal() +
  labs(
    title = "Number of Titles by Year"
    , x = "The year"
    , y = "Number of titles"
  ) +
  theme(panel.grid.minor = element_blank()) 

rm(ds1, years_all)
# ----------------------------------------- DS_GENRE -------------------------------------------------------------
 
ds2 <- ds_genre_wide

ds_genre_copy <- 
  ds2 %>% 
  filter(
    measure == "copy_count"
  ) %>% 
  pivot_longer(
    cols = -c(year, measure),  # adding genre column
    names_to = "genre",
    values_to = "value"
  )


g_genre_copy<- ds_genre_copy %>%
  ggplot(aes(x = genre, y = value, fill = genre)) +
  geom_col() +
  facet_wrap(~ year, ncol = 4) +
  scale_y_continuous(breaks = seq(0, 30000, by = 7500), limits = c(0, 37000)) +
  labs(
    title = "Number of Copies by Genre and Year",
    x = "Genre",
    y = "Number of Copies (ths.)",
    fill = "Genre"
  ) +
  theme_get() +
  theme(
    axis.text.x = element_blank(),      
    axis.title.x = element_blank()      
  )

ds_genre_title <- 
  ds2 %>% 
  filter(
    measure == "title_count"
  ) %>% 
  pivot_longer(
    cols = -c(year, measure),  # adding genre column
    names_to = "genre",
    values_to = "value"
  )

g_genre_title <- ds_genre_title %>%
  ggplot(aes(x = genre, y = value, fill = genre)) +
  geom_col() +
  facet_wrap(~ year, ncol = 4) +
  labs(
    title = "Number of Titles by Genre and Year",
    x = "Genre",
    y = "Number of Titles",
    fill = "Genre"
  ) +
  theme_get() +
  theme(
    axis.text.x = element_blank(),      
    axis.title.x = element_blank()      
  )

rm( ds2)
# ----------------------------------------- DS_GEOGRAPHY -------------------------------------------------------------
ds3 <- ds_geography_wide

region_groups <- list(
  "Західна Україна" = c("Львівська", "Івано-Франківська", "Закарпатська", "Тернопільська", "Чернівецька", "Волинська", "Рівненська"),
  "Центральна Україна" = c("Київська", "Житомирська", "Черкаська", "Кіровоградська", "Полтавська", "Вінницька"),
  "Південна Україна" = c("Одеська", "Миколаївська", "Херсонська", "Запорізька"),
  "Східна Україна" = c("Харківська", "Донецька", "Луганська", "Дніпропетровська"),
  "Північна Україна" = c("Чернігівська", "Сумська")
  , "Крим" = "Автономна Республіка Крим"
)

region_group_df <- tibble::tibble(
  region_name = unlist(region_groups),
  group = rep(names(region_groups), times = sapply(region_groups, length))
)

g_geography <- ds3  %>%
  pivot_longer(
    cols = -c(year, measure),    
    names_to = "region_name",
    values_to = "value"
  )  %>%
  left_join(region_group_df, by = "region_name") %>%
  select(year, measure, region_name, group, everything())

g_geography_central_copies <- g_geography %>%
  filter(measure == "copy_count", group == "Центральна Україна") %>%
  complete(year, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ year, ncol = 4) +
  scale_y_continuous(breaks = seq(0, 750, by = 250)) +      # без limits!
  coord_cartesian(ylim = c(0, 750)) +                       # обрізає тільки картинку!
  labs(
    title = "Number of Copies by Region (Central Ukraine) and Year",
    x = "Region",
    y = "Number of Copies",
    fill = "Region"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),
    axis.title.x = element_blank()
  )
g_geography_zahidna_copies <- g_geography %>%
  filter(measure == "copy_count", group == "Західна Україна") %>%
  complete(year, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ year, ncol = 4) +
  scale_y_continuous(breaks = seq(0, 1250, by = 500)) +      # без limits!
  coord_cartesian(ylim = c(0, 1250)) +                       # обрізає тільки картинку!
  labs(
    title = "Number of Copies by Region (Zahinda Ukraine) and Year",
    x = "Region",
    y = "Number of Copies",
    fill = "Region"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),
    axis.title.x = element_blank()
  )
g_geography_shidna_copies <- g_geography %>%
  filter(measure == "copy_count", group == "Східна Україна") %>%
  complete(year, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ year, ncol = 4) +
  scale_y_continuous(breaks = seq(0, 3500, by = 1000)) +      # без limits!
  coord_cartesian(ylim = c(0, 3500)) +                       # обрізає тільки картинку!
  labs(
    title = "Number of Copies by Region (Shidna Ukraine) and Year",
    x = "Region",
    y = "Number of Copies",
    fill = "Region"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),
    axis.title.x = element_blank()
  )
g_geography_pivdena_copies <- g_geography %>%
  filter(measure == "copy_count", group == "Південна Україна") %>%
  complete(year, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ year, ncol = 4) +
  scale_y_continuous(breaks = seq(0, 500, by = 250)) +      # без limits!
  coord_cartesian(ylim = c(0, 500)) +                       # обрізає тільки картинку!
  labs(
    title = "Number of Copies by Region (Pivdenna Ukraine) and Year",
    x = "Region",
    y = "Number of Copies",
    fill = "Region"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),
    axis.title.x = element_blank()
  )
g_geography_pivnichna_copies <- g_geography %>%
  filter(measure == "copy_count", group == "Північна Україна") %>%
  complete(year, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ year, ncol = 4) +
  scale_y_continuous(breaks = seq(0, 500, by = 250)) +      # без limits!
  coord_cartesian(ylim = c(0, 500)) +                       # обрізає тільки картинку!
  labs(
    title = "Number of Copies by Region (Pivnichna Ukraine) and Year",
    x = "Region",
    y = "Number of Copies",
    fill = "Region"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),
    axis.title.x = element_blank()
  )

g_geography_krym_copies <- 
  g_geography %>% 
  filter(
    measure == "copy_count"
    , group == "Крим"
  ) %>% 
  ggplot(aes(x = year, y = value)) +
  geom_point() +
  geom_line() +
  labs(
    title = "Number of Copies by Region (Krym) and Year",
    x = "Region",
    y = "Number of Copies",
  ) +
  scale_y_continuous(breaks = seq(0, 1500, by = 250), limits = c(0, 1500)) +  
  scale_x_continuous(breaks = c(2005:2024)) +
  theme_minimal()+
  theme(panel.grid.minor = element_blank()) 

#g_geography_central_copies
#g_geography_zahidna_copies
#g_geography_shidna_copies
#g_geography_pivdena_copies
#g_geography_pivnichna_copies

g_geography_central_title <- g_geography %>%
  filter(measure == "title_count", group == "Центральна Україна") %>%
  complete(year, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ year, ncol = 4) +
  scale_y_continuous(breaks = seq(0, 750, by = 250)) +      # без limits!
  coord_cartesian(ylim = c(0, 750)) +                       # обрізає тільки картинку!
  labs(
    title = "Number of Titles by Region (Central Ukraine) and Year",
    x = "Region",
    y = "Number of Titles",
    fill = "Region"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),
    axis.title.x = element_blank()
  )
g_geography_zahidna_title <- g_geography %>%
  filter(measure == "title_count", group == "Західна Україна") %>%
  complete(year, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ year, ncol = 4) +
  scale_y_continuous(breaks = seq(0, 1250, by = 500)) +      # без limits!
  coord_cartesian(ylim = c(0, 1250)) +                       # обрізає тільки картинку!
  labs(
    title = "Number of Titles by Region (Zahinda Ukraine) and Year",
    x = "Region",
    y = "Number of Titles",
    fill = "Region"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),
    axis.title.x = element_blank()
  )
g_geography_shidna_title <- g_geography %>%
  filter(measure == "title_count", group == "Східна Україна") %>%
  complete(year, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ year, ncol = 4) +
  scale_y_continuous(breaks = seq(0, 4000, by = 1000)) +      # без limits!
  coord_cartesian(ylim = c(0, 4000)) +                       # обрізає тільки картинку!
  labs(
    title = "Number of Titles by Region (Shidna Ukraine) and Year",
    x = "Region",
    y = "Number of Titles",
    fill = "Region"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),
    axis.title.x = element_blank()
  )
g_geography_pivdena_title<- g_geography %>%
  filter(measure == "title_count", group == "Південна Україна") %>%
  complete(year, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ year, ncol = 4) +
  scale_y_continuous(breaks = seq(0, 750, by = 250)) +      # без limits!
  coord_cartesian(ylim = c(0, 750)) +                       # обрізає тільки картинку!
  labs(
    title = "Number of Titles by Region (Pivdenna Ukraine) and Year",
    x = "Region",
    y = "Number of Titles",
    fill = "Region"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),
    axis.title.x = element_blank()
  )
g_geography_pivnichna_title <- g_geography %>%
  filter(measure == "title_count", group == "Північна Україна") %>%
  complete(year, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ year, ncol = 4) +
  scale_y_continuous(breaks = seq(0, 750, by = 250)) +      # без limits!
  coord_cartesian(ylim = c(0, 750)) +                       # обрізає тільки картинку!
  labs(
    title = "Number of Titles by Region (Pivnichna Ukraine) and Year",
    x = "Region",
    y = "Number of Titles",
    fill = "Region"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),
    axis.title.x = element_blank()
  )

g_geography_krym_title <- 
  g_geography %>% 
  filter(
    measure == "title_count"
    , group == "Крим"
  ) %>% 
  ggplot(aes(x = year, y = value)) +
  geom_point() +
  geom_line() +
  labs(
    title = "Number of Titles by Region (Krym) and Year",
    x = "Region",
    y = "Number of Titles",
  ) +
  scale_y_continuous(breaks = seq(0, 1000, by = 250), limits = c(0, 1000)) +  
  scale_x_continuous(breaks = c(2005:2024)) +
  theme_minimal()+
  theme(panel.grid.minor = element_blank()) 

#g_geography_central_title
#g_geography_zahidna_title
#g_geography_shidna_title
#g_geography_pivdena_title
#g_geography_pivnichna_title

# ----------------------------------------- DS_LANGUAGE -------------------------------------------------------------

g_lanugae <- ds_language_wide

g_language <- g_lanugae %>%
  pivot_longer(
    cols = -c(year, measure),     
    names_to = "language",
    values_to = "value"
  )

g_language_2018 <- 
  g_language %>% 
  filter(
    year == 2018
    ,  (measure == "copy_count" & value > 10) | (measure == "title_count" & value > 10)
  ) %>%  mutate(
    measure = recode(measure,
                     copy_count = "Copies",         # new label
                     title_count = "Titles")        # new label
  ) %>%
  ggplot(aes(x = language, y = value, fill = measure)) +
  geom_col(position = "dodge") +
  scale_y_continuous(breaks = seq(0, 40000, by = 5000), limits = c(0, 40000)) +  
  labs(
    title = "Number of Copies and Titles (2018)",
    x = "Language",
    y = "Count",
    fill = "Measure"
  ) +
  theme_minimal()

g_language_2019 <- 
  g_language %>% 
  filter(
    year == 2019
    ,  (measure == "copy_count" & value > 10) | (measure == "title_count" & value > 10)
  ) %>%  mutate(
    measure = recode(measure,
                     copy_count = "Copies",         # new label
                     title_count = "Titles")        # new label
  ) %>%
  ggplot(aes(x = language, y = value, fill = measure)) +
  geom_col(position = "dodge") +
  scale_y_continuous(breaks = seq(0, 55000, by = 10000), limits = c(0, 55000)) +  
  labs(
    title = "Number of Copies and Titles (2019)",
    x = "Language",
    y = "Count",
    fill = "Measure"
  ) +
  theme_minimal()

g_language_2020 <- 
  g_language %>% 
  filter(
    year == 2020
    ,  (measure == "copy_count" & value > 10) | (measure == "title_count" & value > 10)
  ) %>%  mutate(
    measure = recode(measure,
                     copy_count = "Copies",         # new label
                     title_count = "Titles")        # new label
  ) %>%
  ggplot(aes(x = language, y = value, fill = measure)) +
  geom_col(position = "dodge") +
  scale_y_continuous(breaks = seq(0, 40000, by = 5000), limits = c(0, 40000)) +  
  labs(
    title = "Number of Copies and Titles (2020)",
    x = "Language",
    y = "Count",
    fill = "Measure"
  ) +
  theme_minimal()

g_language_2021 <- 
  g_language %>% 
  filter(
    year == 2021
    ,  (measure == "copy_count" & value > 10) | (measure == "title_count" & value > 10)
  ) %>%  mutate(
    measure = recode(measure,
                     copy_count = "Copies",         # new label
                     title_count = "Titles")        # new label
  ) %>%
  ggplot(aes(x = language, y = value, fill = measure)) +
  geom_col(position = "dodge") +
  scale_y_continuous(breaks = seq(0, 40000, by = 5000), limits = c(0, 40000)) +  
  labs(
    title = "Number of Copies and Titles (2021)",
    x = "Language",
    y = "Count",
    fill = "Measure"
  ) +
  theme_minimal()

g_language_2022 <- 
  g_language %>% 
  filter(
    year == 2022
    ,  (measure == "copy_count" & value > 10) | (measure == "title_count" & value > 10)
  ) %>%  mutate(
    measure = recode(measure,
                     copy_count = "Copies",         # new label
                     title_count = "Titles")        # new label
  ) %>%
  ggplot(aes(x = language, y = value, fill = measure)) +
  geom_col(position = "dodge") +
  scale_y_continuous(breaks = seq(0, 15000, by = 5000), limits = c(0, 15000)) +  
  labs(
    title = "Number of Copies and Titles (2022)",
    x = "Language",
    y = "Count",
    fill = "Measure"
  ) +
  theme_minimal()

g_language_2023 <- 
  g_language %>% 
  filter(
    year == 2023
    ,  (measure == "copy_count" & value > 10) | (measure == "title_count" & value > 10)
  ) %>%  mutate(
    measure = recode(measure,
                     copy_count = "Copies",         # new label
                     title_count = "Titles")        # new label
  ) %>%
  ggplot(aes(x = language, y = value, fill = measure)) +
  geom_col(position = "dodge") +
  scale_y_continuous(breaks = seq(0, 25000, by = 5000), limits = c(0, 25000)) +  
  labs(
    title = "Number of Copies and Titles (2023)",
    x = "Language",
    y = "Count",
    fill = "Measure"
  ) +
  theme_minimal()

g_language_2024 <- 
  g_language %>% 
  filter(
    year == 2024
    ,  (measure == "copy_count" & value > 10) | (measure == "title_count" & value > 10)
  ) %>%  mutate(
    measure = recode(measure,
                     copy_count = "Copies",         # new label
                     title_count = "Titles")        # new label
  ) %>%
  ggplot(aes(x = language, y = value, fill = measure)) +
  geom_col(position = "dodge") +
  scale_y_continuous(breaks = seq(0, 35000, by = 5000), limits = c(0, 35000)) +  
  labs(
    title = "Number of Copies and Titles (2024)",
    x = "Language",
    y = "Count",
    fill = "Measure"
  ) +
  theme_minimal()

# ----------------------------------------- DS_PUBTYPE -------------------------------------------------------------

ds5 <- ds_pubtype_wide


ds_pubtype_l <- ds5 %>%
  pivot_longer(
    cols = -c(year, measure),    # залишаємо 'year' і 'measure', інше — типи видань
    names_to = "pubtype",      # назва нової колонки з типом
    values_to = "value"        # значення
  )


ds_pubtype_copy <- 
  ds_pubtype_l %>%
  filter(measure == "copy_count")

g_pubtype_copy <- ds_pubtype_copy %>%
  ggplot(aes(x = pubtype, y = value, fill = pubtype)) +
  geom_col() +
  facet_wrap(~ year, ncol = 4) +
  scale_y_continuous(breaks = seq(0, 30000, by = 7500), limits = c(0, 37000)) +
  coord_cartesian(ylim = c(0, 37000)) +
  labs(
    title = "Number of Copies by Publication Type and Year",
    x = "Publication Type",
    y = "Number of Copies (ths.)",
    fill = "Publication Type"
  ) +
  theme_get() +
  theme(
    axis.text.x = element_blank(),
    axis.title.x = element_blank()
  )


ds_pubtype_title <- 
  ds_pubtype_l %>%
  filter(measure == "title_count")

g_pubtype_title <- ds_pubtype_title %>%
  ggplot(aes(x = pubtype, y = value, fill = pubtype)) +
  geom_col() +
  facet_wrap(~ year, ncol = 4) +
  labs(
    title = "Number of Titles by Publication Type and Year",
    x = "Publication Type",
    y = "Number of Titles",
    fill = "Publication Type"
  ) +
  theme_get() +
  theme(
    axis.text.x = element_blank(),
    axis.title.x = element_blank()
  )

