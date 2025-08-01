# CACHE Manifest Template

This document serves as a template for creating comprehensive guides to data structure and organization for research projects. It provides a reference framework for understanding data sources, their relationships, and how they are utilized in analytical workflows.

The CACHE is designed to support research missions by offering a streamlined and accessible repository of analysis-ready data derived from source systems. It facilitates analysis and decision-making by ensuring clarity and consistency in data handling.

---

# CACHE Overview

## FERRY LOAD PROCESS

The CACHE is populated through a ferry load process that extracts data from various source systems and transforms them into project-specific analysis-ready format.

- **Source Systems**: Primary data sources (databases, APIs, spreadsheets, external systems)
- **Ferry Scripts**: Data extraction, transformation, and loading workflows
- **Schema Organization**: Structured database schemas with consistent naming conventions
- **Output Format**: Analysis-ready tables optimized for research workflows

## CACHE STRUCTURE

The CACHE follows a multi-layered approach with consistent data organization patterns:

### Schema Organization
- **Primary Schema**: `[PROJECT_SCHEMA]` - Main analysis schema containing all processed tables
- **Table Naming**: Consistent prefixes and descriptive names (e.g., `ds_`, `ANALYSIS_`, `BASE_`)
- **Key Structure**: Standardized primary and foreign key relationships
- **Data Types**: Consistent type definitions across related tables

### Common Data Patterns
- **Entity Tables**: Core subject/unit tables with unique identifiers
- **Event Tables**: Time-sequenced observations or transactions
- **Classification Tables**: Categorical dimensions and taxonomies
- **Linkage Tables**: Relationship mappings between entities
- **Derived Tables**: Analysis-ready aggregations and calculations

---

## CACHE TABLES

### Ferry Load Tables (Raw Import Layer)

| **Table Name** | **Primary Key(s)** | **Purpose** | **Source System** |
|----------------|-------------------|-------------|-------------------|
| **`BASE_ENTITIES`** | `entity_id` | Core subject roster/registry | Primary source system |
| **`EVENT_RECORDS`** | `entity_id` + `event_date` | Transactional/event data | Event tracking system |
| **`CLASSIFICATION_DATA`** | `entity_id` + `classification_type` | Categorical classifications | Classification system |
| **`LINKAGE_RECORDS`** | `primary_id` + `secondary_id` | Relationship mappings | Linkage system |
| **`REFERENCE_DATA`** | `reference_id` | Lookup tables and metadata | Reference system |

### Analysis-Ready Tables (Processed Layer)

| **Table Name** | **Primary Key(s)** | **Purpose** | **Cohort/Filter** |
|----------------|-------------------|-------------|--------------------|
| **`ds_analysis_primary`** | `entity_id` + contextual keys | Main analytical dataset | Primary research cohort |
| **`ds_analysis_secondary`** | `entity_id` + sequence variables | Secondary analytical focus | Secondary research cohort |
| **`ds_longitudinal`** | `entity_id` + `sequence_order` | Time-sequenced analysis | Longitudinal tracking cohort |
| **`ds_crosssectional`** | `entity_id` + snapshot variables | Point-in-time analysis | Cross-sectional research cohort |

---

## Data Transformation Details

### BASE_ENTITIES (Foundation Table)
- **Definition**: Core registry of research subjects/units
- **Variables**: `entity_id`, `[core_attributes]`, `[demographic_variables]`
- **Coverage**: Complete population or sampling frame
- **Key Features**:
  - Unique identifier for all subsequent linkages
  - Standardized demographic/characteristic variables
  - Data quality flags and validation indicators

### EVENT_RECORDS (Transactional Data)
- **Definition**: Time-sequenced observations or transactions
- **Variables**: `entity_id`, `event_date`, `event_type`, `[event_attributes]`
- **Coverage**: Variable by event type and data availability
- **Key Features**:
  - Temporal sequencing capabilities
  - Event classification taxonomies
  - Linkage to entity characteristics
  - Duration and frequency calculations

### CLASSIFICATION_DATA (Categorical Dimensions)
- **Definition**: Categorical classifications and groupings
- **Variables**: `entity_id`, `classification_type`, `category_value`, `[classification_attributes]`
- **Coverage**: Variable by classification system
- **Key Features**:
  - Hierarchical category structures
  - Multiple classification schemes per entity
  - Temporal validity of classifications
  - Cross-classification analysis capabilities

