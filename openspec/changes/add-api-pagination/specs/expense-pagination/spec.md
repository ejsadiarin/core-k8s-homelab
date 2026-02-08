## ADDED Requirements

### Requirement: Cursor-based pagination for expense listings
The system SHALL support cursor-based pagination for expense listings using expense_date and id as cursor keys.

#### Scenario: Request first page of expenses
- **WHEN** user requests GET /api/budget/expenses without cursor parameter
- **THEN** system returns first 20 expenses ordered by expense_date DESC, id ASC
- **THEN** response includes pagination metadata with hasMore and nextCursor

#### Scenario: Request subsequent page with cursor
- **WHEN** user requests GET /api/budget/expenses?cursor={base64_encoded_cursor}
- **THEN** system decodes cursor to extract (expense_date, id)
- **THEN** system returns next 20 expenses after cursor position
- **THEN** response includes updated pagination metadata

#### Scenario: Last page of expenses
- **WHEN** user requests page with cursor and no more results exist
- **THEN** system returns empty data array
- **THEN** pagination metadata shows hasMore=false and nextCursor=null

#### Scenario: Custom page size
- **WHEN** user requests GET /api/budget/expenses?limit=50
- **THEN** system returns up to 50 expenses per page
- **THEN** system validates limit ≤ 100 (max page size)

#### Scenario: Invalid cursor format
- **WHEN** user provides malformed cursor parameter
- **THEN** system returns 400 Bad Request with error message

#### Scenario: Cursor with filters
- **WHEN** user requests GET /api/budget/expenses?cursor={cursor}&category_id={id}
- **THEN** system applies filters and continues from cursor position
- **THEN** pagination works correctly with filtered dataset

#### Scenario: Concurrent inserts don't cause page drift
- **WHEN** user loads page 1 at time T1
- **WHEN** new expense is inserted at time T2 before expense_date of cursor
- **WHEN** user loads page 2 at time T3 using cursor from page 1
- **THEN** system returns expenses after cursor position (no duplicates)

### Requirement: Cursor encoding and stability
Cursors SHALL be base64-encoded JSON containing expense_date and id for stable pagination.

#### Scenario: Encode cursor
- **WHEN** system generates nextCursor for last expense on page
- **THEN** cursor contains {\"date\":\"2026-02-08\",\"id\":\"uuid\"}
- **THEN** cursor is base64 encoded before returning to client

#### Scenario: Decode cursor
- **WHEN** system receives base64 cursor from client
- **THEN** system decodes to JSON
- **THEN** system extracts date and id for WHERE clause

#### Scenario: Stable ordering with same-date expenses
- **WHEN** multiple expenses share same expense_date
- **THEN** system uses (expense_date, id) tuple for stable sort order
- **THEN** pagination never skips or duplicates records

### Requirement: Pagination metadata response
All paginated expense responses SHALL include pagination metadata.

#### Scenario: Metadata structure
- **WHEN** system returns paginated expenses
- **THEN** response includes pagination object with:
  - hasMore (boolean): true if more pages exist
  - nextCursor (string | null): base64 cursor for next page
  - limit (number): current page size

#### Scenario: First page metadata
- **WHEN** user requests first page (no cursor)
- **THEN** pagination.hasMore indicates if >20 total expenses exist
- **THEN** pagination.nextCursor contains cursor for page 2 if hasMore=true

#### Scenario: Final page metadata
- **WHEN** user requests page with no subsequent results
- **THEN** pagination.hasMore = false
- **THEN** pagination.nextCursor = null
