# Setup Guide: Google Sheets Access for Books of Ukraine Project

> **Goal**: Enable new users to access the Books of Ukraine Google Spreadsheet for data analysis without browser authentication.

## Overview

This project uses Google Sheets as the primary data source. To access the data automatically in your scripts (especially `manipulation/0-ellis.R`), you need to set up authentication. This guide provides **two methods** - choose the one that best fits your needs.

## Method 1: Service Account (Recommended) 🏆

**Best for**: Automation, team collaboration, CI/CD environments  
**Setup time**: 15-20 minutes (one-time)  
**Experience**: Zero browser interaction after setup

### Step 1: Create Google Cloud Project & Service Account

#### 1.1 Create/Select Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Sign in with your Google account
3. **Create a new project**:
   - Click "Select a project" dropdown → "New Project"
   - Project name: `books-of-ukraine-analysis` (or your preference)
   - Click "Create"
4. **Or select an existing project** if you already have one

#### 1.2 Enable Google Sheets API
1. In the Google Cloud Console, go to **"APIs & Services" → "Library"**
2. Search for **"Google Sheets API"**
3. Click on "Google Sheets API" from results
4. Click **"Enable"** button
5. Wait for confirmation that the API is enabled

#### 1.3 Create Service Account
1. Go to **"IAM & Admin" → "Service Accounts"**
2. Click **"Create Service Account"**
3. Fill in the details:
   - **Service account name**: `books-of-ukraine-reader`
   - **Service account ID**: Will auto-populate (e.g., `books-of-ukraine-reader`)
   - **Description**: `Service account for accessing Books of Ukraine data spreadsheets`
4. Click **"Create and Continue"**
5. **Skip** "Grant this service account access to project" (click "Continue")
6. **Skip** "Grant users access to this service account" (click "Done")

#### 1.4 Create and Download Credentials
1. Click on your newly created service account name
2. Go to the **"Keys"** tab
3. Click **"Add Key" → "Create new key"**
4. Select **"JSON"** format
5. Click **"Create"**
6. **Save the downloaded file** - this is your authentication key!

### Step 2: Setup Project Authentication

#### 2.1 Place Credentials in Project
1. **Rename** the downloaded JSON file to: `google-service-account.json`
2. **Copy** it to your project's **root directory**:

```
books-of-ukraine/
├── google-service-account.json  ← Place here
├── guides/
│   ├── google-service-account-template.json  ← Template reference
│   └── setup-google-access.md
├── manipulation/
├── scripts/
├── README.md
└── ...
```

⚠️ **Security Note**: This file contains private keys. Never commit it to Git (it's already in `.gitignore`).

#### 2.2 Grant Access to Google Sheets
You need to give your service account permission to access the Books of Ukraine spreadsheet:

1. **Get your service account email**:
   - Open the `google-service-account.json` file in a text editor
   - Find the `"client_email"` field
   - Copy the email (format: `books-of-ukraine-reader@your-project.iam.gserviceaccount.com`)

2. **Add to Google Sheet**:
   - Open the [Books of Ukraine Google Sheet](https://docs.google.com/spreadsheets/d/1nxMTUD9gRhaE_VIT6WPR4V-_7BWNVwsJu__qjtCtSF0)
   - Click the **"Share"** button (top-right)
   - Paste your service account email
   - Set permission to **"Editor"**
   - **Uncheck** "Notify people" (it's a service account, not a person)
   - Click **"Share"**

### Step 3: Test Your Setup

Run this command in your terminal to test the authentication:

```bash
Rscript scripts/test-service-account.R
```

**Expected Output** (success):
```
✅ Service account authentication successful!
📄 Using credentials from: google-service-account.json
✅ Successfully accessed Google Sheet!
📊 Sheet name: [Sheet Name]
📄 Available tabs: Рік, [other tabs]
✅ SERVICE ACCOUNT SETUP IS WORKING CORRECTLY!
```

### Step 4: Run Data Import

Now you can run the main data import script:

```bash
Rscript manipulation/0-ellis.R
```

This should run completely automatically without any browser windows or authentication prompts.

---

## Method 2: One-Time Authentication (Alternative)

**Best for**: Personal use, quick setup  
**Setup time**: 2-3 minutes  
**Experience**: Authenticate once per computer, then automatic

### Step 1: Initial Authentication
Run this command once in your R console or terminal:

```bash
Rscript -e "library(googlesheets4); options(gargle_oauth_cache = '.secrets'); gs4_auth(cache = '.secrets', email = TRUE)"
```

This will:
1. Open a browser window
2. Ask you to sign in to Google
3. Request permission to access Google Sheets
4. Cache your authentication token

### Step 2: Test and Use
After the one-time authentication, run:

```bash
Rscript manipulation/0-ellis.R
```

Future runs will use the cached token automatically.

---

## Troubleshooting

### Service Account Issues

**❌ "Permission denied" when accessing Google Sheets**
- **Solution**: Ensure you added the service account email to the Google Sheet with Editor permissions
- **Check**: Open the sheet → Share → verify the service account email is listed

**❌ "Service account not found"**
- **Solution**: Ensure `google-service-account.json` is in the project root directory
- **Check**: File should be at `books-of-ukraine/google-service-account.json`

**❌ "Invalid credentials" or JSON parsing errors**
- **Solution**: Re-download the service account key from Google Cloud Console
- **Check**: Ensure the JSON file wasn't corrupted during download/transfer

**❌ "Google Sheets API not enabled"**
- **Solution**: Go to Google Cloud Console → APIs & Services → Library → Enable Google Sheets API

### General Authentication Issues

**❌ "Working directory" errors**
- **Solution**: Ensure you're running scripts from the project root directory
- **Check**: Run `getwd()` in R - it should show your project path

**❌ Scripts still asking for browser authentication**
- **For Service Account**: Check that `google-service-account.json` exists and is valid
- **For Cached Auth**: Delete `.secrets` folder and re-authenticate

### Getting Help

1. **Test your setup**: Run `Rscript scripts/test-service-account.R`
2. **Check authentication status**: Run `Rscript -e "source('scripts/service-account-auth.R'); check_auth_status()"`
3. **Review detailed documentation**: This comprehensive guide covers both authentication methods
4. **Contact project maintainers** with specific error messages

---

## What This Enables

Once authentication is set up, you can:

✅ **Run data import scripts automatically**  
✅ **Execute analysis workflows without interruption**  
✅ **Set up automated reporting systems**  
✅ **Collaborate easily** (each team member has their own credentials)  
✅ **Deploy to cloud environments** for automated processing

## Security Best Practices

- 🔒 **Never commit** `google-service-account.json` to version control
- 🔒 **Treat service account keys like passwords** - store them securely
- 🔒 **Use separate service accounts** for different team members
- 🔒 **Regularly rotate service account keys** (recommended annually)
- 🔒 **Grant minimum necessary permissions** (Editor access only to required sheets)

---

## Summary

**Recommended Path**: Use **Method 1 (Service Account)** for the best automation experience. The initial setup takes longer but provides seamless operation afterward.

**Quick Start Path**: Use **Method 2 (One-Time Auth)** if you need to get started immediately and don't mind occasional re-authentication.

Both methods will allow you to run `manipulation/0-ellis.R` and other data scripts automatically once configured.
