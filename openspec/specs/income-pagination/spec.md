# Purpose

Defines the offset-based pagination system for income listings.

## ADDED Requirements

### Requirement: Offset-based pagination for income listings
The system SHALL support offset/limit pagination for income listings with page numbers.

#### Scenario: Request first page of incomes
- **WHEN** user requests GET /api/budget/incomes without pagination params
- **THEN** system returns first 10 incomes ordered by created_at DESC
- **THEN** response includes pagination metadata with total, page, hasMore

#### Scenario: Request specific page by offset
- **WHEN** user requests GET /api/budget/incomes?offset=20&limit=10
- **THEN** system returns incomes 21-30 (offset skip 20, take 10)
- **THEN** response includes updated pagination metadata

#### Scenario: Request specific page by page number
- **WHEN** user requests GET /api/budget/incomes?page=3&limit=10
- **THEN** system calculates offset = (page-1) * limit = 20
- **THEN** system returns incomes for page 3

#### Scenario: Last page of incomes
- **WHEN** user requests page beyond available data
- **THEN** system returns empty data array
- **THEN** pagination metadata shows hasMore=false

#### Scenario: Custom page size
- **WHEN** user requests GET /api/budget/incomes?limit=25
- **THEN** system returns up to 25 incomes per page
- **THEN** system validates limit ≤ 100 (max page size)

#### Scenario: Invalid pagination params
- **WHEN** user provides negative offset or page
- **THEN** system returns 400 Bad Request with validation error

#### Scenario: Total count for pagination
- **WHEN** user requests any page of incomes
- **THEN** system includes total count of incomes in pagination metadata
- **THEN** client can calculate total pages = ceil(total / limit)

### Requirement: Pagination metadata for incomes
All paginated income responses SHALL include pagination metadata with total count.

#### Scenario: Metadata structure
- **WHEN** system returns paginated incomes
- **THEN** response includes pagination object with:
  - total (number): total count of incomes
  - page (number): current page number (1-indexed)
  - limit (number): current page size
  - hasMore (boolean): true if more pages exist

#### Scenario: First page metadata
- **WHEN** user requests first page (no params)
- **THEN** pagination.page = 1
- **THEN** pagination.hasMore = (total > limit)

#### Scenario: Final page metadata
- **WHEN** user requests last page
- **THEN** pagination.hasMore = false
- **THEN** pagination.page = ceil(total / limit)

### Requirement: Offset pagination with filters
Pagination SHALL work correctly with income filters.

#### Scenario: Paginate filtered incomes
- **WHEN** user requests GET /api/budget/incomes?recurring_type=monthly&page=2&limit=10
- **THEN** system applies recurring_type filter first
- **THEN** system paginates filtered results
- **THEN** total count reflects filtered dataset

#### Scenario: Date range with pagination
- **WHEN** user requests GET /api/budget/incomes?start_date=2026-01-01&end_date=2026-01-31&page=1
- **THEN** system filters by date range
- **THEN** system paginates filtered results
- **THEN** pagination metadata reflects filtered total
