## ADDED Requirements

### Requirement: Budget remaining calculation
The system SHALL calculate budget remaining as total income minus total expenses for a given date range.

#### Scenario: Calculate budget remaining for specific date
- **WHEN** user requests GET /api/budget/remaining?date=2026-02-07
- **THEN** system calculates total income from start to date
- **THEN** system calculates total expenses from start to date
- **THEN** system returns budget_remaining = total_income - total_expenses

#### Scenario: Budget remaining positive
- **WHEN** total income > total expenses for date range
- **THEN** system returns positive budget_remaining value
- **THEN** system includes status indicator 'green'

#### Scenario: Budget remaining negative
- **WHEN** total income < total expenses for date range
- **THEN** system returns negative budget_remaining value
- **THEN** system includes status indicator 'red'

#### Scenario: Budget remaining zero
- **WHEN** total income = total expenses for date range
- **THEN** system returns zero budget_remaining value
- **THEN** system includes status indicator 'neutral'

### Requirement: Running total calculation
The budget remaining SHALL be calculated as a running total from the beginning of user's data to the specified date, including all recurring income types.

#### Scenario: Calculate running total
- **WHEN** user requests budget remaining for date D
- **THEN** system sums all one-time incomes with date ≤ D
- **THEN** system sums all recurring incomes (daily, weekly, monthly) prorated from start_date to min(end_date or D, D)
- **THEN** system sums all expenses with expense_date ≤ D
- **THEN** system returns running total = (one-time_income + recurring_income) - expenses

#### Scenario: Recurring income prorated correctly
- **WHEN** recurring income is ₱500/day starting Feb 1 with no end_date
- **WHEN** user requests budget remaining for Feb 5
- **THEN** system includes 5 days × ₱500 = ₱2,500 from recurring income

#### Scenario: Weekly recurring income in calculation
- **WHEN** weekly recurring income is ₱3000/week starting Feb 1
- **WHEN** user requests budget remaining for Feb 21
- **THEN** system includes 3 weeks × ₱3000 = ₱9,000 from recurring income

#### Scenario: Monthly recurring income in calculation
- **WHEN** monthly recurring income is ₱15000/month starting Jan 1
- **WHEN** user requests budget remaining for Mar 15
- **THEN** system includes 3 months × ₱15000 = ₱45,000 from recurring income

#### Scenario: Recurring income with end_date in calculation
- **WHEN** recurring income has end_date = Feb 28
- **WHEN** user requests budget remaining for Mar 15
- **THEN** system only includes income from start_date to Feb 28, not beyond

### Requirement: Budget remaining scoped to user
Budget remaining SHALL be calculated for the authenticated user's data only.

#### Scenario: User requests budget remaining
- **WHEN** authenticated user requests budget remaining
- **THEN** system calculates using only that user's income and expense data

#### Scenario: Guest requests budget remaining
- **WHEN** unauthenticated user requests budget remaining
- **THEN** system calculates using demo user's data

### Requirement: Date filtering
Users SHALL request budget remaining for specific dates or use current date as default.

#### Scenario: Request with specific date
- **WHEN** user requests GET /api/budget/remaining?date=2026-02-07
- **THEN** system calculates budget remaining for that specific date

#### Scenario: Request without date parameter
- **WHEN** user requests GET /api/budget/remaining
- **THEN** system calculates budget remaining for current date

#### Scenario: Invalid date format
- **WHEN** user requests with invalid date format
- **THEN** system returns 400 Bad Request

### Requirement: Budget remaining validation
The system SHALL validate date parameters and user access before calculating budget remaining.

#### Scenario: Future date request
- **WHEN** user requests budget remaining for future date
- **THEN** system calculates based on existing income and expense data (no future data)

#### Scenario: Date before any income/expense
- **WHEN** user requests budget remaining for date before any data exists
- **THEN** system returns budget_remaining = 0

### Requirement: Admin budget remaining access
Admins SHALL be able to view budget remaining for any user.

#### Scenario: Admin requests budget remaining with user filter
- **WHEN** admin requests /api/budget/remaining?user_id=<id>
- **THEN** system returns budget remaining for specified user

#### Scenario: Admin requests global budget remaining
- **WHEN** admin requests /api/budget/remaining without user filter
- **THEN** system returns aggregated budget remaining across all users

### Requirement: Budget remaining UI displays readable colors
The budget remaining card SHALL use accessible color combinations for all status states.

#### Scenario: Over budget color scheme
- **WHEN** budget_remaining_status = 'red'
- **THEN** UI displays light red background (bg-red-50)
- **THEN** UI displays dark red text (text-red-900)
- **THEN** UI displays red border (border-red-200)

#### Scenario: On track color scheme
- **WHEN** budget_remaining_status = 'green'
- **THEN** UI displays light green background (bg-green-50)
- **THEN** UI displays dark green text (text-green-900)
- **THEN** UI displays green border (border-green-200)

#### Scenario: Neutral color scheme
- **WHEN** budget_remaining_status = 'neutral'
- **THEN** UI displays gray text (text-gray-600)
- **THEN** UI uses default background and border

#### Scenario: Color contrast meets WCAG AA
- **WHEN** budget remaining card displays any status
- **THEN** text-to-background contrast ratio is at least 4.5:1
