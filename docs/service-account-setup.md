# Google Service Account Setup Guide

This guide will help you set up Google Service Account authentication for automatic, browser-free access to Google Sheets.

## Why Service Account?

- ✅ **No browser authentication** required
- ✅ **Perfect for automation** and scripts
- ✅ **Easy for new users** - just drop a JSON file
- ✅ **Works in CI/CD** environments
- ✅ **Each user has their own credentials**

## One-Time Setup (Per Organization)

### Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the **Google Sheets API**:
   - Go to "APIs & Services" → "Library"
   - Search for "Google Sheets API"
   - Click "Enable"

### Step 2: Create Service Account

1. Go to "IAM & Admin" → "Service Accounts"
2. Click "Create Service Account"
3. Fill in details:
   - **Name**: `books-of-ukraine-reader` 
   - **Description**: `Service account for Books of Ukraine data analysis`
4. Click "Create and Continue"
5. Skip "Grant this service account access to project" (click Continue)
6. Skip "Grant users access to this service account" (click Done)

### Step 3: Create and Download Key

1. Click on the newly created service account
2. Go to "Keys" tab
3. Click "Add Key" → "Create new key"
4. Select "JSON" format
5. Click "Create"
6. **Save the downloaded JSON file** - this contains your credentials

## Per-User Setup (Easy!)

### Step 1: Get Your Credentials File

Ask your project administrator for:
- The service account JSON file, OR
- Instructions to create your own service account following the steps above

### Step 2: Place Credentials in Project

1. Copy your service account JSON file to the project
2. Rename it to: `google-service-account.json`
3. Place it in the **project root directory**

```
books-of-ukraine/
├── google-service-account.json  ← Place your file here
├── manipulation/
├── scripts/
└── ...
```

### Step 3: Grant Access to Google Sheets

For each Google Sheet you want to access:

1. Open the Google Sheet
2. Click "Share" button
3. Add the service account email as an editor:
   - Email format: `books-of-ukraine-reader@your-project.iam.gserviceaccount.com`
   - You can find this email in your JSON file under `"client_email"`

### Step 4: Test the Setup

Run this in R console to test:

```r
source("scripts/test-service-account.R")
```

If successful, you'll see: ✅ Service account authentication working!

## Security Notes

- ⚠️ **Never commit** `google-service-account.json` to Git
- ⚠️ The JSON file contains **private keys** - treat it like a password
- ⚠️ Each user should have their **own service account** for security
- ✅ The file is already excluded in `.gitignore`

## Troubleshooting

### "Permission denied" errors
- Ensure the service account email is added to the Google Sheet with Editor permissions
- Check that the Google Sheets API is enabled in your Google Cloud project

### "File not found" errors  
- Ensure `google-service-account.json` is in the project root directory
- Check that the file name is exactly `google-service-account.json`

### "Invalid credentials" errors
- Ensure the JSON file is valid (not corrupted during download/transfer)
- Try downloading a new key from the Google Cloud Console

## Files Modified

This setup adds/modifies:
- `google-service-account.json` (user-provided, not in Git)
- `scripts/service-account-auth.R` (authentication helper)
- `scripts/test-service-account.R` (testing script)
- `manipulation/0-ellis.R` (updated to use service account)
