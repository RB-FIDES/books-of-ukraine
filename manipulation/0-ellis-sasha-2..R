# To rub this document, you need to connect your profile to Google account, first:
# Use this command to connect your profile to Google account:
# library(googlesheets4) - run it in console first
# gs4_auth() - then run this, and connect account
# ------------------------------------- Important to run ------------------------------------- 
# If you run this scipts first, you can rub chunks below in order you want
## ------- Preparation -------
rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
cat("\014") # Clear the console 
# verify root location
cat("Working directory: ", getwd()) # Must be set to Project Directory
# Project Directory should be the root by default unless overwritten
## ------- Creating a Function -------

import_selected_sheets <- function(sheet_url, sheets_to_import, clean_names = TRUE) {
  
  # Get sheet information
  sheet_info <- googlesheets4::gs4_get(sheet_url)
  all_sheet_names <- sheet_info$sheets$name
  
  cat("Доступні вкладки (sheets):\n")
  cat(paste(all_sheet_names, collapse = ", "), "\n")
  
  # Check which sheets to import
  valid_sheets <- sheets_to_import[sheets_to_import %in% all_sheet_names]
  
  if (length(valid_sheets) == 0) {
    stop("Жодної з вказаних вкладок не знайдено у Google Sheets.")
  }
  
  cat("\nБуде імпортовано", length(valid_sheets), "вкладок:\n")
  cat(paste(valid_sheets, collapse = ", "), "\n")
  
  # Import selected sheets and combine into a data frame
  all_tables <- list()
  
  for (sheet_name in valid_sheets) {
    cat("Завантажуємо вкладку:", sheet_name, "\n")
    
    # Import the sheet
    sheet_data <- googlesheets4::read_sheet(
      ss = sheet_url,
      sheet = sheet_name,
      .name_repair = "minimal"
    )
    
    # Clean column names if requested
    if (clean_names) {
      sheet_data <- janitor::clean_names(sheet_data)
    }
    
    # Store in list
    all_tables[[sheet_name]] <- sheet_data
    
    cat("  - Розмір:", nrow(sheet_data), "рядків x", ncol(sheet_data), "колонок\n")
  }
  
  # Combine all sheets into a single data frame (no sheet_name column)
  combined_table <- dplyr::bind_rows(all_tables, .id = NULL)
  
  return(combined_table)
}
## -------Load libraries-------
library(magrittr)
library(ggplot2)   # graphs
library(forcats)   # factors
library(stringr)   # strings
library(lubridate) # dates
library(labelled)  # labels
library(dplyr)     # data wrangling
library(tidyr)     # data wrangling
library(scales)    # format
library(broom)     # for model
library(emmeans)   # for interpreting model results
library(ggalluvial)
library(janitor)
library(openxlsx)
library(DBI)      # For database connection and operations
library(RSQLite)
library(ggrepel)  # for text labels in ggplot2
## --- Creating folders for data manipulation ----
data_private_derived <- "./data-private/derived/manipulation/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)} # nolint

data_private_derived_sqlite <- "./data-private/derived/manipulation/SQLite/"
if (!fs::dir_exists(data_private_derived_sqlite)) {fs::dir_create(data_private_derived_sqlite)}

data_private_derived_csv <- "./data-private/derived/manipulation/CSV/"
if (!fs::dir_exists(data_private_derived_csv)) {fs::dir_create(data_private_derived_csv)}

books_of_ukraine <- dbConnect(RSQLite::SQLite(), "data-private/derived/manipulation/SQLite/books-of-ukraine.sqlite")

# ------------------------------- DS_YEAR --------------------------------
## ------ Data import ------
df_raw <- import_selected_sheets(
  sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
  sheets_to_import = "К-ть видань"
)
## ------ Data cleaning ------
df_raw_clean <- df_raw %>%
  mutate(across(-1, ~ as.character(.)))

