rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
cat("\014") # Clear the console
# verify root location
cat("Working directory: ", getwd()) # Must be set to Project Directory
# Project Directory should be the root by default unless overwritten
# rmarkdown::render(input = "./manipulation/2-ellis.R") # run to knit, don't uncomment
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
# -- 2.Import only certain functions of a package into the search path.
# import::from("magrittr", "%>%")
# -- 3. Verify these packages are available on the machine, but their functions need to be qualified
requireNamespace("readr"    )# data import/export
requireNamespace("readxl"   )# data import/export
requireNamespace("janitor"  )# tidy data
requireNamespace("testit"   )# For asserting conditions meet expected patterns.

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
base::source("./scripts/operational-functions.R") # project-level

# ---- declare-globals ---------------------------------------------------------
target_window_opens  <- as.Date("2013-04-01")
target_window_closes <- as.Date("2024-03-31")
target_window <- c(target_window_opens, target_window_closes)
local_root <- "./manipulation/"
local_data <- paste0(local_root, "data-local/") # for local outputs

if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

data_private_derived <- "./data-private/derived/manipulation/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

prints_folder <- paste0(local_root, "prints/2-ellis")
if (!fs::dir_exists(prints_folder)) {fs::dir_create(prints_folder)}

sample_of_interest1 <- 4734747 # real id in focus
# sample_of_interest1 <- 179820 # scramble id in focus
sample_of_interest <- c(
  1017460
  ,1411830
  ,3777415
  ,4812318
  ,4734747
  ,2099597
)
sample_of_interest1 <- sample_of_interest[6]
# ---- declare-functions -------------------------------------------------------
# base::source(paste0(local_root,"local-functions.R")) # project-level

# ---- define-queries ----------------------------------------------------------
# Bring in the query from ./manipulation/1-assemble-flat.sql
sql_fs_episodes <- "
SELECT --top 10000
    fs.[PERSON_OID] -- Unique identifier for the person
    ,fs.[HSID] --Househould ID
    ,fs.[PERIOD_START] AS date_start -- Start date of the financial support period
    ,fs.[PERIOD_END]   AS date_end -- End date of the financial support period
    ,fs.[SPELL_NUMBER] -- Identifier for the spell of financial support
    ,fs.[SPELL_BIT_NUMBER] -- Subdivision of the spell for finer granularity
    ,fs.[SPELL_BIT_DURATION] -- Duration of the spell bit in months
    ,fs.[BENEFIT_BIT_DURATION] -- Duration of the benefit bit in months
    ,fs.[IS_SPELL_BIT_BENEFIT] -- Total benefit amount received in this spell bit
    ,fs.[ROLE_TYPE_START] -- Role type at the start of the period
    ,fs.[CLIENT_TYPE_CODE] -- Code representing the type of client
    -- Demographic data from FINANCIAL SUPPORT
    ,fs.AGE_AS_OF_IS_START_IN_YEARS as age -- Age of the person at the start of the period
    ,fs.GENDER -- Gender of the person
    ,fs.MARITAL_STATUS -- Marital status of the person
    ,fs.TOTAL_DEPENDENT_COUNT -- Total number of dependents
    ,fs.VISIBLE_MINORITY_FLAG -- Flag indicating visible minority status
    ,fs.VISIBLE_MINORITY_SELF_DECLARED_FLAG -- Self-declared visible minority status
    ,fs.IMMIGRANT_FLAG -- Flag indicating immigrant status
    ,fs.IMMIGRANT_SELF_DECLARED_FLAG -- Self-declared immigrant status
    ,fs.ABORIGINAL_FLAG -- Flag indicating aboriginal status
    ,fs.ABORIGINAL_STATUS_SELF_DECLARED_FLAG -- Self-declared aboriginal status
    ,fs.DISABILITY_FLAG -- Flag indicating disability status
    ,fs.DISABILITY_SELF_DECLARED_FLAG -- Self-declared disability status
    ,fs.HIGHEST_EDUCATION_LEVEL_START as HIGHEST_EDUCATION_LEVEL -- Highest education level at the start of the period
    -- Taxonomy data from PROGRAM_CLASS
    ,pc.program_class0 -- Top-level classification (Financial Support, Assessment, Training)
    ,pc.program_class1 -- Second-level classification (Income Support, AISH, DRES, etc.)
    ,pc.program_class2 -- Third-level classification (ETW, BFE, OTI, etc.)
    ,pc.client_type -- Client type description
    ,pc.pc0 -- Abbreviated program_class0 (FS, AS, TR)
    ,pc.pc1 -- Abbreviated program_class1 (OTI, IS, AISH, DRES, etc.)
    ,pc.pc2 -- Abbreviated program_class2 (OTI, BFE, ETW, etc.)
    ,pc.fs_type -- Financial support type (OTI, ETW, BFE, AISH)
    ,pc.program_group -- Custom research grouping for analysis with ordered factor levels
