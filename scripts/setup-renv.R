# scripts/setup-renv.R
# Initialize renv environment for the Books of Ukraine project.
# This script:
#   1. Installs/loads renv
#   2. Reads utility/package-dependency-list.csv
#   3. Installs required CRAN + GitHub packages (where install==TRUE)
#   4. Creates renv.lock (snapshot)
#   5. Prints a concise status report
#
# Run via: Rscript scripts/setup-renv.R
# After running, commit renv.lock and the renv/ directory (excluding caches)

message("[renv-setup] Starting...")

# 1. Ensure renv available
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv", repos = "https://cran.rstudio.com")
}

library(utils)
library(tools)

# 2. Initialize renv if not already
if (!file.exists("renv/activate.R")) {
  message("[renv-setup] Initializing new renv project...")
  renv::init(bare = TRUE)
} else {
  message("[renv-setup] renv already initialized; activating...")
  source("renv/activate.R")
}

# 3. Read dependency list
csv_path <- "utility/package-dependency-list.csv"
if (!file.exists(csv_path)) {
  stop("Dependency CSV not found at ", csv_path)
}

raw_df <- tryCatch(read.csv(csv_path, stringsAsFactors = FALSE), error = function(e) stop("Could not read ", csv_path, ": ", e$message))

# Basic cleaning: drop empty rows, keep needed columns
pkg_df <- subset(raw_df, nzchar(package_name) & tolower(install) == "true")

# Separate GitHub vs CRAN
pkg_df$on_cran[is.na(pkg_df$on_cran)] <- TRUE

cran_pkgs <- pkg_df$package_name[pkg_df$on_cran %in% c(TRUE, "TRUE", "true")]
non_cran <- subset(pkg_df, !(on_cran %in% c(TRUE, "TRUE", "true")))

# Include devtools if GitHub packages exist
if (nrow(non_cran) > 0 && !requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools", repos = "https://cran.rstudio.com")
}

message("[renv-setup] Installing CRAN packages (if missing)...")
if (length(cran_pkgs)) {
  renv::install(cran_pkgs)
}

if (nrow(non_cran) > 0) {
  message("[renv-setup] Installing GitHub packages...")
  for (i in seq_len(nrow(non_cran))) {
    gh_user <- non_cran$github_username[i]
    pkg     <- non_cran$package_name[i]
    if (!nzchar(gh_user)) {
      warning("Skipping non-CRAN package without github_username: ", pkg)
      next
    }
    repo_spec <- paste0(gh_user, "/", pkg)
    renv::install(repo_spec)
  }
}

# 4. Snapshot
message("[renv-setup] Creating lockfile (snapshot)...")
renv::snapshot(prompt = FALSE)

# 5. Status
message("[renv-setup] Complete. Key files:")
message("  - renv.lock (commit this file)")
message("  - renv/ (in version control; consider ignoring renv/library via .gitignore)")
message("[renv-setup] To activate in a new session: source('renv/activate.R') or restart R in project root.")

invisible(TRUE)
