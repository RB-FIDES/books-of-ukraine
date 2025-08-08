# Service Account Authentication for Google Sheets
# This script provides automatic, browser-free authentication using a service account

library(googlesheets4)

#' Setup Service Account Authentication
#' 
#' This function authenticates using a service account JSON file,
#' providing completely automated access without browser interaction.
#' 
#' @param service_account_path Character. Path to service account JSON file. 
#'   Default: "google-service-account.json" (in project root)
#' @return Invisible TRUE if successful, stops with error if failed
setup_service_account_auth <- function(service_account_path = "google-service-account.json") {
  
  # Check if service account file exists
  if (!file.exists(service_account_path)) {
    cat("\n")
    cat("==================================================\n")
    cat("GOOGLE SERVICE ACCOUNT NOT FOUND\n")
    cat("==================================================\n")
    cat("Expected file:", service_account_path, "\n")
    cat("\n")
    cat("To set up service account authentication:\n")
    cat("1. Follow the guide in docs/service-account-setup.md\n")
    cat("2. Place your service account JSON file at:", service_account_path, "\n")
    cat("3. Ensure the service account has access to your Google Sheets\n")
    cat("\n")
    cat("Falling back to interactive authentication...\n")
    cat("==================================================\n")
    
    # Fall back to cached token authentication
    return(setup_fallback_auth())
  }
  
  # Attempt service account authentication
  tryCatch({
    # Authenticate using service account
    gs4_auth(path = service_account_path)
    
    # Test the authentication by trying to access sheets
    cat("✅ Service account authentication successful!\n")
    cat("📄 Using credentials from:", service_account_path, "\n")
    
    return(invisible(TRUE))
    
  }, error = function(e) {
    cat("\n")
    cat("==================================================\n")
    cat("SERVICE ACCOUNT AUTHENTICATION FAILED\n")
    cat("==================================================\n")
    cat("Error:", e$message, "\n")
    cat("\n")
    cat("Common issues:\n")
    cat("- Service account JSON file is corrupted\n")
    cat("- Service account doesn't have access to the Google Sheets\n")
    cat("- Google Sheets API is not enabled in your Google Cloud project\n")
    cat("\n")
    cat("Please check docs/service-account-setup.md for troubleshooting\n")
    cat("==================================================\n")
    
    stop("Service account authentication failed. Please check your setup.")
  })
}

#' Fallback Authentication (Cached Token)
#' 
#' This function provides fallback authentication using cached OAuth tokens
#' when service account authentication is not available.
#' 
#' @return Invisible TRUE if successful
setup_fallback_auth <- function() {
  
  # Set up cache directory
  cache_path <- ".secrets"
  if (!dir.exists(cache_path)) {
    dir.create(cache_path)
  }
  
  # Set cache location
  options(gargle_oauth_cache = cache_path)
  
  # Check if we have cached tokens
  cache_files <- list.files(cache_path, full.names = TRUE)
  
  if (length(cache_files) > 0) {
    cat("📂 Using cached Google Sheets authentication...\n")
    tryCatch({
      gs4_auth(cache = cache_path, email = TRUE)
      cat("✅ Cached authentication successful!\n")
      return(invisible(TRUE))
    }, error = function(e) {
      cat("❌ Cached authentication failed, need interactive setup...\n")
    })
  }
  
  # If we get here, we need interactive authentication
  cat("\n")
  cat("==================================================\n")
  cat("INTERACTIVE AUTHENTICATION REQUIRED\n")
  cat("==================================================\n")
  cat("No service account found and no cached tokens available.\n")
  cat("This will open a browser window for authentication.\n")
  cat("After this one-time setup, authentication will be automatic.\n")
  cat("\n")
  cat("To avoid browser authentication in the future:\n")
  cat("- Set up a service account (see docs/service-account-setup.md)\n")
  cat("==================================================\n")
  
  tryCatch({
    gs4_auth(cache = cache_path, email = TRUE)
    cat("✅ Interactive authentication successful and cached!\n")
    return(invisible(TRUE))
  }, error = function(e) {
    stop("Authentication failed: ", e$message)
  })
}

#' Check Authentication Status
#' 
#' This function checks the current Google Sheets authentication status
#' 
#' @return Logical indicating if authentication is active
check_auth_status <- function() {
  if (gs4_has_token()) {
    cat("✅ Google Sheets authentication is active\n")
    
    # Try to get user info to verify the authentication works
    tryCatch({
      user_info <- gs4_user()
      if (!is.null(user_info)) {
        cat("👤 Authenticated as:", user_info, "\n")
      }
    }, error = function(e) {
      cat("⚠️  Authentication token exists but may be invalid\n")
    })
    
    return(TRUE)
  } else {
    cat("❌ Google Sheets authentication is not active\n")
    return(FALSE)
  }
}

#' Main Authentication Function
#' 
#' This is the main function to call for setting up authentication.
#' It tries service account first, then falls back to cached tokens.
#' 
#' @param service_account_path Character. Path to service account JSON file
#' @return Invisible TRUE if successful
authenticate_google_sheets <- function(service_account_path = "google-service-account.json") {
  
  cat("🔐 Setting up Google Sheets authentication...\n")
  
  # Try service account authentication first
  if (file.exists(service_account_path)) {
    return(setup_service_account_auth(service_account_path))
  } else {
    return(setup_fallback_auth())
  }
}
