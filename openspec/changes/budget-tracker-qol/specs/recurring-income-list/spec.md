## MODIFIED Requirements

### Requirement: Recent Incomes section shows recurring occurrences for context
The "Recent Incomes" section on the budget dashboard SHALL include recent virtual recurring income occurrences (from the last 7 days) alongside the most recent stored income entries, giving users visibility into recurring income that was applied recently.

Virtual entries SHALL be visually distinguished with a recurring frequency badge and a subtle background indicator. The combined list SHALL be sorted by date descending and limited to 5-8 entries total.

#### Scenario: Wednesday recurring income shows on dashboard
- **WHEN** today is Thursday and user has a weekly Wednesday recurring income of +500 PHP
- **THEN** the Recent Incomes section shows a virtual entry for yesterday's Wednesday occurrence with a "weekly" badge

#### Scenario: Mixed one-time and recurring entries
- **WHEN** user has both one-time incomes and recurring incomes in the last 7 days
- **THEN** the Recent Incomes section shows both types interleaved by date, with recurring entries marked distinctly
