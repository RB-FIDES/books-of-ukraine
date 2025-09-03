# Ціль: дослідити через книговидання наявність в Украхні мов світу
rm(list = ls(all.names = TRUE)) # Очищення пам'яті від змінних попереднього запуску
# Очищення пам'яті від змінних попереднього запуску. Не викликається knitr, бо знаходиться над першим чанком.
cat("\014") # Clear the console "Очищення консолі"
# verify root location "Перевірка робочої директорії"
cat("Working directory: ", getwd()) # Must be set to Project Directory "Має бути встановлена на директорію проєкту"
# Project Directory should be the root by default unless overwritten
# Директорія проєкту має бути кореневою за замовчуванням, якщо не перевизначено

# ---- load-packages -----------------------------------------------------------
# Choose to be greedy: load only what's needed
# Three ways, from least (1) to most(3) greedy:
# -- 1.Attach these packages so their functions don't need to be qualified:
# http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr)
library(ggplot2) # graphs графіки
library(forcats) # factors фактори
library(stringr) # strings робота з рядками
library(lubridate) # dates дати
library(labelled) # labels мітки
library(dplyr) # data wrangling обробка даних
library(tidyr) # data wrangling обробка даних
library(scales) # format форматування
library(broom) # for model для моделей
library(emmeans) # for interpreting model results для інтерпретації результатів моделей
library(ggalluvial)
library(janitor) # tidy data охайні дані
library(testit) # For asserting conditions meet expected patterns.
# Для перевірки відповідності умов очікуваним шаблонам.


# ---- httpgd (VS Code interactive plots) ------------------------------------
# Optional: httpgd convenience notes
# - The script uses the httpgd namespace (httpgd::hgd()) so attaching the package
#   is not required. If you prefer calling functions without the `httpgd::` prefix,
#   you can attach the package in an interactive session by uncommenting the
#   following line or running it manually in your R console before sourcing this file:
#
#   # In R interactive session only
#   # if (interactive()) suppressPackageStartupMessages(library(httpgd, quietly = TRUE))
#
# - To force automatic httpgd start when VS Code does not set VSCODE_PID, set
#   the environment variable for your session: Sys.setenv(FORCE_HTTPGD = 'TRUE')
#   or set the option: options(books_of_ukraine.force_httpgd = TRUE)
#
# Start httpgd only for interactive VS Code sessions. This avoids attempting
# to start a server during non-interactive Quarto/CI renders.
#
# If you are in an interactive R session but VS Code does not expose
# VSCODE_PID, you can force starting httpgd for this session by either:
#  - setting the environment variable: Sys.setenv(FORCE_HTTPGD = 'TRUE')
#  - or setting the option: options(books_of_ukraine.force_httpgd = TRUE)
force_httpgd_env <- tolower(Sys.getenv("FORCE_HTTPGD", unset = ""))
force_httpgd <- nzchar(force_httpgd_env) && force_httpgd_env %in% c("1", "true", "yes")
force_httpgd <- force_httpgd || isTRUE(getOption("books_of_ukraine.force_httpgd", FALSE))

if (interactive() && (nzchar(Sys.getenv("VSCODE_PID")) || force_httpgd)) {
    if (requireNamespace("httpgd", quietly = TRUE)) {
        tryCatch(
            {
                # prefer hgd(); older versions may expose httpgd()
                # Optionally attach httpgd for convenience in interactive sessions
                if (interactive()) {
                    try(suppressPackageStartupMessages(library(httpgd, quietly = TRUE)), silent = TRUE)
                }
                if (is.function(httpgd::hgd)) {
                    httpgd::hgd()
                } else if (is.function(httpgd::httpgd)) {
                    httpgd::httpgd()
                }
                message("httpgd started for interactive VS Code session. Use the VS Code Plot pane or httpgd::hgd_browse() to view plots.")
            },
            error = function(e) {
                message("httpgd detected but failed to start: ", conditionMessage(e))
            }
        )
    } else {
        message("httpgd not installed. To enable interactive plotting in VS Code, install httpgd: install.packages('httpgd')")
    }
} else {
    if (interactive() && !nzchar(Sys.getenv("VSCODE_PID")) && !force_httpgd) {
        message("Interactive R session detected but no VS Code PID found; httpgd was not started automatically. To force it in this session set FORCE_HTTPGD=TRUE or options(books_of_ukraine.force_httpgd = TRUE).")
    }
    # Non-interactive contexts (Quarto / CI): do nothing; static devices will be used.
}

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
base::source("./scripts/operational-functions.R") # project-level

# ---- declare-globals ---------------------------------------------------------

local_root <- "./analysis/eda-3/"
local_data <- paste0(local_root, "data-local/") # for local outputs

if (!fs::dir_exists(local_data)) {
    fs::dir_create(local_data)
}

data_private_derived <- "./data-private/derived/eda-3/"
if (!fs::dir_exists(data_private_derived)) {
    fs::dir_create(data_private_derived)
}

prints_folder <- paste0(local_root, "prints/")
if (!fs::dir_exists(prints_folder)) {
    fs::dir_create(prints_folder)
}


# ---- declare-functions -------------------------------------------------------
# base::source(paste0(local_root,"local-functions.R")) # project-level

# Generate data dictionary in local analysis folder
generate_local_data_dictionary <- function() {
    source("./scripts/generate-data-dictionary.R")
    generate_long_datasets_dictionary(analysis_folder = local_root)
    cat("Data dictionary generated in:", file.path(local_root, "data-dictionary-long-datasets.md"), "\n")
}

# ---- load-data --------------------------------------

# Connect to the default Books of Ukraine database using custom functions
# Note: Using 'main' database which contains analysis-ready tables created by Ellis pipeline
# Note: The complete optimized database (books + ua admin + extra)
# Note: wide tables (those with a _wide suffix) are good for getting to know the data, but tables (without _wide suffix) are better for analysis.
db <- connect_books_db("main") # connects to the final analytical database
# now let's inspect what data tables are available in the database
db_tables_all <- DBI::dbListTables(db)

# Keep only tables that do NOT end with the `_wide` suffix (we'll import these)
# db_tables <- db_tables_all[!grepl("_wide$", db_tables_all)]
db_tables <- db_tables_all

# Read selected tables into a named list (tbls) and also assign sanitized names
# into the global environment for convenience. This keeps the connection open
# while we read data, then disconnects.
message("Reading ", length(db_tables), " non-_wide tables from DB: ", paste(db_tables, collapse = ", "))
tbls <- lapply(db_tables, function(t) {
    message(" - ", t)
    DBI::dbReadTable(db, t)
})
names(tbls) <- db_tables

# helper to convert table names into safe R object names
sanitize_name <- function(x) {
    nm <- gsub("[^A-Za-z0-9_]+", "_", x)
    nm <- gsub("^([0-9])", "_\\1", nm)
    nm
}

# assign into global env using sanitized names
for (nm in db_tables) {
    obj_name <- sanitize_name(nm)
    assign(obj_name, tbls[[nm]], envir = .GlobalEnv)
}
# Close the database connection
DBI::dbDisconnect(db)

# Print concise summary of loaded tables
cat("Loaded tables (name: rows x cols):\n")
for (nm in db_tables) {
    df <- tbls[[nm]]
    if (is.data.frame(df) || is.matrix(df)) {
        rows <- nrow(df)
        cols <- ncol(df)
    } else {
        rows <- NA
        cols <- NA
    }
    cat("   -", nm, ":", rows, "rows and", cols, "columns\n")
}

# ---- tweak-data-0 -------------------------------------

# ---- inspect-data-0 -------------------------------------

# ---- inspect-data-1 -------------------------------------
# Let's explore the structure and content of our key datasets
ds_year %>% glimpse()
ds_language %>% glimpse()
ds_territory %>% glimpse()
ds_theme %>% glimpse()
ds_purpose %>% glimpse()
ds_oblast %>% glimpse()

## Спочатку дослідимо структуру та вміст ds_language
### Напиши код для дослідження структури та вмісту ds_language
# Перевірка структури таблиці
str(ds_language)

# Перегляд перших рядків
head(ds_language)

# Виведення унікальних мов
unique(ds_language$language)

# Підрахунок кількості записів для кожної мови
table(ds_language$language)

# Описова статистика для числових змінних
summary(ds_language)

# Перевірка на пропущені значення
colSums(is.na(ds_language))

# ---- analysis-below -------------------------------------
# ----- g1 ------------------------------------------------
### Напиши код для побудови графіка (обери вид графіка), який показує кількість примірників кожною мовою з 2018 по 2024 роки
# Фільтруємо дані за роками 2018-2024
library(dplyr)
language_2018_2024 <- ds_language %>%
    filter(year >= 2018 & year <= 2024)

# Групуємо та підраховуємо кількість примірників для кожної мови
language_summary <- language_2018_2024 %>%
    group_by(language) %>%
    summarise(total_copies = sum(print_run, na.rm = TRUE)) %>%
    arrange(desc(total_copies))

# Будуємо стовпчиковий графік
library(ggplot2)
ggplot(language_summary, aes(x = reorder(language, total_copies), y = total_copies, fill = language)) +
    geom_bar(stat = "identity") +
    labs(
        title = "Кількість примірників кожною мовою (2018-2024)",
        x = "Мова",
        y = "Кількість примірників"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
## Виправляємо помилку: Помилка означає, що у таблиці ds_language немає колонки language.
names(ds_language)
str(ds_language)
### Ось інформація про структуру ds_language, можеш виправити код.
### 'data.frame':	1480 obs. of  5 variables:
### $ year          : int  2005 2005 2005 2005 2005 2005 2005 2005 2005 2005 ...
### $ category_type : chr  "language" "language" "language" "language" ...
### $ category_value: chr  "Іврит" "Іврит" "Іспанська" "Іспанська" ...
### $ measure       : chr  "copy_count" "title_count" "copy_count" "title_count" ...
### $ value         : num  0 0 0 0 0 0 0 0 0 0 ...
# Фільтруємо дані за роками 2018-2024 та лише для примірників
library(dplyr)
language_2018_2024 <- ds_language %>%
    filter(year >= 2018 & year <= 2024, measure == "copy_count")

# Групуємо та підраховуємо кількість примірників для кожної мови
language_summary <- language_2018_2024 %>%
    group_by(category_value) %>%
    summarise(total_copies = sum(value, na.rm = TRUE)) %>%
    arrange(desc(total_copies))

# Будуємо стовпчиковий графік
library(ggplot2)
ggplot(language_summary, aes(x = reorder(category_value, total_copies), y = total_copies, fill = category_value)) +
    geom_bar(stat = "identity") +
    labs(
        title = "Кількість примірників кожною мовою (2018-2024)",
        x = "Мова",
        y = "Кількість примірників"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
### Зміни вид графіка на geom_col
# Будуємо стовпчиковий графік з використанням geom_col
ggplot(language_summary, aes(x = reorder(category_value, total_copies), y = total_copies, fill = category_value)) +
    geom_col() +
    labs(
        title = "Кількість примірників кожною мовою (2018-2024)",
        x = "Мова",
        y = "Кількість примірників"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
### Виключи розподіл за роками, подивимося на сумарну кількість примірників
# Групуємо всі дані лише за мовою та підраховуємо сумарну кількість примірників
language_total <- ds_language %>%
    filter(measure == "copy_count") %>%
    group_by(category_value) %>%
    summarise(total_copies = sum(value, na.rm = TRUE)) %>%
    arrange(desc(total_copies))

# Будуємо стовпчиковий графік для сумарної кількості примірників
ggplot(language_total, aes(x = reorder(category_value, total_copies), y = total_copies, fill = category_value)) +
    geom_col() +
    labs(
        title = "Сумарна кількість примірників кожною мовою",
        x = "Мова",
        y = "Кількість примірників"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
### Заміни на стовпчикову діаграму
# Класична стовпчикова діаграма (base R)
barplot(
    height = language_total$total_copies,
    names.arg = language_total$category_value,
    las = 2,
    col = "skyblue",
    main = "Сумарна кількість примірників кожною мовою",
    xlab = "Мова",
    ylab = "Кількість примірників"
)
### Застосуй фільтр: прибери "Українською", "Російською" та "Кількома мовами народів світу"
# Фільтруємо дані, виключаючи зазначені мови
language_total_filtered <- language_total %>%
    filter(!category_value %in% c("Українською", "Російською", "Кількома мовами народів світу"))

# Будуємо стовпчикову діаграму для відфільтрованих даних
barplot(
    height = language_total_filtered$total_copies,
    names.arg = language_total_filtered$category_value,
    las = 2,
    col = "skyblue",
    main = "Сумарна кількість примірників (без укр/рос/кілька мов)",
    xlab = "Мова",
    ylab = "Кількість примірників"
)
### Зроби графік: вісь Х - роки, вісь Y  - мова і кольорами - кількість примірників. Розбий кількість примірників на три логічні групи: 0<Gr1<100 і так далі. Виключи роки до 2018, не включай "Українською", "Російською" та "Кількома мовами народів світу"
# Підготовка даних
library(dplyr)
library(ggplot2)
library(forcats)
lang_year <- ds_language %>%
    filter(
        year >= 2018,
        measure == "copy_count",
        !category_value %in% c("Українською", "Російською", "Кількома мовами народів світу")
    ) %>%
    mutate(
        group = case_when(
            value == 0 ~ "Gr0",
            value > 0 & value < 100 ~ "Gr1",
            value >= 100 & value < 1000 ~ "Gr2",
            value >= 1000 ~ "Gr3"
        )
    )

# Побудова графіка
ggplot(lang_year, aes(x = factor(year), y = fct_reorder(category_value, value), fill = group)) +
    geom_tile(aes(alpha = value > 0)) +
    scale_fill_manual(values = c("Gr0" = "grey90", "Gr1" = "skyblue", "Gr2" = "dodgerblue", "Gr3" = "navy")) +
    labs(
        title = "Кількість примірників за мовами та роками (2018-2024)",
        x = "Рік",
        y = "Мова",
        fill = "Група примірників"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 0, hjust = 0.5))
### На візуалізації є "Українською", "Російською". Виправ помилку.
# Додатково фільтруємо дані з урахуванням регістру та пробілів
lang_year_filtered <- lang_year %>%
    filter(!tolower(trimws(category_value)) %in% c(
        "українською",
        "російською",
        "кількома мовами народів світу"
    ))

ggplot(lang_year_filtered, aes(x = factor(year), y = fct_reorder(category_value, value), fill = group)) +
    geom_tile(aes(alpha = value > 0)) +
    scale_fill_manual(values = c("Gr0" = "grey90", "Gr1" = "skyblue", "Gr2" = "dodgerblue", "Gr3" = "navy")) +
    labs(
        title = "Кількість примірників за мовами та роками (2018-2024)",
        x = "Рік",
        y = "Мова",
        fill = "Група примірників"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 0, hjust = 0.5))
### Я бачу фільтр у коді, однак зайві показники залишилися. В чому проблема?
#### Причина:
#### Можливо, у даних є різні варіанти написання ("Українською", "українською", пробіли, тощо) або трапляються дублікати/помилки у назвах.

#### Рішення:

#### 1. Перевірте унікальні значення:
unique(ds_language$category_value)
#### 2. Додайте фільтрацію з урахуванням регістру та пробілів:
## Код виправлено вище.
### Тепер я виправлю завдання для g2. Фільтр: без "Українська", "Російська" та "Кількома мовами народів світу". Графік: вісь Х - роки, вісь Y  - мова і кольорами - кількість примірників. Розбий кількість примірників на три логічні групи: 0<Gr1<100, 100<Gr1<1000 і 1000<Gr1.
# Підготовка даних для g2
lang_year_g2 <- ds_language %>%
    filter(
        year >= 2018,
        measure == "copy_count",
        !tolower(trimws(category_value)) %in% c(
            "українська",
            "російська",
            "кількома мовами народів світу"
        )
    ) %>%
    mutate(
        group = case_when(
            value == 0 ~ "Gr0",
            value > 0 & value < 100 ~ "Gr1",
            value >= 100 & value < 1000 ~ "Gr2",
            value >= 1000 ~ "Gr3"
        )
    )

# Побудова графіка для g2
ggplot(lang_year_g2, aes(x = factor(year), y = fct_reorder(category_value, value), fill = group)) +
    geom_tile(aes(alpha = value > 0)) +
    scale_fill_manual(values = c("Gr0" = "grey90", "Gr1" = "skyblue", "Gr2" = "dodgerblue", "Gr3" = "navy")) +
    labs(
        title = "Кількість примірників за мовами та роками (2018-2024), g2",
        x = "Рік",
        y = "Мова",
        fill = "Група примірників"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 0, hjust = 0.5))
### Додай фільтр: прибери ті мови, які мають кількість примірників бульше нуля лише один раз
# Фільтруємо мови, які мають кількість примірників > 0 більше одного разу
lang_year_g2_filtered <- lang_year_g2 %>%
    group_by(category_value) %>%
    mutate(n_positive = sum(value > 0)) %>%
    ungroup() %>%
    filter(n_positive > 1)

# Побудова графіка для відфільтрованих даних
ggplot(lang_year_g2_filtered, aes(x = factor(year), y = fct_reorder(category_value, value), fill = group)) +
    geom_tile(aes(alpha = value > 0)) +
    scale_fill_manual(values = c("Gr0" = "grey90", "Gr1" = "skyblue", "Gr2" = "dodgerblue", "Gr3" = "navy")) +
    labs(
        title = "Кількість примірників за мовами та роками (2018-2024), g2, фільтр >1",
        x = "Рік",
        y = "Мова",
        fill = "Група примірників"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 0, hjust = 0.5))