### ds_analysis_primary (Main Research Dataset)
- **Definition**: Primary analytical dataset with research-specific transformations
- **Variables**: `entity_id`, `[research_variables]`, `[derived_measures]`
- **Coverage**: Defined by research cohort criteria
- **Key Features**:
  - Research-specific variable creation
  - Cohort filtering and selection logic
  - Standardized analytical variables
  - Quality assurance and validation flags

### ds_longitudinal (Sequential Analysis)
- **Definition**: Time-ordered observations for trajectory analysis
- **Variables**: `entity_id`, `sequence_order`, `observation_date`, `[tracking_variables]`
- **Coverage**: Entities with multiple observations over time
- **Key Features**:
  - Sequential ordering and tracking
  - Change detection variables
  - Longitudinal consistency checks
  - Trajectory classification capabilities

---

## Cohort Definitions and Data Transformations

### BASE Cohort (Ferry Load Layer)
- **Definition**: Complete population or sampling frame from source systems
- **Inclusion Logic**: All entities meeting basic data quality and completeness criteria
- **Size**: Full population as defined by source system scope
- **Usage**: Foundation for all subsequent analytical cohorts

### PRIMARY Research Cohort (Analysis Layer)
- **Definition**: Main research population with specific inclusion/exclusion criteria
- **Inclusion Logic**: [Project-specific research criteria]
- **Filters Applied**:
  - Data quality thresholds
  - Temporal boundaries
  - Characteristic-based selection
  - Completeness requirements
- **Key Variables Added**:
  - Research-specific derived measures
  - Standardized categorical variables
  - Quality flags and indicators

### SECONDARY Research Cohort (Specialized Analysis)
- **Definition**: Subset or alternative view of research population
- **Inclusion Logic**: [Secondary research focus criteria]
- **Specialized Features**:
  - Alternative variable definitions
  - Different temporal windows
  - Specialized quality criteria
  - Cross-cohort comparison capabilities

### LONGITUDINAL Cohort (Sequential Analysis)
- **Definition**: Entities with multiple observations enabling trajectory analysis
- **Inclusion Logic**: Minimum observation requirements and temporal spread
- **Key Features**:
  - Sequential ordering variables
  - Change tracking indicators
  - Consistency validation across observations
  - Trajectory classification variables

---

## Key Data Transformations

### Demographic Standardization
**Standardized Variables Created**:

| **Domain** | **Variables** | **Categories/Levels** |
|------------|---------------|----------------------|
| **Age** | `age_category`, `age_continuous` | Categorical groupings + continuous measure |
| **Geographic** | `region_level1`, `region_level2` | Hierarchical geographic classifications |
| **Classification** | `primary_class`, `secondary_class` | Domain-specific classification hierarchies |
| **Status** | `status_current`, `status_historical` | Current and historical status indicators |
| **Derived** | `calculated_measures`, `index_scores` | Research-specific calculated variables |

### Identifier Management and Linkage
- **Primary Keys**: Consistent entity identification across all tables
- **Foreign Keys**: Standardized linkage patterns between related tables
- **Sequence Variables**: Temporal or logical ordering within entities
- **Validation Keys**: Data quality and consistency checking identifiers

### Variable Harmonization
- **Categorical Standardization**: Consistent category definitions across sources
- **Missing Data Handling**: Explicit missing value categories and flags
- **Data Type Consistency**: Standardized formats for dates, numbers, text
- **Naming Conventions**: Consistent variable naming patterns throughout

---

## Data Quality and Business Rules

### Temporal Boundaries
- **Study Period**: [Define relevant time boundaries]
- **Data Availability**: Variable coverage by source system and data type
- **Update Cycles**: Frequency and timing of data refresh processes

### Data Quality Standards
- **Completeness Thresholds**: Minimum data completeness requirements
- **Consistency Checks**: Cross-table validation and logical consistency rules
- **Accuracy Validation**: Source verification and quality assurance processes

