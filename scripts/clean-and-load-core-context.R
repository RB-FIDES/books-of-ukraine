# Clean and Load Core Context Script
# This script removes all dynamic content and loads core context components

# Source the context management functions
source('scripts/update-copilot-context.R')

# Clean up dynamic content
remove_all_dynamic_instructions()

# Load core context (onboarding-ai, mission, method)
add_core_context()

cat("✅ Dynamic content cleaned and core context loaded!\n")
cat("📚 Loaded components: onboarding-ai, mission, method\n")