FROM [RESEARCH_PROJECT_CACHE_UAT].[P20250625].[FS_EPISODES] fs
LEFT JOIN [RESEARCH_PROJECT_CACHE_UAT].[TAXONOMY].[PROGRAM_CLASS] pc
    ON fs.[CLIENT_TYPE_CODE] = pc.[client_type_code] -- Link using client_type_code as per RDB-manifest
;
"



#+ load-data ---------------------------------------------------------------
dsn <- "RESEARCH_PROJECT_CACHE_UAT" # one per database, typically in config file
cnn <- DBI::dbConnect(odbc::odbc(), dsn = dsn) # open the connection
# Load financial support episodes
ds_fs_episodes <- DBI::dbGetQuery(cnn, sql_fs_episodes)
DBI::dbDisconnect(cnn) # hang up the phone

#+ tweak-data-0 --------------------------------------------------------------
ds0 <-
  ds_fs_episodes %>%
  # slice(1:1000) %>% # for testing, remove later
  janitor::clean_names() %>%
  mutate_at(
    .vars = c("date_start", "date_end"),
    .funs = ~lubridate::ymd(.)
  ) %>% # convert to date
  mutate_at(
    .vars = c("spell_number", "spell_bit_number", "spell_bit_duration")
    ,.funs = ~as.integer(.)
  )

ds0 %>% glimpse()  

#+ tweak-data-1 --------------------------------------------------------------

  # Not every episode in this table is a financial support episode.
ds0 %>% count(program_class1,pc2)

# let's keep only the individuals who did not have any episodes of Income Support prior to 2015
# and whose first Income Support episode started after 2015


#  The meaning of "episode duration" differs for these groups:
# OTI are single day events and AISH is a life-long support.
# let's isolate financial support episodes that started after 2015
ds1 <- ds0 %>%
  # filter(person_oid == 3503052) %>% # test
  filter(program_class0 == "Financial Support") %>% # only financial support episodes
  filter(program_class1 == "Income Support") %>% # OTI are single day events, not financial support episodes 
  filter(!is.na(spell_bit_duration)) %>% # only those with spell bit duration
  filter(spell_bit_duration > 0) %>% # only those with positive spell bit duration
  group_by(person_oid) %>%
  mutate(
    spell_bit_order = row_number(), # order of spells for each person
    first_is_after_2015 = case_when(
      date_start >= as.Date("2015-01-01") & date_start == min(date_start[date_start >= as.Date("2015-01-01")], na.rm = TRUE) ~ TRUE,
      TRUE ~ FALSE
    ) # first spell of IS after 2015
  ) %>%
  ungroup()  
  # now we can keep only those FIRST TIME SPELLS OF IS that started after our target year - 2015
  # ds1 %>% group_by(fs_type, spell_number, spell_bit_number, spell_bit_order) %>% count()

# target <- 3503052 # we found and put to testing
target <- 3680085  # we found and put to testing
cat("\014")
t1 <- ds0 %>% 
  select(pc2,client_type_code, 1:5) %>% 
  keep_random_id() %>% # find
  # filter(person_oid == target) %>% # test
  arrange(date_start) %>% print()
ds1 %>% 
  select(pc2,client_type_code, 1:5,spell_bit_order, first_is_after_2015) %>% 
  filter(person_oid == unique(t1$person_oid)) %>% # find
  # filter(person_oid == target) %>% # test
  arrange(date_start)
# So we only want to accept individuals with 
# spell_bit_order==1L & first_is_after_2015==TRUE
ds1 %>% 
  select(pc2,client_type_code, 1:5,spell_bit_order, first_is_after_2015) %>% 
  filter(person_oid == unique(t1$person_oid)) %>% # find
  filter(
     spell_bit_order == 1L
    ,first_is_after_2015 == TRUE
  )
  
