# AI Prompt Templates

This directory contains centralized prompt templates for OrbitHub's AI providers.

## 📋 Overview

All hardcoded prompt templates are stored in `prompt_templates.dart` for easy maintenance and organization. These templates serve as **fallback** when Confluence templates are not configured.

## 📂 Structure

```
lib/core/templates/
├── README.md              # This file
└── prompt_templates.dart  # All hardcoded templates
```

## 🎯 Available Templates

### 1. Questions Template (Template Q)
- **Role**: Business Analyst
- **Purpose**: Format for structured clarifying questions
- **Format**: Background → Question → Options → Decision
- **dmtools equivalent**: Template Q
- **Used by**: `OpenAIProvider`, `ClaudeProvider`
- **Location**: `PromptTemplates.questionsTemplate`

### 2. Acceptance Criteria Template (Template AC)
- **Role**: Business Analyst
- **Purpose**: Gherkin-style acceptance criteria
- **Format**: Given-When-Then with Jira Markdown
- **dmtools equivalent**: Template AC
- **Used by**: `OpenAIProvider`, `ClaudeProvider`
- **Location**: `PromptTemplates.acceptanceCriteriaTemplate`

### 3. Solution Design Template (Template SD)
- **Role**: Software Architect
- **Purpose**: High-level technical design
- **Format**: Purpose → Requirements → Components → Diagram
- **dmtools equivalent**: Template SD CORE/API
- **Used by**: Future implementation
- **Location**: `PromptTemplates.solutionDesignTemplate`

### 4. Implementation Plan Template
- **Role**: Software Engineer
- **Purpose**: Detailed development plan
- **Format**: Summary → Approach → Files → Testing → Risks
- **dmtools equivalent**: N/A (OrbitHub specific)
- **Used by**: Future implementation
- **Location**: `PromptTemplates.implementationPlanTemplate`

## 🔄 Template Loading Flow

```
AI Provider needs template
  ↓
Checks: Confluence configured?
  ├─ YES → Load from Confluence (external)
  │   ├─ Success → Use Confluence template
  │   └─ Failure → Fall back to hardcoded ↓
  └─ NO → Use hardcoded template
              ↓
      PromptTemplates.getTemplate(type)
              ↓
      Returns template from this file
```

## 📝 Usage in Code

### Getting a Template

```dart
import 'package:orbithub/core/templates/prompt_templates.dart';

// Get questions template
final template = PromptTemplates.getTemplate(TemplateType.questions);

// Or directly
final template = PromptTemplates.questionsTemplate;
```

### Template Metadata

```dart
// Get all templates with metadata
for (final meta in TemplateMetadata.all) {
  print('${meta.name}: ${meta.description}');
  print('Role: ${meta.role}');
  print('dmtools: ${meta.dmtoolsEquivalent}');
}
```

## 🎨 Template Format Guidelines

### Questions Template Format
```
---QUESTION---
Background: [Context explaining why this matters]
Question: [Clear, specific question]
Options:
• Option A: [Specific option with examples]
• Option B: [Specific option with examples]
• Option C: [Specific option with examples]
• Option D: Other (please specify)
Decision:
---END---
```

### Acceptance Criteria Format
```
h3. Acceptance Criteria

h4. Scenario 1: [Scenario Name]
{code:gherkin}
Given [initial state]
When [action]
Then [expected result]
And [additional expectations]
{code}
```

## ✏️ Updating Templates

### Option 1: Update Hardcoded (this file)
```dart
// Edit prompt_templates.dart
static const String questionsTemplate = '''
[Your updated template]
''';
```

**Requires:**
- Code change + commit
- Redeploy/rebuild

### Option 2: Use Confluence (external)
```bash
# Add to .env
TEMPLATE_QUESTIONS_URL=https://your-domain.atlassian.net/wiki/spaces/SPACE/pages/12345/Template+Q
```

**Requires:**
- Create Confluence page
- No code changes
- Updates instantly

## 🆚 Confluence vs Hardcoded

| Aspect | Hardcoded (this file) | Confluence |
|--------|----------------------|------------|
| **Update speed** | Slow (code change) | Fast (edit wiki) |
| **Deployment** | Required | Not required |
| **Offline** | ✅ Works | ❌ Needs network |
| **Version control** | ✅ Git | ✅ Confluence history |
| **Team editing** | ⚠️ Requires dev access | ✅ Anyone with wiki access |
| **Consistency** | ✅ Always available | ⚠️ Depends on connectivity |

## 🎯 Best Practices

### When to Use Hardcoded (this file)
- ✅ Stable, well-tested templates
- ✅ Templates rarely change
- ✅ Want offline capability
- ✅ Small team, dev-controlled

### When to Use Confluence
- ✅ Templates evolve frequently
- ✅ BA/QA team manages templates
- ✅ Need quick iterations
- ✅ Multiple projects with different formats

## 📖 Related Documentation

- **Confluence Integration**: `/docs/CONFLUENCE_INTEGRATION.md`
- **Structured Questions**: `/docs/STRUCTURED_QUESTIONS.md`
- **Acceptance Criteria**: `/docs/ACCEPTANCE_CRITERIA_GENERATION.md`
- **dmtools Templates**: See agent configs in dmtools `agents/` directory

## 🔍 Template Sources

All templates inspired by dmtools patterns:
- **Template Q**: dmtools Business Analyst questions format
- **Template AC**: dmtools Gherkin acceptance criteria
- **Template SD**: dmtools Architect solution design
- **Jira Markdown**: dmtools formatting guidelines

## 🚀 Future Enhancements

- [ ] Template validation on load
- [ ] Custom template sets per project
- [ ] Template versioning
- [ ] A/B testing different formats
- [ ] Template analytics (which work best)