ds_year <- df_raw_clean %>%
  pivot_longer(
    cols = -1,
    names_to = "yr",
    values_to = "value_raw"
  ) %>%
  mutate(
    yr = as.integer(str_remove(yr, "^x")),
    value_clean = str_remove_all(value_raw, " "),
    value = as.numeric(value_clean)
  ) %>%
  group_by(yr) %>%
  mutate(
    measure = case_when(
      row_number() == 1 ~ "copy_count",
      row_number() == 2 ~ "title_count",
      TRUE ~ NA_character_
    )
  ) %>%
  ungroup() %>%
  select(yr, measure, value) %>%
  arrange(yr, measure) %>% 
  mutate(
    measure = case_when(
      measure == "copy_count" ~ "title_count",
      measure == "title_count" ~ "copy_count",
      TRUE ~ measure
    )
  )
## ------- rm() cleaning -------
rm(df_raw, df_raw_clean)

## -------- RDS saving  --------
saveRDS(ds_year, "data-private/derived/manipulation/ds_year.rds")

## ------- SQLite saving -------
dbWriteTable(books_of_ukraine, "ds_year", ds_year, overwrite = TRUE)

## ------ CSV saving ------
write.csv(ds_year, "data-private/derived/manipulation/csv/ds_year.csv", row.names = FALSE)
## ------- Sheet Saving -------
sheet_url <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854"
sheet_write(ds_year, ss = sheet_url, sheet = "ds_year")


# ------------------------------- DS_LANGUAGE ----------------------------------------------------------------------------------------------------------------------
## ------ Data import ------
ds <- import_selected_sheets(
  sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
  sheets_to_import = "мови народу світу"
)
## ------ Data cleaning ------
cols_number <- grep("^x\\d{4}$", names(ds), value = TRUE)     
cols_circulation <- grep("^x_\\d+$", names(ds), value = TRUE) 

ds$mova <- as.character(ds$x)  

long_number <- ds %>%
  select(mova, all_of(cols_number)) %>%
  pivot_longer(
    cols = -mova,
    names_to = "yr",
    names_prefix = "x",
    values_to = "value"
  ) %>%
  mutate(measure = "title_count")

long_circulation <- ds %>%
  select(mova, all_of(cols_circulation)) %>%
  pivot_longer(
    cols = -mova,
    names_to = "temp",
    names_prefix = "x_",
    values_to = "value"
  ) %>%
  mutate(
    measure = "copy_count",
    yr = as.character(as.numeric(temp) + 2016)  
  ) %>%
  select(-temp)

long_all <- bind_rows(long_number, long_circulation)

ds_language <- long_all %>%
  pivot_wider(
    names_from = mova,
    values_from = value
  ) %>%
  arrange(yr, measure)
## ------- rm() cleaning -------
rm(df_raw, df_raw_clean, ds, long_number, long_circulation, long_all)
## -------- RDS saving  -------- 
saveRDS(ds_language, "data-private/derived/manipulation/ds_language.rds")
## ------- SQLite saving -------
dbWriteTable(books_of_ukraine, "ds_language", ds_language, overwrite = TRUE)
## ------ CSV saving ------
write.csv(ds_language, "data-private/derived/manipulation/csv/ds_language.csv", row.names = FALSE)
## ------- Sheet Saving -------
sheet_url <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854"
sheet_write(ds_language, ss = sheet_url, sheet = "ds_language")

# ------------------------------- DS_GENRE---------------------------------------------------------------------------------------------------------------------
## ------ Data import_naclad------
df3 <- import_selected_sheets(
    sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
    sheets_to_import = "Наклад тематич."
)
## ------ Data cleaning_naclad ------
df3 <- df3 %>%
  mutate(x2010 = as.numeric(gsub("\\s+", "", as.character(x2010))))
df3$x2010[10] <- 1045.6
genre_col <- names(df3)[1]

df3_fixed <- df3 %>%
  mutate(across(-all_of(genre_col), ~ as.numeric(as.character(.))))

df3_long <- df3_fixed %>%
  pivot_longer(
    cols = -all_of(genre_col),
    names_to = "yr",
    values_to = "copy_count"
  ) %>%
  mutate(
    yr = as.integer(str_remove(yr, "^x"))
  )