# LINES BELOW RECORD THE OUTPUT OF THE ABOVE COMMANDS
# > t1 <- ds0 %>% 
#   +   select(pc2,client_type_code, 1:5) %>% 
#   +   # keep_random_id() %>% # find
#   +   filter(person_oid == target) %>% # test
#   +   arrange(date_start) %>% print()
# pc2 client_type_code person_oid date_start   date_end spell_number spell_bit_number
# 1   ETW               23    3503052 2001-03-01 2001-05-31            1                1
# 2   OTI               82    3503052 2005-01-01 2005-01-31            2                1
# 3   ETW               14    3503052 2005-02-01 2005-04-30            2                2
# 4   ETW               13    3503052 2005-12-01 2006-10-31            3                1
# 5   ETW               14    3503052 2011-06-01 2011-06-30            4                1
# 6   ETW               14    3503052 2011-09-01 2011-09-30            5                1
# 7   ETW               17    3503052 2013-06-01 2013-07-31            6                1
# 8   ETW               17    3503052 2013-10-01 2013-12-31            7                1
# 9   ETW               17    3503052 2015-11-01 2016-01-31            8                1
# 10  OTI               82    3503052 2016-07-01 2016-07-31            9                1
# 11  OTI               82    3503052 2017-01-01 2017-01-31           10                1
# 12  ETW               17    3503052 2017-02-01 2017-05-31           10                2
# 13  OTI               82    3503052 2018-06-01 2018-06-30           11                1
# 14 AISH               91    3503052 2019-05-01 2022-07-31           12                1
# > ds1 %>% 
#   +   select(pc2,client_type_code, 1:5,spell_bit_order, first_is_after_2015) %>% 
#   +   # filter(person_oid == unique(t1$person_oid)) %>% # find
#   +   filter(person_oid == target) %>% # test
#   +   arrange(date_start)
# # A tibble: 9 × 9
# pc2   client_type_code person_oid date_start date_end   spell_number spell_bit_number spell_bit_order first_is_after_2015
# <chr> <chr>                 <int> <chr>      <chr>      <chr>        <chr>                      <int> <lgl>              
# 1 ETW   23                  3503052 2001-03-01 2001-05-31 1            1                          1   FALSE              
# 2 ETW   14                  3503052 2005-02-01 2005-04-30 2            2                          2   FALSE              
# 3 ETW   13                  3503052 2005-12-01 2006-10-31 3            1                          3   FALSE              
# 4 ETW   14                  3503052 2011-06-01 2011-06-30 4            1                          4   FALSE              
# 5 ETW   14                  3503052 2011-09-01 2011-09-30 5            1                          5   FALSE              
# 6 ETW   17                  3503052 2013-06-01 2013-07-31 6            1                          6   FALSE              
# 7 ETW   17                  3503052 2013-10-01 2013-12-31 7            1                          7   FALSE              
# 8 ETW   17                  3503052 2015-11-01 2016-01-31 8            1                          8   TRUE               
# 9 ETW   17                  3503052 2017-02-01 2017-05-31 10           2                          9   FALSE  

# Now we can filter out the first spell of IS that started after 2015
# This allows us to finetune the definition of our research cohort to
# enhance the interpretability of results. The first time an individual
# qualifies for Income Support represents a significant life event, which
# can be used to homogenize the cohort and reduce the noise in the data.
# We have to draw the line somewhere, so let it be 2015-01-01  
# Our research cohort will include individuals who have received their first ever
# month on Income Support on or after 2015-01-01.
# Individuals for who received Income Support prior to 2015-01-01 are excluded from this sample. 
# Theirs is a different story.
# let's store the list of these individuals for future reference
first_is_was_after_2015 <-
  ds1 %>%
  filter(
    spell_bit_order == 1L
    ,first_is_after_2015 == TRUE
  ) %>% 
  select(person_oid, date_start, spell_bit_order) %>%
  arrange(person_oid, date_start)
# let's verify that person_ois is a unique identifier
first_is_was_after_2015 %>%
  group_by(person_oid) %>%
  summarise(n = n()) %>%
  filter(n > 1) # should be empty

