# Google Sheets Authentication Helper
# This script provides functions for automated Google Sheets authentication

library(googlesheets4)

#' Setup Google Sheets Authentication
#' 
#' This function handles Google Sheets authentication automatically,
#' using cached tokens, service accounts, or interactive auth as needed.
#' 
#' @param cache_path Character. Path to store authentication cache. Default: ".secrets"
#' @param email Logical or character. Email for authentication. Default: TRUE
#' @param interactive Logical. Whether to allow interactive authentication. Default: TRUE
#' @param service_account_path Character. Path to service account JSON file. Default: NULL
#' @return Invisible TRUE if successful
setup_google_auth <- function(cache_path = ".secrets", email = TRUE, interactive = TRUE, service_account_path = NULL) {
  
  # Check if we're already authenticated
  if (gs4_has_token()) {
    cat("✓ Google Sheets authentication already active.\n")
    return(invisible(TRUE))
  }
  
  cat("Setting up Google Sheets authentication...\n")
  
  # Try service account authentication first if provided
  if (!is.null(service_account_path) && file.exists(service_account_path)) {
    tryCatch({
      gs4_auth(path = service_account_path)
      cat("✓ Authentication successful using service account.\n")
      return(invisible(TRUE))
    }, error = function(e) {
      cat("Service account authentication failed, trying cached token...\n")
    })
  }
  
  # Check for environment variables
  service_account_env <- Sys.getenv("GOOGLE_SHEETS_SERVICE_ACCOUNT_JSON", unset = "")
  if (service_account_env != "" && file.exists(service_account_env)) {
    tryCatch({
      gs4_auth(path = service_account_env)
      cat("✓ Authentication successful using service account from environment.\n")
      return(invisible(TRUE))
    }, error = function(e) {
      cat("Environment service account authentication failed, trying cached token...\n")
    })
  }
  
  # Create cache directory if it doesn't exist
  if (!dir.exists(cache_path)) {
    dir.create(cache_path, recursive = TRUE)
    cat("Created authentication cache directory:", cache_path, "\n")
  }
  
  # Try to authenticate with cached token first
  tryCatch({
    # Check if we have cached tokens (look for any file, not just 32-char hex)
    cache_files <- list.files(cache_path, full.names = TRUE)
    
    if (length(cache_files) > 0) {
      # Use cached authentication with specific email if available
      if (is.character(email) && email != "") {
        gs4_auth(cache = cache_path, email = email)
      } else {
        # Try to extract email from filename
        token_files <- cache_files[grepl("_.*@.*\\.", basename(cache_files))]
        if (length(token_files) > 0) {
          # Extract email from filename
          email_from_file <- sub(".*_(.+@.+)$", "\\1", basename(token_files[1]))
          gs4_auth(cache = cache_path, email = email_from_file)
        } else {
          gs4_auth(cache = cache_path, email = TRUE)
        }
      }
      cat("✓ Authentication successful using cached token.\n")
      return(invisible(TRUE))
    } else {
      stop("No cached tokens found")
    }
  }, error = function(e) {
    
    # If no cached token and we're in an interactive session
    if (interactive && interactive()) {
      cat("No cached authentication found. Setting up interactive authentication...\n")
      cat("This will open a browser window for authentication.\n")
      
      tryCatch({
        gs4_auth(cache = cache_path, email = email)
        cat("✓ Authentication successful. Token cached for future use.\n")
        return(invisible(TRUE))
      }, error = function(e2) {
        stop("Interactive authentication failed: ", e2$message)
      })
    } else {
      # Non-interactive mode - provide instructions
      cat("\n")
      cat("==================================================\n")
      cat("GOOGLE SHEETS AUTHENTICATION REQUIRED\n")
      cat("==================================================\n")
      cat("You need to authenticate Google Sheets access.\n")
      cat("Please run the following commands in R console:\n")
      cat("\n")
      cat("  library(googlesheets4)\n")
      cat("  gs4_auth(cache = '.secrets')\n")
      cat("\n")
      cat("After authentication, you can run this script again.\n")
      cat("==================================================\n")
      
      stop("Authentication required. Please authenticate interactively first.")
    }
  })
}

#' Clear Google Sheets Authentication
#' 
#' This function clears the current authentication token
#' 
#' @return Invisible TRUE if successful
clear_google_auth <- function() {
  gs4_deauth()
  cat("✓ Google Sheets authentication cleared.\n")
  return(invisible(TRUE))
}

#' Check Google Sheets Authentication Status
#' 
#' This function checks if Google Sheets authentication is active
#' 
#' @return Logical indicating if authentication is active
check_google_auth <- function() {
  has_token <- gs4_has_token()
  
  if (has_token) {
    cat("✓ Google Sheets authentication is active.\n")
  } else {
    cat("✗ Google Sheets authentication is not active.\n")
  }
  
  return(has_token)
}

#' Force Google Sheets Re-authentication
#' 
#' This function forces a new authentication process
#' 
#' @param cache_path Character. Path to store authentication cache. Default: ".secrets"
#' @return Invisible TRUE if successful
force_google_reauth <- function(cache_path = ".secrets") {
  # Clear current auth
  gs4_deauth()
  
  # Remove cached tokens
  if (dir.exists(cache_path)) {
    unlink(cache_path, recursive = TRUE)
    cat("Cleared authentication cache.\n")
  }
  
  # Setup new auth
  setup_google_auth(cache_path = cache_path)
  
  return(invisible(TRUE))
}