### Data Cleaning Rules Applied
1. **Identifier Validation**: Entity ID consistency and uniqueness checks
2. **Data Type Conversion**: Standardized formats and type consistency
3. **Missing Data Treatment**: Explicit handling and categorization of missing values
4. **Outlier Detection**: Statistical and logical outlier identification and treatment
5. **Consistency Validation**: Cross-table and cross-variable consistency checks

### Data Integrity Checks
- **Entity Consistency**: Same entity characteristics across tables
- **Temporal Logic**: Logical ordering and consistency of time-dependent data
- **Classification Validity**: Valid category assignments and hierarchical consistency
- **Linkage Integrity**: Successful joins and relationship validations

---

## Data Storage and Access

### File Formats and Locations

| **Format** | **Location** | **Purpose** |
|------------|--------------|-------------|
| **Database** | `[DATABASE_SERVER].[SCHEMA_NAME].[TABLE_NAME]` | Primary storage for analysis queries |
| **Parquet** | `./data-private/derived/manipulation/[dataset_name].parquet` | High-performance analysis format |
| **CSV** | `./data-private/derived/manipulation/CSV/[dataset_name].csv` | Universal format for sharing |
| **RDS** | `./data-private/derived/manipulation/[dataset_name].rds` | R-native format for analysis |
| **External** | [Web-accessible sharing platforms] | Stakeholder access and collaboration |

### Database Schema Organization

**Primary Schema Structure**:
- **Schema**: `[PROJECT_SCHEMA_NAME]`
- **Tables**: Organized by processing layer (raw, processed, analysis-ready)
- **Indexes**: Optimized for common query patterns and join operations
- **Permissions**: Appropriate access controls for different user types

### Query Optimization
- **Primary Keys**: Efficient unique identification and join operations
- **Foreign Keys**: Relationship integrity and join optimization
- **Indexes**: Performance optimization for common analytical queries
- **Partitioning**: Large table optimization strategies where applicable

---

## Usage Guidelines

### For Entity-Based Analysis
1. **Start with BASE_ENTITIES** for population definitions and characteristics
2. **Join with EVENT_RECORDS** using `entity_id` for behavioral/transactional analysis
3. **Link to CLASSIFICATION_DATA** for categorical segmentation and grouping
4. **Use analysis-ready tables** for research-specific variables and cohorts

### For Longitudinal Analysis
- **Sequential Analysis**: Use sequence variables for temporal ordering
- **Change Detection**: Leverage change-tracking variables for trend analysis
- **Trajectory Modeling**: Utilize longitudinal cohorts for pathway analysis
- **Consistency Validation**: Apply consistency checks for multi-observation entities

### For Cross-Sectional Analysis
- **Point-in-Time**: Use snapshot variables for cross-sectional comparisons
- **Demographic Segmentation**: Apply standardized categorical variables
- **Comparative Analysis**: Use consistent variable definitions across groups
- **Quality Filtering**: Apply data quality flags for analysis population definition

### For Linkage and Integration
- **Entity Linkage**: Use `entity_id` as universal linking key
- **Event Sequencing**: Apply temporal variables for chronological analysis
- **Classification Joining**: Link multiple classification schemes per analytical needs
- **Validation**: Use consistency flags to ensure data integrity in joins

### Data Export Recommendations
- **For Database Analysis**: Use native database connections for complex queries
- **For Statistical Software**: Use Parquet format for high-performance analytics
- **For Sharing**: Use CSV format with appropriate encoding for universal access
- **For R Analysis**: Use RDS format for native R data type preservation
- **For Visualization**: Use analysis-ready tables with pre-calculated variables

---

## Key Research Applications

### Primary Research Capabilities
1. **Entity Characterization**: Demographic and characteristic profiling
2. **Behavioral Analysis**: Event patterns and transactional behaviors
3. **Classification Analysis**: Category-based segmentation and comparison
4. **Longitudinal Tracking**: Time-based trajectory and change analysis
5. **Cross-Sectional Comparison**: Point-in-time comparative analysis

### Analytical Frameworks Supported
- **Cohort Studies**: Multiple cohort definitions with consistent variable structures
- **Case-Control Studies**: Flexible entity selection and comparison capabilities
- **Longitudinal Studies**: Sequential tracking and change detection
- **Cross-Sectional Studies**: Snapshot analysis with standardized variables
- **Mixed-Methods**: Integration of quantitative patterns with qualitative insights

