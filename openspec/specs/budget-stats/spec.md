## ADDED Requirements

### Requirement: Stats scoped to user
Budget statistics SHALL be calculated for the authenticated user's data only.

#### Scenario: User requests summary
- **WHEN** user requests /api/budget/stats/summary
- **THEN** system calculates stats from user's expenses only

#### Scenario: User requests category breakdown
- **WHEN** user requests /api/budget/stats/category-breakdown
- **THEN** system calculates breakdown from user's expenses and categories

#### Scenario: User requests trends
- **WHEN** user requests /api/budget/stats/trends
- **THEN** system calculates trends from user's expenses only

### Requirement: Guest sees demo stats
Unauthenticated users SHALL see statistics for demo data.

#### Scenario: Guest requests summary
- **WHEN** unauthenticated user requests stats
- **THEN** system returns stats calculated from demo user's data

### Requirement: Admin can view any user's stats
Admins SHALL be able to view statistics for any user.

#### Scenario: Admin requests stats with user filter
- **WHEN** admin requests stats with user_id query param
- **THEN** system returns stats for specified user

#### Scenario: Admin requests global stats
- **WHEN** admin requests stats without user filter
- **THEN** system returns aggregated stats across all users

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
The budget remaining calculation SHALL accept optional `start_date` and `end_date` parameters. If `end_date` is provided without `start_date`, the system MUST NOT fail and SHALL calculate from the beginning of the user's tracking period (or epoch) to the `end_date`.

#### Scenario: Summary stats without date
- **WHEN** user requests GET /api/budget/stats/summary without date filter
- **THEN** system calculates budget remaining from start to current date

#### Scenario: Summary stats with full date filter
- **WHEN** user requests GET /api/budget/stats/summary?start_date=2026-01-01&end_date=2026-02-07
- **THEN** system calculates budget remaining strictly between those dates

#### Scenario: Summary stats with only end_date filter
- **WHEN** user requests GET /api/budget/stats/summary?end_date=2026-02-07
- **THEN** system calculates budget remaining from the beginning of time/tracking to the specified end date without error
