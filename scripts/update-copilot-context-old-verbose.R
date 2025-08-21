# ==============================================================================
# Update Copilot Instructions Context (Streamlined)
# ==============================================================================
# 
# This script automates the process of updating .github/copilot-instructions.md
# with the contents of foundational project files. It allows analysts to quickly
# refresh the AI context by typing: add_to_instructions("glossary", "mission", ...)
#
# Author: GitHub Copilot (with human analyst)
# Created: 2025-07-16
# Updated: 2025-08-15 - Streamlined based on mature sda-ceis-impact implementation

update_copilot_instructions <- function(file_list) {
  # Map friendly names to actual file paths (Books of Ukraine - streamlined)
  file_map <- list(
    "onboarding-ai" = "./ai/onboarding-ai.md",
    "mission" = "./ai/mission.md", 
    "method" = "./ai/method.md",
    "glossary" = "./ai/glossary.md",
    "semiology" = "./ai/semiology.md",
    "pipeline" = "./pipeline.md",
    "fides" = "./ai/FIDES.md",
    "cache-manifest" = "./data-public/metadata/CACHE-manifest-0.md",
    "cache-manifest-enhanced" = "./data-public/metadata/CACHE-MANIFEST-1.md",
    "cache-manifest-analytical" = "./ai/CACHE-manifest-analytical.md",
    "memory-hub" = "./ai/memory-hub.md",
    "memory-human" = "./ai/memory-human.md",
    "memory-ai" = "./ai/memory-ai.md"
  )
  
  instructions_path <- ".github/copilot-instructions.md"
  
  # Check if instructions file exists
  if (!file.exists(instructions_path)) {
    stop("Copilot instructions file not found at: ", instructions_path)
  }
  
  # Read the current copilot instructions
  current_content <- readLines(instructions_path, warn = FALSE)
  
  # Find the dynamic content section markers
  start_marker <- which(grepl("<!-- DYNAMIC CONTENT START -->", current_content))
  end_marker <- which(grepl("<!-- DYNAMIC CONTENT END -->", current_content))
  
  if (length(start_marker) == 0 || length(end_marker) == 0) {
    stop("Dynamic content markers not found in copilot instructions. Please add:\n<!-- DYNAMIC CONTENT START -->\n<!-- DYNAMIC CONTENT END -->")
  }
  
  
  # Build new content section with summary
  component_list <- paste(file_list, collapse=", ")
  new_content <- c(
    "<!-- DYNAMIC CONTENT START -->",
    "",
    paste("**Currently loaded components:**", component_list),
    ""
  )
  
  for (file_name in file_list) {
    if (file_name %in% names(file_map)) {
      file_path <- file_map[[file_name]]
      if (file.exists(file_path)) {
        file_content <- readLines(file_path, warn = FALSE)
        new_content <- c(
          new_content,
          paste0("### ", tools::toTitleCase(gsub("-", " ", file_name)), " (from `", file_path, "`)"),
          "",
          file_content,
          ""
        )
        message("✓ Added: ", file_path)
      } else {
        warning("✗ File not found: ", file_path)
      }
    } else {
      warning("✗ Unknown file alias: ", file_name, ". Available: ", paste(names(file_map), collapse=", "))
    }
  }
  
  # Don't add the closing marker here - we'll use the existing one
  
  # Replace the section (including both markers)
  updated_content <- c(
    current_content[1:(start_marker-1)],
    new_content,
    current_content[end_marker:length(current_content)]
  )
  
  # Write back
  writeLines(updated_content, instructions_path)
  
  # Ensure file ends with newline to prevent warnings
  if (length(updated_content) > 0 && !endsWith(updated_content[length(updated_content)], "\n")) {
    cat("\n", file = instructions_path, append = TRUE)
  }
  
  message("🔄 Updated .github/copilot-instructions.md with: ", paste(file_list, collapse=", "))
  message("📄 Total lines in updated file: ", length(updated_content))
}

# Convenience function for easy calling
add_to_instructions <- function(...) {
  file_list <- c(...)
  if (length(file_list) == 0) {
    message("Available file aliases:")
    file_map <- list(
      "onboarding-ai" = "./ai/onboarding-ai.md",
      "mission" = "./ai/mission.md", 
      "method" = "./ai/method.md",
      "glossary" = "./ai/glossary.md",
      "semiology" = "./ai/semiology.md",
      "pipeline" = "./pipeline.md",
      "fides" = "./ai/FIDES.md",
      "cache-manifest" = "./data-public/metadata/CACHE-manifest-0.md",
      "memory-hub" = "./ai/memory-hub.md",
      "memory-human" = "./ai/memory-human.md",
      "memory-ai" = "./ai/memory-ai.md"
    )
    for (alias in names(file_map)) {
      exists_marker <- if (file.exists(file_map[[alias]])) "✓" else "✗"
      message("  ", exists_marker, " ", alias, " -> ", file_map[[alias]])
    }
    message("\nUsage: add_to_instructions('onboarding-ai','mission', 'glossary')")
  } else {
    update_copilot_instructions(file_list)
  }
}

# Quick alias for common combinations
add_core_context <- function() {
  add_to_instructions("onboarding-ai", "mission", "method")
}

add_full_context <- function() {
  add_to_instructions("onboarding-ai", "mission", "method", "glossary", "pipeline")
}

# Books of Ukraine specific context combinations
add_data_context <- function() {
  add_to_instructions("cache-manifest", "pipeline")
}

add_memory_context <- function() {
  add_to_instructions("memory-hub", "memory-human", "memory-ai")
}

remove_all_dynamic_instructions <- function() {
  instructions_path <- ".github/copilot-instructions.md"
  
  # Check if instructions file exists
  if (!file.exists(instructions_path)) {
    stop("Copilot instructions file not found at: ", instructions_path)
  }
  
  # Read the current copilot instructions
  current_content <- readLines(instructions_path, warn = FALSE)
  
  # Find the dynamic content section markers
  start_marker <- which(grepl("<!-- DYNAMIC CONTENT START -->", current_content))
  end_marker <- which(grepl("<!-- DYNAMIC CONTENT END -->", current_content))
  
  if (length(start_marker) == 0 || length(end_marker) == 0) {
    stop("Dynamic content markers not found in copilot instructions. Please add:\n<!-- DYNAMIC CONTENT START -->\n<!-- DYNAMIC CONTENT END -->")
  }
  
  # Create new content with just the markers and empty space between
  new_content <- c(
    "<!-- DYNAMIC CONTENT START -->",
    "",
    "<!-- DYNAMIC CONTENT END -->"
  )
  
  # Replace the section (including both markers)
  updated_content <- c(
    current_content[1:(start_marker-1)],
    new_content,
    current_content[(end_marker+1):length(current_content)]
  )
  
  # Write back
  writeLines(updated_content, instructions_path)
  
  # Ensure file ends with newline to prevent warnings
  if (length(updated_content) > 0 && !endsWith(updated_content[length(updated_content)], "\n")) {
    cat("\n", file = instructions_path, append = TRUE)
  }
  
  message("🗑️ Removed all dynamic content from .github/copilot-instructions.md")
  message("📄 Total lines in updated file: ", length(updated_content))
}

# ==============================================================================
# CONTEXT MANAGEMENT COMMANDS
# ==============================================================================

# ==============================================================================
# CONTEXT MANAGEMENT COMMANDS
# ==============================================================================

# Helper operator for string repetition
`%r%` <- function(str, times) paste(rep(str, times), collapse = "")

# Quick context scan and refresh - triggered by keyphrase
context_refresh <- function() {
  message("🔍 DYNAMIC CONTEXT SCAN")
  message(paste(rep("=", 50), collapse = ""))
  
  # Quick setup check first
  setup_status <- project_setup_check(verbose = FALSE, return_status = TRUE)
  if (!setup_status$is_ready) {
    message("⚠️  Setup issues detected! Run project_setup_check() for details")
    message("    Critical errors: ", length(setup_status$errors))
    if (length(setup_status$warnings) > 0) {
      message("    Warnings: ", length(setup_status$warnings))
    }
  } else {
    message("✅ Project setup validated")
  }
  
  # Check current context
  instructions_path <- ".github/copilot-instructions.md"
  
  if (!file.exists(instructions_path)) {
    message("❌ Copilot instructions file not found")
    return()
  }
  
  content <- readLines(instructions_path, warn = FALSE)
  component_line <- content[grepl("\\*\\*Currently loaded components:\\*\\*", content)]
  
  if (length(component_line) == 0) {
    message("📋 Current status: NO dynamic content loaded")
  } else {
    components <- gsub(".*Currently loaded components:\\*\\* ", "", component_line)
    message("📋 Currently loaded: ", components)
  }
  
  # Check file freshness
  validate_context()
  check_context_size()
  
  message("\n🚀 QUICK REFRESH OPTIONS:")
  message("1️⃣  Core context: add_core_context()")
  message("2️⃣  Data context: add_data_context()")  
  message("3️⃣  Compass context: add_compass_context()")
  message("4️⃣  Full context: add_full_context()")
  message("5️⃣  Custom phase: suggest_context('phase')")
  message("🗑️  Reset: remove_all_dynamic_instructions()")
  message("\n🔧 SETUP & TROUBLESHOOTING:")
  message("🔍  Full setup check: project_setup_check()")
  message("⚡  Quick setup check: quick_setup_check()")  
  message("🚀  Safe script run: safe_run_script('path/to/script.R')")
  message("📊  Check CACHE status: check_cache_manifest()")
  message("\n💡 Or specify custom files: add_to_instructions('file1', 'file2')")
}

# ==============================================================================
# PROPOSED IMPROVEMENTS
# ==============================================================================

# 1. Context Validation - Check if loaded content is still current
validate_context <- function() {
  instructions_path <- ".github/copilot-instructions.md"
  
  if (!file.exists(instructions_path)) {
    message("❌ Copilot instructions file not found")
    return(FALSE)
  }
  
  content <- readLines(instructions_path, warn = FALSE)
  
  # Find loaded components
  component_line <- content[grepl("\\*\\*Currently loaded components:\\*\\*", content)]
  
  if (length(component_line) == 0) {
    message("ℹ️ No dynamic content currently loaded")
    return(TRUE)
  }
  
  # Extract component list
  components <- gsub(".*Currently loaded components:\\*\\* ", "", component_line)
  component_list <- trimws(strsplit(components, ",")[[1]])
  
  # Map to file paths and check if files have been modified recently
  file_map <- list(
    "onboarding-ai" = "./ai/onboarding-ai.md",
    "mission" = "./ai/mission.md", 
    "method" = "./ai/method.md",
    "project-map" = "./ai/project-map.md",
    "glossary" = "./ai/glossary.md",
    "semiology" = "./ai/semiology.md",
    "pipeline" = "./pipeline.md",
    "fides" = "./ai/FIDES.md",
    "logbook" = "./ai/logbook.md"
  )
  
  message("🔍 Checking context freshness...")
  stale_files <- c()
  
  for (component in component_list) {
    if (component %in% names(file_map)) {
      file_path <- file_map[[component]]
      if (file.exists(file_path)) {
        file_time <- file.mtime(file_path)
        instructions_time <- file.mtime(instructions_path)
        if (file_time > instructions_time) {
          stale_files <- c(stale_files, component)
        }
      }
    }
  }
  
  if (length(stale_files) > 0) {
    message("⚠️ These components have been updated since last context load:")
    for (file in stale_files) {
      message("  📝 ", file)
    }
    message("💡 Consider running: add_to_instructions(", paste0('"', paste(component_list, collapse='", "'), '"'), ")")
    return(FALSE)
  } else {
    message("✅ All loaded components are current")
    return(TRUE)
  }
}

