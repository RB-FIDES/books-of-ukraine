<!-- INstructions to AI agent:
1. refer to  `./ai/RDB-manifest.md` to understand the structure and naming conventions of initial data.
2. refer to `./manipulation/0-ferry-to-cache.R` script to understand how it changes the data, which is being brought over to the cache of the project.
3. 
-->

# CACHE Manifest

This document serves as a comprehensive guide to the data structure and organization of the CACHE. It provides a reference for understanding the data sources, their relationships, and how they are utilized in research projects.

The CACHE is designed to support the mission of the project by offering a streamlined and accessible repository of data derived from the RDB. It facilitates analysis and decision-making by ensuring clarity and consistency in data handling.

---

# CACHE Overview


## FERRY LOAD 

The CACHE is populated through a ferry load process that extracts data from the various sources and moves them to project CACHE.

- **Schema**: `P20250625`
   - **`BASE_COHORT`**: Roster for BASE research cohort. Primary Key: `person_oid`.
   - **`FS_EPISODES`**: Financial support episodes (Spell bits) of BASE cohort. Primary Keys: `person_oid`, `period_start`.
   - **`ES_SERVICES`**: Training and employment service events for BASE cohort. Primary Key: `edb_service_id`.
   - **`EA_EVENTS`**: Assessment events (EA, SND, NI, ERA) of BASE cohort. Primary Key: `edb_service_id`.
   - **`EA_BARRIERS`**: Employability assessment responses (EA, SND, NI) captured at events. Primary Key: `edb_service_id`.
   - **`ERA_BARRIERS`**: Employability readiness assessment (ERA) responses. Primary Key: `edb_service_id`.
   - **`EA_DECISION`**: EA decision events for BASE cohort. Primary Key: `compass_Assessment_ID`.

## ELLIS ISLAND

- **Schema**: `P20250625`
- **`ds_ellis`**: Analysis-ready data table groomed by the `./manipulation/2-ellis.R` script, preparing for more focused analysis. Uses ANALYSIS1 cohort definition for focus.

> NOTE on COHORT: `ds_ellis` contains records for **ANALYSIS1** cohort, a subset of the BASE cohort. **ANALYSIS1** cohort narrows BASE down to individuals for whom the event of receiving Income Support benefits the first time in their lives took place on or after `2015-01-01`. This is done to focus on a specific group of clients who are more likely to benefit from our analysis.

---

## ELLIS ISLAND ERA


## CACHE MANIFEST

Based on RDB-manifest, 0-ferry-to-cache.R, and 2-ellis.R scripts, the following manifest guides working with `P20250625` schema in the CACHE.

### Data Flow & Transformations

**FERRY LOAD → ELLIS ISLAND → ANALYSIS-READY**
- **Raw RDB** → **CACHE (P20250625)** → **Analysis Dataset (ds_ellis)**

---

## P20250625 Schema Tables

### FERRY LOAD Tables (Raw Import)

| **Table Name** | **Primary Key(s)** | **Purpose** | **Source Query** |
|----------------|-------------------|-------------|------------------|
| **`RESEARCH_COHORT`** | `PERSON_OID` | BASE cohort roster: anyone with IS spells OR assessments since 2015-01-01 | `sql_research_cohort` |
| **`FS_EPISODES`** | `PERSON_OID` + `PERIOD_START` | Financial support spell bits for BASE cohort | `sql_fs_episodes` |
| **`ES_SERVICES`** | `EDB_SERVICE_ID` | Training and employment service events for BASE cohort | `sql_es_events` |
| **`EA_EVENTS`** | `EDB_SERVICE_ID` | Assessment events (EA, SND, NI, ERA) for BASE cohort | `sql_assessments` |
| **`EA_BARRIERS`** | `EDB_SERVICE_ID` | Employability assessment barrier responses (EA, SND, NI) | `sql_ea_barriers` |
| **`ERA_BARRIERS`** | `EDB_SERVICE_ID` | Employment Readiness Assessment barrier responses | `sql_era_barriers` |
| **`EA_DECISION`** | `COMPASS_ASSESSMENT_ID` | EA decision outcomes for BASE cohort | `sql_ea_decision` |

### Stream Classification & Eligibility Tracing

**Client Streams**: Income Support clients are segmented into three streams based on their employment readiness and barriers:
- **Stream A**: Job-ready clients with minimal barriers to employment
- **Stream B**: Clients with moderate barriers requiring assessment and intervention
- **Stream C**: Clients with significant barriers to employment requiring intensive support

