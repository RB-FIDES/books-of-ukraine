# Load Core Context Script
# This script loads the core context components for Copilot instructions

# Source the context management functions
source('scripts/update-copilot-context.R')

# Load core context (onboarding-ai, mission, method)
add_core_context()

cat("✅ Core context loaded successfully!\n")
cat("📚 Loaded components: onboarding-ai, mission, method\n")
