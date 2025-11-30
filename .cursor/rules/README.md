# Cursor Rules for OrbitHub

This directory contains Cursor AI rules that define coding standards, patterns, and best practices for the OrbitHub project.

## Rules Files

### Core Rules (Always Apply)

- **`dart-coding-style.mdc`** - Dart coding standards, naming conventions, and project structure
  - Dart 3.x+ patterns
  - Package organization
  - Error handling
  - Documentation standards

### Specialized Rules (Apply to Specific Files)

- **`testing.mdc`** - Comprehensive testing guidelines
  - AAA pattern (Arrange-Act-Assert)
  - Mocking with mockito
  - Test coverage requirements (80%+)
  - Anti-patterns to avoid

- **`ai-teammate-workflow.mdc`** - AI Teammate workflow patterns
  - AI Provider interface
  - Question generation
  - Answer checking
  - Acceptance Criteria generation

- **`jira-integration.mdc`** - Jira API integration patterns
  - JiraClient structure
  - CRUD operations
  - Exception handling
  - Subtask and comment management

- **`configuration-management.mdc`** - Configuration loading rules
  - Priority: .env > env vars > defaults
  - Config validation
  - Error messages

- **`structured-questions.mdc`** - Structured questions format
  - Question format specification
  - Parsing and validation
  - Answer detection

## How Cursor Uses These Rules

Cursor AI automatically applies these rules when:
- Files match the `globs` pattern specified in each rule
- Rules with `alwaysApply: true` are always active
- You ask Cursor to generate or modify code

## Rules Philosophy

These rules follow the same philosophy as dmtools:
- **"ALL business logic MUST be covered by tests"** - Non-negotiable
- **"NO production code without tests"** - Mandatory
- **OOP driven, no code duplication** - Core principle
- **Clear error messages with troubleshooting tips** - User-friendly

## Adapting from dmtools

OrbitHub rules are adapted from dmtools (Java/Spring Boot) patterns:

| dmtools | OrbitHub | Purpose |
|---------|----------|---------|
| `java-coding-style.mdc` | `dart-coding-style.mdc` | Language standards |
| `unit-testing.mdc` | `testing.mdc` | Testing patterns |
| `agents-jobs.mdc` | `ai-teammate-workflow.mdc` | AI workflows |
| `networking-tools.mdc` | `jira-integration.mdc` | API integration |
| N/A | `structured-questions.mdc` | OrbitHub-specific |
| N/A | `configuration-management.mdc` | OrbitHub-specific |

## Updating Rules

When updating rules:
1. Keep the metadata section (---...---) intact
2. Follow the existing structure: Overview → Patterns → Best Practices → Anti-Patterns
3. Include code examples with ✅ GOOD and ❌ BAD patterns
4. Use emojis for visual hierarchy
5. Test that Cursor recognizes the updates

## See Also

- `/orbithub_llm_rules.md` - CLI usage guide for LLMs
- `/docs/` - Project documentation