### Побудуй новий графік для пʼятірки мов, які мають найбільшу кількість примірників
# Визначаємо топ-5 мов за сумарною кількістю примірників
top5_langs <- lang_year_g2_filtered %>%
    group_by(category_value) %>%
    summarise(total_copies = sum(value, na.rm = TRUE)) %>%
    arrange(desc(total_copies)) %>%
    slice_head(n = 5) %>%
    pull(category_value)

# Фільтруємо дані для топ-5 мов
lang_year_g2_top5 <- lang_year_g2_filtered %>%
    filter(category_value %in% top5_langs)

# Побудова графіка для топ-5 мов
ggplot(lang_year_g2_top5, aes(x = factor(year), y = fct_reorder(category_value, value), fill = group)) +
    geom_tile(aes(alpha = value > 0)) +
    scale_fill_manual(values = c("Gr0" = "grey90", "Gr1" = "skyblue", "Gr2" = "dodgerblue", "Gr3" = "navy")) +
    labs(
        title = "Кількість примірників за топ-5 мовами та роками (2018-2024)",
        x = "Рік",
        y = "Мова",
        fill = "Група примірників"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 0, hjust = 0.5))
### Маємо помилку: Error: object 'lang_year_g2_top5' not found
#### Причина: помилка виникає, якщо код для створення lang_year_g2_filtered або lang_year_g2_top5 не був виконаний, або якщо ви змінили/видалили частину коду вручну.
#### Ось правильна послідовність:
#### Створити lang_year_g2 (фільтр, групування)
#### Створити lang_year_g2_filtered
#### Створити lang_year_g2_top5
#### Побудувати графік
#### Бажаєте, щоб я автоматично додав/відновив повний робочий блок для цих змінних у файл?
### Так, будь ласка, додай повний робочий блок для цих змінних у файл.
# Повний робочий блок для топ-5 мов
library(dplyr)
library(ggplot2)
library(forcats)

