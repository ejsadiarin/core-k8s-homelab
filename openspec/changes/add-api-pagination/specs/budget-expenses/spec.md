## MODIFIED Requirements

### Requirement: Expense isolation by user
Users SHALL only see and manage their own expenses with support for pagination.

#### Scenario: List expenses
- **WHEN** user requests expenses
- **THEN** system returns only expenses where user_id matches current user
- **THEN** system returns paginated results with cursor-based navigation

#### Scenario: Get single expense
- **WHEN** user requests expense by ID
- **WHEN** expense belongs to current user
- **THEN** system returns expense

#### Scenario: Access other user's expense
- **WHEN** user tries to access expense with different user_id
- **THEN** system returns 404 Not Found

#### Scenario: Paginated expense listing
- **WHEN** user requests GET /api/budget/expenses with optional cursor param
- **THEN** system returns paginated list with cursor metadata
- **THEN** system enforces user_id isolation on paginated results

## ADDED Requirements

### Requirement: Backward compatible pagination
Expense list endpoint SHALL support both paginated and non-paginated requests for backward compatibility.

#### Scenario: Legacy request without pagination params
- **WHEN** user requests GET /api/budget/expenses without cursor or limit
- **THEN** system returns first page (default limit=20)
- **THEN** response includes pagination metadata

#### Scenario: Explicit pagination request
- **WHEN** user requests GET /api/budget/expenses?cursor={cursor}&limit=50
- **THEN** system returns up to 50 expenses after cursor
- **THEN** response follows paginated format

### Requirement: Expense list performance optimization
The system SHALL use database indexes for efficient cursor-based pagination.

#### Scenario: Index usage for pagination query
- **WHEN** system executes paginated expense query
- **THEN** query uses composite index on (user_id, expense_date DESC, id)
- **THEN** query execution time < 100ms for P95 with 10,000+ expenses

#### Scenario: Efficient next page fetch
- **WHEN** user requests next page with cursor
- **THEN** system uses index seek (not scan) for cursor position
- **THEN** system fetches only requested limit (+1 for hasMore check)
