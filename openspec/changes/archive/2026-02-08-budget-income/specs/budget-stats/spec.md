## ADDED Requirements

### Requirement: Budget remaining in summary stats
The summary stats endpoint SHALL include budget remaining metric calculated from total income minus total expenses.

#### Scenario: User requests summary stats
- **WHEN** user requests GET /api/budget/stats/summary
- **THEN** system returns budget_remaining field with calculated value
- **THEN** system returns budget_remaining_status indicator ('green', 'red', or 'neutral')

#### Scenario: Summary stats with period filter
- **WHEN** user requests GET /api/budget/stats/summary?period=month
- **THEN** system calculates budget remaining for the period
- **THEN** system includes budget_remaining and budget_remaining_status in response

#### Scenario: Budget remaining calculation in stats
- **WHEN** system calculates summary stats
- **THEN** system calculates total income for period (one-time + recurring prorated)
- **THEN** system calculates total expenses for period
- **THEN** system sets budget_remaining = total_income - total_expenses
- **THEN** system sets budget_remaining_status to 'green' if positive, 'red' if negative, 'neutral' if zero

#### Scenario: Guest requests summary stats
- **WHEN** unauthenticated user requests GET /api/budget/stats/summary
- **THEN** system returns budget_remaining calculated from demo user's data

### Requirement: Budget remaining defaults to current date
The budget remaining calculation SHALL default to current date if no date parameter provided.

#### Scenario: Summary stats without date
- **WHEN** user requests GET /api/budget/stats/summary without date filter
- **THEN** system calculates budget remaining from start to current date

#### Scenario: Summary stats with date filter
- **WHEN** user requests GET /api/budget/stats/summary?date=2026-02-07
- **THEN** system calculates budget remaining from start to specified date
