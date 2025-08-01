# Ellis Script - Long Format Version
# This script creates CACHE tables in long format as specified in CACHE-manifest.md
# Long format schema: yr + measure + [category] + value

# To run this document, you need to connect your profile to Google account, first:
# Use this command to connect your profile to Google account:
# library(googlesheets4) - run it in console first
# gs4_auth() - then run this, and connect account
# ------------------------------------- Important to run ------------------------------------- 
# If you run this scripts first, you can run chunks below in order you want
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

# Helper function for robust numeric conversion
safe_numeric_convert <- function(x) {
  # Handle various formats and clean the data
  cleaned <- as.character(x)
  # Remove all non-numeric characters except dots, minus signs, and spaces
  cleaned <- gsub("[^0-9.\\s-]", "", cleaned)
  # Remove extra spaces
  cleaned <- gsub("\\s+", "", cleaned)
  # Replace empty strings, lone dashes, and various null representations with zero
  cleaned[cleaned == "" | cleaned == "-" | cleaned == "NULL" | 
          cleaned == "NA" | cleaned == "n/a" | is.na(cleaned)] <- "0"
  # Handle cases where we might have multiple dots
  cleaned <- gsub("\\.{2,}", ".", cleaned)
  # Convert to numeric
  result <- suppressWarnings(as.numeric(cleaned))
  # Replace any remaining NAs with 0
  result[is.na(result)] <- 0
  return(result)
}

# Safe pivot function that ensures data consistency
safe_pivot_longer <- function(data, cols, names_to = "yr", values_to = "value", names_prefix = "", ...) {
  # Ensure numeric columns are truly numeric
  if (is.character(cols) && length(cols) > 0) {
    # If cols is character vector, use them directly
    numeric_cols <- cols
  } else {
    # If cols is a selection expression, evaluate it
    numeric_cols <- names(dplyr::select(data, {{cols}}))
  }
  
  # Ensure all selected columns are numeric
  data_prepared <- data %>%
    dplyr::mutate(dplyr::across(dplyr::all_of(numeric_cols), safe_numeric_convert))
  
  # Perform the pivot
  data_prepared %>%
    tidyr::pivot_longer(
      cols = dplyr::all_of(numeric_cols),
      names_to = names_to,
      values_to = values_to,
      names_prefix = names_prefix,
      ...
    )
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
library(ggrepel)
library(googlesheets4)

## --- Creating folders for data manipulation ----
data_private_derived <- "./data-private/derived/manipulation/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)} # nolint

data_private_derived_sqlite <- "./data-private/derived/manipulation/SQLite/"
if (!fs::dir_exists(data_private_derived_sqlite)) {fs::dir_create(data_private_derived_sqlite)}

data_private_derived_csv <- "./data-private/derived/manipulation/CSV/"
if (!fs::dir_exists(data_private_derived_csv)) {fs::dir_create(data_private_derived_csv)}

books_of_ukraine <- dbConnect(RSQLite::SQLite(), "data-private/derived/manipulation/SQLite/books-of-ukraine.sqlite")

# ------------------------------- DS_YEAR_LONG --------------------------------
## ------ Data import ------
df_raw <- import_selected_sheets(
  sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
  sheets_to_import = "К-ть видань"
)

## ------ Data cleaning ------
df_raw_clean <- df_raw %>%
  mutate(across(-1, ~ as.character(.)))

ds_year_long <- df_raw_clean %>%
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
saveRDS(ds_year_long, "data-private/derived/manipulation/ds_year_long.rds")

## ------- SQLite saving -------
dbWriteTable(books_of_ukraine, "ds_year_long", ds_year_long, overwrite = TRUE)

## ------ CSV saving ------
write.csv(ds_year_long, "data-private/derived/manipulation/CSV/ds_year_long.csv", row.names = FALSE)

## ------- Sheet Saving -------
sheet_url <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854"
sheet_write(ds_year_long, ss = sheet_url, sheet = "ds_year_long")

# ------------------------------- DS_LANGUAGE_LONG --------------------------------
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

# Combine and keep in long format
ds_language_long <- bind_rows(long_number, long_circulation) %>%
  rename(language = mova) %>%
  select(yr, measure, language, value) %>%
  arrange(yr, measure, language)

## ------- rm() cleaning -------
rm(ds, long_number, long_circulation)

## -------- RDS saving  -------- 
saveRDS(ds_language_long, "data-private/derived/manipulation/ds_language_long.rds")

## ------- SQLite saving -------
dbWriteTable(books_of_ukraine, "ds_language_long", ds_language_long, overwrite = TRUE)

## ------ CSV saving ------
write.csv(ds_language_long, "data-private/derived/manipulation/CSV/ds_language_long.csv", row.names = FALSE)

## ------- Sheet Saving -------
sheet_url <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854"
sheet_write(ds_language_long, ss = sheet_url, sheet = "ds_language_long")

# ------------------------------- DS_GENRE_LONG --------------------------------
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
  mutate(across(-all_of(genre_col), safe_numeric_convert))

# Use safe pivot function
year_columns <- names(df3_fixed)[names(df3_fixed) != genre_col]

df3_long <- safe_pivot_longer(
  df3_fixed,
  cols = year_columns,
  names_to = "yr",
    values_to = "value"
  ) %>%
  mutate(
    yr = as.integer(str_remove(yr, "^x")),
    measure = "copy_count"
  ) %>%
  # Filter to keep only reasonable years (2005-2025)
  filter(yr >= 2005 & yr <= 2025) %>%
  rename(genre = !!genre_col) %>%
  select(yr, measure, genre, value)

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
  ) %>%
  # Filter to keep only reasonable years (2005-2025)
  filter(yr >= 2005 & yr <= 2025) %>%
  select(yr, measure, genre, value)

