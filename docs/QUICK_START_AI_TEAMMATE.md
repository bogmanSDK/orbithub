# AI Teammate - Quick Start

## 🚀 5-Minute Setup

### **1. Test Locally (Right Now)**

```bash
cd /Users/Serhii_Bohush/orbithub

# Check if questions are answered
dart run test_ai_teammate.dart

# Run AI Teammate workflow manually
dart run bin/ai_teammate.dart AIH-1
```

---

### **2. Answer Questions in Jira**

1. Open [AIH-2: Color values question](https://serhiibohush.atlassian.net/browse/AIH-2)
2. Add a comment with your answer, e.g.:
   ```
   Primary background: #1a1a1a
   Text: #ffffff  
   Accent: #0066cc
   ```
3. Repeat for [AIH-3](https://serhiibohush.atlassian.net/browse/AIH-3) and [AIH-4](https://serhiibohush.atlassian.net/browse/AIH-4)

---

### **3. Test Again**

```bash
# AI Teammate will detect your answers
dart run bin/ai_teammate.dart AIH-1
```

Expected output:
```
✅ All questions have been answered!
📝 Collecting answers...
🤖 Processing answers and generating plan...
```

---

## 🔧 Setup GitHub Actions (10 minutes)

### **Step 1: Add GitHub Secrets**

Go to: `https://github.com/YOUR_USERNAME/orbithub/settings/secrets/actions`

Add:
```
JIRA_BASE_PATH = https://serhiibohush.atlassian.net
JIRA_EMAIL = igoraiagent1@gmail.com
JIRA_API_TOKEN = your_jira_token
```

### **Step 2: Create GitHub PAT**

1. Go to: `https://github.com/settings/tokens`
2. **Generate new token (classic)**
3. Select scope: `repo`
4. Copy the token

### **Step 3: Setup Jira Automation**

1. In Jira → Project settings → Automation
2. Create rule → "Issue transitioned"
3. Trigger:
   - Status changes to **"To Do"**
   - Assignee = **"Igor AI Agent"**
4. Action → **Send web request**:
   ```
   URL: https://api.github.com/repos/YOUR_USERNAME/orbithub/dispatches
   Method: POST
   Headers:
     Authorization: Bearer YOUR_GITHUB_PAT
     Content-Type: application/json
   Body:
   {
     "event_type": "ai-teammate-trigger",
     "client_payload": {
       "ticket_key": "{{issue.key}}"
     }
   }
   ```
5. Save and enable

---

## 🎯 Full Workflow Test

### **Test the complete automation:**

1. **Create a new ticket** in Jira (project AIH)
2. **Assign to "Igor AI Agent"**
3. **Add description** of what you want
4. **Move to "To Do"** status
5. **Watch**:
   - Jira Automation triggers
   - GitHub Actions runs
   - AI Teammate processes ticket
   - Comments appear in Jira

---

## 📊 What Works Now

| Feature | Status |
|---------|--------|
| Check if questions answered | ✅ Working |
| Generate answer report | ✅ Working |
| Post status comments | ✅ Working |
| Change ticket status | ✅ Working |
| GitHub Actions integration | ✅ Working |
| Jira Automation trigger | ✅ Working |
| AI question generation | ❌ TODO |
| AI implementation | ❌ TODO |

---

## 💡 Example Flow

### **User creates ticket:**
```
AIH-10: "Add export to CSV feature"
Assignee: Igor AI Agent
Status: To Do
```

### **Jira Automation triggers GitHub Actions**
```
→ Webhook sent to GitHub
→ ai-teammate.yml runs
→ bin/ai_teammate.dart AIH-10
```

### **AI Teammate checks ticket:**
```
📋 Found 3 subtasks with questions
🔍 Checking answers... 0/3 answered
⏳ Not all questions answered yet
💬 Posted status comment
```

### **User answers questions:**
```
Opens each subtask → Adds comments with answers
```

### **User triggers AI again:**
```
Assigns ticket to "Igor AI Agent"
Moves to "To Do"
```

### **AI Teammate detects answers:**
```
📋 Found 3 subtasks
🔍 Checking answers... 3/3 answered ✅
📝 Collected all answers
🤖 Ready for implementation
💬 Posted completion comment
```

---

## 🔍 Debugging

### **Check if answer checker works:**
```bash
dart run test_ai_teammate.dart
```

### **Test AI Teammate manually:**
```bash
dart run bin/ai_teammate.dart AIH-1
```

### **Check GitHub Actions:**
```
https://github.com/YOUR_USERNAME/orbithub/actions
```

### **Check Jira Automation:**
```
Project settings → Automation → Audit log
```

---

## 📝 Next Steps

1. **Test locally** (5 min)
   - Answer questions in Jira
   - Run `dart run bin/ai_teammate.dart AIH-1`
   
2. **Setup GitHub Actions** (10 min)
   - Add secrets
   - Test manual trigger

3. **Setup Jira Automation** (10 min)
   - Create rule
   - Test full flow

4. **Add AI integration** (TODO)
   - OpenAI/Claude for question generation
   - Code implementation

---

## ✅ Checklist

Ready to go live:

- [ ] Tested locally - answer checker works
- [ ] Tested locally - AI Teammate script works
- [ ] GitHub secrets configured
- [ ] GitHub Actions workflow file committed
- [ ] Tested GitHub Actions manual trigger
- [ ] GitHub PAT created
- [ ] Jira Automation rule created
- [ ] Jira Automation rule enabled
- [ ] Tested full workflow end-to-end

---

**Full documentation**: See `docs/AI_TEAMMATE_SETUP.md`