# 2. Smart Context Management - Auto-suggest relevant context based on analysis phase
suggest_context <- function(analysis_phase = NULL) {
  if (is.null(analysis_phase)) {
    message("🎯 Available analysis phases:")
    message("  📊 'data-setup' - Focus on data assembly and pipeline")
    message("  🔍 'exploration' - Focus on EDA and initial findings") 
    message("  📈 'modeling' - Focus on analysis and reporting")
    message("  🚀 'compass' - Focus on compass_Assessment_ID updates")
    message("\nUsage: suggest_context('data-setup')")
    return()
  }
  
  suggestions <- switch(analysis_phase,
    "data-setup" = c("onboarding-ai", "pipeline", "cache-manifest"),
    "exploration" = c("onboarding-ai", "mission", "method", "glossary"),
    "modeling" = c("mission", "method", "semiology", "fides"),
    "compass" = c("logbook", "cache-manifest"),
    c("onboarding-ai", "mission", "method")
  )
  
  message("💡 Suggested context for '", analysis_phase, "' phase:")
  message("   add_to_instructions(", paste0('"', paste(suggestions, collapse='", "'), '"'), ")")
  
  # Auto-load option
  response <- readline("🤖 Load this context automatically? (y/n): ")
  if (tolower(trimws(response)) %in% c("y", "yes")) {
    do.call(add_to_instructions, as.list(suggestions))
  }
}

# 3. Context Size Management - Warn about large contexts
check_context_size <- function() {
  instructions_path <- ".github/copilot-instructions.md"
  
  if (!file.exists(instructions_path)) {
    return()
  }
  
  file_size <- file.size(instructions_path)
  line_count <- length(readLines(instructions_path, warn = FALSE))
  
  message("📊 Context file stats:")
  message("  📄 Size: ", round(file_size / 1024, 1), " KB")
  message("  📝 Lines: ", line_count)
  
  # Multi-tier warnings for better guidance
  if (file_size > 100000) { # ~100KB - Critical
    message("🚨 CRITICAL: Context file is very large (>100KB) - high risk of truncation")
    message("    Recommend: remove_all_dynamic_instructions() and use focused contexts")
  } else if (file_size > 50000) { # ~50KB - Warning
    message("⚠️ WARNING: Context file is getting large (>50KB) - may impact performance")
    message("    Recommend: consider using focused contexts for better efficiency")
  } else if (file_size > 25000) { # ~25KB - Caution
    message("💡 NOTICE: Context file approaching optimal size (>25KB)")
    message("    Consider: focused contexts for complex analysis tasks")
  } else {
    message("✅ Context file size is optimal for AI focus")
  }
}

# ==============================================================================
# CACHE MANIFEST MANAGEMENT
# ==============================================================================

# Function to check and update CACHE-manifest-0.md based on actual 0-ellis outputs
check_cache_manifest <- function(update_if_needed = TRUE) {
  cache_manifest_path <- "./data-public/metadata/CACHE-manifest-0.md"
  # Note: CACHE-manifest-example.md was removed - template no longer needed
  # cache_example_path <- "./ai/CACHE-manifest-example.md"
  logbook_path <- "./ai/logbook.md"
  
  # Check if required files exist (example file check removed)
  # if (!file.exists(cache_example_path)) {
  # if (!file.exists(cache_example_path)) {
    # stop("❌ CACHE-manifest-example.md not found at: ", cache_example_path)
  # }
  
  message("🔍 Analyzing 0-ellis script outputs...")
  
  # Check if CACHE manifest exists and get its timestamp
  manifest_exists <- file.exists(cache_manifest_path)
  manifest_timestamp <- if (manifest_exists) file.mtime(cache_manifest_path) else NULL
  
  message("📋 CACHE Manifest Status:")
  if (manifest_exists) {
    message("   ✅ File exists: ", cache_manifest_path)
    message("   📅 Last updated: ", format(manifest_timestamp, "%Y-%m-%d %H:%M:%S"))
  } else {
    message("   ❌ File missing: ", cache_manifest_path)
  }
  
  # Define the datasets created by 0-ellis script
  ellis_datasets <- list(
    "ds_year_long" = list(
      description = "Annual aggregate publishing statistics",
      primary_key = "year + measure",
      source_sheet = "К-ть видань",
      purpose = "Total publication counts across all categories by year"
    ),
    "ds_language_long" = list(
      description = "Publications by language",
      primary_key = "year + measure + language", 
      source_sheet = "мови народу світу",
      purpose = "Language distribution of publications over time"
    ),
    "ds_genre_long" = list(
      description = "Publications by thematic genre",
      primary_key = "year + measure + genre",
      source_sheet = "Тематичні розділи, Наклад тематич., Тематичні розділи 05-06",
      purpose = "Genre/thematic classification of publications"
    ),
    "ds_pubtype_long" = list(
      description = "Publications by publication type",
      primary_key = "year + measure + pubtype",
      source_sheet = "Аркуш15, Цільові призначення", 
      purpose = "Publication type classification and analysis"
    ),
    "ds_geography_long" = list(
      description = "Publications by Ukrainian region",
      primary_key = "year + measure + geography",
      source_sheet = "території, Терир. наклад",
      purpose = "Regional distribution of publishing activity"
    ),
    "ds_ukr_rus_long" = list(
      description = "Ukrainian vs Russian language publications",
      primary_key = "year + measure + language",
      source_sheet = "мови народу світу (derived)",
      purpose = "Comparative analysis of Ukrainian and Russian language publishing"
    )
  )
  
  # Check which datasets actually exist
  existing_datasets <- list()
  new_datasets <- c()
  updated_datasets <- c()
  stale_manifest <- FALSE
  
  message("\n📊 Dataset Analysis:")
  
  for (dataset_name in names(ellis_datasets)) {
    rds_path <- paste0("data-private/derived/manipulation/", dataset_name, ".rds")
    if (file.exists(rds_path)) {
      existing_datasets[[dataset_name]] <- ellis_datasets[[dataset_name]]
      
      file_timestamp <- file.mtime(rds_path)
      file_age_hours <- as.numeric(difftime(Sys.time(), file_timestamp, units = "hours"))
      
      # Check if this dataset is new (file modified recently)
      if (file_age_hours < 2) {  # Consider files modified in last 2 hours as "new"
        new_datasets <- c(new_datasets, dataset_name)
      }
      
      # Check if manifest is older than this dataset
      if (manifest_exists && file_timestamp > manifest_timestamp) {
        updated_datasets <- c(updated_datasets, dataset_name)
        stale_manifest <- TRUE
      }
      
      # Report dataset status
      status_icon <- if (dataset_name %in% new_datasets) "🆕" else "✅"
      age_text <- if (file_age_hours < 1) {
        paste(round(file_age_hours * 60), "min ago")
      } else if (file_age_hours < 24) {
        paste(round(file_age_hours, 1), "hrs ago")
      } else {
        paste(round(file_age_hours / 24, 1), "days ago")
      }
      
      message("   ", status_icon, " ", dataset_name, " (", age_text, ")")
      
    } else {
      message("   ❌ ", dataset_name, " - FILE MISSING")
    }
  }
  
  
  # Summary of findings
  message("\n📈 SUMMARY:")
  message("   📊 Total datasets found: ", length(existing_datasets), "/", length(ellis_datasets))
  
  if (length(existing_datasets) == 0) {
    message("   ❌ No datasets found. Run 0-ellis script first:")
    message("      safe_run_script('manipulation/0-ellis.R')")
    return(list(status = "no_data", datasets = 0, manifest_current = FALSE))
  }
  
  # Determine overall status
  if (length(new_datasets) > 0) {
    message("   🆕 New datasets: ", paste(new_datasets, collapse = ", "))
  }
  
  if (stale_manifest && manifest_exists) {
    message("   ⚠️  CACHE manifest is OUTDATED")
    message("      Datasets updated since manifest: ", paste(updated_datasets, collapse = ", "))
  } else if (!manifest_exists) {
    message("   ❌ CACHE manifest MISSING")
  } else {
    message("   ✅ CACHE manifest is CURRENT")
  }
  
  # Decision logic for updates
  needs_update <- !manifest_exists || stale_manifest || length(new_datasets) > 0
  
  if (!needs_update) {
    message("\n🎉 CACHE manifest is up-to-date! No action needed.")
    return(list(
      status = "current", 
      datasets = length(existing_datasets), 
      manifest_current = TRUE,
      new_datasets = c(),
      updated_datasets = c()
    ))
  }
  
  if (!update_if_needed) {
    message("\n💡 CACHE manifest needs updating but update_if_needed = FALSE")
    message("    Run check_cache_manifest(update_if_needed = TRUE) to update")
    return(list(
      status = "needs_update", 
      datasets = length(existing_datasets), 
      manifest_current = FALSE,
      new_datasets = new_datasets,
      updated_datasets = updated_datasets
    ))
  }
  
  message("\n🔄 Updating CACHE manifest...")
  
  if (length(existing_datasets) == 0) {
    message("⚠️ No datasets found. Run 0-ellis script first: safe_run_script('manipulation/0-ellis.R')")
    return(FALSE)
  }
  
  message("📊 Found ", length(existing_datasets), " datasets from 0-ellis script")
  if (length(new_datasets) > 0) {
    message("🆕 New/updated datasets: ", paste(new_datasets, collapse = ", "))
  }
  
  # Read the example template
  template_content <- readLines(cache_example_path, warn = FALSE)
  
  # Create the updated manifest content
  manifest_content <- c(
    "# CACHE Manifest",
    "",
    "This document serves as a comprehensive guide to the data structure and organization of the CACHE for the Books of Ukraine project. It provides a reference for understanding the data sources, their relationships, and how they are utilized in research projects.",
    "",
    "The CACHE is designed to support the mission of investigating publishing trends in Ukraine since 2005, understanding regional differences, and detecting patterns in Russian language usage in published books within the larger cultural, political, and economic context of Ukraine.",
    "",
    "---",
    "",
    "# CACHE Overview",
    "",
    "## DATA FERRY PROCESS",
    "",
    "The CACHE is populated through a ferry process implemented in `./manipulation/0-ellis.R` that extracts data from Google Sheets and transforms it into analysis-ready format.",
    "",
    "- **Source**: Google Sheets containing Ukrainian publishing statistics (2005-2023)",
    "- **Ferry Script**: `./manipulation/0-ellis.R`", 
    "- **Output Schema**: Long-format datasets optimized for time-series analysis",
    paste("- **Last Updated**: ", Sys.Date(), " (", length(existing_datasets), " datasets)"),
    "",
    "## CACHE STRUCTURE", 
    "",
    "All datasets follow a consistent long-format structure optimized for temporal analysis and visualization:",
    "",
    "| **Column** | **Type** | **Description** |",
    "|------------|----------|-----------------|",
    "| `year` | Integer | Year of observation (2005-2023) |",
    "| `measure` | Character | Type of measurement (`title_count` or `copy_count`) |",
    "| `[category]` | Character | Category variable (language, genre, geography, pubtype) |",
    "| `value` | Numeric | Measured value for the year-measure-category combination |",
    "",
    "---",
    "",
    "## CACHE TABLES",
    "",
    "### Ferry Load Tables (Analysis-Ready)",
    "",
    "| **Table Name** | **Primary Key(s)** | **Purpose** | **Source Sheet** |",
    "|----------------|-------------------|-------------|------------------|"
  )
  
  # Add table information for existing datasets
  for (dataset_name in names(existing_datasets)) {
    dataset_info <- existing_datasets[[dataset_name]]
    status_marker <- if (dataset_name %in% new_datasets) "🆕 " else ""
    
    manifest_content <- c(manifest_content,
      paste0("| **`", status_marker, dataset_name, "`** | `", dataset_info$primary_key, "` | ", 
             dataset_info$description, " | ", dataset_info$source_sheet, " |")
    )
  }
  
  manifest_content <- c(manifest_content,
    "",
    "---",
    "",
    "## Data Transformation Details"
  )
  
  # Add detailed information for each dataset
  for (dataset_name in names(existing_datasets)) {
    dataset_info <- existing_datasets[[dataset_name]]
    rds_path <- paste0("data-private/derived/manipulation/", dataset_name, ".rds")
    
    # Get file information
    file_size <- round(file.size(rds_path) / 1024, 1)  # KB
    file_date <- format(file.mtime(rds_path), "%Y-%m-%d %H:%M")
    
    manifest_content <- c(manifest_content,
      "",
      paste("### ", dataset_name),
      paste("- **Definition**: ", dataset_info$purpose),
      paste("- **Primary Key**: ", dataset_info$primary_key),
      paste("- **File Size**: ", file_size, " KB"),
      paste("- **Last Modified**: ", file_date),
      paste("- **File Path**: `data-private/derived/manipulation/", dataset_name, ".rds`")
    )
  }
  
  manifest_content <- c(manifest_content,
    "",
    "---",
    "",
    "## SQLite Database",
    "",
    "All datasets are also stored in a SQLite database for efficient querying:",
    "",
    "- **Database**: `data-private/derived/manipulation/books-of-ukraine.sqlite`",
    "- **Tables**: All `ds_*_long` datasets with identical structure",
    "- **Connection**: Use `DBI::dbConnect(RSQLite::SQLite(), \"path/to/database\")`",
    "",
    paste("**Database last updated**: ", Sys.Date())
  )
  
  # Write the updated manifest
  writeLines(manifest_content, cache_manifest_path)
  
  # Update logbook
  update_logbook_entry(new_datasets, existing_datasets)
  
  message("✅ Updated CACHE-manifest-0.md with current dataset information")
  message("📊 Total datasets: ", length(existing_datasets))
  if (length(new_datasets) > 0) {
    message("🆕 New datasets documented: ", paste(new_datasets, collapse = ", "))
  }
  message("📝 Logbook updated with changes")
  
  return(list(
    status = "updated", 
    datasets = length(existing_datasets), 
    manifest_current = TRUE,
    new_datasets = new_datasets,
    updated_datasets = updated_datasets
  ))
}

