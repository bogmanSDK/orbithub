/// Centralized storage for all AI prompt templates
/// 
/// This file contains hardcoded templates used as fallback when
/// Confluence templates are not configured or unavailable.
/// 
/// Templates here follow dmtools patterns and provide consistent
/// formatting guidelines for AI providers.
library prompt_templates;

/// Default prompt templates
class PromptTemplates {
  PromptTemplates._(); // Prevent instantiation

  /// Get template by type
  static String getTemplate(TemplateType type) {
    switch (type) {
      case TemplateType.questions:
        return questionsTemplate;
      case TemplateType.acceptanceCriteria:
        return acceptanceCriteriaTemplate;
      case TemplateType.solutionDesign:
        return solutionDesignTemplate;
      case TemplateType.implementationPlan:
        return implementationPlanTemplate;
    }
  }

  /// Template for structured questions (BA Agent role)
  /// 
  /// Format: Background → Question → Options → Decision
  /// Used by: OpenAI Provider, Claude Provider
  /// 
  /// Similar to dmtools Template Q:
  /// https://dmtools.atlassian.net/wiki/spaces/AINA/pages/11665581/Template+Q
  static const String questionsTemplate = '''
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

EXAMPLE of a well-formatted question:
---QUESTION---
Background: GitHub Pages can be deployed from root, /docs folder, or gh-pages branch. The current workflow structure uses GitHub Actions with proper permissions already configured.

Question: What deployment configuration should be used for GitHub Pages?

Options:
• Option A: Deploy from gh-pages branch (clean separation, standard approach)
• Option B: Deploy from /docs folder on main branch (simpler, no separate branch)
• Option C: Deploy from root on main branch (not recommended for this project structure)
• Option D: Other (please specify)

Decision:
---END---

GUIDELINES:
- Always provide 3-4 concrete options (not vague "yes/no")
- Include specific examples in options when possible
- Leave "Decision:" empty for user to fill
- Separate questions with ---QUESTION--- and ---END--- markers
- Focus on critical missing information only
- Avoid obvious questions that don't add value
''';

  /// Template for Acceptance Criteria generation (BA Agent role)
  /// 
  /// Format: Gherkin Given-When-Then with Jira Markdown
  /// Used by: OpenAI Provider, Claude Provider
  /// 
  /// Similar to dmtools Template AC:
  /// https://dmtools.atlassian.net/wiki/spaces/AINA/pages/12345678/Template+AC
  static const String acceptanceCriteriaTemplate = '''
FORMAT: Use Gherkin format (Given-When-Then) with Jira Markdown

Example Structure:
h3. Acceptance Criteria

h4. Scenario 1: User Login Success
{code:gherkin}
Given the user is on the login page
When the user enters valid credentials
Then the user should be redirected to the dashboard
And a success message should be displayed
{code}

h4. Scenario 2: User Login Failure
{code:gherkin}
Given the user is on the login page
When the user enters invalid credentials
Then an error message should be displayed
And the user should remain on the login page
{code}

GUIDELINES:
- Use h3. for main "Acceptance Criteria" heading
- Use h4. for each scenario name
- Wrap Gherkin in {code:gherkin}...{code} blocks
- Each scenario should be testable and specific
- Include positive and negative test cases
- Cover edge cases mentioned in Q&A
- Use clear, unambiguous language
''';

  /// Template for Solution Design (Architect role)
  /// 
  /// Format: Purpose → Technical Requirements → Components → Diagram
  /// Used by: Future implementation
  /// 
  /// Similar to dmtools Template SD CORE/API:
  /// https://dmtools.atlassian.net/wiki/spaces/AINA/pages/12877825/Template+SD+CORE
  static const String solutionDesignTemplate = '''
FORMAT: High-level technical solution design

Structure:
*Purpose:*
[Why this solution is needed and what problem it solves]

*Technical Requirements:*
- Requirement 1
- Requirement 2
- Requirement 3

*Components to Create/Modify:*
- component_name.dart - [description]
- another_component.dart - [description]

*Story AC Coverage:*
- AC1: [How this AC is covered by the design]
- AC2: [How this AC is covered by the design]

*Dependencies:*
- package_name: ^version (description)

*Testing Strategy:*
- Unit tests: [what to test]
- Integration tests: [what to test]

*Architecture Diagram:*
[Include Mermaid diagram showing component relationships]

GUIDELINES:
- Focus on high-level design, not implementation details
- Map each AC to specific technical components
- Identify external dependencies early
- Consider testing from the start
- Use Mermaid for architecture visualization
''';

  /// Template for Implementation Plan (Developer role)
  /// 
  /// Format: Summary → Approach → Files → Testing → Risks
  /// Used by: Future implementation
  static const String implementationPlanTemplate = '''
FORMAT: Detailed implementation plan

Structure:
## Summary
[Brief overview of what will be implemented]

## Technical Approach
[Detailed explanation of implementation strategy]

## Files to Create/Modify
- `path/to/file.dart` - [What changes and why]
- `path/to/test.dart` - [Test coverage]

## Implementation Steps
1. Step 1 description
2. Step 2 description
3. Step 3 description

## Testing Strategy
- Unit tests: [specific tests]
- Integration tests: [specific tests]
- Manual testing: [scenarios]

## Potential Risks
- Risk 1: [description and mitigation]
- Risk 2: [description and mitigation]

## Estimated Effort
[Time estimate with breakdown]

GUIDELINES:
- Be specific about file changes
- Include step-by-step approach
- Identify risks proactively
- Provide realistic time estimates
''';
}

/// Template types
enum TemplateType {
  /// Structured questions template (Template Q)
  questions,

  /// Acceptance criteria template (Template AC)
  acceptanceCriteria,

  /// Solution design template (Template SD)
  solutionDesign,

  /// Implementation plan template
  implementationPlan,
}

/// Template metadata for documentation
class TemplateMetadata {
  final TemplateType type;
  final String name;
  final String description;
  final String dmtoolsEquivalent;
  final String role;

  const TemplateMetadata({
    required this.type,
    required this.name,
    required this.description,
    required this.dmtoolsEquivalent,
    required this.role,
  });

  /// All available templates with metadata
  static const List<TemplateMetadata> all = [
    TemplateMetadata(
      type: TemplateType.questions,
      name: 'Template Q (Questions)',
      description: 'Structured format for clarifying questions with Background, Question, Options, Decision',
      dmtoolsEquivalent: 'https://dmtools.atlassian.net/wiki/spaces/AINA/pages/11665581/Template+Q',
      role: 'Business Analyst',
    ),
    TemplateMetadata(
      type: TemplateType.acceptanceCriteria,
      name: 'Template AC (Acceptance Criteria)',
      description: 'Gherkin Given-When-Then format with Jira Markdown for testable acceptance criteria',
      dmtoolsEquivalent: 'https://dmtools.atlassian.net/wiki/spaces/AINA/pages/12345678/Template+AC',
      role: 'Business Analyst',
    ),
    TemplateMetadata(
      type: TemplateType.solutionDesign,
      name: 'Template SD (Solution Design)',
      description: 'High-level technical design with components, dependencies, and architecture diagram',
      dmtoolsEquivalent: 'https://dmtools.atlassian.net/wiki/spaces/AINA/pages/12877825/Template+SD+CORE',
      role: 'Software Architect',
    ),
    TemplateMetadata(
      type: TemplateType.implementationPlan,
      name: 'Implementation Plan',
      description: 'Detailed development plan with approach, files, testing, and risks',
      dmtoolsEquivalent: 'N/A (OrbitHub specific)',
      role: 'Software Engineer',
    ),
  ];
}