# 1. Підготовка даних: фільтр, групування
lang_year_g2 <- ds_language %>%
    filter(
        year >= 2018,
        measure == "copy_count",
        !tolower(trimws(category_value)) %in% c(
            "українська",
            "російська",
            "кількома мовами народів світу"
        )
    ) %>%
    mutate(
        group = case_when(
            value == 0 ~ "Gr0",
            value > 0 & value < 100 ~ "Gr1",
            value >= 100 & value < 1000 ~ "Gr2",
            value >= 1000 ~ "Gr3"
        )
    )

# 2. Фільтруємо мови, які мають кількість примірників > 0 більше одного разу
lang_year_g2_filtered <- lang_year_g2 %>%
    group_by(category_value) %>%
    mutate(n_positive = sum(value > 0)) %>%
    ungroup() %>%
    filter(n_positive > 1)

# 3. Визначаємо топ-5 мов за сумарною кількістю примірників
top5_langs <- lang_year_g2_filtered %>%
    group_by(category_value) %>%
    summarise(total_copies = sum(value, na.rm = TRUE)) %>%
    arrange(desc(total_copies)) %>%
    slice_head(n = 5) %>%
    pull(category_value)

# 4. Фільтруємо дані для топ-5 мов
lang_year_g2_top5 <- lang_year_g2_filtered %>%
    filter(category_value %in% top5_langs)

# 5. Побудова графіка для топ-5 мов
ggplot(lang_year_g2_top5, aes(x = factor(year), y = fct_reorder(category_value, value), fill = group)) +
    geom_tile(aes(alpha = value > 0)) +
    scale_fill_manual(values = c("Gr0" = "grey90", "Gr1" = "skyblue", "Gr2" = "dodgerblue", "Gr3" = "navy")) +
    labs(
        title = "Кількість примірників за топ-5 мовами та роками (2018-2024)",
        x = "Рік",
        y = "Мова",
        fill = "Група примірників"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 0, hjust = 0.5))
### Зроби кольори більш контрастними
# Побудова графіка для топ-5 мов з більш контрастними кольорами
ggplot(lang_year_g2_top5, aes(x = factor(year), y = fct_reorder(category_value, value), fill = group)) +
    geom_tile(aes(alpha = value > 0)) +
    scale_fill_manual(values = c(
        "Gr0" = "white",
        "Gr1" = "orange",
        "Gr2" = "red",
        "Gr3" = "black"
    )) +
    labs(
        title = "Кількість примірників за топ-5 мовами та роками (2018-2024)",
        x = "Рік",
        y = "Мова",
        fill = "Група примірників"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 0, hjust = 0.5))