# Helper function to update logbook with CACHE changes
update_logbook_entry <- function(new_datasets, all_datasets) {
  logbook_path <- "./ai/logbook.md"
  
  # Read current logbook
  if (file.exists(logbook_path)) {
    logbook_content <- readLines(logbook_path, warn = FALSE)
  } else {
    logbook_content <- c(
      "# logbook.md",
      "",
      "## Project Logbook", 
      "Use this to document key decisions, model revisions, and reasoning transitions across modalities.",
      ""
    )
  }
  
  # Create new entry
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  entry_header <- paste("## CACHE Manifest Update -", format(Sys.Date(), "%Y-%m-%d"))
  
  entry_content <- c(
    "",
    entry_header,
    paste("**Timestamp**: ", timestamp),
    paste("**Total datasets**: ", length(all_datasets)),
    ""
  )
  
  if (length(new_datasets) > 0) {
    entry_content <- c(entry_content,
      "**New/Updated datasets**:",
      paste("- `", new_datasets, "`", collapse = "\n"),
      ""
    )
  }
  
  entry_content <- c(entry_content,
    "**All available datasets**:",
    paste("- `", names(all_datasets), "`", collapse = "\n"),
    "",
    "**Ferry script**: `manipulation/0-ellis.R`",
    "**Database**: `data-private/derived/manipulation/books-of-ukraine.sqlite`", 
    "",
    "**Key changes**:",
    if (length(new_datasets) > 0) {
      paste("- Added/updated", length(new_datasets), "datasets:", paste(new_datasets, collapse = ", "))
    } else {
      "- Refreshed manifest with current dataset status"
    },
    paste("- Verified", length(all_datasets), "total datasets in CACHE"),
    "- Updated file sizes and modification dates",
    "",
    "---"
  )
  
  # Add entry to logbook (insert after header)
  header_end <- which(grepl("^## Project Logbook", logbook_content))
  if (length(header_end) > 0) {
    updated_logbook <- c(
      logbook_content[1:(header_end + 1)],
      entry_content,
      logbook_content[(header_end + 2):length(logbook_content)]
    )
  } else {
    updated_logbook <- c(logbook_content, entry_content)
  }
  
  # Write updated logbook
  writeLines(updated_logbook, logbook_path)
}

# Convenience wrapper for backward compatibility and quick updates
update_cache_manifest <- function() {
  message("🔄 Calling check_cache_manifest() with auto-update enabled...")
  result <- check_cache_manifest(update_if_needed = TRUE)
  return(result$status == "updated" || result$status == "current")
}

# ==============================================================================
# AI MEMORY SYSTEM INTEGRATION
# ==============================================================================

# Load AI Memory System
if (file.exists("./scripts/ai-memory-functions.R")) {
  source("./scripts/ai-memory-functions.R")
}

# ==============================================================================
# PROJECT ANALYSIS & COMMAND OVERVIEW SYSTEM
# ==============================================================================

