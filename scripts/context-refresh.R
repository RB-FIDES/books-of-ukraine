# Context Refresh Script
# This script provides a comprehensive context status and refresh options

# Source the context management functions
source('scripts/update-copilot-context.R')

# Run context refresh
context_refresh()

cat("\n💡 Context refresh complete!\n")
