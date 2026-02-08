## MODIFIED Requirements

### Requirement: Expense isolation by user
Users SHALL only see and manage their own expenses with support for pagination.

#### Scenario: List expenses
- **WHEN** user requests expenses
- **THEN** system returns only expenses where user_id matches current user
- **THEN** system returns paginated results with offset-based navigation

#### Scenario: Get single expense
- **WHEN** user requests expense by ID
- **WHEN** expense belongs to current user
- **THEN** system returns expense

#### Scenario: Access other user's expense
- **WHEN** user tries to access expense with different user_id
- **THEN** system returns 404 Not Found

#### Scenario: Paginated expense listing
- **WHEN** user requests GET /api/budget/expenses with optional page/limit params
- **THEN** system returns paginated list with total count metadata
- **THEN** system enforces user_id isolation on paginated results

## ADDED Requirements

### Requirement: Backward compatible pagination
Expense list endpoint SHALL support both paginated and non-paginated requests for backward compatibility.

#### Scenario: Legacy request without pagination params
- **WHEN** user requests GET /api/budget/expenses without page or limit
- **THEN** system returns first page (default limit=5)
- **THEN** response includes pagination metadata

#### Scenario: Explicit pagination request
- **WHEN** user requests GET /api/budget/expenses?page=2&limit=5
- **THEN** system returns expenses 6-10
- **THEN** response follows paginated format