# now let's remove negative values of person_oid(training cases)
# and select ALL episodes for these individuals
ds2 <- ds1 %>% # remember that ds0-to-ds1 only filtered. 
  filter(program_class0 == "Financial Support") %>% # only financial support episodes
  filter(program_class1 == "Income Support") %>% # OTI are single day events, not fs episodes 
  filter(person_oid > 0L) %>%  # remove training cases
  filter(person_oid %in% first_is_was_after_2015$person_oid) %>% # first IS on and after 2025-01-01
  filter(!is.na(spell_bit_duration)) %>% # only those with spell bit duration
  filter(spell_bit_duration > 0) # only those with positive spell bit duration
  

# let's verify that we selected the right individuals
cat("\014")
t1 <- ds0 %>% 
  select(pc2,client_type_code, 1:5) %>% 
  keep_random_id() %>% # find
  # filter(person_oid == target) %>% # test
  arrange(date_start) %>% print()
ds1 %>% 
  select(pc2,client_type_code, 1:5,spell_bit_order, first_is_after_2015) %>% 
  filter(person_oid == unique(t1$person_oid)) %>% # find
  # filter(person_oid == target) %>% # test
  arrange(date_start)
# we should  only see cases that had first ever IS on or after 2015-01-01
ds2 %>% 
  select(pc2,client_type_code, 1:5,spell_bit_order, first_is_after_2015,) %>% 
  filter(person_oid == unique(t1$person_oid)) %>% # find
  arrange(date_start)



#+ tweak-data-3-functions ---------------------------------------------------
# Now that the cohort is operationalized with precise language and 
# Individuals in the first month of their first Income Support episode
# have a lot in common, and a shared timeline, relative to individuals
# where time=0 is the first month of their first in income support episode,
# (if this episode occured on or after 2015-01-01)
wrangle_age <- function(d_in){
  # d_out <- is_source
  d_out <-
    d_in %>%
    mutate(
      age_category3 = case_when(
        ((age  >= 15) & (age <= 24)) ~ "15-24"
        ,((age >= 25) & (age <= 54)) ~ "25-54"
        ,(age >= 55)                 ~ "55+"
        ,TRUE ~ "(Missing)"
      ) %>% factor(levels = c("(Missing)", "15-24", "25-54", "55+"))
      
      ,age_category5 = case_when(
        ((age  >= 15) & (age <= 24)) ~ "15-24"
        ,((age >= 25) & (age <= 34)) ~ "25-34"
        ,((age >= 35) & (age <= 44)) ~ "35-44"
        ,((age >= 45) & (age <= 54)) ~ "45-54"
        ,(age  >= 55)                ~ "55+"
        ,TRUE ~ "(Missing)"
      ) %>% factor(levels = c("(Missing)", "15-24", "25-34", "35-44", "45-54", "55+"))
      
      ,age_in_years = case_when(
        age > 14 & age < 81 ~ age # ages outside of this range are considered suspicous
        ,TRUE                              ~ NA_integer_
      )
    )
  return(d_out)
}

wrangle_sex <- function(d_in){
  # d_out <- is_source
  d_out <-
    d_in %>%
    mutate(
      gender = str_trim(gender)
    ) %>% 
    mutate(
      sex3 = case_when(
        gender  %in% c("Male")    ~ "Male"
        ,gender %in% c("Female")  ~ "Female"
        ,gender %in% c("X")       ~ "X"   # !!!
        ,gender %in% c("Unknown") ~ "(Missing)"
        ,TRUE ~ NA_character_
      ) %>% as_factor() %>% relevel(ref = "Male")
      ,sex2 = case_when(
        gender  %in% c("Male")        ~ "Male"
        ,gender %in% c("Female")      ~ "Female"
        ,gender %in% c("Unknown","X") ~ "(Missing)"
        ,TRUE ~ NA_character_
      ) %>% as_factor() %>% relevel(ref = "Male")
    )
  return(d_out)
}

