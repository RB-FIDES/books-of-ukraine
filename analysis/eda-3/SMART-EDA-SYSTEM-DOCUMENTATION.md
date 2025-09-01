# Smart Mini-EDA System for Intelligent ggplot Design

## Overview

We've created a small, two-layer system that separates pure dataset analysis from intent-driven plotting recommendations.
This keeps responsibilities clear: one function inspects and describes the data; the other interprets a user's plotting intent and returns actionable recommendations. Plot creation stays explicit and manual so analysts keep full control.

## Components Created

### 1. Silent Mini-EDA Engine (`scripts/silent-mini-eda.R`)

**Core Function: `silent_mini_eda(dataset_name, .env, include_samples, verbose)`**

- **Purpose**: Analyzes dataset structure without cluttering console output
- **Returns**: Structured list with comprehensive data insights
- **Key Features**:
  - Detects variable types (categorical, continuous, date)
  - Identifies plotting opportunities (time series, relationships, etc.)
  - Recognizes long-format data structures
  - Provides aesthetic recommendations
  - Suggests data preprocessing needs

**Example Output Structure**:
```r
result <- silent_mini_eda("ds_language")
# result$structure$dimensions          # rows x cols
# result$variable_types$categorical    # variables good for grouping/color
# result$variable_types$continuous     # variables good for axes
# result$plotting_recommendations      # smart plot suggestions
# result$samples                       # data previews
```

### 2. Smart Plotting Assistant (`smart_ggplot_assistant()` / `smart_plot()`)

**Purpose**: Interpret a user's plotting intent in the context of the dataset and return recommendations (not a full ggplot object).

**Key Capabilities**:
- Detects time series potential (year/date columns + continuous variables)
- Identifies optimal grouping variables for aesthetics
- Recognizes long-format data (measure/value columns)
- Suggests appropriate plot types and layers based on data structure
- Provides preprocessing recommendations and aesthetic hints

### 3. Integration with Common Functions (`scripts/common-functions.R`)

**Added Functions**:
- `source_silent_mini_eda()`: Loads the silent EDA system
- `smart_plot(dataset_name, plot_intent, verbose)`: Wrapper for easy use

### 4. Practical Implementation (`analysis/eda-3/eda-3.R`)

**Demonstrates**:
- Behind-the-scenes analysis of `ds_language`
- Intelligent ggplot creation based on insights
- Smart aesthetic choices (color palettes, themes)
- Automatic detection of optimal measures to plot

## How It Works in Practice

### Scenario: User asks for language dynamics plot

1. **User Prompt**: "Create a plot showing book publishing trends by language over time"

2. **Behind the Scenes** (invisible to user):
   ```r
   analysis <- silent_mini_eda("ds_language", verbose = FALSE)
   ```

3. **Copilot's Intelligent Decisions**:
   - ✅ Detects time series structure (year column)
   - ✅ Identifies long-format data (measure/value columns)
   - ✅ Finds multiple languages suitable for color mapping
   - ✅ Chooses appropriate measure (title_count vs copy_count)
   - ✅ Selects optimal color palette for number of categories

4. **Result**: Intelligent ggplot code with smart defaults

### Example Smart Decisions Made

The assistant suggests choices (not code) such as which measure to use, grouping variables, and palette choices. Example decisions the assistant might return:

- Prefer `measure == "title_count"` when both `title_count` and `copy_count` are present and title counts better reflect the user intent.
- Recommend `viridis_d` palette with option `plasma` for ≤6 categories; a different palette for larger cardinalities.
- Suggest `scale_y_continuous(labels = scales::comma_format())` when y-values are large.

These are recommendations for the analyst to implement; the system does not auto-generate or evaluate ggplot code.

## Benefits

### For Users
- **No Technical Questions**: Copilot doesn't ask "What variables do you want to plot?"
- **Optimal Defaults**: Gets good plots immediately without iteration
- **Context-Aware**: Plots are designed for the specific data structure

### For Copilot
- **Informed Decisions**: Makes choices based on actual data characteristics
- **Consistent Quality**: Avoids common plotting mistakes
- **Extensible**: Easy to add new detection patterns and recommendations

## Usage Examples

### Silent Analysis (No Console Output)
Use `silent_mini_eda()` when you want a full, raw description of the dataset.
```r
eda <- silent_mini_eda("ds_language", verbose = FALSE)
# Inspect eda$plotting_recommendations and eda$variable_types to design plots
```

### Intent-driven Recommendations
Use `smart_plot()` when you want a concise, intent-specific set of recommendations derived from `silent_mini_eda()`.
```r
result <- smart_plot("ds_language", "language dynamics", verbose = TRUE)
# result$dataset_analysis  # raw EDA
# result$plot_suggestions  # intent-aware suggestions (textual)
# result$recommended_aesthetics  # which var to use for color, palette hints
```

### Direct Integration in Scripts
```r
# Load once, use throughout script
source("./scripts/silent-mini-eda.R")

# Quick analysis before any plot
if (silent_mini_eda("my_dataset")$plotting_recommendations$time_series$suitable) {
  # Create time series plot
} else {
  # Create alternative plot type
}
```

## Files Created/Modified

1. **`scripts/silent-mini-eda.R`** - Core silent analysis engine (returns raw EDA)
2. **`scripts/common-functions.R`** - Integration helpers (including `smart_plot()` wrapper)
3. **`analysis/eda-3/demonstration-smart-plotting.R`** - Updated demonstration showing how to inspect results and manually build plots

## Future Enhancements

### Potential Additions
- **More Plot Type Detection**: Correlation matrices, geographic plots, etc.
- **Interactive Plot Recommendations**: Suggest plotly vs ggplot based on data size
- **Custom Business Logic**: Domain-specific recommendations for book publishing data
- **Error Prevention**: Detect common ggplot errors before they happen
- **Theme Intelligence**: Choose themes based on publication/presentation context

### Integration Opportunities
- **VS Code Extension**: Direct integration with Copilot
- **Quarto Integration**: Smart chunk generation for reports
- **Database Integration**: Analyze data directly from SQL queries
- **Package Recommendations**: Suggest specialized packages based on data patterns

## Key Innovation

This system transforms the interaction model from:
- **Traditional**: User → Copilot → "What variables?" → User → "Year and count" → Copilot → Plot
- **Smart**: User → "Show language trends" → Copilot (silent analysis) → Optimal Plot

The silent analysis enables Copilot to be truly intelligent rather than just a sophisticated template generator.