### Common Analysis Patterns
- **Descriptive Analysis**: Population characteristics and distributions
- **Comparative Analysis**: Between-group and within-group comparisons
- **Trend Analysis**: Temporal patterns and change detection
- **Segmentation Analysis**: Classification-based grouping and profiling
- **Predictive Modeling**: Outcome prediction using entity and event variables

### Visualization Applications
- **Entity Profiling**: Demographic and characteristic distribution charts
- **Event Timelines**: Sequential and temporal visualization of events
- **Classification Matrices**: Category-based cross-tabulations and heatmaps
- **Trajectory Plots**: Longitudinal pathway and change visualization
- **Comparative Dashboards**: Multi-cohort and multi-dimensional comparisons

---

## Data Lineage and Provenance

### Source Data Provenance
- **Original Sources**: [Primary data collection systems and organizations]
- **Data Collection Methods**: [Systematic data gathering approaches and standards]
- **Coverage Scope**: [Population, temporal, and geographic coverage details]
- **Quality Standards**: [Data quality characteristics, validation methods, and accuracy measures]

### Processing Lineage and Workflow
1. **Data Extraction**: Source system connections, extraction logic, and scheduling
2. **Ferry Process**: Transformation scripts, data cleaning, and standardization procedures
3. **Quality Assurance**: Validation checks, consistency testing, and error handling
4. **Schema Loading**: Database population, indexing, and optimization
5. **Analysis Preparation**: Research-specific transformations and cohort definitions
6. **Version Control**: All processing steps documented and tracked in version control

### Update and Maintenance Process
- **Update Frequency**: [Schedule based on source data availability and research needs]
- **Refresh Process**: [Systematic approach to incorporating new or updated data]
- **Quality Validation**: [Procedures for ensuring data quality during updates]
- **Change Documentation**: [Process for documenting structural or content changes]
- **Rollback Procedures**: [Methods for reverting problematic updates]

### Data Governance
- **Access Controls**: Appropriate permissions and security measures
- **Audit Trails**: Comprehensive logging of data access and modifications
- **Retention Policies**: Data preservation and archival strategies
- **Compliance**: Adherence to relevant data protection and research ethics standards

---

## Ethical Considerations and Research Integrity

### Data Limitations and Scope
- **Population Coverage**: Data may not represent all relevant populations or contexts
- **Temporal Boundaries**: Historical data may not predict future patterns or behaviors
- **Classification Constraints**: Categorical systems may oversimplify complex phenomena
- **Source Bias**: Original data collection may reflect institutional or systematic biases
- **Completeness**: Administrative or formal data may not capture all relevant activities or behaviors

### Ethical Use Guidelines and Standards
- **Source Attribution**: Proper citation and acknowledgment of original data sources
- **Contextual Presentation**: Findings presented within appropriate analytical and historical context
- **Sensitivity Awareness**: Recognition of potential sensitive aspects of data and analysis results
- **Accuracy Standards**: Commitment to not extrapolate beyond data availability or statistical confidence
- **Transparency**: Clear documentation of methods, limitations, and assumptions

### Research Validity Considerations
- **External Validity**: Findings may not generalize beyond specific study context or population
- **Temporal Validity**: Historical patterns and relationships may not persist over time
- **Construct Validity**: Measured variables serve as proxies but may not directly capture theoretical constructs
- **Statistical Power**: Some analytical subgroups may have insufficient sample sizes for reliable inference
- **Selection Bias**: Cohort definitions and inclusion criteria may introduce systematic biases

### Privacy and Confidentiality
- **Individual Privacy**: Appropriate measures to protect individual identities and sensitive information
- **Aggregate Reporting**: Use of aggregated data and suppression of small cell sizes where appropriate
- **Data Security**: Secure storage, transmission, and access procedures for sensitive data
- **Consent Considerations**: Alignment with original data collection consent and usage permissions

---

## Integration with Research Ecosystem

