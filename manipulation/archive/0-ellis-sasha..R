rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
cat("\014") # Clear the console
# verify root location
cat("Working directory: ", getwd()) # Must be set to Project Directory
# Project Directory should be the root by default unless overwritten

# ---- load-packages -----------------------------------------------------------
# Choose to be greedy: load only what's needed
# Three ways, from least (1) to most(3) greedy:
# -- 1.Attach these packages so their functions don't need to be qualified: 
# http://r-pkgs.had.co.nz/namespace.html#search-path
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
library(googlesheets4)
# -- 2.Import only certain functions of a package into the search path.
# import::from("magrittr", "%>%")
# -- 3. Verify these packages are available on the machine, but their functions need to be qualified
requireNamespace("readr"    )# data import/export
requireNamespace("readxl"   )# data import/export
requireNamespace("janitor"  )# tidy data
requireNamespace("testit"   )# For asserting conditions meet expected patterns.
requireNamespace("googlesheets4") # for Google Sheets import

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
base::source("./scripts/operational-functions.R") # project-level

# ---- declare-globals ---------------------------------------------------------

local_root <- "./manipulation/"
local_data <- paste0(local_root, "data-local/") # for local outputs

if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

data_private_derived <- "./data-private/derived/manipulation/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

prints_folder <- paste0(local_root, "prints/")
if (!fs::dir_exists(prints_folder)) {fs::dir_create(prints_folder)}


# ---- declare-functions -------------------------------------------------------

#' Import all sheets from Google Spreadsheet
#' 
#' This function imports all available sheets (tabs) from a Google Spreadsheet
#' and returns them as a named list of data frames
#'
#' @param sheet_url Character string with Google Sheets URL
#' @param clean_names Logical, whether to clean column names using janitor
#' @return Named list of data frames, one for each sheet
import_all_sheets <- function(sheet_url, clean_names = TRUE) {
  
  # Get sheet information
  sheet_info <- googlesheets4::gs4_get(sheet_url)
  sheet_names <- sheet_info$sheets$name
  
  cat("Знайдено", length(sheet_names), "вкладок (sheets):\n")
  cat(paste(sheet_names, collapse = ", "), "\n")
  
  # Import each sheet
  all_sheets <- list()
  
  for (sheet_name in sheet_names) {
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
    
    # Store in list with sheet name as key
    all_sheets[[sheet_name]] <- sheet_data
    
    cat("  - Розмір:", nrow(sheet_data), "рядків x", ncol(sheet_data), "колонок\n")
  }
  
  return(all_sheets)
}

# ----- define-query -----------------------------------------------------------

# ---- load-data ---------------------------------------------------------------
# a google spreadsheet with multiple tabs stores the main input of the project
# https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?usp=sharing

# URL Google Spreadsheet
main_spreadsheet_url <- "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?usp=sharing"

# Authenticate with Google Sheets (якщо потрібно)
# googlesheets4::gs4_auth() # Розкоментуйте якщо потрібна автентифікація

# For public sheets, disable authentication
googlesheets4::gs4_deauth()

cat("Починаємо завантаження даних з Google Spreadsheet...\n")

# Import all sheets from the main spreadsheet
all_data <- import_all_sheets(
  sheet_url = main_spreadsheet_url,
  clean_names = TRUE
)

# Display summary of imported data
cat("\n=== ПІДСУМОК ЗАВАНТАЖЕННЯ ===\n")
cat("Загалом завантажено", length(all_data), "таблиць:\n")

for (sheet_name in names(all_data)) {
  df <- all_data[[sheet_name]]
  cat(sprintf("  • %s: %d рядків × %d колонок\n", 
              sheet_name, nrow(df), ncol(df)))
  
  # Show first few column names
  col_preview <- head(names(df), 5)
  if (ncol(df) > 5) {
    col_preview <- c(col_preview, "...")
  }
  cat(sprintf("    Колонки: %s\n", paste(col_preview, collapse = ", ")))
}

# Create individual data frames for easier access
# Automatically assign each sheet to a variable based on its name
for (sheet_name in names(all_data)) {
  # Create a valid R variable name from sheet name
  var_name <- janitor::make_clean_names(sheet_name)
  assign(var_name, all_data[[sheet_name]])
  cat("Створено змінну:", var_name, "\n")
}





# ---- write-to-disk -------------------------

# Save all imported data to local files for faster access in future runs
cat("\nЗбереження даних на диск...\n")

# Save the complete list of all sheets
saveRDS(
  object = all_data,
  file = paste0(data_private_derived, "all_sheets_raw.rds")
)
cat("Збережено повний список таблиць у:", paste0(data_private_derived, "all_sheets_raw.rds\n"))

# Save each sheet as individual RDS file
for (sheet_name in names(all_data)) {
  file_name <- paste0(janitor::make_clean_names(sheet_name), ".rds")
  file_path <- paste0(data_private_derived, file_name)
  
  saveRDS(
    object = all_data[[sheet_name]],
    file = file_path
  )
  cat("Збережено:", sheet_name, "→", file_path, "\n")
}

# Optional: Save as CSV files for external access
csv_folder <- paste0(data_private_derived, "csv/")
if (!fs::dir_exists(csv_folder)) {fs::dir_create(csv_folder)}

for (sheet_name in names(all_data)) {
  file_name <- paste0(janitor::make_clean_names(sheet_name), ".csv")
  file_path <- paste0(csv_folder, file_name)
  
  readr::write_csv(
    x = all_data[[sheet_name]],
    file = file_path
  )
}
cat("CSV файли збережено у:", csv_folder, "\n")

