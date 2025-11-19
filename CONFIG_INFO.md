# Configuration Guide

## Configuration Loading

OrbitHub loads configuration in this priority order:

1. **`.env` file** (if exists) - your local configuration
2. **Environment variables** - system-level fallback

**Note**: `orbithub.env` is ONLY an example file and is NOT used for configuration.

## Setup

### 1. Create your `.env` file

```bash
# Copy the example
cp orbithub.env.example .env

# Edit with your credentials
nano .env
```

### 2. Required variables

```bash
# Jira Configuration
JIRA_BASE_PATH=https://your-company.atlassian.net
JIRA_EMAIL=your@email.com
JIRA_API_TOKEN=your_jira_api_token

# AI Configuration (optional)
AI_PROVIDER=openai
AI_API_KEY=your_openai_api_key
```

## Files

- `.env` - Your actual configuration (NOT committed to git)
- `orbithub.env.example` - Template file (committed to git)
- `orbithub.env` - Old name, now renamed to `.example`

## Security

- ✅ `.env` is in `.gitignore` - never committed
- ✅ `orbithub.env.example` has placeholder values only
- ❌ Never commit real credentials to git

## For GitHub Actions

Configuration is loaded from GitHub Secrets:
- `JIRA_BASE_PATH`
- `JIRA_EMAIL`
- `JIRA_API_TOKEN`
- `AI_PROVIDER`
- `AI_API_KEY`

See: https://github.com/YOUR_USERNAME/orbithub/settings/secrets/actions