### Supporting Documentation Framework
- **Mission and Objectives**: Research goals, aims, and theoretical frameworks
- **Methodological Documentation**: Analytical approaches, statistical methods, and validation procedures
- **Conceptual Framework**: Theoretical models, ontologies, and definitional structures
- **Quality Assurance**: Data validation procedures, limitation assessments, and reliability measures

### Analysis Infrastructure Integration
- **Data Processing Pipeline**: Primary ferry scripts, transformation workflows, and automation procedures
- **Analytical Templates**: Standardized analysis patterns, visualization approaches, and reporting frameworks
- **Statistical Computing**: Integration with R, Python, SQL, and other analytical environments
- **Reproducibility**: Version control, documentation standards, and replication procedures

### Output and Dissemination Integration
- **Report Generation**: All CACHE tables designed for integration with automated reporting systems
- **Dashboard Development**: Data structures optimized for interactive visualization and monitoring
- **Publication Support**: Data organization supports academic publication and peer review requirements
- **Stakeholder Communication**: Appropriate formats and access methods for different audience needs

### Collaboration and Sharing
- **Team Coordination**: Shared access patterns and collaborative analysis workflows
- **External Partnerships**: Data sharing agreements and collaborative research protocols
- **Knowledge Transfer**: Documentation and training materials for new team members
- **Community Engagement**: Open science practices where appropriate and permissible

---

## Glossary of Terms

### Data Architecture Terms
- **CACHE** — Centralized repository of analysis-ready datasets derived from source systems through standardized processing workflows
- **Ferry Process** — Data extraction, transformation, and loading pipeline that moves data from source systems to research-ready formats
- **Schema** — Organized database structure defining table relationships, data types, and constraints
- **Entity** — Core research subject or unit of analysis (individual, organization, transaction, etc.)
- **Primary Key** — Variable or combination of variables that uniquely identify each record in a table
- **Foreign Key** — Variables that create linkages and relationships between different tables

### Research Data Terms
- **Cohort** — Defined research population with specific inclusion/exclusion criteria
- **Longitudinal Data** — Observations of the same entities across multiple time points
- **Cross-Sectional Data** — Observations of entities at a single point in time
- **Event Data** — Time-sequenced records of occurrences, transactions, or observations
- **Classification Variables** — Categorical dimensions for analytical segmentation and grouping
- **Derived Variables** — Calculated measures created through transformation of source data

### Data Quality Terms
- **Data Lineage** — Complete documentation of data flow from original sources through all transformation steps
- **Data Provenance** — Record of data origins, collection methods, and custody chain
- **Validation Rules** — Systematic checks for data consistency, completeness, and logical integrity
- **Quality Flags** — Indicators of data reliability, completeness, or validation status
- **Standardization** — Process of applying consistent formats, categories, and definitions across datasets

### Analytical Terms
- **Analysis-Ready Data** — Datasets processed and structured for immediate analytical use
- **Research Variables** — Measures specifically created or adapted for research questions
- **Sequence Variables** — Indicators of temporal or logical ordering within entities
- **Trajectory Analysis** — Study of pathways, changes, and patterns over time or sequence
- **Segmentation** — Division of population into meaningful analytical subgroups

### Technical Infrastructure Terms
- **Database Server** — Central system hosting research databases and supporting analytical queries
- **Parquet Format** — Efficient columnar storage format optimized for analytical processing
- **Index** — Database optimization structure improving query performance
- **Join Operation** — Method for combining data from multiple tables using common identifiers
- **Query Optimization** — Techniques for improving database query performance and efficiency

### Research Methodology Terms
- **External Validity** — Extent to which findings can be generalized beyond specific study context
- **Construct Validity** — Degree to which measurements accurately represent theoretical concepts
- **Selection Bias** — Systematic differences arising from population selection or inclusion criteria
- **Temporal Validity** — Stability of relationships and patterns across different time periods
- **Statistical Power** — Ability to detect true effects given sample size and analytical approach

---

## Template Customization Guide

### Essential Customization Steps
1. **Replace Schema Placeholders**: Update `[PROJECT_SCHEMA]`, `[DATABASE_SERVER]` with actual system details
2. **Define Entity Types**: Specify the core subjects/units of analysis for your research domain
3. **Customize Table Structure**: Adapt table names, relationships, and key structures to your data model
4. **Update Cohort Definitions**: Replace generic cohort descriptions with research-specific population criteria
5. **Modify Variable Domains**: Adjust demographic and classification variables to match your analytical needs
6. **Adapt File Locations**: Update storage paths and database connections to match your infrastructure

