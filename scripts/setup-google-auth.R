# Google Sheets Authentication Setup
# Run this script once to set up authentication for Google Sheets

# Load required library
library(googlesheets4)

# Load the authentication helper
source("scripts/google-auth-helper.R")

cat("============================================\n")
cat("GOOGLE SHEETS AUTHENTICATION SETUP\n")
cat("============================================\n")
cat("This will set up authentication for Google Sheets.\n")
cat("You'll need to:\n")
cat("1. Sign in to your Google account in the browser\n")
cat("2. Allow access to Google Sheets\n")
cat("3. This token will be cached for future use\n")
cat("\n")

# Force authentication setup
tryCatch({
  # Clear any existing auth
  gs4_deauth()
  
  # Set up new authentication
  gs4_auth(cache = ".secrets")
  
  cat("\n")
  cat("✓ Authentication setup complete!\n")
  cat("✓ Token cached in .secrets folder\n")
  cat("✓ You can now run 0-ellis.R without manual authentication\n")
  cat("\n")
  cat("To test the setup, you can run:\n")
  cat("  source('manipulation/0-ellis.R')\n")
  cat("or\n")
  cat("  Rscript manipulation/0-ellis.R\n")
  
}, error = function(e) {
  cat("\n")
  cat("✗ Authentication setup failed:\n")
  cat(e$message, "\n")
  cat("\n")
  cat("Please ensure you have internet access and try again.\n")
})

cat("============================================\n")
