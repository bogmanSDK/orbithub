# Ticket: AIH-46

## Summary
Change tabs position

## Description
Move tab “Advance“ after the tab “Intergation“ un Orbithub configuration app
---
## Acceptance Criteria
### Scenario 1: Successful tab rearrangement
Given the user is logged in to the Orbithub configuration app
When the user navigates to the tab section
Then the tab "Advance" should be situated to the right of the tab "Intergation"
And no other tabs should be positioned between the "Intergation" and "Advance" tabs
### Scenario 2: Tab functionality remains after rearrangement
Given the "Advance" tab has been moved after the "Intergation" tab
When the user clicks on the "Advance" tab
Then the user should be able to access all functionalities of the "Advance" tab as before the rearrangement
And the same applies to the "Intergation" tab
### Scenario 3: Tab rearrangement persists across sessions
Given the user has rearranged the tabs with the "Advance" tab being positioned after the "Intergation" tab
When the user logs out and logs back in
Then the order of tabs remains the same, with the "Advance" tab after the "Intergation" tab
###

## Acceptance Criteria
### Scenario 1: Successful tab rearrangement
Given the user is logged in to the Orbithub configuration app
When the user navigates to the tab section
Then the tab "Advance" should be situated to the right of the tab "Intergation"
And no other tabs should be positioned between the "Intergation" and "Advance" tabs

## Implementation Instructions

- Implement code changes following existing patterns
- Create unit tests with good coverage
- Write development summary to outputs/response.md
- DO NOT create branches or push - handled by workflow

