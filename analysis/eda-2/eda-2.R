# ---- load-packages -----------------------------------------------------------
library(magrittr)
library(ggplot2)
library(dplyr)
library(scales)
library(here)

# ---- load-sources ------------------------------------------------------------
# Source the main analysis script to get all data and plots
source(here("analysis", "eda-1", "eda-1.R"))

# ---- presentation-specific-plots ---------------------------------------------
# The g2 plot from eda-1.R will be used in the presentation
# Additional presentation-specific customizations can be added here if needed

# Ensure the plot exists and is accessible
if (!exists("g2")) {
  stop("Plot g2 not found. Please ensure eda-1.R runs successfully.")
}

# Optional: Create a version of g2 optimized for presentation display
g2_presentation <- g2 +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold"),
    plot.subtitle = element_text(size = 14),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    axis.title.y.left = element_text(color = "#005BBB", size = 14),
    axis.title.y.right = element_text(color = "#DC143C", size = 14),
    legend.position = "none"  # Remove legend for cleaner presentation
  )

# Print dimensions and basic info for verification
cat("Presentation data loaded successfully.\n")
cat("Plot g2 dimensions and summary:\n")
print(g2_presentation)