**Eligibility Decision Tracing**: The `COMPASS_ASSESSMENT_ID` serves as the critical link for tracing eligibility decisions:
- **Links**: `EA_EVENTS.COMPASS_ASSESSMENT_ID` ↔ `EA_DECISION.COMPASS_ASSESSMENT_ID`
- **Purpose**: Enables tracking of assessment outcomes (approved/denied) for clients across different streams
- **Research Focus**: Particularly important for **Stream B** clients who undergo Intake and Employment Readiness Assessment (ERA)
- **Decision Outcomes**: Captures approval/denial decisions that determine eligibility for Income Support and subsequent service pathways

### ELLIS ISLAND Tables (Analysis-Ready)

| **Table Name** | **Primary Key(s)** | **Purpose** | **Cohort Definition** |
|----------------|-------------------|-------------|----------------------|
| **`ds_ellis`** | `PERSON_OID` + `PERIOD_START` | Analysis-ready Income Support episodes with demographics | **ANALYSIS1 Cohort** |
| **`ANALYSIS2_ERA_EVENT`** | `PERSON_OID` + `COMPASS_ASSESSMENT_ID` | ERA assessments with longitudinal tracking and eligibility decisions | **ANALYSIS2 Cohort** |
| **`ds_trajectory_groups`** | `PERSON_OID` | ERA-to-Income Support trajectory analysis dataset linking approved ERA assessments to subsequent IS episodes | **TRAJECTORY Cohort** |

---

## Cohort Definitions

### BASE Cohort (FERRY LOAD)
- **Definition**: Anyone with Income Support spells OR assessments since 2015-01-01
- **Query Logic**:
  ```sql
  -- People with IS spells since 2015
  SELECT PERSON_OID FROM TC2_IS_SPELLS WHERE PERIOD_START >= '2015-01-01'
  UNION
  -- People with assessments since 2015  
  SELECT PERSON_OID FROM TC_EA_EVENTS WHERE ASSESSMENT_DATE >= '2015-01-01'
  ```
- **Size**: ~Full cohort from source systems

### ANALYSIS1 Cohort (ELLIS ISLAND)
- **Definition**: Individuals whose **first-ever Income Support episode** started on or after 2015-01-01
- **Rationale**: Focus on clients entering IS system during study period for enhanced interpretability
- **Filters Applied**:
  - `program_class0 == "Financial Support"`
  - `program_class1 == "Income Support"` (excludes OTI single-day events)
  - `person_oid > 0` (excludes training cases)
  - `spell_bit_order == 1 & first_is_after_2015 == TRUE`
  - `spell_bit_duration > 0`
- **Key Variables Added**:
  - `spell_bit_order`: Sequential order of episodes per person
  - `first_is_after_2015`: Boolean flag for first IS episode timing

### ANALYSIS2 Cohort (ELLIS ISLAND ERA)
- **Definition**: Individuals with completed ERA assessments and linked eligibility decisions since 2015-01-01
- **Rationale**: Track client evolution through multiple ERA assessments and decision patterns
- **Filters Applied**:
  - `ASSESSMENT_TYPE == "ERA"`
  - `!is.na(completed_date)` (assessment completed)
  - `!is.na(decision)` (decision available)
  - `!is.na(stream) & stream != ""` (valid stream classification)
  - `age_as_of_asmt_date_in_years` between 15-100
- **Key Variables Added**:
  - `era_assessment_order`: Sequential order of ERA assessments per person
  - `is_first_era`: Boolean flag for first ERA assessment
  - `approved`: Binary variable (1 if "Approved", 0 if "Denied")
  - `decision_changed`: Tracks changes in decision patterns across assessments
  - `stream_changed`: Tracks changes in stream classification over time

**IMPORTANT**: Approval rate calculations exclude "ApprovedOneTime", "Withdrawn", and "Duplicate" decisions. See `./ai/method.md` for detailed rationale.

