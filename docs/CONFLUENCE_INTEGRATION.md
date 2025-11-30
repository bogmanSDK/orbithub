# Confluence Integration for OrbitHub

OrbitHub supports loading AI prompt templates from Confluence Wiki pages, similar to dmtools. This allows you to maintain and update templates without modifying code.

## 🎯 Overview

Instead of hardcoded templates in the code, you can store them in Confluence:
- **Template Q** - Questions format
- **Template AC** - Acceptance Criteria format
- **Template SD** - Solution Design format (future)

## 📋 Setup

### Step 1: Create Confluence Pages

Create pages in your Confluence space with your templates:

**Example: Template Q (Questions)**
```
FORMAT REQUIREMENTS:
Each question MUST follow this EXACT structure:

---QUESTION---
Background: [Brief context explaining why this question is important]

Question: [Clear, specific question]

Options:
• Option A: [First possible approach/answer]
• Option B: [Second possible approach/answer]
• Option C: [Third possible approach/answer]
• Option D: Other (please specify)

Decision:
---END---

EXAMPLE:
---QUESTION---
Background: GitHub Pages can be deployed from root, /docs folder, or gh-pages branch.

Question: What deployment configuration should be used for GitHub Pages?

Options:
• Option A: Deploy from gh-pages branch
• Option B: Deploy from /docs folder
• Option C: Deploy from root
• Option D: Other

Decision:
---END---
```

### Step 2: Get Page IDs or URLs

Get the page ID from the URL:
```
https://your-domain.atlassian.net/wiki/spaces/SPACE/pages/12345678/Template+Q
                                                                   ^^^^^^^^
                                                                   Page ID
```

### Step 3: Configure Environment

Add to your `.env` file:

```bash
# Confluence Configuration (optional)
CONFLUENCE_BASE_URL=https://your-domain.atlassian.net/wiki
CONFLUENCE_EMAIL=your.email@example.com
CONFLUENCE_API_TOKEN=your_confluence_api_token

# Template URLs (full URL or just page ID)
TEMPLATE_QUESTIONS_URL=https://your-domain.atlassian.net/wiki/spaces/SPACE/pages/12345678/Template+Q
TEMPLATE_AC_URL=https://your-domain.atlassian.net/wiki/spaces/SPACE/pages/23456789/Template+AC
```

**Note:** If you use the same email and API token for both Jira and Confluence (common setup), you can omit `CONFLUENCE_EMAIL` and `CONFLUENCE_API_TOKEN` - they will fall back to `JIRA_EMAIL` and `JIRA_API_TOKEN`.

### Step 4: Get Confluence API Token

1. Go to: https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Give it a name: "OrbitHub Confluence"
4. Copy the token
5. Add to `.env`: `CONFLUENCE_API_TOKEN=your_token`

## 🔄 How It Works

When OrbitHub generates questions or AC:

1. **Checks configuration**: Is `TEMPLATE_QUESTIONS_URL` set?
2. **If YES**: Loads template from Confluence
   - Fetches page content via Confluence REST API
   - Strips HTML tags to get plain text
   - Uses as prompt template
3. **If NO or fails**: Falls back to hardcoded template
   - No errors, seamless fallback
   - Works offline

## 💡 Benefits

### ✅ **Centralized Templates**
- Update templates in Confluence → instantly used by all
- No code changes needed
- No deployment required

### ✅ **Team Collaboration**
- BA/QA can edit templates directly
- Version history in Confluence
- Comments and discussions on pages

### ✅ **Consistency**
- Same templates across all tickets
- Easy to enforce standards
- Documentation and examples in one place

### ✅ **Flexibility**
- Different templates for different projects
- A/B testing of formats
- Quick iterations

## 🚨 Fallback Behavior

If Confluence is not configured or unavailable:
- ✅ OrbitHub continues to work
- ✅ Uses hardcoded templates (same as before)
- ✅ Prints warning but doesn't fail
- ✅ No impact on functionality