wrangle_marital <- function(d_in){
  d_out <-
    d_in %>%
    mutate(
      marital2 = case_when(
        marital_status %in% c("Married", "Common Law") ~ "married"
        ,marital_status %in% c("Separated", "Single", "Divorced", "Widowed") ~ "single"
        ,TRUE ~ "(Missing)"
      ) %>% as_factor() %>% relevel(ref = "single")
      ,marital3 = case_when(
        marital_status %in% c("Married", "Common Law") ~ "together"
        ,marital_status %in% c("Separated", "Divorced", "Widowed") ~ "apart"
        ,marital_status == "Single" ~ "never married"
        ,TRUE ~ "(Missing)"
      ) %>% as_factor() %>% relevel(ref = "never married")
    )
  
  return(d_out)
}

wrangle_dependents <- function(d_in){
  # NOTE: First trust survey, if missing, reach for admin 
  
  # d_out <- is_source
  # browser
  d_out <-
    d_in %>%
    mutate(
      dependent4 = case_when(
        total_dependent_count == 0L ~  "0 dependents"
        ,total_dependent_count == 1L ~  "1 dependent"
        ,total_dependent_count == 2L ~  "2 dependents"
        ,total_dependent_count >= 3L ~  "3+ dependents"
        ,TRUE ~ "(Missing)"
      ) %>% as_factor() %>% relevel(ref = "0 dependents")
      ,dependent2 = case_when(
        total_dependent_count == 0L ~ "0 dependents"
        ,total_dependent_count >= 1L ~  "1+ dependents"
        ,TRUE ~ "(Missing)"
      ) %>% as_factor() %>% relevel(ref = "0 dependents")
    )
  return(d_out)
}

wrangle_ethnicity <- function(d_in){
  # d_out <- is_source
  # browser()
  d_out <-
    d_in %>%
    mutate(
      ethnicity = case_when(
        (aboriginal_flag == "Y") | (aboriginal_status_self_declared_flag == "Y") ~ "Indigenous"
        ,(visible_minority_flag == "Y") | (visible_minority_self_declared_flag == "Y") ~ "Visible Minority"
        ,(visible_minority_flag == "N") | (visible_minority_self_declared_flag == "N") ~ "Caucasian"
        ,TRUE ~ "(Missing)"
      ) %>% as.factor() %>% relevel(ref = "Caucasian")
    )
  return(d_out)
}

wrangle_disability <- function(d_in){
  # d_out <- is_source
  # browser()
  d_out <-
    d_in %>%
    mutate(
      disability2 = case_when(
        disability_flag == "Y" ~ TRUE
        ,disability_self_declared_flag == "Y" ~ TRUE
        ,TRUE ~ FALSE
      )
      ,disability3 = case_when(
        disability2 ~ "With Disability"
        ,disability_flag == "N" ~ "No Disability"
        ,disability_self_declared_flag == "N" ~ "No Disability"
        ,TRUE ~ "(Missing)"
      ) %>% as_factor() %>% relevel(ref = "(Missing)")
    )
  # There is no disability type variable to wrangle
  return(d_out)
}

wrangle_immigration <- function(d_in){
  d_out <- 
    d_in %>% 
    mutate(
      immigration = case_when(
        (immigrant_flag == "Y") | (immigrant_self_declared_flag == "Y") ~ "immigrant"
        ,(immigrant_flag == "N") | (immigrant_self_declared_flag == "N") ~ "born in Canada"
        ,TRUE ~ "(Missing)"
      ) %>% as.factor() %>% relevel(ref = "born in Canada")
    )
  return(d_out)
}

