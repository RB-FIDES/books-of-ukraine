# Project Setup Validation Script
# Run this script to check if your environment is ready for the books-of-ukraine project
# Usage: Rscript scripts/check-setup.R

cat("=========================================================\n")
cat("📚 BOOKS OF UKRAINE PROJECT - SETUP VALIDATION\n")
cat("=========================================================\n")
cat("Checking your development environment...\n\n")

# Function to check file/directory existence
check_file <- function(path, description, required = TRUE) {
  exists <- file.exists(path) || dir.exists(path)
  status <- if(exists) "✅" else if(required) "❌" else "⚠️"
  cat(sprintf("%-50s %s\n", description, status))
  return(exists)
}

# Function to check package installation
check_package <- function(pkg, description = NULL) {
  if(is.null(description)) description <- paste("Package:", pkg)
  installed <- requireNamespace(pkg, quietly = TRUE)
  status <- if(installed) "✅" else "❌"
  cat(sprintf("%-50s %s\n", description, status))
  return(installed)
}

# Initialize error tracking
setup_errors <- c()
setup_warnings <- c()

cat("1. PROJECT STRUCTURE\n")
cat("-------------------\n")
required_dirs <- c(
  "data-private",
  "data-public", 
  "manipulation",
  "analysis",
  "scripts",
  "ai"
)

for(dir in required_dirs) {
  if(!check_file(dir, paste("Directory:", dir))) {
    setup_errors <- c(setup_errors, paste("Missing directory:", dir))
  }
}

required_files <- c(
  "flow.R",
  "config.yml",
  "scripts/google-auth-helper.R",
  "scripts/setup-google-auth.R",
  "manipulation/0-ellis.R"
)

for(file in required_files) {
  if(!check_file(file, paste("File:", file))) {
    setup_errors <- c(setup_errors, paste("Missing file:", file))
  }
}

cat("\n2. R PACKAGES\n")
cat("-------------\n")
required_packages <- c(
  "googlesheets4",
  "dplyr", 
  "tidyr",
  "magrittr",
  "stringr",
  "janitor",
  "DBI",
  "RSQLite",
  "config"
)

for(pkg in required_packages) {
  if(!check_package(pkg)) {
    setup_errors <- c(setup_errors, paste("Missing package:", pkg))
  }
}

optional_packages <- c(
  "ggplot2",
  "lubridate", 
  "forcats",
  "scales",
  "broom",
  "emmeans"
)

cat("\nOptional packages (recommended):\n")
for(pkg in optional_packages) {
  if(!check_package(pkg)) {
    setup_warnings <- c(setup_warnings, paste("Missing optional package:", pkg))
  }
}

cat("\n3. AUTHENTICATION\n")
cat("-----------------\n")
secrets_exists <- check_file(".secrets", "Google Sheets auth cache (.secrets)", required = FALSE)
gitignore_exists <- check_file(".gitignore", ".gitignore file", required = FALSE)

# Check if .secrets is in .gitignore
if(gitignore_exists) {
  gitignore_content <- readLines(".gitignore", warn = FALSE)
  secrets_in_gitignore <- any(grepl("\\.secrets", gitignore_content, fixed = TRUE))
  check_file(".secrets (in .gitignore)", "Auth cache properly ignored", required = FALSE)
  if(!secrets_in_gitignore) {
    setup_warnings <- c(setup_warnings, ".secrets should be added to .gitignore for security")
  }
}

# Test Google Sheets authentication
cat("\n4. GOOGLE SHEETS ACCESS\n")
cat("-----------------------\n")
if(secrets_exists) {
  tryCatch({
    suppressMessages({
      library(googlesheets4)
      source("scripts/google-auth-helper.R")
      setup_google_auth(interactive = FALSE)
    })
    
    if(gs4_has_token()) {
      cat("Google Sheets authentication        ✅\n")
    } else {
      cat("Google Sheets authentication        ❌\n")
      setup_errors <- c(setup_errors, "Google Sheets authentication failed")
    }
  }, error = function(e) {
    cat("Google Sheets authentication        ❌\n")
    setup_errors <- c(setup_errors, paste("Authentication error:", e$message))
  })
} else {
  cat("Google Sheets authentication        ❌ (No .secrets folder)\n")
  setup_errors <- c(setup_errors, "Google Sheets not configured")
}

cat("\n5. DATA DIRECTORIES\n")
cat("-------------------\n")
data_dirs <- c(
  "data-private/derived",
  "data-private/derived/manipulation",
  "data-private/derived/manipulation/SQLite",
  "data-private/derived/manipulation/CSV"
)

for(dir in data_dirs) {
  check_file(dir, paste("Data directory:", dir), required = FALSE)
}

cat("\n=========================================================\n")
cat("📋 SETUP SUMMARY\n")
cat("=========================================================\n")

if(length(setup_errors) == 0 && length(setup_warnings) == 0) {
  cat("🎉 PERFECT! Your environment is fully configured!\n")
  cat("\n✅ You can now run:\n")
  cat("   • Rscript flow.R\n")
  cat("   • Rscript manipulation/0-ellis.R\n")
  cat("   • Any analysis scripts in the analysis/ folder\n")
  
} else if(length(setup_errors) == 0) {
  cat("✅ GOOD! Your environment is ready with minor warnings.\n")
  cat("\n⚠️  Warnings to address:\n")
  for(warning in setup_warnings) {
    cat("   •", warning, "\n")
  }
  cat("\n✅ You can run the scripts, but consider addressing warnings.\n")
  
} else {
  cat("❌ SETUP INCOMPLETE! Please fix the following issues:\n\n")
  
  if(length(setup_errors) > 0) {
    cat("🚨 CRITICAL ERRORS:\n")
    for(error in setup_errors) {
      cat("   •", error, "\n")
    }
  }
  
  if(length(setup_warnings) > 0) {
    cat("\n⚠️  WARNINGS:\n")
    for(warning in setup_warnings) {
      cat("   •", warning, "\n")
    }
  }
  
  cat("\n🔧 NEXT STEPS:\n")
  
  # Missing packages
  missing_pkgs <- setup_errors[grepl("Missing package:", setup_errors)]
  if(length(missing_pkgs) > 0) {
    pkgs <- gsub("Missing package: ", "", missing_pkgs)
    cat("   1. Install missing packages:\n")
    cat("      install.packages(c(", paste0("'", pkgs, "'", collapse = ", "), "))\n")
  }
  
  # Google Sheets setup
  if(any(grepl("Google Sheets|Authentication", setup_errors))) {
    cat("   2. Set up Google Sheets authentication:\n")
    cat("      Rscript scripts/setup-google-auth.R\n")
  }
  
  # Missing directories
  missing_dirs <- setup_errors[grepl("Missing directory:", setup_errors)]
  if(length(missing_dirs) > 0) {
    cat("   3. Create missing directories or re-clone the repository\n")
  }
}

cat("\n=========================================================\n")
cat("📖 NEED HELP?\n")
cat("=========================================================\n")
cat("If you encounter issues:\n")
cat("1. Check the README.md file for detailed setup instructions\n")
cat("2. Review the ai/onboarding-ai.md for project-specific guidance\n") 
cat("3. Ask a team member for assistance\n")
cat("\n💡 TIP: Run this script again after making changes!\n")
cat("=========================================================\n")

# Exit with appropriate code
if(length(setup_errors) > 0) {
  quit(status = 1)
} else {
  quit(status = 0)
}