Example output:
```
📚 Loading questions template from Confluence...
⚠️  Failed to load Confluence template: 404 Not Found
💡 Falling back to hardcoded template
```

## 📝 Example .env Configuration

### Minimal (Uses Jira credentials)
```bash
# Jira (required)
JIRA_BASE_URL=https://your-domain.atlassian.net
JIRA_EMAIL=your.email@example.com
JIRA_API_TOKEN=your_jira_token

# AI Provider (required)
AI_PROVIDER=openai
AI_API_KEY=sk-your_openai_key

# Confluence Templates (optional)
TEMPLATE_QUESTIONS_URL=https://your-domain.atlassian.net/wiki/spaces/AINA/pages/11665581/Template+Q
TEMPLATE_AC_URL=https://your-domain.atlassian.net/wiki/spaces/AINA/pages/12345678/Template+AC
```

### Full (Separate Confluence credentials)
```bash
# Jira
JIRA_BASE_URL=https://your-domain.atlassian.net
JIRA_EMAIL=your.email@example.com
JIRA_API_TOKEN=your_jira_token

# Confluence
CONFLUENCE_BASE_URL=https://your-domain.atlassian.net/wiki
CONFLUENCE_EMAIL=confluence@example.com
CONFLUENCE_API_TOKEN=different_confluence_token

# Templates
TEMPLATE_QUESTIONS_URL=https://your-domain.atlassian.net/wiki/spaces/AINA/pages/11665581/Template+Q
TEMPLATE_AC_URL=https://your-domain.atlassian.net/wiki/spaces/AINA/pages/12345678/Template+AC
```

## 🔧 Testing

Test Confluence connection:

```dart
import 'lib/core/confluence/confluence_config.dart';
import 'lib/core/confluence/confluence_client.dart';

void main() async {
  final config = ConfluenceConfig.fromEnvironment();
  final client = ConfluenceClient(config);
  
  try {
    final content = await client.getContent('12345678');
    print('✅ Connected! Content length: ${content.length}');
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}
```

## 📚 Template Examples

### Template Q (Questions)
See: `docs/STRUCTURED_QUESTIONS.md`

### Template AC (Acceptance Criteria)
See: `docs/ACCEPTANCE_CRITERIA_GENERATION.md`

## 🆚 Comparison: dmtools vs OrbitHub

| **Aspect** | **dmtools** | **OrbitHub** |
|------------|-------------|--------------|
| **Confluence Required** | ✅ Yes (hardcoded URLs) | ❌ No (optional) |
| **Fallback** | ❌ No (fails if Confluence down) | ✅ Yes (hardcoded templates) |
| **Configuration** | Java code | .env file |
| **Template Format** | Confluence HTML/Storage | Plain text (stripped) |
| **Integration** | Deep (reads Figma, images, etc.) | Basic (text templates only) |

## 🔜 Future Enhancements

- [ ] Cache templates to reduce API calls
- [ ] Support for multiple template sets (per project)
- [ ] Template validation on load
- [ ] Automatic template discovery
- [ ] Rich media support (images, diagrams)

## ❓ FAQ

**Q: Do I need Confluence?**  
A: No, it's optional. OrbitHub works without it using hardcoded templates.

**Q: Will my code break if Confluence is down?**  
A: No, it falls back to hardcoded templates automatically.

**Q: Can I use just page IDs instead of full URLs?**  
A: Yes, both work. The client extracts the page ID from URLs automatically.

**Q: Can I have different templates per project?**  
A: Not yet, but you can change the URLs in `.env` per project.

**Q: Does this work with Confluence Cloud and Server?**  
A: Yes, both are supported via REST API.

## 📖 See Also

- [Structured Questions](STRUCTURED_QUESTIONS.md)
- [Acceptance Criteria Generation](ACCEPTANCE_CRITERIA_GENERATION.md)
- [Jira Integration](../README.md#jira-integration)

