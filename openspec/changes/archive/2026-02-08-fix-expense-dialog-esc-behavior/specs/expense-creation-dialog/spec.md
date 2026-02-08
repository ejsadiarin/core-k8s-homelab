## MODIFIED Requirements

### Requirement: Expense dialog proper UX
The expense dialog SHALL follow best practices for modal UX patterns.

#### Scenario: Escape key closes dialog without navigation
- **WHEN** expense dialog is open
- **WHEN** user presses Escape key
- **THEN** system closes dialog without saving
- **THEN** system prevents default browser navigation behavior
- **THEN** user remains on current page (budget dashboard or expenses list)

### Requirement: Deep linking to expense dialog
Users SHALL be able to navigate directly to expense creation via URL.

#### Scenario: Browser back button closes dialog
- **WHEN** user opens expense dialog via button click (no URL change)
- **WHEN** user clicks browser back button
- **THEN** dialog closes and user remains on current page
- **THEN** system does not navigate to previous route
