## ADDED Requirements

### Requirement: Monthly Summary page displays period financial overview
The system SHALL provide a dedicated summary page at `/dashboard/budget/summary` that displays:
- Total income (one-time + recurring) for the selected period
- Total expenses for the selected period
- Net savings (income - expenses)
- Savings rate percentage
- A list of income entries (including virtual recurring occurrences) for the period
- A list of expense entries for the period

#### Scenario: User views current month summary
- **WHEN** user navigates to the summary page with "This Month" preset selected
- **THEN** the page displays total income, total expenses, net savings, and savings rate for the current calendar month, along with itemized income and expense lists

#### Scenario: User views 7-day summary
- **WHEN** user selects the "7D" preset filter
- **THEN** the page displays financial summary for the last 7 days from today

#### Scenario: User views custom date range summary
- **WHEN** user sets custom start and end dates
- **THEN** the page displays financial summary for the specified custom period

### Requirement: Summary page shows itemized transactions
The system SHALL display expandable/collapsible sections for income entries and expense entries within the selected period, sorted by date descending.

#### Scenario: Income section shows recurring occurrences
- **WHEN** user has a weekly recurring income and views the monthly summary
- **THEN** the income section shows individual virtual occurrence entries for each week, clearly marked with the recurring frequency badge

#### Scenario: Empty period
- **WHEN** user selects a period with no income or expenses
- **THEN** the page shows zero totals and empty transaction lists with appropriate messaging

### Requirement: Summary page accessible from sidebar navigation
The system SHALL add a "Summary" navigation item in the FINANCE section of the sidebar, positioned after "Incomes" and before "Settings".

#### Scenario: Navigation to summary page
- **WHEN** user clicks "Summary" in the sidebar
- **THEN** the user is navigated to `/dashboard/budget/summary`