# Comprehensive project analysis and command recommendations
analyze_project_status <- function() {
  cat("🔍 COMPREHENSIVE PROJECT ANALYSIS\n")
  cat("=" %r% 80, "\n")
  cat("Analyzing project memory, context, setup, and providing recommendations...\n\n")
  
  # === 1. PROJECT SETUP STATUS ===
  cat("📋 1. PROJECT SETUP STATUS\n")
  cat("-" %r% 40, "\n")
  setup_status <- project_setup_check(verbose = FALSE, return_status = TRUE)
  
  if (setup_status$is_ready) {
    cat("✅ Setup Status: READY\n")
  } else {
    cat("❌ Setup Status: ISSUES DETECTED\n")
    cat("   Critical Errors: ", length(setup_status$errors), "\n")
    cat("   Warnings: ", length(setup_status$warnings), "\n")
    cat("   🔧 Recommendation: Run project_setup_check() for details\n")
  }
  
  # === 2. AI CONTEXT STATUS ===
  cat("\n📚 2. AI CONTEXT STATUS\n")
  cat("-" %r% 40, "\n")
  
  instructions_path <- ".github/copilot-instructions.md"
  if (file.exists(instructions_path)) {
    content <- readLines(instructions_path, warn = FALSE)
    component_line <- content[grepl("\\*\\*Currently loaded components:\\*\\*", content)]
    
    if (length(component_line) == 0) {
      cat("📄 Dynamic Context: NONE LOADED\n")
      cat("   🤖 Recommendation: Run add_core_context() to start\n")
    } else {
      components <- gsub(".*Currently loaded components:\\*\\* ", "", component_line)
      cat("📄 Dynamic Context: LOADED\n")
      cat("   Components: ", components, "\n")
      
      # Check freshness
      stale_info <- validate_context_silent()
      if (length(stale_info$stale_files) > 0) {
        cat("   ⚠️  Status: STALE (some files updated since last load)\n")
        cat("   🔄 Recommendation: Refresh with add_to_instructions()\n")
      } else {
        cat("   ✅ Status: CURRENT\n")
      }
    }
    
    # Check file size
    file_size <- file.size(instructions_path)
    cat("   📊 Size: ", round(file_size / 1024, 1), " KB")
    if (file_size > 50000) {
      cat(" (⚠️  Large - may impact performance)")
    } else if (file_size > 25000) {
      cat(" (💡 Getting large - consider focused contexts)")
    } else {
      cat(" (✅ Optimal)")
    }
    cat("\n")
  } else {
    cat("❌ Copilot Instructions: NOT FOUND\n")
    cat("   🔧 Recommendation: Check repository structure\n")
  }
  
  # === 3. PROJECT MEMORY STATUS ===
  cat("\n🧠 3. PROJECT MEMORY STATUS\n")
  cat("-" %r% 40, "\n")
  
  if (exists("memory_status")) {
    tryCatch({
      memory_status()
    }, error = function(e) {
      cat("❌ Memory System: ERROR\n")
      cat("   Issue: ", e$message, "\n")
    })
  } else {
    cat("⚠️  Memory System: NOT LOADED\n")
    cat("   💡 Memory functions available via ai-memory-functions.R\n")
  }
  
  # === 4. DATA STATUS ===
  cat("\n💾 4. DATA STATUS\n")
  cat("-" %r% 40, "\n")
  
  # Check for key data files
  data_files <- c(
    "data-private/derived/manipulation/books-of-ukraine.sqlite",
    "data-private/derived/manipulation/ds_year_long.rds",
    "data-private/derived/manipulation/ds_language_long.rds",
    "data-private/derived/manipulation/ds_genre_long.rds"
  )
  
  data_exists <- sapply(data_files, file.exists)
  existing_count <- sum(data_exists)
  
  cat("📊 Data Files: ", existing_count, "/", length(data_files), " found\n")
  
  if (existing_count == 0) {
    cat("   Status: NO PROCESSED DATA\n")
    cat("   🚀 Recommendation: Run safe_run_script('manipulation/0-ellis.R')\n")
  } else if (existing_count < length(data_files)) {
    cat("   Status: PARTIAL DATA\n")
    cat("   🔄 Recommendation: Re-run data processing to ensure completeness\n")
  } else {
    cat("   Status: COMPLETE\n")
    
    # Check data freshness
    newest_data <- max(sapply(data_files[data_exists], file.mtime))
    hours_old <- as.numeric(difftime(Sys.time(), newest_data, units = "hours"))
    
    if (hours_old > 24) {
      cat("   ⏰ Age: ", round(hours_old, 1), " hours old\n")
      cat("   💡 Consider refreshing if source data has changed\n")
    } else {
      cat("   ✅ Age: Recent (", round(hours_old, 1), " hours old)\n")
    }
  }
  
  # === 5. FLOW.R STATUS ===
  cat("\n🔄 5. FLOW.R STATUS\n")
  cat("-" %r% 40, "\n")
  
  if (file.exists("./flow.R")) {
    flow_check <- tryCatch({
      check_flow_currency(update_if_needed = FALSE)
    }, error = function(e) {
      list(status = "error", message = e$message)
    })
    
    if (flow_check$status == "error") {
      cat("❌ Flow Analysis: ERROR\n")
      cat("   Issue: ", flow_check$message, "\n")
    } else if (flow_check$status == "current") {
      cat("✅ Flow Status: CURRENT\n")
      cat("   Age: ", round(flow_check$flow_age_hours, 1), " hours\n")
    } else {
      cat("⚠️  Flow Status: NEEDS ATTENTION\n")
      cat("   Age: ", round(flow_check$flow_age_hours, 1), " hours\n")
      if (length(flow_check$newer_scripts) > 0) {
        cat("   Newer scripts: ", length(flow_check$newer_scripts), "\n")
      }
      if (length(flow_check$missing_scripts) > 0) {
        cat("   Missing scripts: ", length(flow_check$missing_scripts), "\n")
      }
      cat("   🔧 Recommendation: Run analyze_and_update_flow()\n")
    }
  } else {
    cat("❌ Flow.R: NOT FOUND\n")
    cat("   🔧 Recommendation: Check repository structure\n")
  }
  
  # === 6. ANALYSIS READINESS ===
  cat("\n📈 6. ANALYSIS READINESS\n")
  cat("-" %r% 40, "\n")
  
  analysis_ready <- setup_status$is_ready && existing_count > 0
  
  if (analysis_ready) {
    cat("🎯 Status: READY FOR ANALYSIS\n")
    cat("   Available datasets: ", existing_count, "\n")
    cat("   🚀 Next: Run analysis scripts or create new ones\n")
  } else {
    cat("⏳ Status: NOT READY\n")
    if (!setup_status$is_ready) {
      cat("   Blocker: Setup issues need resolution\n")
    }
    if (existing_count == 0) {
      cat("   Blocker: No processed data available\n")
    }
  }
  
  # === 7. COMPREHENSIVE COMMAND REFERENCE ===
  cat("\n🛠️  7. COMPLETE COMMAND REFERENCE\n")
  cat("=" %r% 80, "\n")
  
  cat("\n🔧 SETUP & DIAGNOSTICS:\n")
  cat("├─ project_setup_check()     │ Full environment validation with detailed diagnostics\n")
  cat("├─ quick_setup_check()       │ Fast setup status check (returns TRUE/FALSE)\n")
  cat("└─ safe_run_script('file.R') │ Execute scripts with automatic setup validation\n")
  
  cat("\n📚 CONTEXT MANAGEMENT:\n")
  cat("├─ context_refresh()         │ Complete status scan + setup check + context options\n")
  cat("├─ add_core_context()        │ Load essential context (onboarding, mission, method, project-map)\n")
  cat("├─ add_data_context()        │ Load data-focused context (cache-manifest, pipeline)\n")
  cat("├─ add_compass_context()     │ Load compass-specific context (logbook)\n")
  cat("├─ add_full_context()        │ Load comprehensive context set\n")
  cat("├─ suggest_context('phase')  │ Smart context suggestions by analysis phase\n")
  cat("├─ add_to_instructions()     │ Manual context loading with custom file selection\n")
  cat("├─ remove_all_dynamic_instructions() │ Reset/clear all dynamic context\n")
  cat("├─ validate_context()        │ Check if loaded context files are current\n")
  cat("├─ check_context_size()      │ Monitor context file size and performance impact\n")
  cat("├─ check_cache_manifest()    │ 🆕 Check CACHE manifest status and update if needed\n")
  cat("├─ update_cache_manifest()   │ 🆕 Force update CACHE manifest with current 0-ellis outputs\n")
  cat("├─ check_project_map()       │ 🆕 Scan project structure and update project map\n")
  cat("├─ update_project_map()      │ 🆕 Force update project map with current structure\n")
  cat("├─ check_flow_currency()     │ 🆕 Check if flow.R is current vs project scripts\n")
  cat("├─ analyze_and_update_flow() │ 🆕 Intelligently analyze and update flow.R structure\n")
  cat("└─ check_flow_status()       │ 🆕 Quick flow.R status check\n")
  
  cat("\n🧠 MEMORY & INTELLIGENCE:\n")
  cat("├─ ai_memory_check()         │ Main AI memory function with intent detection\n")
  cat("├─ memory_status()           │ Quick project memory status overview\n")
  cat("├─ generate_project_briefing()│ Comprehensive project briefing generation\n")
  cat("└─ update_project_memory()   │ Manual project memory updates\n")
  
  cat("\n📊 PROJECT ANALYSIS:\n")
  cat("├─ analyze_project_status()  │ THIS COMMAND - Complete project analysis\n")
  cat("└─ get_command_help('cmd')   │ Detailed help for specific commands\n")
  
  # === 7. INTELLIGENT RECOMMENDATIONS ===
  cat("\n🎯 7. INTELLIGENT RECOMMENDATIONS\n")
  cat("=" %r% 80, "\n")
  
  recommendations <- c()
  
  # Setup recommendations
  if (!setup_status$is_ready) {
    recommendations <- c(recommendations, 
      "🔧 CRITICAL: Fix setup issues first → project_setup_check()")
  }
  
  # Context recommendations
  if (length(component_line) == 0) {
    recommendations <- c(recommendations,
      "🤖 Start with core AI context → add_core_context()")
  } else if (exists("stale_info") && length(stale_info$stale_files) > 0) {
    recommendations <- c(recommendations,
      "🔄 Refresh stale context → add_to_instructions()")
  }
  
  # Flow recommendations
  if (exists("flow_check") && !is.null(flow_check) && flow_check$status != "current") {
    recommendations <- c(recommendations,
      "🔄 Update workflow structure → analyze_and_update_flow()")
  }
  
  # Data recommendations
  if (existing_count == 0) {
    recommendations <- c(recommendations,
      "💾 Generate initial data → safe_run_script('manipulation/0-ellis.R')")
  } else if (existing_count < length(data_files)) {
    recommendations <- c(recommendations,
      "📊 Complete data processing → safe_run_script('manipulation/0-ellis.R')")
  }
  
  # Analysis phase recommendations
  if (analysis_ready) {
    recommendations <- c(recommendations,
      "📈 Ready for analysis → suggest_context('exploration') or suggest_context('modeling')",
      "🎯 Run analysis workflows → safe_run_script('flow.R')")
  }
  
  if (length(recommendations) > 0) {
    cat("Based on current status, recommended next steps:\n\n")
    for (i in seq_along(recommendations)) {
      cat(sprintf("%d. %s\n", i, recommendations[i]))
    }
  } else {
    cat("🎉 Excellent! Your project is in great shape.\n")
    cat("💡 Consider running suggest_context() for phase-specific optimizations.\n")
  }
  
  cat("\n" %r% 80, "\n")
  cat("💡 Pro tip: Save this analysis → capture.output(analyze_project_status())\n")
  cat("🔄 Re-run anytime to get updated status and recommendations\n")
  cat("=" %r% 80, "\n")
}

# Helper function for context validation without verbose output
validate_context_silent <- function() {
  instructions_path <- ".github/copilot-instructions.md"
  
  if (!file.exists(instructions_path)) {
    return(list(stale_files = c(), current = TRUE))
  }
  
  content <- readLines(instructions_path, warn = FALSE)
  component_line <- content[grepl("\\*\\*Currently loaded components:\\*\\*", content)]
  
  if (length(component_line) == 0) {
    return(list(stale_files = c(), current = TRUE))
  }
  
  components <- gsub(".*Currently loaded components:\\*\\* ", "", component_line)
  component_list <- trimws(strsplit(components, ",")[[1]])
  
  file_map <- list(
    "onboarding-ai" = "./ai/onboarding-ai.md",
    "mission" = "./ai/mission.md", 
    "method" = "./ai/method.md",
    "project-map" = "./ai/project-map.md",
    "glossary" = "./ai/glossary.md",
    "semiology" = "./ai/semiology.md",
    "pipeline" = "./pipeline.md",
    "fides" = "./ai/FIDES.md",
    "logbook" = "./ai/logbook.md",
    "cache-manifest" = "./data-public/metadata/CACHE-manifest-0.md"
  )
  
  stale_files <- c()
  
  for (component in component_list) {
    if (component %in% names(file_map)) {
      file_path <- file_map[[component]]
      if (file.exists(file_path)) {
        file_time <- file.mtime(file_path)
        instructions_time <- file.mtime(instructions_path)
        if (file_time > instructions_time) {
          stale_files <- c(stale_files, component)
        }
      }
    }
  }
  
  return(list(
    stale_files = stale_files,
    current = length(stale_files) == 0
  ))
}

# Detailed command help system
get_command_help <- function(command_name = NULL) {
  help_info <- list(
    "project_setup_check" = list(
      description = "Comprehensive environment validation with detailed diagnostics",
      usage = "project_setup_check(verbose = TRUE, return_status = FALSE)",
      purpose = "Validates R packages, project structure, authentication, and data directories",
      when_to_use = "New team member setup, troubleshooting environment issues"
    ),
    
    "context_refresh" = list(
      description = "Complete project status scan with setup validation and context options",
      usage = "context_refresh()",
      purpose = "One-stop command for project overview + context management options",
      when_to_use = "Regular project status checks, when starting work sessions"
    ),
    
    "safe_run_script" = list(
      description = "Execute R scripts with automatic setup validation first",
      usage = "safe_run_script('path/to/script.R', check_setup = TRUE)",
      purpose = "Prevents script failures due to environment issues",
      when_to_use = "Running any project scripts, especially for new team members"
    ),
    
    "add_core_context" = list(
      description = "Load essential AI context (onboarding, mission, method, project-map)",
      usage = "add_core_context()",
      purpose = "Provides AI with fundamental project understanding and structure overview",
      when_to_use = "Starting analysis work, when AI needs project background and navigation"
    ),
    
    "analyze_project_status" = list(
      description = "Comprehensive analysis of project status with intelligent recommendations",
      usage = "analyze_project_status()",
      purpose = "Complete project health check with actionable next steps",
      when_to_use = "Project onboarding, regular health checks, when unsure what to do next"
    ),
    
    "check_flow_currency" = list(
      description = "Check if flow.R is current vs project scripts",
      usage = "check_flow_currency(update_if_needed = TRUE)",
      purpose = "Analyzes all project scripts and compares with flow.R to detect needed updates",
      when_to_use = "After adding new scripts, reorganizing project, or when flow.R execution fails"
    ),
    
    "analyze_and_update_flow" = list(
      description = "Intelligently analyze and update flow.R structure",
      usage = "analyze_and_update_flow(backup = TRUE)",
      purpose = "Automatically reconstructs flow.R based on current project script structure",
      when_to_use = "When flow.R is outdated, after major project reorganization, team onboarding"
    ),
    
    "check_flow_status" = list(
      description = "Quick flow.R status check",
      usage = "check_flow_status()",
      purpose = "Lightweight boolean check of flow.R currency for automation",
      when_to_use = "Script automation, quick status checks, CI/CD workflows"
    ),
    
    "check_project_map" = list(
      description = "Scan project structure and create/update project-map.md",
      usage = "check_project_map(update_if_needed = TRUE)",
      purpose = "Creates comprehensive project overview for new team members and tracks structural changes",
      when_to_use = "New team member onboarding, after adding new files/directories, periodic documentation updates"
    ),
    
    "update_project_map" = list(
      description = "Force update project map with current structure",
      usage = "update_project_map()",
      purpose = "Regenerates project map regardless of current status and logs any detected changes",
      when_to_use = "After major project reorganization, when you want to ensure map is completely current"
    )
  )
  
  if (is.null(command_name)) {
    cat("📖 AVAILABLE COMMANDS FOR DETAILED HELP:\n")
    cat("=" %r% 50, "\n")
    for (cmd in names(help_info)) {
      cat("• get_command_help('", cmd, "')\n", sep = "")
    }
    cat("\nUsage: get_command_help('command_name')\n")
    return()
  }
  
  if (!command_name %in% names(help_info)) {
    cat("❌ Command not found: ", command_name, "\n")
    cat("Available commands: ", paste(names(help_info), collapse = ", "), "\n")
    return()
  }
  
  info <- help_info[[command_name]]
  cat("📖 COMMAND HELP: ", toupper(command_name), "\n")
  cat("=" %r% 60, "\n")
  cat("Description: ", info$description, "\n")
  cat("Usage:       ", info$usage, "\n")
  cat("Purpose:     ", info$purpose, "\n")
  cat("When to use: ", info$when_to_use, "\n")
  cat("=" %r% 60, "\n")
}

