Local AI Context

This folder is used by analysis scripts to persist small, structured context files
produced by `silent_mini_eda()` for consumption by local AI helpers or tooling.

Location pattern created by `write_mini_eda_json()`:

  ./analysis/eda-3/local-ai-context/<dataset>/<dataset>_mini_eda.json

Guidelines:
- Files are JSON, pretty-printed, and use ISO8601 timestamps for date/time values.
- Filenames and folder names are sanitized to remove path separators.
- By default, writes will overwrite existing files. Pass `overwrite = FALSE` to avoid this.

To produce a JSON for `ds_language` from this folder:

```r
# inside analysis/eda-3/ script
ds_language_mini_eda <- silent_mini_eda("ds_language")
write_mini_eda_json(ds_language_mini_eda, script_dir = "./analysis/eda-3")
```
