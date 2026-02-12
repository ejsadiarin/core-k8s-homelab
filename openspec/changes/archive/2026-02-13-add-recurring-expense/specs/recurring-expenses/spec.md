## ADDED Requirements

### Requirement: Recurring expense types
Users SHALL create recurring expenses with daily, weekly, monthly, or yearly intervals, or as one-time expenses.

#### Scenario: Create daily recurring expense
- **WHEN** user creates expense with recurring_type set to 'daily'
- **THEN** system stores amount, start_date, end_date (optional), description, category, tags, and user_id
- **THEN** system marks entry as recurring with type 'daily'

#### Scenario: Create weekly recurring expense
- **WHEN** user creates expense with recurring_type set to 'weekly'
- **THEN** system stores expense as weekly recurring entry
- **THEN** system requires start_date to be provided

#### Scenario: Create monthly recurring expense
- **WHEN** user creates expense with recurring_type set to 'monthly'
- **THEN** system stores expense as monthly recurring entry
- **THEN** system returns created record with recurring_type = 'monthly'

#### Scenario: Create yearly recurring expense
- **WHEN** user creates expense with recurring_type set to 'yearly'
- **THEN** system stores expense as yearly recurring entry
- **THEN** system accepts start_date for yearly recurrence

#### Scenario: Create one-time expense
- **WHEN** user creates expense without recurring_type (NULL)
- **THEN** system stores expense as one-time entry
- **THEN** system stores expense_date (not start_date) for one-time expenses

### Requirement: Start date requirement for recurring expenses
Recurring expenses SHALL require a start_date to indicate when the recurrence begins.

#### Scenario: Create recurring expense without start_date
- **WHEN** user attempts to create recurring expense with recurring_type set but no start_date
- **THEN** system returns 400 Bad Request with validation error

#### Scenario: Create one-time expense without start_date
- **WHEN** user creates one-time expense (recurring_type = NULL)
- **THEN** system allows creation without start_date
- **THEN** system uses expense_date field instead

### Requirement: End date support for recurring expenses
Users SHALL optionally specify an end_date for recurring expenses to support time-bound subscriptions or contracts.

#### Scenario: Create recurring expense with end date
- **WHEN** user creates recurring expense with end_date specified
- **THEN** system validates end_date >= start_date
- **THEN** system stores end_date value

#### Scenario: Create recurring expense without end date
- **WHEN** user creates recurring expense with end_date = NULL
- **THEN** system stores NULL indicating indefinite recurrence

#### Scenario: End date validation failure
- **WHEN** user creates recurring expense with end_date < start_date
- **THEN** system returns 400 Bad Request with error message "end_date must be on or after start_date"

#### Scenario: Update end date on existing expense
- **WHEN** user updates recurring expense to add or change end_date
- **THEN** system accepts change and stores new end_date

### Requirement: API response includes recurring fields
All expense API responses SHALL include recurring_type, start_date, and end_date fields.

#### Scenario: List expenses includes recurring data
- **WHEN** user requests expense list
- **THEN** response includes recurring_type field (null or string)
- **THEN** response includes start_date field (null or ISO date)
- **THEN** response includes end_date field (null or ISO date)

#### Scenario: Get single expense includes recurring data
- **WHEN** user requests single expense by ID
- **THEN** response includes complete recurring expense information

### Requirement: Filter expenses by recurring type
Users SHALL filter expense lists by recurring_type to view only recurring or one-time expenses.

#### Scenario: Filter by daily recurring type
- **WHEN** user requests expenses with query param recurring_type=daily
- **THEN** system returns only expenses with recurring_type = 'daily'

#### Scenario: Filter by monthly recurring type
- **WHEN** user requests expenses with query param recurring_type=monthly
- **THEN** system returns only expenses with recurring_type = 'monthly'

#### Scenario: Filter to show only one-time expenses
- **WHEN** user requests expenses with query param recurring_type=null
- **THEN** system returns only expenses where recurring_type IS NULL

#### Scenario: Invalid recurring_type filter
- **WHEN** user requests expenses with invalid recurring_type value
- **THEN** system returns 400 Bad Request with validation error

### Requirement: Database constraint enforcement
The database SHALL enforce valid recurring_type values and data integrity through constraints.

#### Scenario: Invalid recurring type rejected at database level
- **WHEN** application attempts to insert expense with recurring_type = 'invalid'
- **THEN** database rejects with constraint violation error

#### Scenario: Recurring expense without start_date rejected
- **WHEN** application attempts to insert recurring expense with NULL start_date
- **THEN** database rejects with constraint violation error

### Requirement: Backward compatible expense creation
Existing expense creation without recurring fields SHALL continue to work unchanged.

#### Scenario: Create expense without recurring fields (legacy)
- **WHEN** user POSTs to /api/budget/expenses with legacy format (no recurring_type, start_date, end_date)
- **THEN** system creates expense as one-time entry
- **THEN** system returns successful response

#### Scenario: Response format unchanged for one-time expenses
- **WHEN** system returns one-time expense
- **THEN** recurring_type field is null in response
- **THEN** start_date and end_date fields are null in response
