#' ---
#' title: "Ferry to Cache"
#' author: "Andriy Koval"
#' date: "Last Updated: `r Sys.Date()`"
#' ---
#+ echo=F

# rmarkdown::render(input = "./manipulation/0-ferry-to-cache.R")

#+ echo=F ----------------------------------------------------------------------
# Ingest ./ai/RDB-manifest.md to understand the structure of the data sources.
rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run.
cat("\014") # Clear the console

#+ mission -------------------------------------------------------------
# Bring over several tables into the P20250625 schema.
# Tables: research cohort, assessments (EA_EVENTS), EA_Barriers, ERA_Barriers, ES_EVENTS.
# Filter data to PERSON_OID in the research cohort.

#+ load-packages -----------------------------------------------------------
library(magrittr)
library(dplyr)
library(DBI)
library(odbc)
library(arrow)
library(janitor)
library(OuhscMunge)

#+ load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R")
base::source("./scripts/operational-functions.R")

#+ declare-globals ---------------------------------------------------------
target_window_opens  <- as.Date("2015-01-01")
target_window_closes <- as.Date("2025-06-25")
target_window <- c(target_window_opens, target_window_closes)

#+ declare-functions -------------------------------------------------------
truncate_strings <- function(df, max_length = 255) {
  # Truncate string columns to a maximum length
  string_cols <- sapply(df, is.character)
  df[string_cols] <- lapply(df[string_cols], function(x) {
    ifelse(nchar(x) > max_length, substr(x, 1, max_length), x)
  })
  return(df)
}

#+ define-queries ----------------------------------------------------------
# Research cohort: anyone who had IS episode OR assessment since 2015
sql_research_cohort <- "
WITH research_cohort AS (
  -- People with IS spells since 2015
  SELECT PERSON_OID
  FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC2_IS_SPELLS]
  WHERE PERIOD_START >= '2015-01-01'
  
  UNION
  
  -- People with assessments since 2015
  SELECT PERSON_OID
  FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC_EA_EVENTS]
  WHERE ASSESSMENT_DATE >= '2015-01-01'
),
research_cohort_sub AS (
  SELECT DISTINCT TOP 1000 PERSON_OID
FROM research_cohort
)

SELECT person_oid 
FROM research_cohort;
-- FROM research_cohort_sub;
"
# the definition of the cohort in the lines immediately above must be the same
# in all other subsequent queries, so that the cohort is consistent across all tables.
# When deviations are detected, refer to above as the source of truth and update the query accordingly.

# let's select episodes of financial support (defined as SPELL_BITS)
sql_fs_episodes <- "
WITH research_cohort AS (
  -- People with IS spells since 2015
  SELECT PERSON_OID
  FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC2_IS_SPELLS]
  WHERE PERIOD_START >= '2015-01-01'
  
  UNION
  
  -- People with assessments since 2015
  SELECT PERSON_OID
  FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC_EA_EVENTS]
  WHERE ASSESSMENT_DATE >= '2015-01-01'
),
research_cohort_sub AS (
  SELECT DISTINCT TOP 1000 PERSON_OID
FROM research_cohort
)

SELECT *
FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC2_IS_SPELL_BITS]
WHERE PERSON_OID IN (
SELECT PERSON_OID FROM research_cohort
-- SELECT PERSON_OID FROM research_cohort_sub
)
;
"

sql_es_events <- "
WITH research_cohort AS (
  -- People with IS spells since 2015
  SELECT PERSON_OID
  FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC2_IS_SPELLS]
  WHERE PERIOD_START >= '2015-01-01'
  
  UNION
  
  -- People with assessments since 2015
  SELECT PERSON_OID
  FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC_EA_EVENTS]
  WHERE ASSESSMENT_DATE >= '2015-01-01'
),
research_cohort_sub AS (
  SELECT DISTINCT TOP 1000 PERSON_OID
FROM research_cohort
)

SELECT *
FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC_ES_SERVICES]
WHERE PERSON_OID IN (
SELECT PERSON_OID FROM research_cohort
-- SELECT PERSON_OID FROM research_cohort_sub
)
;
"

sql_assessments <- "
WITH research_cohort AS (
  -- People with IS spells since 2015
  SELECT PERSON_OID
  FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC2_IS_SPELLS]
  WHERE PERIOD_START >= '2015-01-01'
  
  UNION
  
  -- People with assessments since 2015
  SELECT PERSON_OID
  FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC_EA_EVENTS]
  WHERE ASSESSMENT_DATE >= '2015-01-01'
),
research_cohort_sub AS (
   SELECT DISTINCT TOP 1000 PERSON_OID
FROM research_cohort
)

SELECT *
FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC_EA_EVENTS]
WHERE PERSON_OID IN (
SELECT PERSON_OID FROM research_cohort
-- SELECT PERSON_OID FROM research_cohort_sub
)
;
"

sql_ea_barriers <- "
WITH research_cohort AS (
  -- People with IS spells since 2015
  SELECT PERSON_OID
  FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC2_IS_SPELLS]
  WHERE PERIOD_START >= '2015-01-01'
  
  UNION
  
  -- People with assessments since 2015
  SELECT PERSON_OID
  FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC_EA_EVENTS]
  WHERE ASSESSMENT_DATE >= '2015-01-01'
),
research_cohort_sub AS (
  SELECT DISTINCT TOP 1000 PERSON_OID
FROM research_cohort
)

SELECT *
FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC_EA_BARRIERS]
WHERE PERSON_OID IN (
SELECT PERSON_OID FROM research_cohort
-- SELECT PERSON_OID FROM research_cohort_sub
)
;
"