### TRAJECTORY Cohort (ERA-to-Income Support Linkage)
- **Definition**: Individuals with approved ERA assessments (Groups 1 & 2) linked to subsequent Income Support episodes within 3 months
- **Rationale**: Analyze Income Support usage patterns following ERA approval decisions to test for "scarring effects" and pathway differences
- **Source Data**: `ANALYSIS2_ERA_EVENT` (ERA approvals) + `ds_ellis` (Income Support episodes)
- **Linkage Logic**:
  - **Groups 1 & 2 Only**: Group 1 (Direct Approval), Group 2 (Approved After Denial)
  - **First Approval Focus**: `date_of_first_approval` extracted from chronologically first "Approved" decision per person
  - **Episode Matching**: Income Support episodes starting within 3 months after first ERA approval (`date_start >= date_of_first_approval` AND `date_start <= date_of_first_approval + 3 months`)
  - **Temporal Sequence**: First IS episode selected if multiple matches per person
- **Key Variables Created**:
  - `date_of_first_approval`: Date of person's first ERA approval decision
  - `trajectory_group`: "Direct Approval" vs "Approved After Denial"
  - `days_era_to_is`: Days between ERA approval and IS episode start
  - `has_linked_is_episode`: Boolean for successful ERA→IS linkage
  - `valid_trajectory`: Combined flag for valid linkage with consistent demographics
  - `is_episode_duration_days`: Duration of linked Income Support episode
- **Research Purpose**: Compare Income Support duration, usage patterns, and outcomes between direct approval vs post-denial approval pathways
- **Linkage Rate**: 11.5% (3,806 of 33,240 ERA approvals linked to IS episodes)

---

## Key Data Transformations

### Demographics Standardization (ds_ellis)
**Wrangled Variables Created**:

| **Domain** | **Variables** | **Levels/Categories** |
|------------|---------------|----------------------|
| **Age** | `age_category3`, `age_category5`, `age_in_years` | 3-level: 15-24, 25-54, 55+; 5-level: 15-24, 25-34, 35-44, 45-54, 55+ |
| **Sex** | `sex2`, `sex3` | Male/Female/(Missing); Male/Female/X/(Missing) |
| **Marital** | `marital2`, `marital3` | married/single; together/apart/never married |
| **Dependents** | `dependent2`, `dependent4` | 0/1+; 0/1/2/3+ dependents |
| **Ethnicity** | `ethnicity` | Indigenous/Visible Minority/Caucasian/(Missing) |
| **Disability** | `disability2`, `disability3` | Boolean; With Disability/No Disability/(Missing) |
| **Immigration** | `immigration` | immigrant/born in Canada/(Missing) |
| **Education** | `education3`, `education4` | Less HS/High School/More HS; adds University Degree category |

### Program Classification Integration
- **Taxonomy Linkage**: `FS_EPISODES` joined with `PROGRAM_CLASS` via `client_type_code`
- **Classification Hierarchy**: `program_class0` → `program_class1` → `program_class2` → `program_class3`
- **Research Variables**: `pc0`, `pc1`, `pc2`, `fs_type`, `program_group`

---

## Business Rules & Data Quality

### Episode Definition
- **Spell Bit**: Stable segment within spell (constant `client_type_code` + `role_type_start`)
- **Financial Support Focus**: Only `program_class1 == "Income Support"` (excludes OTI single-day events)
- **Positive Duration**: `spell_bit_duration > 0` ensures meaningful episodes

### Demographic Data Integrity
- **Age Range**: Valid ages 15-80 years (`age_in_years`)
- **String Truncation**: Max 253 characters applied during ferry load
- **Missing Data Handling**: Explicit "(Missing)" categories for all demographic factors

### Temporal Boundaries
- **Study Window**: 2015-01-01 to 2025-06-25
- **First Episode Logic**: `date_start >= '2015-01-01' & date_start == min(date_start)`
- **Cohort Homogeneity**: All ANALYSIS1 individuals share "first IS experience" timeline

---

## Usage Guidelines

### For Analysis Queries
1. **Use `ds_ellis`** for modeling duration of income support (ANALYSIS1 cohort)
2. **Join with `EA_EVENTS`** via `PERSON_OID` for assessment linkage  
3. **Join with `EA_DECISION`** for approval/denial outcomes using `COMPASS_ASSESSMENT_ID`
4. **Filter by `spell_bit_order`** for first episode vs. subsequent episodes
5. **Segment by Stream** (A, B, C) for targeted analysis of client populations with different barrier profiles

### For Linking Tables
- **Person-Level**: `PERSON_OID` (universal identifier)
- **Assessment-Level**: `EDB_SERVICE_ID` (links EA_EVENTS, EA_BARRIERS, ERA_BARRIERS)
- **Decision-Level**: `COMPASS_ASSESSMENT_ID` (links EA_EVENTS to EA_DECISION for eligibility outcomes)
- **Temporal**: `PERIOD_START`/`PERIOD_END` for episode timing