ds_genre_naclad <- df3_long %>%
  pivot_wider(
    names_from = !!genre_col,
    values_from = "copy_count"
  ) %>%
  mutate(measure = "copy_count") %>%
  relocate(yr, measure)

ds_genre_naclad
print(names(ds_genre_naclad))
ds_genre_naclad <- ds_genre_naclad %>%
rename("Друк у цілому. Книгознавство. Преса. Поліграфія" = "Друк у цілому. Книгознавство. Преса. Поліграфія")
## ------- data-import_number of titles -------
df <- import_selected_sheets(
    sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
    sheets_to_import = "Тематичні розділи"
)
## ------ Data cleaning_number of titles ------
years <- as.character(unlist(df[1, -1]))
new_names <- c("genre", years)


df_fixed <- df[-1, ]
colnames(df_fixed) <- new_names


df_fixed <- df_fixed %>%
  mutate(across(-genre, as.character))


df_long <- df_fixed %>%
  mutate(genre = as.character(genre)) %>%
  pivot_longer(
    cols = -genre,
    names_to = "yr",
    values_to = "value_raw"
  )


df_long <- df_long %>%
  mutate(
    yr = as.integer(yr),
    value = as.numeric(str_remove_all(value_raw, " ")),
    measure = "title_count"
  )


ds_genre_num <- df_long %>%
  select(yr, measure, genre, value) %>%
  pivot_wider(
    names_from = genre,
    values_from = value
  ) %>%
  arrange(yr)


ds_genre_num <- ds_genre_num %>%
  rename_with(~str_replace_all(., "\\n", " "))
## ------- Data-import_number of titles for 2005-06 -------
df <- import_selected_sheets(
    sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
    sheets_to_import = "Тематичні розділи 05-06"
) %>% clean_names()
## ------ Data cleaning_number of titles for 2005-06 ------
years <- as.character(unlist(df[1, -1]))
new_names <- c("genre", years)


df_fixed <- df[-1, ]
colnames(df_fixed) <- new_names


df_fixed <- df_fixed %>%
  mutate(across(-genre, as.character))


df_long <- df_fixed %>%
  mutate(genre = as.character(genre)) %>%
  pivot_longer(
    cols = -genre,
    names_to = "yr",
    values_to = "value_raw"
  ) %>%
  mutate(
    yr = as.integer(str_extract(yr, "\\d{4}")),  # Витягуємо саме 2005/2006
    value = as.numeric(str_remove_all(value_raw, " ")),
    measure = "title_count"
  )


ds_genre_0506 <- df_long %>%
  select(yr, measure, genre, value) %>%
  pivot_wider(
    names_from = genre,
    values_from = value
  ) %>%
  arrange(yr)

ds_genre_num_2 <- ds_genre_0506 %>%
  mutate(yr = c(2005, 2006))
glimpse(ds_genre_num_2)

ds_genre_num_0506_filtered <- ds_genre_num_2 %>%
  select(
    "yr",
    "measure",
    "Політична і соціально-економічна\nлітература, у т.ч:",
    "Природничо-наукова література, у т.ч.:",
    "Технічна література, у т.ч.:",
    "Сільськогосподарська література, у т.ч.:",
    "Охорона здоров’я. Медична література",
    "Література з фізичної культури і спорту",
    "Література з освіти та культура, у т.ч.:",
    "Друк у цілому. Книгознавство. Преса. \nПоліграфія, у т.ч.:",
    "Мистецтво. Мистецтвознавство, у т.ч.:",
    "Література по філологічним наукам, у т.ч.:",
    "Художня література, у т.ч.:",
    "Дитяча література, у т.ч.:",
    "Література універсального змісту"
  )

names(ds_genre_num_0506_filtered) <- names(ds_genre_num_0506_filtered) %>%
  str_replace_all("\\n", " ") %>%
  str_squish() %>%
  str_replace_all("  +", " ")

print(names(ds_genre_num_0506_filtered))

