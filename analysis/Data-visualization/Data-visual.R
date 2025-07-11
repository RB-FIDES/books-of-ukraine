# Introduction to the project books-of-ukraine
# in this folder I want to do a review to the given tables 
library(dplyr)
library(ggplot2)

# ----------------------------------------- DS_YEAR -------------------------------------------------------------
# in this table we can observe the number of titles and the number of copies for each year from 2005
ds1 <- readRDS("data-private/derived/manipulation/ds_year.rds")

years_all <- seq(min(ds1$yr), max(ds1$yr))

g_year_copy <- ds1 %>% 
  filter(measure == "copy_count") %>% 
  ggplot(aes(x = yr, y = value)) +
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
  filter(
    measure == "title_count"
  ) %>% 
  ggplot(aes(x = yr, y = value)) +
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
 
ds2 <- readRDS("data-private/derived/manipulation/ds_genre.rds")

ds_genre_copy <- 
  ds2 %>% 
  filter(
    measure == "copy_count"
  ) %>% 
  group_by(yr)  %>%
  pivot_longer(
    cols = -c(yr, measure),  # adding genre column
    names_to = "genre",
    values_to = "value"
  )


g_genre_copy<- ds_genre_copy %>%
  ggplot(aes(x = genre, y = value, fill = genre)) +
  geom_col() +
  facet_wrap(~ yr, ncol = 4) +
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
  group_by(yr) %>%
  pivot_longer(
    cols = -c(yr, measure),  # adding genre column
    names_to = "genre",
    values_to = "value"
  )

g_genre_title <- ds_genre_title %>%
  ggplot(aes(x = genre, y = value, fill = genre)) +
  geom_col() +
  facet_wrap(~ yr, ncol = 4) +
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

rm( ds2_long)
# ----------------------------------------- DS_GEOGRAPHY -------------------------------------------------------------
ds3 <- readRDS("data-private/derived/manipulation/ds_geography.rds")

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
    cols = -c(yr, measure),    
    names_to = "region_name",
    values_to = "value"
  )  %>%
  left_join(region_group_df, by = "region_name") %>%
  select(yr, measure, region_name, group, everything())

g_geography_central_copies <- g_geography %>%
  filter(measure == "copy_count", group == "Центральна Україна") %>%
  complete(yr, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ yr, ncol = 4) +
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
  complete(yr, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ yr, ncol = 4) +
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
  complete(yr, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ yr, ncol = 4) +
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
  complete(yr, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ yr, ncol = 4) +
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
  complete(yr, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ yr, ncol = 4) +
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
  ggplot(aes(x = yr, y = value)) +
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
  complete(yr, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ yr, ncol = 4) +
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
  complete(yr, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ yr, ncol = 4) +
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
  complete(yr, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ yr, ncol = 4) +
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
  complete(yr, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ yr, ncol = 4) +
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
  complete(yr, region_name, fill = list(value = 0)) %>%
  ggplot(aes(x = region_name, y = value, fill = region_name)) +
  geom_col() +
  facet_wrap(~ yr, ncol = 4) +
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
  ggplot(aes(x = yr, y = value)) +
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

g_lanugae <- readRDS("data-private/derived/manipulation/ds_language.rds")

g_language <- g_lanugae %>%
  pivot_longer(
    cols = -c(yr, measure),     
    names_to = "language",
    values_to = "value"
  )

g_language_2018 <- 
  g_language %>% 
  filter(
    , yr == 2018
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
    , yr == 2019
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
    , yr == 2020
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
    , yr == 2021
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
    , yr == 2022
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
    , yr == 2023
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
    , yr == 2024
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

ds5 <- readRDS("data-private/derived/manipulation/ds_pubtype.rds") 


ds_pubtype_l <- ds_pubtype %>%
  pivot_longer(
    cols = -c(yr, measure),    # залишаємо 'yr' і 'measure', інше — типи видань
    names_to = "pubtype",      # назва нової колонки з типом
    values_to = "value"        # значення
  )


ds_pubtype_copy <- 
  ds_pubtype_l %>%
  filter(measure == "copy_count") %>%
  group_by(yr)

g_pubtype_copy <- ds_pubtype_copy %>%
  ggplot(aes(x = pubtype, y = value, fill = pubtype)) +
  geom_col() +
  facet_wrap(~ yr, ncol = 4) +
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
  ds5 %>%
  filter(measure == "title_count") %>%
  group_by(yr)

g_pubtype_title <- ds_pubtype_title %>%
  ggplot(aes(x = pubtype, y = value, fill = pubtype)) +
  geom_col() +
  facet_wrap(~ yr, ncol = 4) +
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


# ----------------------------------------- DS_UKR_RUS -------------------------------------------------------------

ds6 <- readRDS("data-private/derived/manipulation/ds_ukr_rus.rds")

g_ukrrus_copies <- 
  ds_ukr_rus %>%
  filter(measure == "copy_count") %>%
  select(yr, ukr, rus) %>%
  pivot_longer(
    cols = c(ukr, rus),
    names_to = "language",
    values_to = "value"
  ) %>% 
ggplot( aes(x = factor(yr), y = value, fill = language)) +
  geom_col(position = "dodge") +
  scale_x_discrete(expand = expansion(mult = c(0))) +
  labs(
    title = "Number of Copies: Ukrainian vs Russian by Year",
    x = "Year",
    y = "Number of Copies (ths.)",
    fill = "Language"
  ) +
  theme_minimal()

g_ukrrus_title <- 
  ds6 %>%
  filter(measure == "title_count") %>%
  select(yr, ukr, rus) %>%
  pivot_longer(
    cols = c(ukr, rus),
    names_to = "language",
    values_to = "value"
  ) %>% 
ggplot( aes(x = factor(yr), y = value, fill = language)) +
  geom_col(position = "dodge") +
  scale_x_discrete(expand = expansion(mult = c(0))) +
  scale_y_continuous(breaks = seq(0, 20000, by = 5000), limits = c(0, 20000)) +
  labs(
    title = "Number of Titles: Ukrainian vs Russian by Year",
    x = "Year",
    y = "Number of Titles",
    fill = "Language"
  ) +
  theme_minimal()