# ==============================================================================
# FLOW.R ANALYSIS AND MANAGEMENT SYSTEM
# ==============================================================================

# Function to check if flow.R is current and analyze project scripts
check_flow_currency <- function(update_if_needed = TRUE) {
  flow_path <- "./flow.R"
  
  if (!file.exists(flow_path)) {
    stop("❌ flow.R not found at: ", flow_path)
  }
  
  message("🔍 Analyzing flow.R currency...")
  
  # Get flow.R timestamp
  flow_timestamp <- file.mtime(flow_path)
  flow_age_hours <- as.numeric(difftime(Sys.time(), flow_timestamp, units = "hours"))
  
  message("📋 Flow.R Status:")
  message("   ✅ File exists: ", flow_path)
  message("   📅 Last updated: ", format(flow_timestamp, "%Y-%m-%d %H:%M:%S"))
  message("   ⏰ Age: ", round(flow_age_hours, 1), " hours")
  
  # Find all executable scripts in the project
  all_scripts <- analyze_project_scripts()
  
  # Check if any scripts are newer than flow.R
  newer_scripts <- c()
  missing_from_flow <- c()
  
  # Read current flow.R content
  flow_content <- readLines(flow_path, warn = FALSE)
  
  message("\n📊 Script Analysis:")
  message("   📁 Total R scripts found: ", length(all_scripts$r_scripts))
  message("   📄 Total .qmd files found: ", length(all_scripts$qmd_files))
  message("   📋 Total .sql files found: ", length(all_scripts$sql_files))
  
  for (script in all_scripts$r_scripts) {
    script_timestamp <- file.mtime(script)
    if (script_timestamp > flow_timestamp) {
      newer_scripts <- c(newer_scripts, script)
    }
    
    # Check if script is referenced in flow.R (simple check)
    script_basename <- basename(script)
    if (!any(grepl(script_basename, flow_content, fixed = TRUE))) {
      missing_from_flow <- c(missing_from_flow, script)
    }
  }
  
  # Summary of findings
  message("\n📈 CURRENCY ANALYSIS:")
  
  if (length(newer_scripts) > 0) {
    message("   ⚠️  Scripts newer than flow.R: ", length(newer_scripts))
    for (script in head(newer_scripts, 5)) {  # Show first 5
      age_diff <- round(as.numeric(difftime(file.mtime(script), flow_timestamp, units = "hours")), 1)
      message("      📝 ", script, " (+", age_diff, "h)")
    }
    if (length(newer_scripts) > 5) {
      message("      ... and ", length(newer_scripts) - 5, " more")
    }
  } else {
    message("   ✅ No scripts newer than flow.R")
  }
  
  if (length(missing_from_flow) > 0) {
    message("   🔍 Scripts not referenced in flow.R: ", length(missing_from_flow))
    for (script in head(missing_from_flow, 5)) {  # Show first 5
      message("      📄 ", script)
    }
    if (length(missing_from_flow) > 5) {
      message("      ... and ", length(missing_from_flow) - 5, " more")
    }
  } else {
    message("   ✅ All main scripts appear to be referenced")
  }
  
  # Decision logic
  needs_update <- length(newer_scripts) > 0 || length(missing_from_flow) > 0
  
  if (!needs_update) {
    message("\n🎉 Flow.R appears to be current! No immediate action needed.")
    return(list(
      status = "current",
      newer_scripts = c(),
      missing_scripts = c(),
      flow_age_hours = flow_age_hours
    ))
  }
  
  if (!update_if_needed) {
    message("\n💡 Flow.R may need updating but update_if_needed = FALSE")
    message("    Run analyze_and_update_flow() to update automatically")
    return(list(
      status = "needs_update",
      newer_scripts = newer_scripts,
      missing_scripts = missing_from_flow,
      flow_age_hours = flow_age_hours
    ))
  }
  
  message("\n🔄 Would you like to analyze and update flow.R?")
  message("    This will suggest changes based on current project structure.")
  message("    Run analyze_and_update_flow() to proceed with smart updates.")
  
  return(list(
    status = "analysis_complete",
    newer_scripts = newer_scripts,
    missing_scripts = missing_from_flow,
    flow_age_hours = flow_age_hours,
    all_scripts = all_scripts
  ))
}

# Function to analyze all scripts in the project
analyze_project_scripts <- function() {
  message("🔍 Scanning project for executable scripts...")
  
  # Find all R scripts (excluding flow.R itself)
  r_scripts <- c()
  
  # Main directories to scan
  scan_dirs <- c("manipulation", "analysis", "scripts")
  
  for (dir in scan_dirs) {
    if (dir.exists(dir)) {
      scripts <- list.files(dir, pattern = "\\.R$", recursive = TRUE, full.names = TRUE)
      # Filter out certain patterns
      scripts <- scripts[!grepl("archive/|backup/|old/|temp/", scripts)]
      scripts <- scripts[!grepl("flow\\.R$", scripts)]  # Exclude flow.R itself
      r_scripts <- c(r_scripts, scripts)
    }
  }
  
  # Find all .qmd files
  qmd_files <- c()
  for (dir in c("analysis", "docs")) {
    if (dir.exists(dir)) {
      qmds <- list.files(dir, pattern = "\\.qmd$", recursive = TRUE, full.names = TRUE)
      qmd_files <- c(qmd_files, qmds)
    }
  }
  
  # Find all .sql files
  sql_files <- c()
  for (dir in c("manipulation", "scripts")) {
    if (dir.exists(dir)) {
      sqls <- list.files(dir, pattern = "\\.sql$", recursive = TRUE, full.names = TRUE)
      sql_files <- c(sql_files, sqls)
    }
  }
  
  return(list(
    r_scripts = sort(r_scripts),
    qmd_files = sort(qmd_files),
    sql_files = sort(sql_files)
  ))
}

# Function to analyze and update flow.R intelligently
analyze_and_update_flow <- function(backup = TRUE) {
  flow_path <- "./flow.R"
  
  if (!file.exists(flow_path)) {
    stop("❌ flow.R not found at: ", flow_path)
  }
  
  message("🔍 Analyzing current flow.R structure...")
  
  # Create backup if requested
  if (backup) {
    backup_path <- paste0(flow_path, ".backup.", format(Sys.time(), "%Y%m%d_%H%M%S"))
    file.copy(flow_path, backup_path)
    message("💾 Backup created: ", backup_path)
  }
  
  # Read current flow.R
  flow_content <- readLines(flow_path, warn = FALSE)
  
  # Find the ds_rail section
  rail_start <- which(grepl("ds_rail.*<-.*c\\(", flow_content))
  rail_end <- which(grepl("^\\)", flow_content) & seq_along(flow_content) > max(rail_start, 1))
  
  if (length(rail_start) == 0 || length(rail_end) == 0) {
    warning("❌ Could not locate ds_rail definition in flow.R")
    return(FALSE)
  }
  
  rail_start <- rail_start[1]
  rail_end <- rail_end[1]
  
  message("📋 Found ds_rail section: lines ", rail_start, " to ", rail_end)
  
  # Analyze project scripts
  all_scripts <- analyze_project_scripts()
  
  # Generate new ds_rail content based on current project structure
  new_rail_content <- generate_flow_rail(all_scripts)
  
  message("\n🔄 Proposed changes to ds_rail:")
  message("   📊 Current entries: ", rail_end - rail_start - 1)
  message("   📈 Proposed entries: ", length(new_rail_content))
  
  # Show preview of changes
  message("\n📝 Preview of new ds_rail structure:")
  for (i in seq_len(min(10, length(new_rail_content)))) {
    message("   ", new_rail_content[i])
  }
  if (length(new_rail_content) > 10) {
    message("   ... and ", length(new_rail_content) - 10, " more entries")
  }
  
  # Ask for confirmation
  message("\n❓ Update flow.R with this new structure? (y/n)")
  if (interactive()) {
    response <- readline("Enter your choice: ")
    if (!tolower(trimws(response)) %in% c("y", "yes")) {
      message("❌ Update cancelled.")
      return(FALSE)
    }
  } else {
    message("🤖 Non-interactive mode: proceeding with update")
  }
  
  # Update the flow.R file
  updated_content <- c(
    flow_content[1:(rail_start - 1)],
    "ds_rail <- c(",
    new_rail_content,
    ")",
    flow_content[(rail_end + 1):length(flow_content)]
  )
  
  writeLines(updated_content, flow_path)
  
  message("✅ flow.R updated successfully!")
  message("📄 Total lines: ", length(updated_content))
  message("🔄 New ds_rail entries: ", length(new_rail_content))
  
  # Validate the updated file
  tryCatch({
    parse(flow_path)
    message("✅ Syntax validation passed")
  }, error = function(e) {
    warning("❌ Syntax error in updated flow.R: ", e$message)
    message("🔄 Restoring from backup...")
    if (backup && file.exists(backup_path)) {
      file.copy(backup_path, flow_path, overwrite = TRUE)
      message("✅ Restored from backup")
    }
    return(FALSE)
  })
  
  return(TRUE)
}