ds_genre_num_0506_filtered_1 <- ds_genre_num_0506_filtered %>%
  rename(
    "Політична і соціально-економічна література" = "Політична і соціально-економічна література, у т.ч:",
    "Друк у цілому. Книгознавство. Преса. Поліграфія" = "Друк у цілому. Книгознавство. Преса. Поліграфія, у т.ч.:",
    "Природничо-наукова література" = "Природничо-наукова література, у т.ч.:" 
    , "Технічна література" = "Технічна література, у т.ч.:" 
    , "Сільськогосподарська література" = "Сільськогосподарська література, у т.ч.:"
    , "Охорона здоров'я. Медична література" = "Охорона здоров’я. Медична література"
    , "Література з фізичної культури і спорту" = "Література з фізичної культури і спорту"
    , "Література з освіти і культури" = "Література з освіти та культура, у т.ч.:"
    , "Друк у цілому. Книгознавство. Преса Поліграфія" = "Друк у цілому. Книгознавство. Преса. Поліграфія, у т.ч.:"
    , "Мистецтво. Мистецтвознавство" = "Мистецтво. Мистецтвознавство, у т.ч.:"
    , "Література з філологічних наук" = "Література по філологічним наукам, у т.ч.:"
    , "Художня література. Фольклор" = "Художня література, у т.ч.:"
    , "Дитяча література" = "Дитяча література, у т.ч.:"
    , "Література універсального змісту" = "Література універсального змісту"
  )
## ------- Data manipulation -------
ds_0506 <- ds_genre_num_0506_filtered_1 %>% filter(yr %in% c(2005, 2006))

ds_genre_num_no_0506 <- ds_genre_num %>% filter(!yr %in% c(2005, 2006))

ds_genre_number <- bind_rows(ds_genre_num_no_0506, ds_0506) %>% arrange(yr)
ds_genre_number <- ds_genre_number %>%
  rename("Друк у цілому. Книгознавство. Преса. Поліграфія" = "Друк у цілому. Книгознавство. Преса Поліграфія")
## -------- Creating ds_genre --------
long_naclad <- ds_genre_naclad %>%
  pivot_longer(
    cols = -c(yr, measure),
    names_to = "genre",
    values_to = "value"
  )

long_number <- ds_genre_number %>%
  pivot_longer(
    cols = -c(yr, measure),
    names_to = "genre",
    values_to = "value"
  )


combined_long <- bind_rows(long_naclad, long_number)


ds_genre <- combined_long %>%
  pivot_wider(
    id_cols = c(yr, measure),
    names_from = genre,
    values_from = value
  ) %>%
  arrange(yr, measure)
## ------- rm() cleaning -------
rm(long_naclad, long_number, combined_long, combined_wide, ds_genre_number, ds_genre_naclad, df, df_fixed, df_long, df3, df3_fixed, df3_long, ds_0506, df_genre_0506, ds_genre_num, ds_genre_num_0506_filtered, ds_genre_num_0506_filtered_1, ds_genre_num_no_0506, ds_genre_num_2, ds_genre_0506)
## -------- RDS saving  --------
saveRDS(ds_genre, "data-private/derived/manipulation/ds_genre.rds")
## ------- SQLite saving -------
dbWriteTable(books_of_ukraine, "ds_genre", ds_genre, overwrite = TRUE)
## ------ CSV saving ------
write.csv(ds_genre, "data-private/derived/manipulation/csv/ds_genre.csv", row.names = FALSE)
## ------- Sheet Saving -------
sheet_url <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854"
sheet_write(ds_genre, ss = sheet_url, sheet = "ds_genre")

# ------------------------------- DS_PUBTYPE -------------------------------------------------------------------------------------------------------------
## ------ Data import ------
df <- import_selected_sheets(
    sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
    sheets_to_import = "Аркуш15"
)
## ------ Data cleaning ------
df_cir <- df %>%
  mutate(measure = "copy_count") %>%
  relocate(measure, .after = 1)  %>% 
  rename(yr = x)
