# AI Integration Guide

OrbitHub supports AI-powered ticket analysis and question generation using OpenAI or Claude.

---

## 🚀 Quick Setup

### **Step 1: Get API Key**

**OpenAI:**
1. Go to: https://platform.openai.com/api-keys
2. Create new secret key
3. Copy the key (starts with `sk-...`)

**Claude:**
1. Go to: https://console.anthropic.com/settings/keys
2. Create key
3. Copy the key (starts with `sk-ant-...`)

### **Step 2: Configure**

Edit `orbithub.env`:

```bash
# Choose provider: openai or claude
AI_PROVIDER=openai

# Paste your API key
AI_API_KEY=sk-...your_key_here

# Optional: specify model
#AI_MODEL=gpt-4
```

### **Step 3: Test**

```bash
# Create a test ticket in Jira
# Assign to AI Agent + move to "To Do"
# Watch GitHub Actions run!
```

---

## 🤖 Supported AI Providers

### **OpenAI**

| Model | Speed | Cost | Best For |
|-------|-------|------|----------|
| `gpt-4` | Medium | $0.03/1K | Complex analysis |
| `gpt-4-turbo` | Fast | $0.01/1K | General use ✅ |
| `gpt-3.5-turbo` | Fastest | $0.001/1K | Simple tickets |

**Default:** `gpt-4`

### **Claude**

| Model | Speed | Cost | Best For |
|-------|-------|------|----------|
| `claude-3-5-sonnet-20241022` | Fast | $0.003/1K | Best overall ✅ |
| `claude-3-opus-20240229` | Medium | $0.015/1K | Complex reasoning |

**Default:** `claude-3-5-sonnet-20241022`

---

## ⚙️ Configuration Options

```bash
# Required
AI_PROVIDER=openai          # or claude
AI_API_KEY=sk-...           # Your API key

# Optional
AI_MODEL=gpt-4              # Override default model
AI_TEMPERATURE=0.7          # 0.0 (focused) to 1.0 (creative)
AI_MAX_TOKENS=2000          # Max response length
```

---

## 📋 How It Works

### **Workflow:**

```
1. You create ticket → Assign to AI Agent → "To Do"
2. Jira Automation → triggers GitHub Actions
3. AI Teammate analyzes ticket with AI

   OPTION A: Requirements are CLEAR
     ✅ AI posts: "Everything is clear!"
     ✅ AI moves to "In Progress"
     ✅ Ready for implementation
   
   OPTION B: Requirements are UNCLEAR
     ⚠️ AI generates 1-5 clarifying questions
     ⚠️ AI creates subtasks for each question
     ⚠️ AI reassigns ticket to you + "In Review"
     ⏳ You answer questions in subtasks
     🔄 You assign back to AI Agent → "To Do"
     ✅ AI processes answers → "In Progress"
```

### **Example 1: Simple ticket (CLEAR)**

**Your ticket:**
```
Title: Fix typo in login button
Description: Change "Submitt" to "Submit" in the login form
```

**AI analyzes:**
```
✅ Everything is clear
✅ No questions needed
🚀 Moving to In Progress
```

**AI posts:**
```
🎉 Requirements are clear and well-defined!
Moving to In Progress and beginning work immediately.
```

### **Example 2: Complex ticket (QUESTIONS)**

**Your ticket:**
```
Title: Add dark mode
Description: Users want dark theme option
```

**AI analyzes:**
```
⚠️ Missing critical information
```

**AI generates:**
```
❓ What color values for dark theme (#1a1a1a or custom)?
❓ Should it be default or opt-in with toggle?
❓ Any accessibility requirements (WCAG compliance)?
```

**AI creates subtasks:**
```
AIH-6: ❓ What color values...
AIH-7: ❓ Should it be default...
AIH-8: ❓ Any accessibility...
```

**You answer:**
```
AIH-6: Use #1a1a1a, text #ffffff
AIH-7: Opt-in with toggle in settings
AIH-8: Follow WCAG 2.1 AA, 4.5:1 contrast
```