### Data Export Locations
- **Database**: `[RESEARCH_PROJECT_CACHE_UAT].[P20250625].[ds_ellis]`
- **Parquet**: `./data-private/derived/manipulation/2-ellis-ds3.parquet`
- **Database**: `[RESEARCH_PROJECT_CACHE_UAT].[P20250625].[ANALYSIS2_ERA_EVENT]`
- **Parquet**: `./data-private/derived/manipulation/3-ellis-era-analysis2.parquet`

## Key Metric Definitions

### Approval Rate (ERA Decisions)
**Formula**: `(Approved decisions) / (Approved + Denied decisions) × 100`

**Exclusions**: 
- "ApprovedOneTime" (emergency assistance, not IS eligibility)
- "Withdrawn" (incomplete applications)  
- "Duplicate" (administrative duplicates)

Only substantive eligibility decisions ("Approved" + "Denied") are included in the denominator. See `./ai/method.md` for complete rationale.

---

## ANALYSIS2_ERA_EVENT Table Schema

**Source**: `./manipulation/3-ellis-era.R`  
**Purpose**: Comprehensive ERA assessment data with longitudinal tracking capabilities  
**Grain**: One record per ERA assessment per person (multiple assessments per person retained)

### Core Identifiers

| **Variable** | **Type** | **Source** | **Description** |
|--------------|----------|------------|-----------------|
| `person_oid` | Integer | EA_EVENTS | Unique person identifier - links to all other tables |
| `compass_assessment_id` | String | EA_EVENTS | Unique assessment identifier - links to EA_DECISION |
| `edb_service_id` | String | EA_EVENTS | Service event identifier - links to barrier tables |

### Assessment Context & Sequencing ⭐

| **Variable** | **Type** | **Source** | **Description** |
|--------------|----------|------------|-----------------|
| `assessment_date` | Date | EA_EVENTS | Date ERA assessment was conducted |
| `assessment_year` | Integer | **⭐ 3-ellis-era** | Year of assessment - enables temporal analysis |
| `assessment_month` | Integer | **⭐ 3-ellis-era** | Month of assessment - seasonal patterns |
| `era_assessment_order` | Integer | **⭐ 3-ellis-era** | Sequential order (1,2,3...) of ERA assessments per person |
| `is_first_era` | Boolean | **⭐ 3-ellis-era** | TRUE if person's first ERA assessment - baseline analysis |
| `total_assessments_for_person` | Integer | **⭐ 3-ellis-era** | Total ERA count per person - client complexity indicator |
| `stream` | String | EA_EVENTS | Client stream classification (A1, A2, B, C) |

**Why useful**: Sequential tracking enables studying client trajectories, policy impacts over time, and identifying patterns in reassessment behavior.

### Decision Outcomes & Timing

| **Variable** | **Type** | **Source** | **Description** |
|--------------|----------|------------|-----------------|
| `decision` | String | EA_DECISION | Original eligibility decision (Approved/Denied/Withdrawn/etc.) |
| `approved` | Binary | **⭐ 3-ellis-era** | 1 if approved (Approved OR ApprovedOneTime), 0 otherwise |
| `decision_reason` | String | EA_DECISION | Reason code for eligibility decision |
| `days_to_decision` | Integer | **⭐ 3-ellis-era** | Time from assessment to decision - processing efficiency |

**Why useful**: Binary approval variable simplifies modeling, days_to_decision reveals administrative efficiency patterns.

### Longitudinal Tracking Variables ⭐

| **Variable** | **Type** | **Source** | **Description** |
|--------------|----------|------------|-----------------|
| `previous_decision` | String | **⭐ 3-ellis-era** | Decision from person's previous ERA (lag analysis) |
| `previous_stream` | String | **⭐ 3-ellis-era** | Stream from person's previous ERA |
| `days_since_previous_assessment` | Integer | **⭐ 3-ellis-era** | Days between consecutive ERA assessments |
| `decision_changed` | String | **⭐ 3-ellis-era** | "Decision Changed"/"Unchanged"/"First Assessment" |
| `stream_changed` | String | **⭐ 3-ellis-era** | "Stream Changed"/"Unchanged"/"First Assessment" |

