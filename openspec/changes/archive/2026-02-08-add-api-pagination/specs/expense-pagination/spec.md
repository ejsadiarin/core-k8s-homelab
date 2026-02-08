## ADDED Requirements

### Requirement: Offset-based pagination for expense listings
The system SHALL support offset/limit pagination for expense listings with page number navigation.

#### Scenario: Request first page of expenses
- **WHEN** user requests GET /api/budget/expenses without pagination params
- **THEN** system returns first 5 expenses ordered by expense_date DESC, created_at DESC
- **THEN** response includes pagination metadata with total, page, limit, totalPages, hasMore

#### Scenario: Request specific page
- **WHEN** user requests GET /api/budget/expenses?page=2&limit=5
- **THEN** system calculates offset = (page-1) * limit = 5
- **THEN** system returns expenses 6-10
- **THEN** response includes updated pagination metadata

#### Scenario: Last page of expenses
- **WHEN** user requests page beyond available data
- **THEN** system returns empty data array
- **THEN** pagination metadata shows hasMore=false

#### Scenario: Custom page size
- **WHEN** user requests GET /api/budget/expenses?limit=10
- **THEN** system returns up to 10 expenses per page
- **THEN** system validates limit ≤ 100 (max page size)

#### Scenario: Invalid pagination params
- **WHEN** user provides invalid page or limit
- **THEN** system returns 400 Bad Request with validation error

#### Scenario: Pagination with filters
- **WHEN** user requests GET /api/budget/expenses?page=2&category_id={id}
- **THEN** system applies filters first
- **THEN** system paginates filtered results
- **THEN** total count reflects filtered dataset

### Requirement: Pagination metadata response
All paginated expense responses SHALL include pagination metadata.

#### Scenario: Metadata structure
- **WHEN** system returns paginated expenses
- **THEN** response includes pagination object with:
  - total (number): total count of expenses
  - page (number): current page number (1-indexed)
  - limit (number): current page size
  - totalPages (number): total number of pages
  - hasMore (boolean): true if more pages exist

#### Scenario: First page metadata
- **WHEN** user requests first page (no params or page=1)
- **THEN** pagination.page = 1
- **THEN** pagination.hasMore = (total > limit)

#### Scenario: Final page metadata
- **WHEN** user requests last page
- **THEN** pagination.hasMore = false
- **THEN** pagination.page = totalPages

### Requirement: Backend parameter binding
The backend SHALL correctly bind query parameters from GET requests.

#### Scenario: Query parameter binding
- **WHEN** user requests GET /api/budget/expenses?page=2&limit=5
- **THEN** system uses `query` struct tags (not `form`) for parameter binding
- **THEN** Echo framework correctly parses URL query parameters
