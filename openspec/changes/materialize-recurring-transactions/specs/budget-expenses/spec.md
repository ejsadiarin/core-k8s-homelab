## MODIFIED Requirements

### Requirement: Backward compatible pagination
Expense list endpoint SHALL support both paginated and non-paginated requests for backward compatibility.

#### Scenario: Create expense with recurring data
- **WHEN** authenticated user creates expense with recurring_type, start_date, and end_date
- **THEN** system sets user_id to current user's ID along with all expense data
- **THEN** system generates occurrence rows in budget_expense_occurrences from start_date to min(end_date, start_date + 1 year)

#### Scenario: Create one-time expense
- **WHEN** authenticated user creates one-time expense
- **THEN** system sets user_id to current user's ID
- **THEN** no occurrence rows are generated (one-time expenses are not materialized)