# Clean genre names
df_long <- df_long %>%
  mutate(genre = str_replace_all(genre, "\\n", " "))

## ------- Data-import_number of titles for 2005-06 -------
df_0506 <- import_selected_sheets(
    sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
    sheets_to_import = "Тематичні розділи 05-06"
) %>% clean_names()

## ------ Data cleaning_number of titles for 2005-06 ------
years <- as.character(unlist(df_0506[1, -1]))
new_names <- c("genre", years)

df_0506_fixed <- df_0506[-1, ]
colnames(df_0506_fixed) <- new_names

df_0506_fixed <- df_0506_fixed %>%
  mutate(across(-genre, as.character))

df_0506_long <- df_0506_fixed %>%
  mutate(genre = as.character(genre)) %>%
  pivot_longer(
    cols = -genre,
    names_to = "yr",
    values_to = "value_raw"
  ) %>%
  mutate(
    yr = as.integer(str_extract(yr, "\\d{4}")),  # Extract 2005/2006
    value = as.numeric(str_remove_all(value_raw, " ")),
    measure = "title_count"
  ) %>%
  # Filter to keep only reasonable years (2005-2025)
  filter(yr >= 2005 & yr <= 2025) %>%
  select(yr, measure, genre, value)

# Standardize genre names for 2005-2006 data
genre_mapping <- c(
  "Політична і соціально-економічна література, у т.ч:" = "Політична і соціально-економічна література",
  "Природничо-наукова література, у т.ч.:" = "Природничо-наукова література",
  "Технічна література, у т.ч.:" = "Технічна література",
  "Сільськогосподарська література, у т.ч.:" = "Сільськогосподарська література",
  "Охорона здоров'я. Медична література" = "Охорона здоров'я. Медична література",
  "Література з фізичної культури і спорту" = "Література з фізичної культури і спорту",
  "Література з освіти та культура, у т.ч.:" = "Література з освіти і культури",
  "Друк у цілому. Книгознавство. Преса. Поліграфія, у т.ч.:" = "Друк у цілому. Книгознавство. Преса. Поліграфія",
  "Мистецтво. Мистецтвознавство, у т.ч.:" = "Мистецтво. Мистецтвознавство",
  "Література по філологічним наукам, у т.ч.:" = "Література з філологічних наук",
  "Художня література, у т.ч.:" = "Художня література. Фольклор",
  "Дитяча література, у т.ч.:" = "Дитяча література",
  "Література універсального змісту" = "Література універсального змісту"
)

df_0506_long <- df_0506_long %>%
  mutate(
    genre = str_replace_all(genre, "\\n", " "),
    genre = str_squish(genre),
    genre = recode(genre, !!!genre_mapping)
  )

## -------- Creating ds_genre_long --------
# Combine all genre data
ds_genre_long <- bind_rows(df3_long, df_long, df_0506_long) %>%
  arrange(yr, measure, genre) %>%
  filter(!is.na(value))