**AI processes:**
```
✅ All questions answered
🤖 Generating implementation plan...
📝 Creating tasks...
```

---

## 💰 Cost Estimation

### **Per Ticket:**

| Provider | Model | Avg Cost | Monthly (100 tickets) |
|----------|-------|----------|----------------------|
| OpenAI | gpt-4-turbo | $0.01 | $1.00 |
| OpenAI | gpt-4 | $0.03 | $3.00 |
| Claude | Sonnet 3.5 | $0.008 | $0.80 ✅ |
| Claude | Opus 3 | $0.015 | $1.50 |

**Cheapest:** Claude Sonnet 3.5  
**Best Value:** Claude Sonnet 3.5 or OpenAI gpt-4-turbo

---

## 🔒 Security

### **API Key Safety:**

✅ **DO:**
- Store in `orbithub.env` (in `.gitignore`)
- Use GitHub Secrets for CI/CD
- Rotate keys every 90 days
- Use separate keys per environment

❌ **DON'T:**
- Commit API keys to git
- Share keys in chat/email
- Use same key everywhere
- Leave keys in code comments

### **GitHub Secrets:**

```bash
# Add to GitHub repo secrets:
AI_PROVIDER = openai
AI_API_KEY = sk-...your_key
```

---

## 🧪 Testing Locally

```bash
# Add API key to orbithub.env
AI_PROVIDER=openai
AI_API_KEY=sk-...

# Test AI integration
dart run bin/ai_teammate.dart AIH-1
```

Expected output:
```
🤖 OrbitHub AI Teammate
📋 Processing ticket: AIH-1
🔍 Generating questions with AI...
   ✅ AI Provider: openai
   ✅ Model: gpt-4
   ✅ Generated 3 question(s)
📝 Creating subtasks...
   ✅ Created: AIH-10
   ✅ Created: AIH-11
   ✅ Created: AIH-12
✨ QUESTIONS CREATED SUCCESSFULLY
```

---

## 🐛 Troubleshooting

### **Error: "AI_API_KEY not found"**

```bash
# Check orbithub.env exists
ls -la orbithub.env

# Check key is set
grep AI_API_KEY orbithub.env
```

### **Error: "OpenAI API error: 401"**

```bash
# Key is invalid - generate new one
# OpenAI: https://platform.openai.com/api-keys
```

### **Error: "Claude API error: 403"**

```bash
# Check Claude key is correct
# Format: sk-ant-api...
```

### **AI generates poor questions:**

```bash
# Try adjusting temperature
AI_TEMPERATURE=0.3  # More focused

# Or try different model
AI_MODEL=gpt-4      # More capable
```

---

## 📊 Programmatic Usage

```dart
import 'package:orbithub/orbithub.dart';

void main() async {
  // Initialize AI
  final aiConfig = AIConfig(
    provider: AIProviderType.openai,
    apiKey: 'sk-...',
    model: 'gpt-4',
  );
  
  final ai = AIFactory.create(aiConfig);
  
  // Generate questions
  final questions = await ai.generateQuestions(
    ticketTitle: 'Add dark mode',
    ticketDescription: 'Users want dark theme',
    maxQuestions: 3,
  );
  
  print('Questions: $questions');
}
```

---

## 🎯 Best Practices

1. **Start with Claude Sonnet 3.5** - best value
2. **Keep temperature at 0.7** - balanced creativity
3. **Limit to 3-5 questions** - don't overwhelm
4. **Provide context** - better questions
5. **Monitor costs** - set API usage alerts

---

## 🔗 Resources

- **OpenAI Docs**: https://platform.openai.com/docs
- **Claude Docs**: https://docs.anthropic.com/claude/docs
- **Pricing**:
  - OpenAI: https://openai.com/pricing
  - Claude: https://www.anthropic.com/pricing

---

**Need help?** Check `docs/HOW_IT_WORKS.md` for full workflow documentation.

