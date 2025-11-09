# AI Teammate Setup Guide

Complete guide to set up AI Teammate workflow with GitHub Actions and Jira Automation.

---

## 🎯 Overview

The AI Teammate workflow:
1. **You** create a ticket and assign it to AI Agent → AI creates questions as subtasks
2. **You** answer questions in subtasks
3. **You** assign ticket back to AI Agent + move to "To Do"
4. **Jira Automation** triggers GitHub Actions
5. **GitHub Actions** runs OrbitHub AI Teammate
6. **AI Teammate** checks answers and proceeds with implementation

---

## 📋 Prerequisites

- [x] OrbitHub Jira functionality working
- [x] GitHub repository with OrbitHub code
- [x] Jira project with subtasks enabled (e.g., AIH)
- [x] Jira user for AI Agent (e.g., Igor AI Agent)

---

## 🔧 Setup Steps

### **Step 1: Configure GitHub Secrets**

1. Go to your GitHub repository: `https://github.com/YOUR_USERNAME/orbithub`
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these secrets:

```
Name: JIRA_BASE_PATH
Value: https://YOUR_DOMAIN.atlassian.net

Name: JIRA_EMAIL
Value: your@email.com

Name: JIRA_API_TOKEN
Value: your_jira_api_token
```

### **Step 2: Create GitHub Personal Access Token**

For Jira to trigger GitHub Actions, you need a PAT:

1. Go to GitHub **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **Generate new token (classic)**
3. Settings:
   - **Name**: `Jira Automation - OrbitHub`
   - **Expiration**: Choose duration (e.g., 90 days or No expiration)
   - **Scopes**: Select `repo` (Full control of private repositories)
4. Click **Generate token**
5. **COPY THE TOKEN** - you won't see it again!

---

### **Step 3: Set up Jira Automation Rule**

#### **3.1 Create Automation Rule**

1. In Jira, go to **Project settings** → **Automation**
2. Click **Create rule**
3. Give it a name: `Trigger AI Teammate on Assignment`

#### **3.2 Configure Trigger**

**Trigger**: `Issue transitioned`

Settings:
- **From status**: Any status
- **To status**: `To Do`
- **Issue type**: Story, Task, Bug (your choice)

**Add another condition** (click the `+` button):

**Trigger**: `Issue assigned`

Settings:
- **Assignee**: Select your AI Agent user (e.g., Igor AI Agent)

Or use **Advanced trigger**:
```
Trigger: Field value changed
Field: Assignee
New value: Igor AI Agent

AND

Field: Status
New value: To Do
```

#### **3.3 Add Condition**

Click **Add condition** → **Issue fields condition**

Settings:
- **Field**: Assignee
- **Condition**: `equals`
- **Value**: Your AI Agent account (Igor AI Agent)

#### **3.4 Add Action - Send Web Request**

Click **Add action** → **Send web request**

Settings:
```
URL: https://api.github.com/repos/YOUR_USERNAME/orbithub/dispatches

HTTP method: POST

HTTP headers:
Authorization: Bearer YOUR_GITHUB_PAT
Accept: application/vnd.github.v3+json
Content-Type: application/json

Webhook body: Custom data

Custom data:
{
  "event_type": "ai-teammate-trigger",
  "client_payload": {
    "ticket_key": "{{issue.key}}",
    "ticket_summary": "{{issue.summary}}",
    "assignee": "{{issue.assignee.displayName}}",
    "status": "{{issue.status.name}}",
    "project": "{{issue.project.key}}"
  }
}
```

**Important**: Replace:
- `YOUR_USERNAME` with your GitHub username
- `YOUR_GITHUB_PAT` with the token from Step 2

#### **3.5 Add Action - Comment (Optional)**

Click **Add action** → **Comment on issue**

```
🤖 AI Teammate has been triggered!

GitHub Actions workflow is now processing this ticket.

Check progress: https://github.com/YOUR_USERNAME/orbithub/actions
```

#### **3.6 Save and Enable**

1. Click **Turn it on**
2. Give it a name: `AI Teammate Workflow`
3. Click **Save**

---

### **Step 4: Test the Workflow**

#### **Option A: Test via Jira (Full workflow)**

1. Create a test story in your project (e.g., AIH):
   ```
   Summary: Test AI Teammate
   Type: Story
   ```

2. Assign it to **AI Agent** (Igor AI Agent)

3. Move status to **To Do**

4. Watch for:
   - Jira Automation runs (check Automation audit log)
   - GitHub Actions starts (check Actions tab)
   - AI Teammate processes the ticket
   - Comment appears in Jira with status

#### **Option B: Test via GitHub UI (Manual trigger)**

1. Go to your GitHub repo → **Actions**
2. Select **AI Teammate** workflow
3. Click **Run workflow**
4. Enter ticket key: `AIH-1`
5. Click **Run workflow**

#### **Option C: Test locally**