## ------- rm() cleaning -------
rm(df3, df3_fixed, df3_long, df, df_fixed, df_long, df_0506, df_0506_fixed, df_0506_long, genre_col, years, new_names, genre_mapping)

## -------- RDS saving  --------
saveRDS(ds_genre_long, "data-private/derived/manipulation/ds_genre_long.rds")

## ------- SQLite saving -------
dbWriteTable(books_of_ukraine, "ds_genre_long", ds_genre_long, overwrite = TRUE)

## ------ CSV saving ------
write.csv(ds_genre_long, "data-private/derived/manipulation/CSV/ds_genre_long.csv", row.names = FALSE)

## ------- Sheet Saving -------
sheet_url <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854"
sheet_write(ds_genre_long, ss = sheet_url, sheet = "ds_genre_long")

# ------------------------------- DS_PUBTYPE_LONG --------------------------------
## ------ Data import circulation ------
df_cir <- import_selected_sheets(
    sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
    sheets_to_import = "Аркуш15"
)

## ------ Data cleaning circulation ------
# Rename columns to standardized names
pubtype_mapping <- c(
  "naukovi_vidanna" = "Наукові видання",
  "naukovo_popularni_vidanna_dla_doroslih" = "Науково-популярні видання для дорослих",
  "normativni_ta_virobnico_prakticni_vidanna" = "Нормативні та виробничо-практичні видання",
  "oficijni_vidanna" = "Офіційні видання",
  "gromads_ko_politicni_vidanna" = "Громадсько-політичні видання",
  "navcal_ni_ta_metodicni_vidanna" = "Навчальні та методичні видання",
  "literaturno_hudozni_vidanna_dla_doroslih" = "Літературно-художні видання для дорослих",
  "vidanna_dla_ditej_ta_unactva" = "Видання для дітей та юнацтва",
  "dovidkovi_vidanna" = "Довідкові видання",
  "informacijni_vidanna" = "Інформаційні видання",
  "bibliograficni_vidanna" = "Бібліографічні видання",
  "vidanna_dla_organizacii_dozvilla" = "Видання для організації дозвілля",
  "reklamni_vidanna" = "Рекламні видання",
  "literatura_religijnogo_zmistu" = "Література релігійного змісту"
)

df_cir_long <- df_cir %>%
  rename(yr = x) %>%
  pivot_longer(
    cols = -yr,
    names_to = "pubtype",
    values_to = "value"
  ) %>%
  mutate(
    measure = "copy_count",
    pubtype = recode(pubtype, !!!pubtype_mapping),
    value = as.numeric(value)
  ) %>%
  select(yr, measure, pubtype, value)

## ------ Data import titles ------
df_num <- import_selected_sheets(
    sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
    sheets_to_import = "Цільові призначення"
) %>%
    slice(-1)  # Remove header row

year_cols <- grep("^x\\d{4}$", names(df_num), value = TRUE)

df_num_cleaned <- df_num %>%
  mutate(across(all_of(year_cols), safe_numeric_convert))

df_num_long <- df_num_cleaned %>%
  pivot_longer(
    cols = all_of(year_cols),   
    names_to = "yr",
    names_prefix = "x",
    values_to = "value"
  ) %>%
  mutate(
    yr = as.integer(yr),
    measure = "title_count"
  ) %>%
  rename(pubtype = x) %>%
  select(yr, measure, pubtype, value)

## -------- Creating ds_pubtype_long --------
ds_pubtype_long <- bind_rows(df_cir_long, df_num_long) %>%
  arrange(yr, measure, pubtype) %>%
  filter(!is.na(value))

## ------- rm() cleaning -------
rm(df_cir, df_cir_long, df_num, df_num_cleaned, df_num_long, year_cols, pubtype_mapping)

## -------- RDS saving  --------
saveRDS(ds_pubtype_long, "data-private/derived/manipulation/ds_pubtype_long.rds")

## ------- SQLite saving -------
dbWriteTable(books_of_ukraine, "ds_pubtype_long", ds_pubtype_long, overwrite = TRUE)

## ------ CSV saving ------
write.csv(ds_pubtype_long, "data-private/derived/manipulation/CSV/ds_pubtype_long.csv", row.names = FALSE)

## ------- Sheet Saving -------
sheet_url <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854"
sheet_write(ds_pubtype_long, ss = sheet_url, sheet = "ds_pubtype_long")

