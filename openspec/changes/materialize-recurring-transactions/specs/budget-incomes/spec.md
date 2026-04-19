## MODIFIED Requirements

### Requirement: Recurring daily income
Users SHALL create recurring daily income rules that auto-calculate daily amounts from a start date with optional end date.

#### Scenario: Create recurring daily income
- **WHEN** user creates income entry with recurring rule set to daily
- **THEN** system stores amount, start_date, end_date (optional), description, and user_id
- **THEN** system marks entry as recurring with type 'daily'
- **THEN** system generates occurrence rows in budget_income_occurrences from start_date to min(end_date, start_date + 1 year)

#### Scenario: Calculate recurring income for date range
- **WHEN** system calculates income for date range X to Y
- **WHEN** recurring income exists with start_date S where S ≤ Y
- **WHEN** end_date is NULL or E ≥ X
- **THEN** system queries SUM(amount) FROM budget_income_occurrences WHERE occurrence_date BETWEEN X AND Y AND is_skipped = false

#### Scenario: Recurring income with start date in future
- **WHEN** recurring income has start_date in the future
- **THEN** system does not include income for dates before start_date
- **THEN** occurrence rows only exist from start_date onward

#### Scenario: Recurring income with end date
- **WHEN** recurring income has end_date specified
- **THEN** system only includes income up to and including end_date
- **THEN** occurrence rows only exist up to end_date
