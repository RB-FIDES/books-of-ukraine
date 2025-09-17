# scripts/install-packages-pak.R
# Install project R packages using pak for speed and parallelism.
# Reads utility/package-dependency-list.csv and installs packages
# (where install == TRUE). GitHub packages are pinned if a commit ref is supplied
# (extend schema later if needed).

if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak", repos = "https://cran.rstudio.com")
}

csv_path <- "utility/package-dependency-list.csv"
if (!file.exists(csv_path)) {
  stop("Dependency CSV not found: ", csv_path)
}

df <- read.csv(csv_path, stringsAsFactors = FALSE)
df <- subset(df, nzchar(df$package_name) & tolower(df$install) == "true")

# Normalize on_cran column
on_cran_flag <- tolower(df$on_cran) %in% c("true", "t", "1", "yes", "y", "") | is.na(df$on_cran)
cran_pkgs <- df$package_name[on_cran_flag]
non_cran  <- df[!on_cran_flag, ]

install_vec <- c()
if (length(cran_pkgs)) {
  message("[pak-install] Installing CRAN packages via pak...")
  pak::pkg_install(cran_pkgs, ask = FALSE)
}

if (nrow(non_cran)) {
  message("[pak-install] Installing GitHub packages via pak...")
  for (i in seq_len(nrow(non_cran))) {
    gh_user <- non_cran$github_username[i]
    pkg     <- non_cran$package_name[i]
    if (!nzchar(gh_user)) {
      warning("Skipping non-CRAN row without github_username for package: ", pkg)
      next
    }
    repo_spec <- paste0("github::", gh_user, "/", pkg)
    pak::pkg_install(repo_spec, ask = FALSE)
  }
}

message("[pak-install] Done.")
