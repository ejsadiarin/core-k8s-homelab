## MODIFIED Requirements

### Requirement: Budget remaining in summary stats
The summary stats endpoint SHALL include budget remaining metric calculated from total income minus total expenses.

#### Scenario: Budget remaining calculation in stats
- **WHEN** system calculates summary stats
- **THEN** system calculates total one-time income for period via existing query
- **THEN** system calculates total recurring income for period via SUM(amount) FROM budget_income_occurrences WHERE occurrence_date in range AND is_skipped = false
- **THEN** system calculates total expenses for period (one-time + SUM from budget_expense_occurrences WHERE occurrence_date in range AND is_skipped = false)
- **THEN** system sets budget_remaining = total_income - total_expenses
- **THEN** system sets budget_remaining_status to 'green' if positive, 'red' if negative, 'neutral' if zero

#### Scenario: Summary stats with period filter
- **WHEN** user requests GET /api/budget/stats/summary?period=month
- **THEN** system calculates budget remaining for the period using materialized occurrence rows
- **THEN** system includes budget_remaining and budget_remaining_status in response