sql_era_barriers <- "
WITH research_cohort AS (
  -- People with IS spells since 2015
  SELECT PERSON_OID
  FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC2_IS_SPELLS]
  WHERE PERIOD_START >= '2015-01-01'
  
  UNION
  
  -- People with assessments since 2015
  SELECT PERSON_OID
  FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC_EA_EVENTS]
  WHERE ASSESSMENT_DATE >= '2015-01-01'
),
research_cohort_sub AS (
  SELECT DISTINCT TOP 1000 PERSON_OID
FROM research_cohort
)

SELECT erb.*
FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC_ERA_BARRIERS] erb
WHERE EDB_SERVICE_ID IN (
  SELECT EDB_SERVICE_ID
  FROM [C-GOA-SQL-10477].[CAO_PROD].[dbo].[TC_EA_EVENTS]
  WHERE PERSON_OID IN (
  SELECT PERSON_OID FROM research_cohort
  -- SELECT PERSON_OID FROM research_cohort_sub
  )
)
"

#+ load-data ---------------------------------------------------------------
dsn <- "CAO_PROD" # one per database, typically in config file
cnn <- DBI::dbConnect(odbc::odbc(), dsn = dsn) # open the connection

# Load research cohort
ds_research_cohort <- DBI::dbGetQuery(cnn, sql_research_cohort)
ds_research_cohort <- ds_research_cohort 

# Load financial support episodes
ds_fs_episodes <- DBI::dbGetQuery(cnn, sql_fs_episodes)
ds_fs_episodes <- ds_fs_episodes %>%
  # janitor::clean_names() %>%
  truncate_strings(max_length = 253)

# Load ES events/services
ds_es_events <- DBI::dbGetQuery(cnn, sql_es_events)
ds_es_events <- ds_es_events %>%
  # janitor::clean_names() %>%
  truncate_strings(max_length = 253)


# Load assessments  
ds_assessments <- DBI::dbGetQuery(cnn, sql_assessments)
ds_assessments <- ds_assessments %>%
   # janitor::clean_names() %>%
  # let's enforce unicode strings
  # mutate(across(where(is.character), ~ iconv(., to = "UTF-8", sub = "byte"))) %>%
   truncate_strings(max_length = 253)

# Load EA barriers
ds_ea_barriers <- DBI::dbGetQuery(cnn, sql_ea_barriers)
ds_ea_barriers <- ds_ea_barriers %>%
  # janitor::clean_names() %>%
  truncate_strings(max_length = 253)

# Load ERA barriers
ds_era_barriers <- DBI::dbGetQuery(cnn, sql_era_barriers)
ds_era_barriers <- ds_era_barriers %>%
  # janitor::clean_names() %>%
  truncate_strings(max_length = 253)

DBI::dbDisconnect(cnn) # hang up the phone


# # count maximum num of characters in each columns
# ds_assessments %>% 
#   select(-PERSON_OID) %>% # remove PERSON_OID, as it is not a variable
#   summarise(across(everything(), ~ max(nchar(as.character(.)), na.rm = TRUE))) %>%
#   pivot_longer(cols = everything(), names_to = "variable", values_to = "max_length") %>%
#   arrange(desc(max_length)) %>% 
#   print_all()
# # Upload assessments events (EA,SND,NI,ERA)
# OuhscMunge::upload_sqls_odbc(
#   d = ds_assessments,
#   schema_name = "P20250625",
#   table_name = "EA_EVENTS",
#   dsn_name = "RESEARCH_PROJECT_CACHE_UAT",
#   clear_table = TRUE,
#   create_table = TRUE
# )


#+ write-to-db -------------------------------------------------------------
# Upload research cohort
OuhscMunge::upload_sqls_odbc(
  d = ds_research_cohort,
  schema_name = "P20250625",
  table_name = "RESEARCH_COHORT",
  dsn_name = "RESEARCH_PROJECT_CACHE_UAT",
  clear_table = TRUE,
  create_table = TRUE
)

# Upload financial support episodes
OuhscMunge::upload_sqls_odbc(
  d = ds_fs_episodes,
  schema_name = "P20250625",
  table_name = "FS_EPISODES",
  dsn_name = "RESEARCH_PROJECT_CACHE_UAT",
  clear_table = TRUE,
  create_table = TRUE
)
# Upload ES events/services
OuhscMunge::upload_sqls_odbc(
  d = ds_es_events,
  schema_name = "P20250625",
  table_name = "ES_SERVICES",
  dsn_name = "RESEARCH_PROJECT_CACHE_UAT",
  clear_table = TRUE,
  create_table = TRUE
)

# Upload assessments events (EA,SND,NI,ERA)
OuhscMunge::upload_sqls_odbc(
  d = ds_assessments,
  schema_name = "P20250625",
  table_name = "EA_EVENTS",
  dsn_name = "RESEARCH_PROJECT_CACHE_UAT",
  clear_table = TRUE,
  create_table = TRUE
)

# Upload Barriers Questionnaires from EA, SND, and NI surveys
OuhscMunge::upload_sqls_odbc(
  d = ds_ea_barriers,
  schema_name = "P20250625",
  table_name = "EA_BARRIERS",
  dsn_name = "RESEARCH_PROJECT_CACHE_UAT",
  clear_table = TRUE,
  create_table = TRUE
)
# Upload Barriers Questionnaires from ERA survey
OuhscMunge::upload_sqls_odbc(
  d = ds_era_barriers,
  schema_name = "P20250625",
  table_name = "ERA_BARRIERS",
  dsn_name = "RESEARCH_PROJECT_CACHE_UAT",
  clear_table = TRUE,
  create_table = TRUE
)

