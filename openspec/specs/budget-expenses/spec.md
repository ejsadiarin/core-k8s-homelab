## ADDED Requirements

### Requirement: Expense ownership
Each expense SHALL be associated with a user via user_id foreign key.

#### Scenario: Create expense
- **WHEN** authenticated user creates expense
- **THEN** system sets user_id to current user's ID

### Requirement: Expense isolation by user
Users SHALL only see and manage their own expenses with support for pagination.

#### Scenario: List expenses
- **WHEN** user requests expenses
- **THEN** system returns only expenses where user_id matches current user
- **THEN** system returns paginated results with offset-based navigation

#### Scenario: Paginated expense listing
- **WHEN** user requests GET /api/budget/expenses with optional page/limit params
- **THEN** system returns paginated list with total count metadata
- **THEN** system enforces user_id isolation on paginated results

#### Scenario: Get single expense
- **WHEN** user requests expense by ID
- **WHEN** expense belongs to current user
- **THEN** system returns expense

#### Scenario: Access other user's expense
- **WHEN** user tries to access expense with different user_id
- **THEN** system returns 404 Not Found

### Requirement: Expense category/tag validation
Users SHALL only use their own categories and tags on expenses.

#### Scenario: Assign own category to expense
- **WHEN** user creates/updates expense with category_id
- **WHEN** category belongs to current user
- **THEN** system allows assignment

#### Scenario: Assign other user's category
- **WHEN** user tries to use category belonging to another user
- **THEN** system returns 400 Bad Request with validation error

#### Scenario: Assign own tags to expense
- **WHEN** user creates/updates expense with tag_ids
- **WHEN** all tags belong to current user
- **THEN** system allows assignment

#### Scenario: Assign other user's tag
- **WHEN** user tries to use tag belonging to another user
- **THEN** system returns 400 Bad Request with validation error

### Requirement: Admin expense access
Admins SHALL be able to view all expenses across users.

#### Scenario: Admin lists all expenses
- **WHEN** admin requests expenses without user filter
- **THEN** system returns all expenses with user info

#### Scenario: Admin filters by user
- **WHEN** admin requests expenses with user_id query param
- **THEN** system returns only that user's expenses

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
