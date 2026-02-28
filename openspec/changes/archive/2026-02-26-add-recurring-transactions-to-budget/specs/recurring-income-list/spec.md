## ADDED Requirements

### Requirement: Display Recurring Income List
The Budget dashboard SHALL display a list of active recurring incomes showing description, amount, frequency, and next expected date.

#### Scenario: List displays active recurring incomes
- **WHEN** user navigates to Budget dashboard
- **THEN** recurring incomes section shows all active recurring incomes with: description, amount, frequency badge (weekly/monthly), next expected date

#### Scenario: List shows empty state
- **WHEN** user has no recurring incomes
- **THEN** section displays "No recurring incomes" message with "Add Income" CTA

#### Scenario: Frequency badge display
- **WHEN** recurring income has recurring_type "weekly"
- **THEN** badge shows "weekly" in secondary color
- **AND** recurring income with "monthly" shows "monthly" badge

#### Scenario: User clicks recurring income
- **WHEN** user clicks on a recurring income item
- **THEN** edit dialog opens showing income details with option to modify or delete

#### Scenario: Skip button present
- **WHEN** recurring income is displayed
- **THEN** each item has a "Skip" button/option to skip the next occurrence

#### Scenario: Next date calculation
- **WHEN** recurring income starts on Wednesday with weekly frequency
- **THEN** next date shown is the upcoming Wednesday
- **AND** for monthly on the 15th, next date shows the 15th of next month
