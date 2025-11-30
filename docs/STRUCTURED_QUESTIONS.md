# Structured Questions Format

## Overview

OrbitHub now generates questions in a structured format similar to dmtools, making it easier for users to understand the context and provide clear answers.

## Question Format

Each question follows this structure:

```
Background: [Brief context explaining why this question is important]

Question: [Clear, specific question]

Options:
• Option A: [First possible approach/answer]
• Option B: [Second possible approach/answer]
• Option C: [Third possible approach/answer]
• Option D: [Fourth possible approach/answer or "Other (please specify)"]

Decision:
```

## Example

```
Background: GitHub Pages can be deployed from root, /docs folder, or gh-pages branch. The current workflow structure uses GitHub Actions with proper permissions already configured.

Question: What deployment configuration should be used for GitHub Pages?

Options:
• Option A: Deploy from gh-pages branch (clean separation, standard approach)
• Option B: Deploy from /docs folder on main branch (simpler, no separate branch)
• Option C: Deploy from root on main branch (not recommended for this project structure)
• Option D: Other deployment approach

Decision:
```

## How to Answer

### In Jira UI (Recommended - like dmtools)

1. Navigate to the subtask (e.g., AIH-33)
2. Click **Edit** (pencil icon)
3. In the **Description** field, find the "Decision:" line
4. Add your answer **after** "Decision:" on the same or next line:

**Before:**
```
Decision:
```

**After:**
```
Decision: Option A - Deploy from gh-pages branch for clean separation
```

or

```
Decision: Option B - /docs folder is simpler for our workflow
```

5. Click **Update**
6. The subtask status will automatically change to **Done** (optional)

### Custom Answer

If you have a different approach (not listed in options):

```
Decision: Option D - We'll use Netlify instead of GitHub Pages because it has better build caching and preview deployments
```

### Important Notes

- ⚠️ **Do NOT answer in comments** - OrbitHub checks only the Description field
- ✅ **Edit the Description directly** - Add your answer after "Decision:"
- ✅ **Be specific** - Include details like colors, values, configurations
- ✅ **Reference options** - Mention which option you chose (A, B, C, or D)

## Technical Details

### For Developers

The AI generates questions using markers:
- Start: `---QUESTION---`
- End: `---END---`

The parser extracts:
1. **Full structured text** → subtask description
2. **Question line** → subtask summary

### Fallback Mode

If AI doesn't generate structured format, the system automatically falls back to legacy parsing (simple question list with ❓ emoji).

## Benefits

1. **Context**: Background section explains why the question matters
2. **Clarity**: Multiple options help guide thinking
3. **Consistency**: Same format across all questions
4. **Compatibility**: Matches dmtools BA Agent format

## Configuration

No configuration needed! The feature works automatically with both OpenAI and Claude providers.

## See Also

- [AI Teammate Setup](AI_TEAMMATE_SETUP.md)
- [How It Works](HOW_IT_WORKS.md)
- [Quick Start Guide](QUICK_START_AI_TEAMMATE.md)