df_cir <- df_cir %>% 
  rename(
    "Наукові видання" = "naukovi_vidanna"
    , "Науково-популярні видання для дорослих" = "naukovo_popularni_vidanna_dla_doroslih"
    , "Нормативні та виробничо-практичні видання" = "normativni_ta_virobnico_prakticni_vidanna"
    , "Офіційні видання" = "oficijni_vidanna"
    , "Громадсько-політичні видання" = "gromads_ko_politicni_vidanna"
    , "Навчальні та методичні видання" = "navcal_ni_ta_metodicni_vidanna"
    , "Літературно-художні видання для дорослих" = "literaturno_hudozni_vidanna_dla_doroslih"
    , "Видання для дітей та юнацтва" = "vidanna_dla_ditej_ta_unactva"
    , "Довідкові видання" = "dovidkovi_vidanna"
    , "Інформаційні видання" = "informacijni_vidanna"
    , "Бібліографічні видання" = "bibliograficni_vidanna"
    , "Видання для організації дозвілля" = "vidanna_dla_organizacii_dozvilla"
    , "Рекламні видання" = "reklamni_vidanna"
    , "Література релігійного змісту" = "literatura_religijnogo_zmistu"
  )

df_num <- import_selected_sheets(
    sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
    sheets_to_import = "Цільові призначення"
) %>%
    slice(-1) %>%
    mutate(measure = "title_count") %>%
    relocate(measure, .after = 1)

year_cols <- grep("^x\\d{4}$", names(df_num), value = TRUE)


df_num <- df_num %>%
  mutate(across(all_of(year_cols), ~as.numeric(gsub("\\s+", "", as.character(.)))))

df_long <- df_num %>%
  pivot_longer(
    cols = -c(x, measure),   
    names_to = "yr",
    names_prefix = "x",
    values_to = "value"
  ) %>%
  select(x, measure, yr, value) %>%
  mutate(yr = as.integer(yr))


df_number  <- df_long %>%
  select(yr, measure, x, value) %>%
  pivot_wider(
    names_from = x, 
    values_from = value
  ) %>%
  arrange(yr) %>%
  relocate(measure, .after = yr)

common_cols <- intersect(names(df_cir), names(df_number))
df_cir <- df_cir %>% select(all_of(common_cols))
df_number <- df_number %>% select(all_of(common_cols))
ds_pubtype <- bind_rows(df_cir, df_number) %>% arrange(yr, measure)

## ------- rm() cleaning -------
rm(df_number, df_cir, common_cols, df_long, df_num, year_cols, df)
## -------- RDS saving  --------
saveRDS(ds_pubtype, "data-private/derived/manipulation/ds_pubtype.rds")
## ------- SQLite saving -------
dbWriteTable(books_of_ukraine, "ds_pubtype", ds_pubtype, overwrite = TRUE)
## ------ CSV saving ------
write.csv(ds_pubtype, "data-private/derived/manipulation/csv/ds_pubtype.csv", row.names = FALSE)
## ------- Sheet Saving -------
sheet_url <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854"
sheet_write(ds_pubtype, ss = sheet_url, sheet = "ds_pubtype")

# ------------------------------- DS_AREA --------------------------------
## ------ Data import ------
ds <- import_selected_sheets(
    sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
    sheets_to_import = "території"
)
## ------ Data cleaning ------
df <- ds %>%
    slice(-1)

year_cols <- grep("^x\\d{4}$", names(df), value = TRUE)

df <- df %>%
  mutate(across(x2007:x2010, ~as.numeric(gsub("\\s+", "", as.character(.))))) %>% 
  slice(-27:-37) 


df_long <- df %>%
  pivot_longer(
    cols = -x,           # pivot all columns except 'x'
    names_to = "yr",
    names_prefix = "x",
    values_to = "value"
  ) %>%
  mutate(
    yr = as.integer(yr),
    measure = "title_count"
  )

