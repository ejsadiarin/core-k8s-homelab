## MODIFIED Requirements

### Requirement: Income isolation by user
Users SHALL only see and manage their own income entries with support for pagination.

#### Scenario: List incomes
- **WHEN** user requests income entries
- **THEN** system returns only incomes where user_id matches current user
- **THEN** system returns paginated results with offset/limit navigation

#### Scenario: Get single income
- **WHEN** user requests income by ID
- **WHEN** income belongs to current user
- **THEN** system returns income entry

#### Scenario: Access other user's income
- **WHEN** user tries to access income with different user_id
- **THEN** system returns 404 Not Found

#### Scenario: Paginated income listing
- **WHEN** user requests GET /api/budget/incomes with optional page/offset params
- **THEN** system returns paginated list with total count metadata
- **THEN** system enforces user_id isolation on paginated results

## ADDED Requirements

### Requirement: Backward compatible pagination for incomes
Income list endpoint SHALL support both paginated and non-paginated requests for backward compatibility.

#### Scenario: Legacy request without pagination params
- **WHEN** user requests GET /api/budget/incomes without pagination params
- **THEN** system returns first page (default limit=10)
- **THEN** response includes pagination metadata with total count

#### Scenario: Explicit pagination request
- **WHEN** user requests GET /api/budget/incomes?page=2&limit=20
- **THEN** system returns incomes 11-30
- **THEN** response follows paginated format

### Requirement: Income list performance optimization
The system SHALL use database indexes for efficient offset-based pagination.

#### Scenario: Index usage for pagination query
- **WHEN** system executes paginated income query
- **THEN** query uses index on (user_id, created_at DESC)
- **THEN** query execution time < 50ms for P95 with 1,000+ incomes

#### Scenario: Total count optimization
- **WHEN** user requests paginated incomes
- **THEN** system executes separate COUNT query with same filters
- **THEN** count query uses covering index for performance