# Helper function to generate ds_rail content based on project analysis
generate_flow_rail <- function(all_scripts) {
  rail_entries <- c()
  
  # Add header comment
  rail_entries <- c(rail_entries,
    "  # ===============================",
    "  # PHASE 1: DATA PREPARATION",
    "  # ==============================="
  )
  
  # Add manipulation scripts
  manip_scripts <- all_scripts$r_scripts[grepl("^manipulation/", all_scripts$r_scripts)]
  manip_scripts <- manip_scripts[!grepl("archive/|backup/|old/", manip_scripts)]
  manip_scripts <- sort(manip_scripts)
  
  for (script in manip_scripts) {
    # Generate description based on filename
    description <- generate_script_description(script)
    rail_entries <- c(rail_entries,
      paste0("  \"run_r\"   , \"", script, "\",            # ", description)
    )
  }
  
  # Add phase separator
  rail_entries <- c(rail_entries,
    "",
    "  # ===============================", 
    "  # PHASE 2: ANALYSIS SCRIPTS",
    "  # ==============================="
  )
  
  # Add analysis R scripts
  analysis_r_scripts <- all_scripts$r_scripts[grepl("^analysis/", all_scripts$r_scripts)]
  analysis_r_scripts <- sort(analysis_r_scripts)
  
  for (script in analysis_r_scripts) {
    description <- generate_script_description(script)
    rail_entries <- c(rail_entries,
      paste0("  \"run_r\"   , \"", script, "\",            # ", description)
    )
  }
  
  # Add phase separator
  rail_entries <- c(rail_entries,
    "",
    "  # ===============================",
    "  # PHASE 3: REPORTS & DOCUMENTATION", 
    "  # ==============================="
  )
  
  # Add .qmd files
  qmd_files <- all_scripts$qmd_files
  qmd_files <- sort(qmd_files)
  
  for (qmd in qmd_files) {
    description <- generate_script_description(qmd)
    rail_entries <- c(rail_entries,
      paste0("  \"run_qmd\" , \"", qmd, "\",            # ", description)
    )
  }
  
  # Add SQL files if any
  if (length(all_scripts$sql_files) > 0) {
    rail_entries <- c(rail_entries,
      "",
      "  # ===============================",
      "  # PHASE 4: DATABASE OPERATIONS",
      "  # ==============================="
    )
    
    for (sql in all_scripts$sql_files) {
      description <- generate_script_description(sql)
      rail_entries <- c(rail_entries,
        paste0("  \"run_sql\" , \"", sql, "\",            # ", description)
      )
    }
  }
  
  return(rail_entries)
}

# Helper function to generate descriptions for scripts
generate_script_description <- function(script_path) {
  # Try to extract description from script comments
  if (file.exists(script_path)) {
    tryCatch({
      lines <- readLines(script_path, warn = FALSE, n = 20)  # Read first 20 lines
      
      # Look for title/description comments
      comment_lines <- lines[grepl("^#", lines)]
      
      # Try to find descriptive comments
      for (line in comment_lines) {
        line_clean <- gsub("^#+\\s*", "", line)
        line_clean <- gsub("\\s*#+\\s*$", "", line_clean)
        
        # Skip common patterns and look for descriptive text
        if (nchar(line_clean) > 10 && 
            !grepl("^-+$|^=+$|^\\*+$", line_clean) &&
            !grepl("^(knitr|Author|Created|Updated|TODO)", line_clean) &&
            !grepl("^(load|library|source|require)", line_clean, ignore.case = TRUE)) {
          return(line_clean)
        }
      }
    }, error = function(e) {
      # Continue to fallback
    })
  }
  
  # Fallback: generate description from filename
  basename_clean <- tools::file_path_sans_ext(basename(script_path))
  
  # Convert common patterns
  description <- gsub("-", " ", basename_clean)
  description <- gsub("_", " ", description)
  description <- gsub("\\b(\\w)", "\\U\\1", description, perl = TRUE)  # Title case
  
  # Add context based on directory
  if (grepl("^manipulation/", script_path)) {
    if (grepl("0-ellis", basename_clean)) {
      description <- "Data ferry from Google Sheets to local storage"
    } else {
      description <- paste("Data preparation:", description)
    }
  } else if (grepl("^analysis/", script_path)) {
    if (grepl("eda", basename_clean, ignore.case = TRUE)) {
      description <- paste("Exploratory data analysis:", description)
    } else if (grepl("visual", basename_clean, ignore.case = TRUE)) {
      description <- paste("Data visualization:", description)
    } else {
      description <- paste("Analysis:", description)
    }
  } else if (grepl("\\.qmd$", script_path)) {
    description <- paste("Report:", description)
  } else if (grepl("\\.sql$", script_path)) {
    description <- paste("Database operation:", description)
  }
  
  return(description)
}

# Convenience wrapper for quick flow check
check_flow_status <- function() {
  message("🔍 Quick flow.R status check...")
  result <- check_flow_currency(update_if_needed = FALSE)
  
  if (result$status == "current") {
    message("✅ Flow.R is current and up-to-date!")
  } else {
    message("⚠️  Flow.R may need attention:")
    if (length(result$newer_scripts) > 0) {
      message("   📝 ", length(result$newer_scripts), " scripts newer than flow.R")
    }
    if (length(result$missing_scripts) > 0) {
      message("   🔍 ", length(result$missing_scripts), " scripts not referenced in flow.R")
    }
    message("💡 Run check_flow_currency() or analyze_and_update_flow() for details")
  }
  
  return(result$status == "current")
}

# ==============================================================================
# PROJECT SETUP VALIDATION SYSTEM
# ==============================================================================

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