wrangle_education <- function(d_in){
  less_high_school <- c(
    "Grade 1"
    ,"Grade 2"
    ,"Grade 3"
    ,"Grade 4"
    ,"Grade 5"
    ,"Grade 6"
    ,"Grade 7"
    ,"Grade 8"
    ,"Grade 9"
    ,"Grade 10"
    ,"Grade 11"
  )
  high_school <- c(
    "Grade 12"
    ,"Grade 13"
    ,"General Equivalency Diploma"
    ,"High School Diploma"
  )
  more_high_school <- c(
    "Certificate"
    ,"Journeyman"
    ,"Journeyperson Certificate"
    ,"College Ent"
    ,"2 Yr Diploma"
    ,"1 Yr Diploma"
    ,"Bachelor Degree"
    ,"1 Year"
    ,"2 Years"
    ,"1st Year Apprentice"
    ,"Applied Degree"
    ,"Community Adult Learning Course(s)"
    ,"2nd Year Apprentice"
    ,"Master Degree"
    ,"4th Year Apprentice"
    ,"Some Post Secondary"
    ,"3rd Year Apprentice"
    ,"Doctorate Degree"
    ,"Apprenticing"
    ,"Tech Cert / College D"
    ,"University"
  )
  university <- c(
    "Bachelor Degree"
    ,"Master Degree"
    ,"Doctorate Degree"
    ,"Applied Degree"
    ,"University"
  )
  d0 <-
    d_in %>%
    mutate(
      education3 = case_when(
        highest_education_level %in% less_high_school  ~ "Less HS"
        ,highest_education_level %in% high_school      ~ "High School"
        ,highest_education_level %in% more_high_school ~ "More HS"
        ,TRUE ~ "(Missing)"
      ) %>% factor(levels = c("(Missing)", "Less HS", "High School", "More HS"))
    )
  d_out <- d0 %>% 
    mutate(
      education4 = case_when(
        highest_education_level %in% university        ~ "University Degree"
        ,highest_education_level %in% less_high_school ~ "Less HS"
        ,highest_education_level %in% high_school      ~ "High School"
        ,highest_education_level %in% more_high_school ~ "Post HS"
        ,TRUE ~ "(Missing)"
      ) %>% factor(levels = c("(Missing)", "Less HS", "High School", "Post HS", "University Degree"))
    )
  return(d_out)
}

#+ tweak-data-3 --------------------------------------------------------------
# Let's wrangle them into a typical format we use for demographic variables.

ds3 <- 
  ds2 %>% 
  wrangle_age() %>% 
  wrangle_sex() %>% 
  wrangle_marital() %>% 
  wrangle_dependents() %>% 
  wrangle_ethnicity() %>% 
  wrangle_disability %>% 
  wrangle_immigration() %>% 
  wrangle_education()

ds3 %>% glimpse()
# New variables:
# $ age_category3 <fct>
# $ age_category5 <fct>
# $ age_in_years  <int>
# $ sex3          <fct>
# $ sex2          <fct>
# $ marital2      <fct>
# $ marital3      <fct>
# $ dependent4    <fct>
# $ dependent2    <fct>
# $ ethnicity     <fct>
# $ disability2   <lgl>
# $ disability3   <fct>
# $ immigration   <fct>
# $ education3    <fct>
# $ education4    <fct>

#+ inspect-data-2 ------------------------------------------------------------

# Let's create for each demographic variable created in ds2-to-ds3 step
# a table with counts and percentages of each level
cat("\014")
d2 <- ds3 %>% 
  # mutate(
  #   client_type_code = paste0(client_type_code," - ", client_type) %>% as.factor()
  # ) %>% 
  select(
    spell_bit_order 
    ,spell_number 
    ,spell_bit_number
    ,spell_bit_duration
    ,program_class2
    ,client_type_code
    # demographic variables
    ,sex2
    ,age_category3
    ,marital2
    ,marital3
    ,dependent2
    ,dependent4
    ,disability2
    ,disability3
    ,education3
    ,education4
    ,ethnicity
    ,immigration
  ) %>% glimpse() %>% 
  mutate_at(c("spell_bit_order", "spell_number", "spell_bit_number", "spell_bit_duration")
            # function that turns every number greater than 10 into 11
            , ~ ifelse(. > 10, 11L, .) %>% as.integer
            ) %>%
  mutate_at(c("spell_bit_order", "spell_number", "spell_bit_number", "spell_bit_duration"), as.factor) %>%
  mutate_at(c("program_class2"), as.factor)

d2 %>% tableone::CreateTableOne(data = .)
d2 %>% 
  select(-spell_number, -spell_bit_number) %>% 
  filter(spell_bit_order %in% as.character(c(1:5))) %>% 
  tableone::CreateTableOne(data = ., strata = "spell_bit_order")



#+ write-to-db -------------------------------------------------------------
# Upload research cohort
OuhscMunge::upload_sqls_odbc(
  d = ds3,
  schema_name = "P20250625",
  table_name = "ds_ellis",
  dsn_name = "RESEARCH_PROJECT_CACHE_UAT",
  clear_table = TRUE,
  create_table = TRUE
)

ds3 %>% arrow::write_parquet(
  sink = paste0(data_private_derived, "2-ellis-ds3.parquet")
)