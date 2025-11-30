# Acceptance Criteria Generation

## Overview

OrbitHub now automatically generates Gherkin-style Acceptance Criteria (AC) when all clarifying questions have been answered, similar to dmtools BA workflow.

---

## 🎯 When AC is Generated

AC generation happens **after all questions are answered**:

```
Story created
    ↓
[AI] Generates questions → Creates subtasks
    ↓
👤 User answers all questions
    ↓
👤 User assigns ticket back to AI Agent
    ↓
[AI] Generates Acceptance Criteria ✨
    ↓
AC added to ticket Description
```

---

## 📋 AC Format

### Gherkin Style (Given-When-Then)

```markdown
## Acceptance Criteria

### Scenario 1: User enables dark theme

**Given** the user is logged in and on the settings page
**When** the user toggles the dark theme switch to ON
**Then** the primary background color changes to #1a1a1a
**And** the text color changes to #ffffff
**And** the accent color changes to #0066cc
**And** the theme preference is saved to user profile
**And** all UI components respect the dark theme setting

### Scenario 2: Theme persists across sessions

**Given** the user has enabled dark theme
**When** the user logs out and logs back in
**Then** the dark theme is still active
**And** all pages display with dark theme colors
```

---

## 🤖 How It Works

### 1. AI Analyzes Context

When all questions are answered, AI receives:

- ✅ Original ticket title
- ✅ Original ticket description  
- ✅ All questions
- ✅ All answers from subtasks

### 2. AI Generates Specific AC

The AI:

- Uses **specific details** from answers (colors, values, configurations)
- Creates **testable and measurable** criteria
- Includes **edge cases** and error scenarios
- Follows **Gherkin Given-When-Then** format
- Creates **2-5 scenarios** covering main functionality
- Makes criteria **concrete, not generic**

### 3. AC is Added to Ticket

The generated AC is:

- ✅ Appended to the ticket Description field
- ✅ Separated with `---` divider
- ✅ Also included in completion comment
- ✅ Formatted in markdown

---

## 💡 Example Workflow

### Original Ticket:

```
AIH-1: Implement dark theme
Description: Add dark theme support to the application
```

### Questions Generated:

```
Q1: What color values for dark theme?
Q2: Should it be default or opt-in?
Q3: Any accessibility requirements?
```

### User Answers:

```
A1: Primary: #1a1a1a, Text: #ffffff, Accent: #0066cc
A2: Make it opt-in with a toggle in settings
A3: Follow WCAG 2.1 AA standards, minimum contrast ratio 4.5:1
```

### Generated AC:

```markdown
## Acceptance Criteria

### Scenario 1: User enables dark theme

**Given** the user is logged in and on the settings page
**When** the user toggles the dark theme switch to ON
**Then** the primary background color changes to #1a1a1a
**And** the text color changes to #ffffff
**And** the accent color changes to #0066cc
**And** the theme preference is saved to user profile
**And** all UI components respect the dark theme setting

### Scenario 2: Theme persists across sessions

**Given** the user has enabled dark theme
**When** the user logs out and logs back in
**Then** the dark theme is still active
**And** all pages display with dark theme colors

### Scenario 3: Accessibility compliance

**Given** dark theme is enabled
**When** any page is displayed
**Then** the contrast ratio is at least 4.5:1
**And** WCAG 2.1 AA standards are met
**And** all text is readable against the background
```

---

## 🔧 Technical Details

### AI Providers

Both OpenAI and Claude are supported:

```dart
// OpenAI (default)
AI_PROVIDER=openai
AI_API_KEY=sk-proj-...

// Claude
AI_PROVIDER=claude  
AI_API_KEY=sk-ant-...
```

### Implementation

#### Interface (`AIProvider`)

```dart
Future<String> generateAcceptanceCriteria({
  required String ticketTitle,
  required String ticketDescription,
  required Map<String, String> questionsAndAnswers,
  String? existingDescription,
});
```

#### Workflow (`ai_teammate.dart`)

1. Collect all answers from subtasks
2. Call `ai.generateAcceptanceCriteria()`
3. Update ticket Description with AC
4. Post completion comment

---

## 📊 Benefits

### vs Manual AC Writing:

| **Aspect** | **Manual** | **AI Generated** |
|-----------|-----------|------------------|
| **Time** | 30-60 min | ~30 seconds |
| **Consistency** | Variable | Always Gherkin format |
| **Detail Level** | Often generic | Specific from answers |
| **Coverage** | May miss cases | Includes edge cases |
| **Based on Q&A** | Sometimes forgotten | Always incorporated |

---

## 🚀 Usage

### Automatic (via GitHub Actions)

1. Create ticket in Jira
2. AI generates questions → subtasks created
3. Answer all questions in subtasks
4. Assign ticket back to AI Agent
5. Move to "To Do" status
6. GitHub Actions runs automatically
7. AC generated and added to ticket ✅

### Manual (local testing)

```bash
cd /Users/Serhii_Bohush/orbithub

# Ensure .env has AI_API_KEY configured
# Answer all questions for ticket AIH-26

dart run bin/ai_teammate.dart AIH-26
```

---

## 🎯 Best Practices

### For Better AC Generation:

1. **Answer questions specifically** - Include exact values, colors, dimensions
2. **Provide examples** - Show concrete examples of expected behavior
3. **Mention edge cases** - Note any special conditions or error scenarios
4. **Reference standards** - Cite any compliance requirements (WCAG, etc.)

### Good Answers:

✅ "Primary background: #1a1a1a, Text: #ffffff, Accent: #0066cc"  
✅ "Opt-in via toggle in Settings > Appearance > Theme"  
✅ "WCAG 2.1 AA compliant, minimum 4.5:1 contrast ratio"

### Poor Answers:

❌ "Dark colors"  
❌ "In settings somewhere"  
❌ "Should be accessible"

---

## 🆚 Comparison with dmtools

| **Feature** | **OrbitHub** | **dmtools** |
|------------|-------------|-------------|
| **AC Generation** | ✅ Yes | ✅ Yes |
| **Based on Q&A** | ✅ Yes | ✅ Yes |
| **Gherkin Format** | ✅ Yes | ✅ Yes |
| **Confluence Template** | ❌ No | ✅ Yes |
| **Code Context** | ❌ No | ✅ Yes (reads codebase) |
| **Figma Integration** | ❌ No | ✅ Yes (reads designs) |
| **Separate SD Tickets** | ❌ No | ✅ Yes (Architecture) |

---

## ❓ FAQ

**Q: Can I edit the generated AC?**  
A: Yes! Edit the Description field in Jira after generation.

**Q: What if I don't like the generated AC?**  
A: Simply delete and write your own, or regenerate by reassigning to AI again.

**Q: Does it work with incomplete answers?**  
A: No, all questions must be answered for AC generation to trigger.

**Q: Can I customize the AC format?**  
A: Currently no, but you can edit after generation. Custom templates coming soon.

**Q: Which AI provider is better?**  
A: Both OpenAI (GPT-4) and Claude work well. Claude tends to be more detailed.

---

## 🔮 Future Enhancements

- [ ] Customizable AC templates
- [ ] Code context integration (like dmtools)
- [ ] Figma design integration
- [ ] Multi-language AC generation
- [ ] AC validation against standards
- [ ] Test case generation from AC

---

## 📚 See Also

- [AI Teammate Setup](AI_TEAMMATE_SETUP.md)
- [Structured Questions](STRUCTURED_QUESTIONS.md)
- [How It Works](HOW_IT_WORKS.md)
- [Quick Start Guide](QUICK_START_AI_TEAMMATE.md)