**Why useful**: Core variables for studying client trajectories, decision consistency, and service pathway evolution. Essential for longitudinal impact analysis and understanding client stability patterns.

### Demographics (Standardized) ⭐

| **Variable** | **Type** | **Source** | **Description** |
|--------------|----------|------------|-----------------|
| `age_as_of_asmt_date_in_years` | Integer | EA_EVENTS | Age at assessment date |
| `age_category3` | String | **⭐ 3-ellis-era** | 3-level age groups: "15-24", "25-54", "55+" |
| `age_category5` | String | **⭐ 3-ellis-era** | 5-level age groups: "15-24", "25-34", "35-44", "45-54", "55+" |
| `sex2` | String | **⭐ 3-ellis-era** | Standardized sex: "Male"/"Female"/"(Missing)" |
| `marital_status` | String | EA_EVENTS | Marital status at assessment |
| `dependent2` | String | **⭐ 3-ellis-era** | Dependents: "0" or "1+" |
| `total_dependent_count` | Integer | EA_EVENTS | Exact number of dependents |
| `highest_education_level` | String | EA_EVENTS | Education level at assessment |

**Why useful**: Standardized categories enable consistent analysis across cohorts. Age groupings align with policy-relevant life stages, dependent categorization captures household complexity.

### Equity-Seeking Groups

| **Variable** | **Type** | **Source** | **Description** |
|--------------|----------|------------|-----------------|
| `immigrant_flag` | String | EA_EVENTS | Immigrant status indicator |
| `visible_minority_flag` | String | EA_EVENTS | Visible minority status indicator |
| `aboriginal_flag` | String | EA_EVENTS | Indigenous status indicator |
| `disability_flag` | String | EA_EVENTS | Disability status indicator |

**Why useful**: Critical for equity analysis and understanding differential approval patterns across protected groups.

### Identified Barriers & Needs

| **Variable** | **Type** | **Source** | **Description** |
|--------------|----------|------------|-----------------|
| `primary_identified_need` | String | EA_EVENTS | Primary barrier to employment identified |
| `secondary_identified_need` | String | EA_EVENTS | Secondary barrier identified |

**Why useful**: Links approval decisions to specific client barriers, enables targeted intervention analysis.

### Geographic Context

| **Variable** | **Type** | **Source** | **Description** |
|--------------|----------|------------|-----------------|
| `client_region` | String | EA_EVENTS | Geographic region of client |

**Why useful**: Regional variation analysis, rural/urban differences in approval patterns.

---

### Variable Creation Logic (3-ellis-era.R)

**Longitudinal Variables**: Created using `group_by(person_oid) %>% arrange(assessment_date) %>% mutate()` pattern to ensure proper temporal sequencing.

**Standardization**: Demographics follow `2-ellis.R` patterns to enable cross-cohort comparisons while adapting to ERA-specific data structure.

**Binary Outcomes**: `approved` variable combines "Approved" and "ApprovedOneTime" decisions for simplified modeling while preserving original `decision` for detailed analysis.

**Temporal Features**: Assessment year/month extraction enables time-series analysis of policy changes and seasonal patterns.

### Analysis Applications

1. **Longitudinal Trajectory Modeling**: Use `era_assessment_order`, `decision_changed`, `stream_changed` 
2. **Approval Rate Analysis**: Use `approved` with demographic segmentation
3. **Client Stability Analysis**: Use `days_since_previous_assessment`, `total_assessments_for_person`
4. **Equity Analysis**: Cross-tabulate approval patterns by equity-seeking group flags
5. **Regional Comparison**: Analyze approval rates and client characteristics by `client_region`
6. **Barrier-Decision Linkage**: Connect `primary_identified_need` to approval outcomes

---

## ds_trajectory_groups Table Schema

**Source**: `./analysis/eda-2/eda-2.R` (duration-of-is section)  
**Purpose**: ERA-to-Income Support trajectory analysis linking approved assessments to subsequent IS episodes  
**Grain**: One record per person with approved ERA assessment linked to first subsequent IS episode within 3 months

### Core Identifiers & Trajectory Classification

| **Variable** | **Type** | **Source** | **Description** |
|--------------|----------|------------|-----------------|
| `person_oid` | Integer | ANALYSIS2_ERA_EVENT | Unique person identifier - universal linkage key |
| `trajectory_group` | String | **⭐ eda-2** | "Direct Approval" or "Approved After Denial" - primary research comparison groups |
| `comparison_group` | String | **⭐ eda-2** | Full group classification: "Group 1: Approved (No Prior Denial)" or "Group 2: Approved (After Denial)" |

