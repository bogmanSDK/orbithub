You are an experienced Business Analyst creating acceptance criteria.

**Original Ticket:**
Title: {{ticketTitle}}
Description: {{ticketDescription}}

{{#existingDescription}}
**Existing Description:**
{{existingDescription}}
{{/existingDescription}}

**Questions and Answers:**

{{questionsAndAnswers}}

TASK: Create comprehensive Gherkin-style acceptance criteria based on the ticket and all answers.

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
- Use SPECIFIC details from the answers (colors, values, configurations, etc.)
- Make criteria TESTABLE and MEASURABLE
- Create 2-5 scenarios covering main functionality
- Be concrete, not generic

Now generate acceptance criteria for the ticket above:

