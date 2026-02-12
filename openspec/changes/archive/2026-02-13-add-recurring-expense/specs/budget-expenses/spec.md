## MODIFIED Requirements

### Requirement: Expense ownership
Each expense SHALL be associated with a user via user_id foreign key.

#### Scenario: Create expense with recurring data
- **WHEN** authenticated user creates expense with recurring_type, start_date, and end_date
- **THEN** system sets user_id to current user's ID along with all expense data

#### Scenario: Create one-time expense
- **WHEN** authenticated user creates one-time expense
- **THEN** system sets user_id to current user's ID

### Requirement: Expense isolation by user
Users SHALL only see and manage their own expenses with support for pagination and filtering.

#### Scenario: List expenses with recurring filter
- **WHEN** user requests expenses with recurring_type filter
- **THEN** system returns only expenses where user_id matches current user
- **THEN** system applies recurring_type filter to user's expenses only

#### Scenario: Paginated expense listing with recurring data
- **WHEN** user requests GET /api/budget/expenses with page/limit params
- **THEN** system returns paginated list with recurring fields included
- **THEN** system enforces user_id isolation on paginated results

### Requirement: Expense category/tag validation
Users SHALL only use their own categories and tags on expenses, including recurring expenses.

#### Scenario: Assign category to recurring expense
- **WHEN** user creates recurring expense with category_id
- **THEN** system validates category belongs to current user
- **THEN** system allows assignment if category is owned by user

### Requirement: Backward compatible pagination
Expense list endpoint SHALL support both paginated and non-paginated requests for backward compatibility, with recurring fields included.

#### Scenario: Legacy request returns expenses with recurring fields
- **WHEN** user requests GET /api/budget/expenses without pagination params
- **THEN** system returns first page with recurring_type, start_date, end_date fields
- **THEN** one-time expenses show null for recurring fields