# ------------------------------- DS_GEOGRAPHY_LONG --------------------------------
## ------ Data import titles ------
ds_titles <- import_selected_sheets(
    sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
    sheets_to_import = "території"
)

## ------ Data cleaning titles ------
df_titles <- ds_titles %>%
    slice(-1)  # Remove header row

year_cols <- grep("^x\\d{4}$", names(df_titles), value = TRUE)

df_titles <- df_titles %>%
  mutate(across(all_of(year_cols), safe_numeric_convert)) %>% 
  slice(-27:-37)  # Remove summary rows

df_titles_long <- df_titles %>%
  pivot_longer(
    cols = -x,           # pivot all columns except 'x'
    names_to = "yr",
    names_prefix = "x",
    values_to = "value"
  ) %>%
  mutate(
    yr = as.integer(yr),
    measure = "title_count"
  ) %>%
  rename(geography = x) %>%
  select(yr, measure, geography, value)

## ------ Data import circulation ------
ds_circulation <- import_selected_sheets(
    sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
    sheets_to_import = "Терир. наклад"
) %>%
    select(-x2025:-x2027)  # Remove future year columns

df_circulation_long <- ds_circulation %>%
  pivot_longer(
    cols = -x,              # all columns except "x" (area)
    names_to = "yr",
    names_prefix = "x",
    values_to = "value"
  ) %>%
  mutate(
    yr = as.integer(yr),
    measure = "copy_count"
  ) %>%
  rename(geography = x) %>%
  select(yr, measure, geography, value)

## -------- Creating ds_geography_long --------
ds_geography_long <- bind_rows(df_titles_long, df_circulation_long) %>%
  arrange(yr, measure, geography) %>%
  filter(!is.na(value))

## ------- rm() cleaning -------
rm(ds_titles, df_titles, df_titles_long, ds_circulation, df_circulation_long, year_cols)

## -------- RDS saving  --------
saveRDS(ds_geography_long, "data-private/derived/manipulation/ds_geography_long.rds")

## ------- SQLite saving -------
dbWriteTable(books_of_ukraine, "ds_geography_long", ds_geography_long, overwrite = TRUE)

## ------ CSV saving ------
write.csv(ds_geography_long, "data-private/derived/manipulation/CSV/ds_geography_long.csv", row.names = FALSE)

## ------- Sheet Saving -------
sheet_url <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854"
sheet_write(ds_geography_long, ss = sheet_url, sheet = "ds_geography_long")

# ------------------------------- DS_UKR_RUS --------------------------------
## ------ Data import ------
df <- import_selected_sheets(
    sheet_url = "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?gid=613842371#gid=613842371",
    sheets_to_import = "Мови"
)

## ------ Data cleaning ------
df_long <- df %>%
  slice(-c(3,6,7)) %>%
  pivot_longer(
    cols = -x,
    names_to = "yr",
    names_prefix = "x",
    values_to = "value"
  ) %>%
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

ds_ukr_rus_long <- df_wide %>%
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
rm(df, df_long, df_wide)

## -------- RDS saving  --------
saveRDS(ds_ukr_rus_long, "data-private/derived/manipulation/ds_ukr_rus_long.rds")

## ------- SQLite saving -------
dbWriteTable(books_of_ukraine, "ds_ukr_rus_long", ds_ukr_rus_long, overwrite = TRUE)

## ------ CSV saving ------
write.csv(ds_ukr_rus_long, "data-private/derived/manipulation/CSV/ds_ukr_rus_long.csv", row.names = FALSE)

## ------- Sheet Saving -------
sheet_url <- "https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854"
sheet_write(ds_ukr_rus_long, ss = sheet_url, sheet = "ds_ukr_rus_long")

# ---------------------------------------------------------------------- End of Script -------------------
cat("✅ All CACHE tables created successfully!\n")
cat("Tables created:\n")
cat("- ds_year_long: yr + measure + value\n")
cat("- ds_language_long: yr + measure + language + value\n") 
cat("- ds_genre_long: yr + measure + genre + value\n")
cat("- ds_pubtype_long: yr + measure + pubtype + value\n")
cat("- ds_geography_long: yr + measure + geography + value\n")
cat("- ds_ukr_rus_long: yr + measure + ukr + rus + perc_ukr + perc_rus (wide format)\n")

dbDisconnect(books_of_ukraine)
