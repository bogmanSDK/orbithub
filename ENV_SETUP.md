# 📝 Environment Configuration Guide

OrbitHub supports two ways to configure your Jira credentials:
1. ✅ **`.env` file** (Recommended)
2. ✅ **Environment variables** (Fallback)

---

## 🎯 Quick Setup (Using .env file)

### Step 1: Run Setup Script

```bash
cd /Users/Serhii_Bohush/orbithub
./setup.sh
```

This will:
- Install dependencies
- Create `.env` file
- Optionally build native executable

### Step 2: Edit .env File

Open `.env` in your editor:

```bash
# Using nano
nano .env

# Using vim
vim .env

# Using VS Code
code .env
```

### Step 3: Fill in Your Credentials

```bash
# Jira Configuration (Required)
JIRA_BASE_PATH=https://mycompany.atlassian.net
JIRA_EMAIL=john.doe@mycompany.com
JIRA_API_TOKEN=ATATT3xFfGF0abcdefghijklmnopqrstuvwxyz

# Optional Settings
JIRA_SEARCH_MAX_RESULTS=100
JIRA_LOGGING_ENABLED=false
```

---

## 🔑 Getting Your Jira API Token

### Step-by-Step:

1. **Go to Atlassian Account Settings**
   - Visit: https://id.atlassian.com/manage-profile/security/api-tokens

2. **Create API Token**
   - Click "Create API token"
   - Name it: "OrbitHub" (or any name you prefer)
   - Click "Create"

3. **Copy the Token**
   - ⚠️ **Important:** Copy it now! You won't see it again
   - Paste it into your `.env` file as `JIRA_API_TOKEN`

4. **Find Your Jira URL**
   - Your Jira base path is usually: `https://yourcompany.atlassian.net`
   - Remove any trailing slashes
   - No need to include `/browse` or any path

5. **Use Your Jira Email**
   - This is the email you use to log into Jira
   - Usually your work email

---

## 📋 Configuration Options

### Required Fields

| Variable | Description | Example |
|----------|-------------|---------|
| `JIRA_BASE_PATH` | Your Jira instance URL | `https://mycompany.atlassian.net` |
| `JIRA_EMAIL` | Your Jira login email | `john.doe@company.com` |
| `JIRA_API_TOKEN` | API token from Atlassian | `ATATT3xFfGF0...` |

### Optional Fields

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `JIRA_SEARCH_MAX_RESULTS` | Max results per search | `100` | `50` or `200` |
| `JIRA_LOGGING_ENABLED` | Enable debug logging | `false` | `true` or `false` |

---

## 🔄 Configuration Priority

OrbitHub checks configuration in this order:

1. **`.env` file** (if exists)
2. **Environment variables** (fallback)

### Example:

```bash
# If .env has:
JIRA_EMAIL=from-env-file@company.com

# And you export:
export JIRA_EMAIL=from-export@company.com

# OrbitHub will use: from-env-file@company.com (.env wins!)
```

---

## 🛡️ Security Best Practices

### ✅ DO:
- ✅ Keep `.env` file in `.gitignore` (already configured)
- ✅ Never commit `.env` to version control
- ✅ Use separate tokens for different machines
- ✅ Rotate tokens regularly (every 90 days)
- ✅ Use descriptive token names ("OrbitHub - MacBook Pro")

### ❌ DON'T:
- ❌ Share your API token with others
- ❌ Commit `.env` file to git
- ❌ Use the same token across multiple projects
- ❌ Hard-code credentials in source files
- ❌ Share your `.env` file in chat/email

---

## 🧪 Testing Your Configuration

### Test 1: Check Configuration

```bash
dart run bin/orbit.dart --version
```

If this works, your Dart setup is correct.

### Test 2: Get Your Profile

```dart
import 'package:orbithub/orbithub.dart';

void main() async {
  final config = JiraConfig.fromEnvironment();
  final jira = JiraClient(config);
  
  final profile = await jira.getMyProfile();
  print('✅ Connected as: ${profile.displayName}');
}
```

