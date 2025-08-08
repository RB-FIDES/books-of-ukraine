# Test Service Account Authentication
# Run this script to verify that your service account setup is working

cat("==================================================\n")
cat("TESTING GOOGLE SHEETS SERVICE ACCOUNT SETUP\n")
cat("==================================================\n")

# Load the service account authentication
source("scripts/service-account-auth.R")

cat("Testing authentication...\n")

# Test authentication
tryCatch({
  authenticate_google_sheets()
  
  cat("\n")
  cat("Testing Google Sheets access...\n")
  
  # Try to access the Books of Ukraine sheet (read-only test)
  test_url <- "https://docs.google.com/spreadsheets/d/1nxMTUD9gRhaE_VIT6WPR4V-_7BWNVwsJu__qjtCtSF0"
  
  # Get sheet information (this tests both authentication and permissions)
  sheet_info <- gs4_get(test_url)
  
  cat("✅ Successfully accessed Google Sheet!\n")
  cat("📊 Sheet name:", sheet_info$name, "\n")
  cat("📄 Available tabs:", paste(sheet_info$sheets$name, collapse = ", "), "\n")
  
  cat("\n")
  cat("==================================================\n")
  cat("✅ SERVICE ACCOUNT SETUP IS WORKING CORRECTLY!\n")
  cat("==================================================\n")
  cat("You can now run manipulation/0-ellis.R without browser authentication.\n")
  cat("==================================================\n")
  
}, error = function(e) {
  cat("\n")
  cat("==================================================\n")
  cat("❌ SERVICE ACCOUNT SETUP FAILED\n")
  cat("==================================================\n")
  cat("Error:", e$message, "\n")
  cat("\n")
  cat("Common solutions:\n")
  cat("1. Ensure google-service-account.json exists in project root\n")
  cat("2. Add service account email to the Google Sheet with Editor access\n")
  cat("3. Check that Google Sheets API is enabled in Google Cloud\n")
  cat("\n")
  cat("See docs/service-account-setup.md for detailed instructions\n")
  cat("==================================================\n")
})