cat("\n=== ЗАВЕРШЕНО ===\n")
cat("Всі дані успішно завантажено та збережено!\n")

# ----------------------------------------------------------------- DS_YEAR ----------------------------
## ------ ds_year 1 --------


df_raw <- readRDS("data-private/derived/manipulation/k_t_vidan.rds")
                
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



## ------ ds_year 2 --------
rm(df_raw, df_raw_clean)
## ------ ds_year 3 --------
rm(df_raw, df_raw_clean)
## ------ ds_year 4 --------
saveRDS(ds_year, "data-private/derived/manipulation/ds_year.rds")

# ----------------------------------------------------------------- DS_LANGUAGE ------------------------
## ------ ds_language 1 ------
ds <- readRDS("data-private/derived/manipulation/movi_narodu_svitu.rds")

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

## ------ ds_language 2 ------

rm(df_raw, df_raw_clean, ds, long_number, long_circulation, long_all)


## ------ ds_language 3 -----
saveRDS(ds_language, "data-private/derived/manipulation/ds_language.rds")

# ------------------------------------------------------------------ DS_GENRE ---------------------------
## ------- ds_genre_naclad ----

df3 <- readRDS("data-private/derived/manipulation/naklad_tematic.rds")
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

## ------- ds_genre_num ----


df <- readRDS("data-private/derived/manipulation/tematicni_rozdili.rds")


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

## ------- ds_genre_num_0506 ---- 



df <- readRDS("data-private/derived/manipulation/tematicni_rozdili_05_06.rds") %>%
  clean_names()


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

## ------- ds_genre_num_whole----


ds_0506 <- ds_genre_num_0506_filtered_1 %>% filter(yr %in% c(2005, 2006))

ds_genre_num_no_0506 <- ds_genre_num %>% filter(!yr %in% c(2005, 2006))

ds_genre_number <- bind_rows(ds_genre_num_no_0506, ds_0506) %>% arrange(yr)
ds_genre_number <- ds_genre_number %>%
  rename("Друк у цілому. Книгознавство. Преса. Поліграфія" = "Друк у цілому. Книгознавство. Преса Поліграфія")



## ------- ds_genre ----

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




## ------- ds_genre_rm -----------
rm(long_naclad, long_number, combined_long, combined_wide, ds_genre_number, ds_genre_naclad, df, df_fixed, df_long, df3, df3_fixed, df3_long, ds_0506, df_genre_0506, ds_genre_num, ds_genre_num_0506_filtered, ds_genre_num_0506_filtered_1, ds_genre_num_no_0506, ds_genre_num_2, ds_genre_0506)
## ------- save ds_genre ----------
saveRDS(ds_genre, "data-private/derived/manipulation/ds_genre.rds")

#--------------------------------------------------------------------- DS_PUBTYPE --------------------
## ----- ds_pubtype 1 -------
df <- readRDS("data-private/derived/manipulation/arkus15.rds")

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

## ----- ds_pubtype 2 -------

df_num <- cil_ovi_priznacenna %>% 
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

## ----- ds_pubtype 3 -------

common_cols <- intersect(names(df_cir), names(df_number))
df_cir <- df_cir %>% select(all_of(common_cols))
df_number <- df_number %>% select(all_of(common_cols))
ds_pubtype <- bind_rows(df_cir, df_number) %>% arrange(yr, measure)

## ----- ds_pubtype 4 ----- 

rm(df_number, df_cir, common_cols, df_long, df_num, year_cols, df)
## ----- ds_pubtype 5 ----- 
saveRDS(ds_pubtype, "data-private/derived/manipulation/ds_pubtype.rds")

# --------------------------------------------------------------------- DS_AREA -----------------------
## ----- ds_area 1 -------
df <- teritorii %>% 
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

## ----- ds_area 2 -------

terir_naklad <- terir_naklad %>% 
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

## ----- ds_area 3 -------
ds_geography <- bind_rows(ds_area_num, ds_area_cir) %>%
  arrange(yr, measure)
## ----- ds_area 4 -------
rm(ds_area_cir, terir_naklad_long, ds_area_num, df_long, df, year_cols, ds_area_num)
## ----- ds_area 5 -------
saveRDS(ds_geography, "data-private/derived/manipulation/ds_geography.rds")



# ---------------------------------------------------------------------- DS_UKR_RUS -----------------------
## ----- ds_ukr_rus 1 ------
df <- movi  %>% 
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

df_long <- movi %>%
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


## ----- ds_ukr_rus 2------

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

## ----- ds_ukr_rus 3  ------
rm(df_perc, df_wide, df_long, df)
## ----- ds_ukr_rus 4  ------
saveRDS(ds_ukr_rus, "data-private/derived/manipulation/ds_ukr_rus.rds")


# ---------------------------------------------------------------------- Converting to Spreadsheets ----------
sheet_url <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=0#gid=0"
sheet_write(ds_geography, ss = sheet_url, sheet = "ds_geography")
sheet_write(ss = sheet_url, data = ds_genre, sheet = "ds_genre")
sheet_write(ss = sheet_url, data = ds_language, sheet = "ds_language")
sheet_write(ss = sheet_url, data = ds_pubtype, sheet = "ds_pubtype")
sheet_write(ss = sheet_url, data = ds_year, sheet = "ds_year")
sheet_write(ss = sheet_url, data = ds_ukr_rus, sheet = "ds_ukr_rus")