# Main setup validation function
project_setup_check <- function(verbose = TRUE, return_status = FALSE) {
  if (verbose) {
    cat("=========================================================\n")
    cat("📚 BOOKS OF UKRAINE PROJECT - SETUP VALIDATION\n")
    cat("=========================================================\n")
    cat("Checking your development environment...\n\n")
  }
  
  # Initialize error tracking
  setup_errors <- c()
  setup_warnings <- c()
  
  if (verbose) {
    cat("1. PROJECT STRUCTURE\n")
    cat("-------------------\n")
  }
  
  required_dirs <- c(
    "data-private",
    "data-public", 
    "manipulation",
    "analysis",
    "scripts",
    "ai"
  )
  
  for(dir in required_dirs) {
    if(!check_file(dir, paste("Directory:", dir), required = TRUE)) {
      setup_errors <- c(setup_errors, paste("Missing directory:", dir))
    }
  }
  
  required_files <- c(
    "flow.R",
    "config.yml",
    "scripts/google-auth-helper.R",
    "scripts/setup-google-auth.R",
    "manipulation/0-ellis-long.R"
  )
  
  for(file in required_files) {
    if(!check_file(file, paste("File:", file), required = TRUE)) {
      setup_errors <- c(setup_errors, paste("Missing file:", file))
    }
  }
  
  if (verbose) {
    cat("\n2. R PACKAGES\n")
    cat("-------------\n")
  }
  
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
  
  if (verbose) {
    cat("\nOptional packages (recommended):\n")
    for(pkg in optional_packages) {
      if(!check_package(pkg)) {
        setup_warnings <- c(setup_warnings, paste("Missing optional package:", pkg))
      }
    }
  }
  
  if (verbose) {
    cat("\n3. AUTHENTICATION\n")
    cat("-----------------\n")
  }
  
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
  if (verbose) {
    cat("\n4. GOOGLE SHEETS ACCESS\n")
    cat("-----------------------\n")
  }
  
  if(secrets_exists) {
    tryCatch({
      suppressMessages({
        library(googlesheets4)
        if (file.exists("scripts/google-auth-helper.R")) {
          source("scripts/google-auth-helper.R")
          setup_google_auth(interactive = FALSE)
        }
      })
      
      if(gs4_has_token()) {
        if (verbose) cat("Google Sheets authentication        ✅\n")
      } else {
        if (verbose) cat("Google Sheets authentication        ❌\n")
        setup_errors <- c(setup_errors, "Google Sheets authentication failed")
      }
    }, error = function(e) {
      if (verbose) cat("Google Sheets authentication        ❌\n")
      setup_errors <- c(setup_errors, paste("Authentication error:", e$message))
    })
  } else {
    if (verbose) cat("Google Sheets authentication        ❌ (No .secrets folder)\n")
    setup_errors <- c(setup_errors, "Google Sheets not configured")
  }
  
  if (verbose) {
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
  }
  
  # Generate summary
  if (verbose) {
    cat("\n=========================================================\n")
    cat("📋 SETUP SUMMARY\n")
    cat("=========================================================\n")
    
    if(length(setup_errors) == 0 && length(setup_warnings) == 0) {
      cat("🎉 PERFECT! Your environment is fully configured!\n")
      cat("\n✅ You can now run:\n")
      cat("   • Rscript flow.R\n")
      cat("   • Rscript manipulation/0-ellis-long.R\n")
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
    cat("1. Check the ONBOARDING.md file for detailed setup instructions\n")
    cat("2. Review the ai/onboarding-ai.md for project-specific guidance\n") 
    cat("3. Ask a team member for assistance\n")
    cat("\n💡 TIP: Run project_setup_check() again after making changes!\n")
    cat("=========================================================\n")
  }
  
  # Return status if requested
  if (return_status) {
    return(list(
      errors = setup_errors,
      warnings = setup_warnings,
      is_ready = length(setup_errors) == 0
    ))
  }
  
  # Return TRUE if setup is ready, FALSE otherwise
  return(length(setup_errors) == 0)
}

# Quick setup check (non-verbose version)
quick_setup_check <- function() {
  status <- project_setup_check(verbose = FALSE, return_status = TRUE)
  
  if (status$is_ready) {
    message("✅ Project setup is ready!")
    return(TRUE)
  } else {
    message("❌ Project setup issues detected. Run project_setup_check() for details.")
    message("🔧 Critical issues: ", length(status$errors))
    if (length(status$warnings) > 0) {
      message("⚠️  Warnings: ", length(status$warnings))
    }
    return(FALSE)
  }
}

# Enhanced file execution with automatic setup check
safe_run_script <- function(script_path, check_setup = TRUE) {
  if (!file.exists(script_path)) {
    message("❌ Script not found: ", script_path)
    if (check_setup) {
      message("🔍 Running setup check to diagnose...")
      project_setup_check()
    }
    return(FALSE)
  }
  
  if (check_setup) {
    message("🔍 Checking project setup before running script...")
    if (!quick_setup_check()) {
      message("🚨 Setup issues detected. Please fix before running the script.")
      message("💡 Run project_setup_check() for detailed diagnostics.")
      return(FALSE)
    }
  }
  
  message("🚀 Running script: ", script_path)
  tryCatch({
    source(script_path)
    message("✅ Script completed successfully!")
    return(TRUE)
  }, error = function(e) {
    message("❌ Script failed: ", e$message)
    message("🔍 This might be a setup issue. Running diagnostics...")
    project_setup_check()
    return(FALSE)
  })
}

# Auto-export functions for easy access
if (!exists("copilot_context_initialized")) {
  cat("🤖 Copilot Context Management System Loaded\n")
  cat("📚 Available functions:\n")
  cat("  - analyze_project_status() # 🆕 COMPREHENSIVE project analysis + recommendations\n")
  cat("  - context_refresh()     # Quick status + refresh options\n")
  cat("  - add_core_context()    # onboarding-ai, mission, method, project-map\n")
  cat("  - add_data_context()    # cache-manifest, pipeline\n")
  cat("  - add_compass_context() # logbook\n")
  cat("  - add_full_context()    # comprehensive set\n")
  cat("  - suggest_context()     # smart suggestions by phase\n")
  cat("  - add_to_instructions() # manual component selection\n")
  cat("  - remove_all_dynamic_instructions() # reset dynamic content\n")
  cat("  - check_cache_manifest()   # 🆕 Check CACHE manifest status & update if needed\n")
  cat("  - update_cache_manifest()  # 🆕 Force update CACHE manifest from 0-ellis outputs\n")
  cat("  - check_project_map()      # 🆕 Scan project structure & update project map\n")
  cat("  - update_project_map()     # 🆕 Force update project map with current structure\n")
  cat("  - check_flow_currency()    # 🆕 Check if flow.R is current vs project scripts\n")
  cat("  - analyze_and_update_flow() # 🆕 Intelligently analyze and update flow.R\n")
  cat("  - check_flow_status()      # 🆕 Quick flow.R status check\n")
  cat("  - ai_memory_check()     # 🧠 Project memory & intent detection\n")
  cat("  - memory_status()       # Quick memory status\n")
  cat("  - log_file_change()     # 📝 Log file modifications to logbook\n")
  cat("  - log_change()          # 📝 Short alias for log_file_change()\n")
  cat("  - get_command_help('cmd') # Detailed help for any command\n")
  cat("\n🔧 Project Setup Functions:\n")
  cat("  - project_setup_check() # Full setup validation & diagnostics\n")
  cat("  - quick_setup_check()   # Fast setup status check\n")
  cat("  - safe_run_script()     # Run scripts with automatic setup validation\n")
  
# ==============================================================================
# FILE CHANGE LOGGING FUNCTION
# ==============================================================================

# Log file changes to logbook with timestamp, user, and change description
log_file_change <- function(file_path, change_description = NULL) {
  logbook_path <- "./ai/logbook.md"
  
  # Validate inputs
  if (missing(file_path)) {
    stop("❌ file_path is required. Usage: log_file_change('path/to/file.ext', 'description of changes')")
  }
  
  # Normalize file path (handle relative paths)
  if (!file.exists(file_path)) {
    # Try relative to project root
    alt_path <- file.path(".", file_path)
    if (file.exists(alt_path)) {
      file_path <- alt_path
    } else {
      stop("❌ File not found: ", file_path)
    }
  }
  
  # Get file information
  file_info <- file.info(file_path)
  file_name <- basename(file_path)
  file_ext <- tools::file_ext(file_path)
  mod_time <- format(file_info$mtime, "%Y-%m-%d %H:%M:%S")
  
  # Get user information (try multiple methods)
  user_name <- Sys.getenv("USERNAME", unset = Sys.getenv("USER", unset = "Unknown User"))
  
  # Create change description if not provided
  if (is.null(change_description)) {
    change_description <- paste("Modified", file_name)
  }
  
  # Create logbook entry
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  entry <- paste0(
    "\n## File Change Log - ", format(Sys.time(), "%Y-%m-%d"),
    "\n**File**: `", file_path, "`  ",
    "\n**Modified**: ", mod_time, "  ",
    "\n**Changed by**: ", user_name, "  ",
    "\n**Changes**: ", change_description, "  ",
    "\n**Logged**: ", timestamp, "\n"
  )
  
  # Check if logbook exists
  if (!file.exists(logbook_path)) {
    # Create basic logbook structure
    initial_content <- paste0(
      "# logbook.md\n\n",
      "## Project Logbook\n",
      "Use this to document key decisions, model revisions, and reasoning transitions across modalities.\n"
    )
    writeLines(initial_content, logbook_path)
    message("📝 Created new logbook at: ", logbook_path)
  }
  
  # Append the entry to logbook
  cat(entry, file = logbook_path, append = TRUE)
  
  # Provide user feedback
  message("📝 Logged change to logbook:")
  message("   File: ", file_name, " (", file_ext, ")")
  message("   User: ", user_name)
  message("   Time: ", mod_time)
  message("   Description: ", change_description)
  
  # Return the entry for potential further use
  invisible(entry)
}

# Convenience function with shorter name
log_change <- function(file_path, description = NULL) {
  log_file_change(file_path, description)
}

# ==============================================================================
# PROJECT MAP GENERATION FUNCTION
# ==============================================================================

# Function to scan project structure and create/update project-map.md
check_project_map <- function(update_if_needed = TRUE) {
  project_map_path <- "./ai/project-map.md"
  logbook_path <- "./ai/logbook.md"
  
  message("🗺️  Scanning project structure...")
  
  # Check if project map exists and get its timestamp
  map_exists <- file.exists(project_map_path)
  map_timestamp <- if (map_exists) file.mtime(project_map_path) else NULL
  
  message("📋 Project Map Status:")
  if (map_exists) {
    message("   ✅ File exists: ", project_map_path)
    message("   📅 Last updated: ", format(map_timestamp, "%Y-%m-%d %H:%M:%S"))
  } else {
    message("   ❌ File missing: ", project_map_path)
  }
  
  # Generate current project structure
  current_structure <- generate_project_structure()
  
  # If map doesn't exist or update is needed
  should_update <- !map_exists || update_if_needed
  
  if (should_update) {
    message("🔄 Generating project map...")
    
    # Read existing map if it exists for comparison
    existing_content <- NULL
    if (map_exists) {
      existing_content <- readLines(project_map_path, warn = FALSE)
    }
    
    # Generate new map content
    new_content <- create_project_map_content(current_structure)
    
    # Write the new content
    writeLines(new_content, project_map_path)
    
    # Compare and log changes if map existed before
    if (!is.null(existing_content)) {
      changes <- detect_project_changes(existing_content, new_content)
      if (length(changes) > 0) {
        message("📝 Changes detected:")
        for (change in changes) {
          message("   ", change)
        }
        
        # Log to logbook
        change_summary <- paste(changes, collapse = "; ")
        log_file_change(project_map_path, paste("Project structure changes:", change_summary))
      } else {
        message("✅ No structural changes detected")
      }
    } else {
      message("📝 Created new project map")
      log_file_change(project_map_path, "Created initial project map")
    }
    
    message("✅ Project map updated: ", project_map_path)
  } else {
    message("ℹ️  Project map is current (use update_project_map() to force update)")
  }
  
  invisible(current_structure)
}

# Function to force update project map regardless of status
update_project_map <- function() {
  message("🔄 Force updating project map...")
  result <- check_project_map(update_if_needed = TRUE)
  return(result)
}

# Helper function to generate project structure
generate_project_structure <- function() {
  # Define key directories to scan
  key_dirs <- c(".", "ai", "analysis", "data-private", "data-public", "docs", 
                "guides", "libs", "manipulation", "philosophy", "scripts", "utility")
  
  # Define file types to highlight
  important_extensions <- c(".R", ".qmd", ".md", ".yml", ".json", ".Rproj")
  
  structure <- list()
  
  for (dir in key_dirs) {
    if (dir.exists(dir)) {
      dir_path <- if (dir == ".") getwd() else file.path(getwd(), dir)
      
      # Get files in directory
      files <- list.files(dir, full.names = FALSE, recursive = FALSE)
      
      # Separate directories and files
      subdirs <- files[file.info(file.path(dir, files))$isdir %in% TRUE]
      files <- files[!file.info(file.path(dir, files))$isdir %in% TRUE]
      
      # Filter for important files
      important_files <- files[tools::file_ext(files) %in% gsub("\\.", "", important_extensions)]
      other_files <- files[!files %in% important_files]
      
      structure[[dir]] <- list(
        subdirs = subdirs,
        important_files = important_files,
        other_files = other_files,
        total_files = length(files)
      )
    }
  }
  
  return(structure)
}

# Helper function to create project map content (tree-style ASCII diagram)
create_project_map_content <- function(structure) {
  content <- c(
    "# Project Map",
    "",
    paste("**Generated**: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
    "",
    "## 🗂️ Books of Ukraine - Project Structure Tree",
    "",
    "**Mission**: Investigate Ukrainian publishing trends (2005+), regional differences, Russian language patterns",
    "**Tech Stack**: R/Quarto + SQLite + Google Sheets | **Team**: Research & Data Science Unit",
    "",
    "```"
  )
  
  # Create tree structure
  tree_lines <- create_tree_structure(structure)
  content <- c(content, tree_lines)
  
  content <- c(content,
    "```",
    "",
    "---",
    "",
    "## 🚀 Quick Commands",
    "",
    "**Setup & Status**: `context_refresh()` • `analyze_project_status()` • `check_cache_manifest()`",
    "**Data Pipeline**: `manipulation/0-ellis.R` → `check_cache_manifest()` → `analysis/eda-*`",
    "**Help**: `get_command_help('function_name')` • `ai/logbook.md` • `ai/README.md`",
    "",
    "*Auto-maintained. Use `update_project_map()` to refresh.*"
  )
  
  return(content)
}

# Helper function to create tree structure (ASCII art style)
create_tree_structure <- function(structure) {
  tree_lines <- c()
  
  # Sort directories for consistent output - root first, then alphabetically
  dirs <- names(structure)
  root_dir <- "."
  other_dirs <- sort(setdiff(dirs, "."))
  ordered_dirs <- c(root_dir, other_dirs)
  
  for (i in seq_along(ordered_dirs)) {
    dir_name <- ordered_dirs[i]
    dir_info <- structure[[dir_name]]
    is_last_dir <- (i == length(ordered_dirs))
    
    # Directory line with emoji
    emoji <- switch(dir_name,
      "." = "🏠",
      "ai" = "🧠", "analysis" = "📊", "data-private" = "🔒", "data-public" = "📂",
      "docs" = "📚", "guides" = "📖", "libs" = "📦", "manipulation" = "🔧",
      "philosophy" = "🤔", "scripts" = "⚙️", "utility" = "🛠️", "_cleanup" = "�️", "�📁"
    )
    
    # Brief description
    desc <- switch(dir_name,
      "." = "Project config & docs",
      "ai" = "Context mgmt & AI memory", 
      "analysis" = "Reports & EDA",
      "data-private" = "Datasets (private)",
      "data-public" = "Datasets (public)",
      "docs" = "Setup guides",
      "guides" = "User workflows", 
      "libs" = "Shared libraries",
      "manipulation" = "Data processing", 
      "philosophy" = "Methods & frameworks",
      "scripts" = "Automation & utilities",
      "utility" = "Project maintenance",
      "_cleanup" = "Temporary/cleanup files",
      ""
    )
    
    if (dir_name == ".") {
      tree_lines <- c(tree_lines, paste0("books-of-ukraine/  ", emoji, " ", desc))
      prefix <- ""
    } else {
      connector <- if (is_last_dir) "└── " else "├── "
      tree_lines <- c(tree_lines, paste0(connector, dir_name, "/  ", emoji, " ", desc))
      prefix <- if (is_last_dir) "    " else "│   "
    }
    
    # Get ALL important files (no truncation)
    all_files <- sort(dir_info$important_files)
    all_subdirs <- sort(dir_info$subdirs)
    
    # Combine files and subdirs for proper ordering
    all_items <- c()
    if (length(all_files) > 0) {
      all_items <- c(all_items, paste0("FILE:", all_files))
    }
    if (length(all_subdirs) > 0) {
      all_items <- c(all_items, paste0("DIR:", all_subdirs))
    }
    
    # Sort all items together
    all_items <- sort(all_items)
    
    for (j in seq_along(all_items)) {
      item <- all_items[j]
      is_last_item <- (j == length(all_items))
      
      item_connector <- if (is_last_item) "└── " else "├── "
      
      if (startsWith(item, "FILE:")) {
        file <- sub("^FILE:", "", item)
        file_desc <- get_brief_file_description(file)
        tree_lines <- c(tree_lines, paste0(prefix, item_connector, file, "  ", file_desc))
      } else if (startsWith(item, "DIR:")) {
        subdir <- sub("^DIR:", "", item)
        tree_lines <- c(tree_lines, paste0(prefix, item_connector, subdir, "/"))
      }
    }
  }
  
  return(tree_lines)
}

# Helper function for very brief file descriptions
get_brief_file_description <- function(filename) {
  descriptions <- list(
    # Root files
    "README.md" = "📄 Project overview",
    "flow.R" = "⚡ Main workflow",
    "config.yml" = "⚙️ Configuration", 
    "books-of-ukraine.Rproj" = "🔧 RStudio project",
    "pipeline.md" = "📋 Data pipeline docs",
    "guides/command-guide.md" = "📖 Command guide",
    "guides/command-reference.md" = "📚 Reference manual",
    "guides/flow-usage.md" = "🔄 Flow usage guide",
    "context7.json" = "🗂️ Context data",
    "LICENSE" = "⚖️ License",
    
    # AI directory
    "mission.md" = "🎯 Project aims",
    "CACHE-manifest-0.md" = "📊 Dataset docs",
    "project-memory.md" = "🧠 Decisions log",
    "logbook.md" = "📝 Change log",
    "method.md" = "📐 Methods",
    "onboarding-ai.md" = "🤖 AI config",
    "FIDES.md" = "🔬 Research framework",
    "glossary.md" = "📖 Terms",
    "semiology.md" = "🔤 Symbols guide",
    "INPUT-manifest.md" = "📥 Input data docs",
    "CACHE-MANIFEST-1.md" = "📊 Enhanced DB",
    "CACHE-manifest-analytical.md" = "📊 Analysis tables", 
    "CACHE-manifest.md" = "� Core star schema",
    "vscode-tasks-reference.md" = "🔧 VS Code tasks",
    "memory-system-demo.md" = "🧠 Memory demo",
    
    # Analysis directory
    "IDEAS.md" = "💡 Analysis ideas",
    "looker-studio-assessment.md" = "📊 Looker assessment",
    
    # Data directories
    "contents.md" = "📄 Data contents",
    
    # Documentation directories
    "google-auth-setup.md" = "🔐 Google auth setup",
    "service-account-setup.md" = "🔑 Service account setup",
    "setup-google-access.md" = "🌐 Google access guide",
    
    # Manipulation directory
    "0-ellis.R" = "📥 Data import",
    "1-ellis.R" = "🔄 Data processing",
    "0-ellis-original-input.R" = "📥 Original import",
    
    # Philosophy directory
    "analysis-templatization.md" = "📝 Analysis templates",
    "causal-inference.md" = "🔬 Causal methods",
    "fides-example.md" = "📖 FIDES example",
    "ontology.md" = "🧬 Data ontology",
    "threats-to-validity.md" = "⚠️ Validity threats",
    
    # Scripts directory
    "update-copilot-context.R" = "🤖 Context mgmt",
    "common-functions.R" = "🛠️ Shared utils",
    "load-core-context.R" = "📚 Context loader",
    "ai-memory-functions.R" = "🧠 Memory system",
    "check-setup.R" = "✅ Setup check",
    "context-refresh.R" = "� Context refresh",
    "operational-functions.R" = "⚙️ Operations",
    "google-auth-helper.R" = "� Google auth",
    "service-account-auth.R" = "� Service auth",
    "setup-google-auth.R" = "� Auth setup",
    "test-service-account.R" = "🧪 Auth test",
    "clean-and-load-core-context.R" = "� Context clean",
    "common-chunks.R" = "📄 Common chunks",
    
    # Utility directory
    "common-headers.R" = "� Common headers",
    "install-packages.R" = "📦 Package install",
    "package-dependency-list.csv" = "� Dependencies",
    "eager.gitignore" = "🚫 Git ignore"
  )
  
  if (filename %in% names(descriptions)) {
    return(descriptions[[filename]])
  } else {
    # Generic by extension
    ext <- tools::file_ext(filename)
    switch(ext,
      "R" = "📊 R script",
      "qmd" = "📑 Report", 
      "md" = "📄 Docs",
      "yml" = "⚙️ Config",
      "yaml" = "⚙️ Config",
      "json" = "🗂️ Data",
      "csv" = "📊 Data",
      "txt" = "📄 Text",
      "Rproj" = "🔧 R project",
      ""
    )
  }
}
get_file_description <- function(filename, directory) {
  # File-specific descriptions
  descriptions <- list(
    # Root files
    "books-of-ukraine.Rproj" = "RStudio project configuration",
    "README.md" = "Project overview and getting started guide",
    "config.yml" = "Project configuration settings",
    "flow.R" = "Main analysis workflow orchestration",
    "pipeline.md" = "Data processing pipeline documentation",
    
    # AI directory
    "project-memory.md" = "Project decisions and intent tracking",
    "CACHE-manifest-0.md" = "Automatically generated dataset documentation",
    "mission.md" = "Project objectives and epistemic aims",
    "method.md" = "Methodological approaches and standards",
    "onboarding-ai.md" = "AI assistant configuration and behavior",
    "logbook.md" = "Change tracking and decision log",
    
    # Scripts directory
    "update-copilot-context.R" = "Context management and automation functions",
    "common-functions.R" = "Shared utility functions across project",
    "operational-functions.R" = "Data processing and analysis helpers",
    "load-core-context.R" = "Core context loading automation",
    
    # Manipulation directory
    "0-ellis.R" = "Primary data import and initial processing",
    "1-ellis.R" = "Secondary data transformation and enrichment",
    
    # Analysis directories
    "eda-1.R" = "Exploratory data analysis scripts",
    "eda-1.qmd" = "Exploratory analysis report document",
    "Data-visual.R" = "Data visualization script",
    "Data-visual.qmd" = "Data visualization report"
  )
  
  # Return specific description or generic one
  if (filename %in% names(descriptions)) {
    return(descriptions[[filename]])
  } else {
    # Generic descriptions based on file extension
    ext <- tools::file_ext(filename)
    switch(ext,
      "R" = "R analysis script",
      "qmd" = "Quarto document for reporting",
      "md" = "Markdown documentation",
      "yml" = "YAML configuration file", 
      "json" = "JSON configuration or data file",
      "Rproj" = "RStudio project file",
      "File in project"
    )
  }
}

# Helper function to detect changes between old and new project maps
detect_project_changes <- function(old_content, new_content) {
  changes <- c()
  
  # Simple change detection - could be enhanced
  old_files <- extract_files_from_content(old_content)
  new_files <- extract_files_from_content(new_content)
  
  # Check for new files
  added_files <- setdiff(new_files, old_files)
  if (length(added_files) > 0) {
    changes <- c(changes, paste("Added:", paste(added_files, collapse = ", ")))
  }
  
  # Check for removed files  
  removed_files <- setdiff(old_files, new_files)
  if (length(removed_files) > 0) {
    changes <- c(changes, paste("Removed:", paste(removed_files, collapse = ", ")))
  }
  
  return(changes)
}

# Helper function to extract file names from content
extract_files_from_content <- function(content) {
  # Extract files mentioned in backticks
  file_pattern <- "`([^`]+\\.[a-zA-Z]+)`"
  matches <- regmatches(content, gregexpr(file_pattern, content))
  files <- unlist(lapply(matches, function(x) gsub("`", "", x)))
  return(unique(files[files != ""]))
}

# ==============================================================================
# ELLIS SCRIPT GENERATION FUNCTION
# ======================================================================
# This function creates a new ellis script (N-ellis.R) by extracting specific
# sections from the previous ellis script (N-1-ellis.R), preserving format and spacing.
# Sections copied: load-packages, generate-documentation, cleanup, validate-enhanced-database,
# and the CASHE-MANIFEST-N section (if present).

create_next_ellis <- function() {
  manip_dir <- "manipulation"
  # List all files matching N-ellis.R, but ignore 10-ellis.R
  ellis_files <- list.files(manip_dir, pattern = "^[0-9]+-ellis\\.R$", full.names = TRUE)
  # Exclude 10-ellis.R from consideration
  ellis_files <- ellis_files[!grepl("(^|/)10-ellis\\.R$", ellis_files)]
  if (length(ellis_files) == 0) {
    stop("No ellis scripts found in manipulation/. At least 0-ellis.R or 1-ellis.R required.")
  }
  # Find the highest N (excluding 10)
  ellis_nums <- as.integer(gsub("-ellis\\.R$", "", basename(ellis_files)))
  last_n <- max(ellis_nums, na.rm = TRUE)
  last_file <- file.path(manip_dir, paste0(last_n, "-ellis.R"))
  next_n <- last_n + 1
  next_file <- file.path(manip_dir, paste0(next_n, "-ellis.R"))
  # Read previous ellis script
  lines <- readLines(last_file, warn = FALSE)
  # Section headers to extract
  section_patterns <- c(
    "# ---- load-packages",
    "# ---- generate-documentation",
    "# ---- cleanup",
    "# ---- validate-enhanced-database",
    paste0("CASHE-MANIFEST-", next_n)
  )
  # Find all section header lines
  section_indices <- lapply(section_patterns, function(pat) grep(pat, lines, fixed = TRUE))
  # Only keep found sections
  found_sections <- which(sapply(section_indices, function(idx) length(idx) > 0))
  if (length(found_sections) == 0) stop("No target sections found in previous ellis script.")
  # For each found section, extract from header to next header or end
  get_section <- function(start_idx) {
    # Find next section header after start_idx
    next_header <- which(grepl("^# ---- ", lines) & seq_along(lines) > start_idx)
    end_idx <- if (length(next_header) > 0) min(next_header) - 1 else length(lines)
    lines[start_idx:end_idx]
  }
  # For CASHE-MANIFEST, allow any line containing it
  get_manifest_section <- function(pat) {
    idx <- grep(pat, lines, fixed = TRUE)
    if (length(idx) == 0) return(NULL)
    # Take block of lines around this header (up to next section or end)
    get_section(idx[1])
  }
  # Build new script content
  new_content <- c()
  for (i in found_sections) {
    pat <- section_patterns[i]
    if (grepl("CASHE-MANIFEST", pat)) {
      sec <- get_manifest_section(pat)
    } else {
      idx <- section_indices[[i]][1]
      sec <- get_section(idx)
    }
    if (!is.null(sec)) {
      # Add a blank line before each section except the first
      if (length(new_content) > 0) new_content <- c(new_content, "")
      new_content <- c(new_content, sec)
    }
  }
  # Write to new ellis script
  writeLines(new_content, next_file)
  message("Created ", next_file, " with selected sections from ", last_file)
  invisible(next_file)
}

  copilot_context_initialized <- TRUE
}