```bash
cd /Users/Serhii_Bohush/orbithub

# Set environment variables
export JIRA_BASE_PATH="https://your-domain.atlassian.net"
export JIRA_EMAIL="your@email.com"
export JIRA_API_TOKEN="your_token"

# Run AI Teammate
dart run bin/ai_teammate.dart AIH-1
```

---

## 🎯 Full Workflow Example

### **Scenario: User asks AI to implement a feature**

#### **Step 1: Create ticket and assign to AI**
```
Ticket: AIH-5 - "Add search functionality"
Assignee: Igor AI Agent
Status: To Do
```

#### **Step 2: AI creates questions (manual for now)**
```
AIH-6 (subtask): "❓ What fields should be searchable?"
AIH-7 (subtask): "❓ Should search be case-sensitive?"
AIH-8 (subtask): "❓ Any specific search syntax required?"
```

AI posts comment and moves to "In Progress"

#### **Step 3: You answer questions**
Open each subtask and add comments with answers:
```
AIH-6: "Search should work on: title, description, tags"
AIH-7: "Case-insensitive by default, with option for exact match"
AIH-8: "Support basic AND/OR operators"
```

#### **Step 4: Trigger AI to continue**
```
1. Assign AIH-5 back to "Igor AI Agent"
2. Move status to "To Do"
```

#### **Step 5: Jira Automation triggers GitHub Actions**
```
✅ Jira sends webhook to GitHub
✅ GitHub Actions starts
✅ OrbitHub AI Teammate runs
```

#### **Step 6: AI Teammate checks answers**
```
📥 Fetching ticket AIH-5
📋 Found 3 subtasks
🔍 Checking answers...
   ✅ AIH-6: Answered by Serhii
   ✅ AIH-7: Answered by Serhii
   ✅ AIH-8: Answered by Serhii
✅ All questions answered!
```

#### **Step 7: AI posts status and proceeds**
```
💬 Posted completion comment
🔄 Moved to "In Progress"
🤖 Ready for implementation (AI integration pending)
```

---

## 🔍 Troubleshooting

### **Jira Automation not triggering?**

Check:
1. **Automation enabled**: Project settings → Automation → Check if rule is ON
2. **Audit log**: Automation → Audit log → See execution history
3. **Conditions**: Make sure assignee matches exactly
4. **Permissions**: Automation actor has permission to trigger webhooks

### **GitHub Actions not starting?**

Check:
1. **PAT valid**: Token not expired?
2. **PAT permissions**: Has `repo` scope?
3. **Webhook URL**: Correct username/repo name?
4. **Workflow file**: `.github/workflows/ai-teammate.yml` exists?

### **AI Teammate failing?**

Check:
1. **Secrets configured**: JIRA_BASE_PATH, JIRA_EMAIL, JIRA_API_TOKEN
2. **Token valid**: Jira API token not expired?
3. **Logs**: GitHub Actions → Workflow run → View logs

---

## 📊 Monitoring

### **Check Jira Automation logs:**
```
Project settings → Automation → Audit log
```

### **Check GitHub Actions runs:**
```
https://github.com/YOUR_USERNAME/orbithub/actions
```

### **Check Jira comments:**
AI Teammate posts status comments to tickets

---

## 🚀 What's Next?

Currently implemented:
- ✅ Answer checking
- ✅ Status reporting  
- ✅ GitHub Actions integration
- ✅ Jira Automation trigger

**TODO** (not yet implemented):
- ❌ AI integration (OpenAI/Claude)
- ❌ Automatic question generation
- ❌ Code implementation
- ❌ PR creation

---

## 💡 Tips

### **Use labels for filtering**
Add label `ai-teammate` to tickets that should be processed

### **Multiple AI agents**
You can create different automation rules for different types of tickets

### **Notification channels**
Add Slack/Email notifications to automation rules

### **Rate limiting**
Be careful with frequent triggers - GitHub Actions has usage limits

---

## 📝 Example Automation Rule (Text format)

```yaml
Name: AI Teammate on Assignment

Trigger:
  - Issue transitioned to "To Do"
  - Assignee changed to "Igor AI Agent"

Conditions:
  - Assignee equals "Igor AI Agent"
  - Status equals "To Do"

Actions:
  1. Send web request to GitHub API
  2. Add comment: "🤖 AI Teammate triggered"

Scope: Project AIH
```

---

## ✅ Checklist

Before going live:

- [ ] GitHub secrets configured
- [ ] GitHub PAT created and tested
- [ ] Jira Automation rule created
- [ ] Jira Automation rule enabled
- [ ] Test workflow executed successfully
- [ ] AI Agent user exists in Jira
- [ ] Project has subtasks enabled
- [ ] `.env` file configured locally for testing

---

**Need help?** Check the logs:
- Jira: Project settings → Automation → Audit log  
- GitHub: Actions tab → AI Teammate workflow → Logs
- Local: Run `dart run bin/ai_teammate.dart TICKET-KEY` with verbose logging


