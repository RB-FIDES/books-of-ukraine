# Google Sheets Authentication System

This project includes an automated authentication system for Google Sheets access, eliminating the need to manually run `library(googlesheets4)` and `gs4_auth()` every time.

## Quick Setup (One-time only)

### Option 1: Interactive Setup (Recommended)
Run this command in R console:
```r
source("scripts/setup-google-auth.R")
```

### Option 2: Manual Setup
Run these commands in R console:
```r
library(googlesheets4)
gs4_auth(cache = ".secrets")
```

## How It Works

1. **First Time**: You'll need to authenticate once using one of the setup methods above
2. **Authentication Token**: Your authentication token is cached in the `.secrets` folder
3. **Automatic Authentication**: All subsequent runs of `0-ellis-long.R` will use the cached token automatically
4. **Security**: The `.secrets` folder is added to `.gitignore` so tokens aren't committed to the repository

## Running the Scripts

### From R Console
```r
source("manipulation/0-ellis-long.R")
```

### From Command Line
```bash
Rscript manipulation/0-ellis-long.R
```

### From flow.R
The script is already included in `flow.R`. Uncomment the line in the `ds_rail` section:
```r
"run_r", "manipulation/0-ellis-long.R",  # Data import and prep (long format)
```

Then run:
```r
source("flow.R")
```

## Troubleshooting

### Authentication Issues
If you get authentication errors:

1. **Clear and reset authentication**:
   ```r
   source("scripts/google-auth-helper.R")
   force_google_reauth()
   ```

2. **Check authentication status**:
   ```r
   source("scripts/google-auth-helper.R")
   check_google_auth()
   ```

3. **Manual re-authentication**:
   ```r
   library(googlesheets4)
   gs4_deauth()
   gs4_auth(cache = ".secrets")
   ```

### Permission Issues
If you get permission errors accessing specific Google Sheets:
- Ensure you have access to the Google Sheets used in the script
- Check that the sheet URLs in the script are correct
- Verify you're authenticated with the correct Google account

### File Not Found Errors
If you get "file not found" errors:
- Ensure you're running the script from the project root directory
- Check that the working directory is set correctly

## Helper Functions

The authentication system includes several helper functions in `scripts/google-auth-helper.R`:

- `setup_google_auth()` - Automatic authentication setup
- `check_google_auth()` - Check authentication status  
- `clear_google_auth()` - Clear current authentication
- `force_google_reauth()` - Force re-authentication

## Security Notes

- Authentication tokens are stored locally in the `.secrets` folder
- This folder is excluded from version control (added to `.gitignore`)
- Tokens are specific to your Google account and this project
- If you share the project, each user needs to authenticate separately

## Files Modified

- `manipulation/0-ellis-long.R` - Added automatic authentication
- `scripts/google-auth-helper.R` - Authentication helper functions
- `scripts/setup-google-auth.R` - One-time setup script
- `flow.R` - Added 0-ellis-long.R to the execution pipeline
- `.gitignore` - Added `.secrets/` to ignore authentication tokens
