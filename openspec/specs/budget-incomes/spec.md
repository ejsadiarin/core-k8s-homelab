## ADDED Requirements

### Requirement: Income ownership
Each income entry SHALL be associated with a user via user_id foreign key.

#### Scenario: Create income
- **WHEN** authenticated user creates income entry
- **THEN** system sets user_id to current user's ID

### Requirement: Income isolation by user
Users SHALL only see and manage their own income entries.

#### Scenario: List incomes
- **WHEN** user requests income entries
- **THEN** system returns only incomes where user_id matches current user

#### Scenario: Get single income
- **WHEN** user requests income by ID
- **WHEN** income belongs to current user
- **THEN** system returns income entry

#### Scenario: Access other user's income
- **WHEN** user tries to access income with different user_id
- **THEN** system returns 404 Not Found

### Requirement: One-time income entries
Users SHALL create one-time income entries with specific dates and amounts.

#### Scenario: Create one-time income
- **WHEN** user creates income entry without recurring rule
- **THEN** system stores amount, date, description, and user_id
- **THEN** system marks entry as one-time (not recurring)

#### Scenario: List one-time incomes
- **WHEN** user requests income entries
- **THEN** system returns all one-time incomes for that user

### Requirement: Recurring daily income
Users SHALL create recurring daily income rules that auto-calculate daily amounts from a start date with optional end date.

#### Scenario: Create recurring daily income
- **WHEN** user creates income entry with recurring rule set to daily
- **THEN** system stores amount, start_date, end_date (optional), description, and user_id
- **THEN** system marks entry as recurring with type 'daily'

#### Scenario: Calculate recurring income for date range
- **WHEN** system calculates income for date range X to Y
- **WHEN** recurring income exists with start_date S where S ≤ Y
- **WHEN** end_date is NULL or E ≥ X
- **THEN** system includes amount × number of days from max(S, X) to min(E or Y, Y)

#### Scenario: Recurring income with start date in future
- **WHEN** recurring income has start_date in the future
- **THEN** system does not include income for dates before start_date

#### Scenario: Recurring income with end date
- **WHEN** recurring income has end_date specified
- **THEN** system only includes income up to and including end_date

### Requirement: Income CRUD operations
Users SHALL create, read, update, and delete their own income entries.

#### Scenario: Create income
- **WHEN** user POSTs to /api/budget/incomes with valid data
- **THEN** system creates income entry and returns created record

#### Scenario: Update income
- **WHEN** user PUTs to /api/budget/incomes/:id with valid data
- **WHEN** income belongs to current user
- **THEN** system updates income entry and returns updated record

#### Scenario: Delete income
- **WHEN** user DELETEs to /api/budget/incomes/:id
- **WHEN** income belongs to current user
- **THEN** system deletes income entry

#### Scenario: Update other user's income
- **WHEN** user tries to update income with different user_id
- **THEN** system returns 404 Not Found

#### Scenario: Delete other user's income
- **WHEN** user tries to delete income with different user_id
- **THEN** system returns 404 Not Found

### Requirement: Guest cannot modify incomes
Unauthenticated users SHALL NOT create, update, or delete income entries.

#### Scenario: Guest creates income
- **WHEN** unauthenticated user POSTs to /api/budget/incomes
- **THEN** system returns 401 Unauthorized

#### Scenario: Guest updates income
- **WHEN** unauthenticated user PUTs to /api/budget/incomes/:id
- **THEN** system returns 401 Unauthorized

#### Scenario: Guest deletes income
- **WHEN** unauthenticated user DELETEs to /api/budget/incomes/:id
- **THEN** system returns 401 Unauthorized

### Requirement: Admin income access
Admins SHALL be able to view all income entries across users.

#### Scenario: Admin lists all incomes
- **WHEN** admin requests incomes without user filter
- **THEN** system returns all incomes with user info

#### Scenario: Admin filters by user
- **WHEN** admin requests incomes with user_id query param
- **THEN** system returns only that user's incomes

### Requirement: Weekly recurring income type
Users SHALL create weekly recurring income in addition to daily.

#### Scenario: Create weekly recurring income
- **WHEN** user POSTs to /api/budget/incomes with recurring_type = 'weekly'
- **THEN** system creates income with weekly recurrence pattern
- **THEN** system returns created record with recurring_type = 'weekly'

#### Scenario: List incomes includes weekly type
- **WHEN** user requests income entries
- **THEN** system returns incomes with recurring_type showing 'weekly' where applicable

### Requirement: Monthly recurring income type
Users SHALL create monthly recurring income in addition to daily and weekly.

#### Scenario: Create monthly recurring income
- **WHEN** user POSTs to /api/budget/incomes with recurring_type = 'monthly'
- **THEN** system creates income with monthly recurrence pattern
- **THEN** system returns created record with recurring_type = 'monthly'

#### Scenario: List incomes includes monthly type
- **WHEN** user requests income entries
- **THEN** system returns incomes with recurring_type showing 'monthly' where applicable

### Requirement: End date field for recurring income
Recurring income entries SHALL optionally include an end_date to support time-bound income.

#### Scenario: Create recurring income with end date
- **WHEN** user POSTs to /api/budget/incomes with end_date specified
- **THEN** system validates end_date ≥ start_date
- **THEN** system stores end_date value in database

#### Scenario: Create recurring income without end date
- **WHEN** user POSTs to /api/budget/incomes without end_date
- **THEN** system stores end_date as NULL (indefinite)

#### Scenario: Update end date on existing income
- **WHEN** user PUTs to /api/budget/incomes/:id with end_date value
- **THEN** system updates end_date and returns updated record

#### Scenario: API response includes end_date
- **WHEN** user requests income by ID or list
- **THEN** response includes end_date field (null or ISO timestamp)