ds_area_num <- df_long %>%
  select(yr, measure, x, value) %>%
  pivot_wider(
    names_from = x,
    values_from = value
  ) %>%
  arrange(yr) %>%
  relocate(measure, .after = yr)

terir_naklad <- import_selected_sheets(
    sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
    sheets_to_import = "Терир. наклад"
) %>%
    select(-x2025:-x2027)

terir_naklad_long <- terir_naklad %>%
  pivot_longer(
    cols = -x,              # all columns except "x" (area)
    names_to = "yr",
    names_prefix = "x",
    values_to = "value"
  ) %>%
  mutate(yr = as.integer(yr))

ds_area_cir <- terir_naklad_long %>%
  select(yr, x, value) %>%
  pivot_wider(
    names_from = x,
    values_from = value
  ) %>%
  arrange(yr) %>% mutate(measure = "copy_count") %>%
  relocate(measure, .after = yr)

  ds_geography <- bind_rows(ds_area_num, ds_area_cir) %>%
  arrange(yr, measure)
## ------- rm() cleaning -------
rm(ds_area_cir, terir_naklad_long, ds_area_num, df_long, df, year_cols, ds_area_num,ds, terir_naklad)
## -------- RDS saving  --------
saveRDS(ds_geography, "data-private/derived/manipulation/ds_geography.rds")
## ------- SQLite saving -------
dbWriteTable(books_of_ukraine, "ds_geography", ds_geography, overwrite = TRUE)
## ------ CSV saving ------
write.csv(ds_geography, "data-private/derived/manipulation/csv/ds_geography.csv", row.names = FALSE)
  ## ------- Sheet Saving -------
  sheet_url <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854"
  sheet_write(ds_area, ss = sheet_url, sheet = "ds_area")
  
# ------------------------------- DS_UKR_RUS --------------------------------
## ------ Data import ------
df <- import_selected_sheets(
    sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
    sheets_to_import = "Мови"
)
## ------ Data cleaning ------
df <- df  %>% 
  slice(-c(3,6,7)) %>%
  mutate(
    measure = case_when(
      x %in% c("ukr", "rus") ~ "title_count",
      x %in% c("накл. укр.", "накл. рус.") ~ "copy_count",
      TRUE ~ NA_character_
    )
  ) %>%
  relocate(measure, .after = 1) %>% 
  rename(yr = x)

df_long <- import_selected_sheets(
    sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
    sheets_to_import = "Мови"
) %>%
  slice(-c(3,6,7)) %>%
  pivot_longer(
    cols = -x,           # this is the important fix!
    names_to = "yr",
    names_prefix = "x",
    values_to = "value"
  )


df_long <- df_long %>%
  mutate(
    measure = case_when(
      x %in% c("ukr", "rus") ~ "title_count",
      x %in% c("накл. укр.", "накл. рус.") ~ "copy_count",
      TRUE ~ NA_character_
    ),
    lang = case_when(
      x %in% c("ukr", "накл. укр.") ~ "ukr",
      x %in% c("rus", "накл. рус.") ~ "rus",
      TRUE ~ NA_character_
    )
  )

df_wide <- df_long %>%
  filter(!is.na(measure)) %>%
  select(yr, measure, lang, value) %>%
  pivot_wider(
    names_from = lang,
    values_from = value
  ) %>%
  arrange(yr, measure)

  df_perc <- df_wide %>%
  filter(measure == "copy_count") %>%
  mutate(
    ukr = as.numeric(ukr),
    rus = as.numeric(rus),
    sum_ = ukr + rus,
    ukr = if_else(sum_ > 0, round(100 * ukr / sum_, 2), NA_real_),
    rus = if_else(sum_ > 0, round(100 * rus / sum_, 2), NA_real_),
    measure = "Percen_ukr"
  ) %>%
  select(-sum_)

ds_ukr_rus <- bind_rows(df_wide, df_perc) %>%
  arrange(yr, measure)

