# Project Memory System

> **Purpose**: Capture creative intent, design decisions, and provide contextual briefings for seamless project continuation after breaks.

## Current State & Intentions

### Core Project Architecture Decisions

**Ellis Script Selection** (July 31, 2025):
- **Decision**: `0-ellis-sasha-2.R` chosen as the main ellis script for project ontology
- **Current State**: `0-ellis.R` is now identical to `0-ellis-sasha-2.R` and serves as the active starting point/checkpoint
- **Significance**: This script defines the foundation for the project ontology and data processing patterns
- **Impact**: All future data manipulation and transformation logic should build from this checkpoint
- **Location**: `manipulation/0-ellis.R` (synchronized with `0-ellis-sasha-2.R`)

### EDA Workflow Development (August 1, 2025):
**Participants**: Andriy + Sasha  
**Achievement**: Successfully established exploratory data analysis infrastructure

- **EDA-1 Foundation**: Comprehensive data exploration template in `analysis/eda-1/`
  - Reproduced Ellis pipeline with all 6 long-format datasets
  - Created reusable visualization functions (time series, language comparison, regional analysis)
  - Generated first custom plots: total publications trend (g1) and titles vs copies comparison (g2)
  - Established analytical infrastructure with helper functions and organized folder structure

- **EDA-2 Presentation**: Created slide deck prototype in `analysis/eda-2/`
  - Developed Quarto revealjs presentation template with Ukrainian branding
  - Integrated EDA-1 visualizations into stakeholder-friendly format
  - Focused on basic pattern communication (titles vs copies dynamics)

- **Technical Patterns Established**:
  - **Long format consistency** across all datasets for flexible analysis
  - **Dual-axis visualization strategy** for comparing discrete titles vs circulation volumes  
  - **Regional aggregation approach** from oblast-level to macro-regions (North/South/East/West/Center)

### Current Intentions & Next Steps

**Immediate Priority 1: Data Overview for Halyna**
- **Intent**: Prepare comprehensive data overview to fuel Halyna's imagination for project teleology refinement
- **Purpose**: Help refine the "why" and "what for" aspects of the research mission
- **Status**: Ready to execute - data patterns identified, visualization capabilities established

**Immediate Priority 2: Looker Studio Assessment**  
- **Intent**: Present Looker Studio capabilities and limitations analysis for team decision-making
- **Purpose**: Understand medium constraints and features for optimal data communication strategy
- **Status**: Needs preparation - should demonstrate alongside current project data

**Creative Intent Detected**: Team is moving from exploratory phase toward strategic communication and stakeholder engagement. The combination of established analytical infrastructure (EDA-1) and presentation capabilities (EDA-2) positions the project for scaling insights to broader audiences.