### Domain-Specific Adaptations
- **Research Questions**: Replace template research applications with domain-specific analytical objectives
- **Data Sources**: Update source system descriptions with actual data collection mechanisms
- **Classification Schemes**: Adapt categorical variables and hierarchies to domain-appropriate taxonomies
- **Temporal Scope**: Adjust time boundaries, update cycles, and temporal analysis approaches
- **Geographic Scope**: Modify regional classifications and spatial analysis capabilities as relevant
- **Ethical Considerations**: Adapt privacy, confidentiality, and sensitivity guidelines to specific data types

### Infrastructure Customization
- **Database Systems**: Adapt to your specific database platform (SQL Server, PostgreSQL, MySQL, etc.)
- **File Formats**: Adjust storage formats based on analytical tool preferences and team capabilities
- **Access Patterns**: Modify security, permissions, and access control descriptions
- **Processing Tools**: Update ferry process descriptions to match your ETL/ELT tools and workflows
- **Version Control**: Adapt documentation tracking to your development and collaboration workflows

### Quality Assurance Adaptation
- **Validation Rules**: Customize data quality checks to your specific data characteristics and requirements
- **Business Rules**: Adapt logical consistency checks to domain-specific constraints and relationships
- **Error Handling**: Modify error detection and resolution procedures to match operational capabilities
- **Audit Requirements**: Adjust compliance and governance procedures to regulatory or institutional needs

### Documentation Maintenance
- **Regular Updates**: Establish procedures for keeping manifest current with system and data changes
- **Version Control**: Track all changes to maintain clear documentation lineage
- **User Training**: Create training materials and onboarding procedures based on customized manifest
- **Stakeholder Communication**: Adapt documentation level and technical detail for different audience needs
- **Standards Compliance**: Ensure adherence to relevant institutional, regulatory, or professional standards

### Integration Considerations
- **Existing Systems**: Plan integration with current data infrastructure and analytical workflows
- **Team Workflows**: Adapt to team collaboration patterns, skills, and tool preferences
- **Reporting Requirements**: Ensure compatibility with existing reporting and dissemination requirements
- **Scalability**: Plan for growth in data volume, complexity, and analytical sophistication
- **Sustainability**: Design for long-term maintenance, updates, and institutional knowledge transfer

---

## Supporting Documentation Links

### Template Implementation Resources
- **Project Setup Guide** — Step-by-step instructions for implementing CACHE structure
- **Database Design Patterns** — Examples of schema design for different research contexts
- **Ferry Process Templates** — Sample scripts and workflows for data extraction and transformation
- **Quality Assurance Checklists** — Systematic approaches to data validation and integrity checking
- **Analysis Workflow Examples** — Demonstrated analytical patterns using CACHE structure

### Technical Documentation
- **Database Administration Guide** — Setup, maintenance, and optimization procedures
- **Data Processing Documentation** — Ferry script documentation, scheduling, and error handling
- **API and Access Documentation** — Programmatic access patterns and connection procedures
- **Security and Compliance Guide** — Data protection, access control, and audit procedures
- **Performance Optimization Guide** — Query optimization, indexing strategies, and scalability planning

### Research Integration Resources
- **Analytical Templates** — Standardized approaches to common research questions using CACHE data
- **Visualization Frameworks** — Chart types, dashboard patterns, and reporting templates optimized for CACHE structure
- **Statistical Analysis Guides** — Methods documentation adapted to CACHE data organization
- **Reproducibility Standards** — Version control, documentation, and replication procedures
- **Collaboration Protocols** — Team coordination, data sharing, and joint analysis procedures

### External Integration
- **Data Sharing Agreements** — Templates for external collaboration and data sharing
- **Publication Guidelines** — Standards for citing, describing, and sharing CACHE-derived research
- **Open Science Practices** — Approaches to transparency, replication, and community engagement
- **Regulatory Compliance** — Guidance for meeting institutional, legal, and ethical requirements
- **Community Resources** — Connections to broader research communities and methodological support networks
