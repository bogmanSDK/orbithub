# OrbitHub Automation Setup Checklist

## ✅ Already Done:
- [x] Jira API configured locally
- [x] AI integration working (OpenAI)
- [x] GitHub Actions workflow created and pushed
- [x] Jira Automation rules created

## 🔧 Need to Configure:

### 1. GitHub Secrets (5 minutes)
Go to: https://github.com/bogmanSDK/orbithub/settings/secrets/actions

Add these secrets:
- [ ] JIRA_BASE_PATH = https://serhiibohush.atlassian.net
- [ ] JIRA_EMAIL = igoraiagent1@gmail.com
- [ ] JIRA_API_TOKEN = (from .env file)
- [ ] AI_PROVIDER = openai
- [ ] AI_API_KEY = (from .env file)

### 2. GitHub PAT for Jira (3 minutes)
- [ ] Go to: https://github.com/settings/tokens
- [ ] Generate new token (classic)
- [ ] Name: "Jira Automation - OrbitHub"
- [ ] Select scope: `repo`
- [ ] Copy the token

### 3. Update Jira Automation (2 minutes)
Update webhook in Jira Automation rule:
- [ ] URL: https://api.github.com/repos/bogmanSDK/orbithub/dispatches
- [ ] Authorization: Bearer YOUR_GITHUB_PAT
- [ ] Body: {"event_type": "ai-teammate-trigger", "client_payload": {"ticket_key": "{{issue.key}}"}}

### 4. Test (5 minutes)
- [ ] Manual test: GitHub Actions → AI Teammate → Run workflow
- [ ] Auto test: Create Jira ticket → Assign to Igor AI Agent → Move to "To Do"
- [ ] Check GitHub Actions ran successfully
- [ ] Check AI created questions in Jira

## 📝 Commands to get secrets from .env:

```bash
cd /Users/Serhii_Bohush/orbithub
cat .env | grep JIRA_API_TOKEN
cat .env | grep AI_API_KEY
```

## 🔗 Quick Links:
- GitHub Repo: https://github.com/bogmanSDK/orbithub
- GitHub Secrets: https://github.com/bogmanSDK/orbithub/settings/secrets/actions
- GitHub Actions: https://github.com/bogmanSDK/orbithub/actions
- GitHub PAT: https://github.com/settings/tokens
- Jira Project: https://serhiibohush.atlassian.net/jira/software/projects/AIH