ds_ukr_rus <- df_wide %>%
  filter(measure %in% c("title_count", "copy_count")) %>%
  mutate(
    ukr = as.numeric(ukr),
    rus = as.numeric(rus),
    perc_ukr = if_else(
      ukr + rus > 0,
      round(100 * ukr / (ukr + rus), 2),
      NA_real_
    ),
    perc_rus = if_else(
      ukr + rus > 0,
      round(100 * rus / (ukr + rus), 2),
      NA_real_
    )
  )

## ------- rm() cleaning -------
rm(df_perc, df_wide, df_long, df)
## -------- RDS saving  --------
saveRDS(ds_ukr_rus, "data-private/derived/manipulation/ds_ukr_rus.rds")
## ------- SQLite saving -------
dbWriteTable(books_of_ukraine, "ds_ukr_rus", ds_ukr_rus, overwrite = TRUE)
## ------ CSV saving ------
write.csv(ds_ukr_rus, "data-private/derived/manipulation/csv/ds_ukr_rus.csv", row.names = FALSE)
## ------- Sheet Saving -------
sheet_url <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854"
sheet_write(ds_ukr_rus, ss = sheet_url, sheet = "ds_ukr_rus")

# ------------------------------- DS_GEOGRAPHY_LOOKER --------------------------------

## ------ Data import ------
ds <- import_selected_sheets(
  sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
  sheets_to_import = "території"
)

## ------ Data cleaning ------
df <- ds %>%
  slice(-1)

year_cols <- grep("^x\\d{4}$", names(df), value = TRUE)

df <- df %>%
  mutate(across(x2007:x2010, ~as.numeric(gsub("\\s+", "", as.character(.))))) %>% 
  slice(-27:-37) 

df_long <- df %>%
  pivot_longer(
    cols = -x,           # pivot all columns except 'x'
    names_to = "yr",
    names_prefix = "x",
    values_to = "value"
  ) %>%
  mutate(
    yr = as.integer(yr),
    measure = "title_count"
  )

ds_area_num <- df_long %>%
  select(yr, measure, geography = x, value) %>%
  arrange(yr) %>%
  relocate(measure, .after = yr)

terir_naklad <- import_selected_sheets(
  sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
  sheets_to_import = "Терир. наклад"
) %>%
  select(-x2025:-x2027)

terir_naklad_long <- terir_naklad %>%
  pivot_longer(
    cols = -x,              # all columns except "x" (area)
    names_to = "yr",
    names_prefix = "x",
    values_to = "value"
  ) %>%
  mutate(yr = as.integer(yr))

ds_area_cir <- terir_naklad_long %>%
  select(yr, geography = x, value) %>%
  arrange(yr) %>%
  mutate(measure = "copy_count") %>%
  relocate(measure, .after = yr)

ds_geography_looker <- bind_rows(ds_area_num, ds_area_cir) %>%
  arrange(yr, measure) %>%
  select(yr, measure, geography, value) %>%
  rename(values = value)

## ------- rm() cleaning -------
rm(ds_area_cir, terir_naklad_long, ds_area_num, df_long, df, year_cols, ds, terir_naklad)

## -------- RDS saving  --------
saveRDS(ds_geography_looker, "data-private/derived/manipulation/ds_geography_looker.rds")
## ------- SQLite saving -------
books_of_ukraine <- dbConnect(RSQLite::SQLite(), "data-private/derived/manipulation/SQLite/books-of-ukraine.sqlite")
dbWriteTable(books_of_ukraine, "ds_geography_looker", ds_geography_looker, overwrite = TRUE)
dbDisconnect(books_of_ukraine)
## ------ CSV saving ------
write.csv(ds_geography_looker, "data-private/derived/manipulation/csv/ds_geography_looker.csv", row.names = FALSE)
## ------ SHEETS Saving ----- 
sheet_url <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854"

# Remove everything after the /edit in the URL:
sheet_url <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854"

# Add or replace the sheet ('ds_geography_looker'):
sheet_write(ds_geography_looker, ss = sheet_url, sheet = "ds_geography_looker")
# ---------------------------------------------------------------------- End of Script -------------------
dbDisconnect(books_of_ukraine)