### Test 3: Get a Ticket

```bash
dart run bin/orbit.dart ticket --get PROJ-123
```

Replace `PROJ-123` with an actual ticket key from your Jira.

---

## ❓ Troubleshooting

### Error: "JIRA_BASE_PATH is required"

**Solution:** Create `.env` file or export environment variables

```bash
# Check if .env exists
ls -la .env

# If not, create it
./setup.sh
```

### Error: "Authentication failed" (401/403)

**Possible causes:**

1. **Wrong email** - Use the exact email from your Jira account
2. **Invalid token** - Generate a new token
3. **Expired token** - Tokens don't expire, but might be revoked
4. **Wrong Jira URL** - Check your base path is correct

**Solution:**
```bash
# Test with curl
curl -u "your-email@company.com:YOUR_API_TOKEN" \
  https://your-company.atlassian.net/rest/api/3/myself

# Should return your user profile
```

### Error: "Could not parse .env file"

**Solution:** Check `.env` file format

```bash
# Valid format (no quotes needed):
JIRA_EMAIL=john@company.com

# NOT (no spaces around =):
JIRA_EMAIL = john@company.com

# NOT (no quotes):
JIRA_EMAIL="john@company.com"
```

### Warning: ".env file not found"

This is OK! OrbitHub will fall back to environment variables.

To use `.env` file:
```bash
./setup.sh
# OR manually create:
touch .env
```

---

## 🔄 Alternative: Environment Variables

If you prefer not to use `.env` file:

### Linux/macOS (bash/zsh):

Add to `~/.bashrc` or `~/.zshrc`:

```bash
export JIRA_BASE_PATH="https://your-company.atlassian.net"
export JIRA_EMAIL="your@email.com"
export JIRA_API_TOKEN="your_token"
```

Then reload:
```bash
source ~/.bashrc  # or ~/.zshrc
```

### Windows (PowerShell):

```powershell
$env:JIRA_BASE_PATH="https://your-company.atlassian.net"
$env:JIRA_EMAIL="your@email.com"
$env:JIRA_API_TOKEN="your_token"
```

Or use System Environment Variables:
1. Search "Environment Variables" in Start menu
2. Click "Environment Variables"
3. Add under "User variables"

---

## 📝 Example .env File

Here's a complete example:

```bash
# OrbitHub Configuration

# ======================
# REQUIRED SETTINGS
# ======================

# Your Jira URL (no trailing slash)
JIRA_BASE_PATH=https://acmecorp.atlassian.net

# Your Jira account email
JIRA_EMAIL=jane.doe@acmecorp.com

# API token from https://id.atlassian.com/manage-profile/security/api-tokens
JIRA_API_TOKEN=ATATT3xFfGF0T4gH0M9dKLxN3pQrStUvWxYz

# ======================
# OPTIONAL SETTINGS
# ======================

# Max search results (50-1000)
JIRA_SEARCH_MAX_RESULTS=100

# Enable debug logging
JIRA_LOGGING_ENABLED=false
```

---

## ✅ Verification Checklist

Before running OrbitHub:

- [ ] `.env` file exists in project root
- [ ] `JIRA_BASE_PATH` is set (e.g., `https://company.atlassian.net`)
- [ ] No trailing slash in `JIRA_BASE_PATH`
- [ ] `JIRA_EMAIL` matches your Jira login email
- [ ] `JIRA_API_TOKEN` is copied from Atlassian account settings
- [ ] No quotes around values in `.env`
- [ ] No spaces around `=` in `.env`
- [ ] `.env` file is in `.gitignore`

---

## 🎉 You're Ready!

Once configured, run:

```bash
# Test with CLI
dart run bin/orbit.dart ticket --get PROJ-123

# Or use compiled binary
./orbit ticket --get PROJ-123

# Or use as library
dart run example/basic_usage.dart
```

---

**Need Help?**
- 📖 See [QUICKSTART.md](QUICKSTART.md) for quick setup
- 📘 See [USAGE.md](USAGE.md) for complete guide
- 📗 See [README.md](README.md) for overview


