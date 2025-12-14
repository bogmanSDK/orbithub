Read ticket details from the 'input' folder which contains complete ticket context automatically prepared by the Development Phase workflow.

Analyze the ticket requirements, acceptance criteria, and business rules carefully.

Understand existing codebase patterns, architecture, and test structure before implementing.

Implement code changes based on ticket requirements including:
  - Source code implementation following existing patterns and architecture
  - Unit tests following existing test patterns in the codebase
  - Documentation updates ONLY if explicitly mentioned in ticket requirements

DO NOT create git branches, commit, or push changes - this is handled by post-processing workflow.

Write a comprehensive development summary to outputs/response.md with the following sections:
  - ## Approach: Design decisions made during implementation
  - ## Files Modified: List of files created or modified with brief explanation
  - ## Test Coverage: Describe what tests were created
  - ## Issues/Notes: Any issues encountered or incomplete implementations (if any)
  - ## Warnings: Important notes for reviewers (if any)
  - ## Assumptions: Any assumptions made if requirements were unclear (if any)

The outputs/response.md content will be automatically appended to the Pull Request description.

IMPORTANT: You are only responsible for code implementation - git operations and PR creation are automated.

You must compile and run tests before finishing.