### ERA Assessment Details ⭐

| **Variable** | **Type** | **Source** | **Description** |
|--------------|----------|------------|-----------------|
| `date_of_first_approval` | Date | **⭐ eda-2** | Date of person's chronologically first ERA approval decision - primary trajectory anchor |
| `first_approval_era_order` | Integer | ANALYSIS2_ERA_EVENT | Sequential order of the first approval within person's ERA sequence |
| `first_approval_stream` | String | ANALYSIS2_ERA_EVENT | Client stream (A1, A2, B, C) at time of first approval |
| `total_assessments` | Integer | **⭐ eda-2** | Total number of ERA assessments per person |
| `approved_count` | Integer | **⭐ eda-2** | Total number of approval decisions per person |
| `denied_count` | Integer | **⭐ eda-2** | Total number of denial decisions per person |
| `decision_sequence` | String | **⭐ eda-2** | Complete chronological sequence of ERA decisions (e.g., "Denied → Approved") |

### Income Support Episode Linkage ⭐

| **Variable** | **Type** | **Source** | **Description** |
|--------------|----------|------------|-----------------|
| `date_start` | Date | ds_ellis | Start date of linked Income Support episode |
| `date_end` | Date | ds_ellis | End date of linked Income Support episode |
| `days_era_to_is` | Integer | **⭐ eda-2** | Days between ERA approval and IS episode start - transition timing |
| `has_linked_is_episode` | Boolean | **⭐ eda-2** | TRUE if person has IS episode within 3 months of ERA approval |
| `valid_trajectory` | Boolean | **⭐ eda-2** | TRUE if linkage is valid (has episode + demographic consistency + positive days) |
| `is_episode_duration_days` | Integer | ds_ellis | Duration of linked Income Support episode in days |
| `is_episode_duration_months` | Numeric | **⭐ eda-2** | Duration of linked Income Support episode in months (days/30.44) |
| `spell_bit_order` | Integer | ds_ellis | Sequential order of this IS episode within person's IS history |

### Demographics & Consistency Checks

| **Variable** | **Type** | **Source** | **Description** |
|--------------|----------|------------|-----------------|
| `first_approval_age` | Integer | ANALYSIS2_ERA_EVENT | Age at time of first ERA approval |
| `age_in_years` | Integer | ds_ellis | Age at start of Income Support episode |
| `age_difference` | Integer | **⭐ eda-2** | Absolute difference between ERA age and IS age |
| `age_consistent` | Boolean | **⭐ eda-2** | TRUE if age difference ≤ 2 years (data quality check) |
| `first_approval_sex` | String | ANALYSIS2_ERA_EVENT | Sex recorded at ERA assessment |
| `first_approval_region` | String | ANALYSIS2_ERA_EVENT | Geographic region at ERA assessment |

### Research Variables & Program Classification

| **Variable** | **Type** | **Source** | **Description** |
|--------------|----------|------------|-----------------|
| `fs_type` | String | ds_ellis | Financial support type classification |
| `pc1` | String | ds_ellis | Program classification level 1 |
| `ethnicity` | String | ds_ellis | Ethnicity classification from Income Support data |
| `immigration` | String | ds_ellis | Immigration status from Income Support data |
| `disability2` | String | ds_ellis | Disability status (binary) from Income Support data |

**Why useful**: Enables comparison of Income Support usage patterns between those who received direct ERA approval versus those who were initially denied but later approved, testing for "scarring effects" and pathway differences.

### Key Research Applications

1. **Trajectory Comparison**: Compare `is_episode_duration_days` between `trajectory_group` values
2. **Transition Speed**: Analyze `days_era_to_is` patterns by approval pathway
3. **Linkage Success**: Model predictors of `has_linked_is_episode` and `valid_trajectory`
4. **Demographic Consistency**: Use consistency checks for data quality validation
5. **Longitudinal Analysis**: Link to additional IS episodes using `person_oid` for extended trajectory modeling

### Dataset Locations
- **Database**: `[RESEARCH_PROJECT_CACHE_UAT].[P20250625].[ds_trajectory_groups]`
- **CSV**: `./analysis/eda-2/data-local/ds_trajectory_groups.csv`
- **Records**: 3,806 ERA approvals with IS episode linkage (11.5% of all ERA approvals)

---