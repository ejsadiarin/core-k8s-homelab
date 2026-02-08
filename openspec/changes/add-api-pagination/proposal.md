## Why

The budget tracker currently loads all expenses and incomes without pagination, causing slow performance with large datasets. Dashboard and expense list pages experience noticeable delays when users have hundreds or thousands of records. Implementing pagination will improve load times, reduce memory usage, and provide better UX for users with extensive financial data.

## What Changes

- Add cursor-based pagination to expenses API (efficient for time-series data with frequent inserts)
- Add offset/limit pagination to incomes API (simpler for smaller datasets with less frequent changes)
- Update backend SQL queries to support pagination parameters and metadata
- Add pagination response metadata (total count, hasMore/nextCursor, page info)
- Update frontend hooks to support paginated data fetching with infinite scroll
- Add "Load More" UI components for expenses and incomes lists
- Implement React Query infinite query pattern for seamless pagination UX
- Add pagination params to API types (cursor, limit, offset, page)

## Capabilities

### New Capabilities

- `expense-pagination`: Cursor-based pagination for expense listings with timestamp-based cursors for efficient traversal of time-ordered data
- `income-pagination`: Offset/limit pagination for income listings with simpler page-based navigation suitable for smaller datasets

### Modified Capabilities

- `budget-expenses`: Update list endpoint to support cursor-based pagination parameters (cursor, limit) and return pagination metadata
- `budget-incomes`: Update list endpoint to support offset/limit pagination parameters (page, limit, offset) and return pagination metadata

## Impact

**Backend:**
- `sql/queries/budget.sql`: Add paginated versions of ListExpenses and ListIncomes queries
- `sql/queries/income.sql`: Add paginated query with offset/limit
- `handlers/budget.go`: Update expense and income list handlers to parse pagination params and return metadata
- `models/requests.go`: Add pagination request/response DTOs
- Swagger documentation updates for new query parameters

**Frontend:**
- `lib/api.ts`: Update fetchExpenses and fetchIncomes to accept pagination params
- `hooks/use-budget.ts`: Replace useExpenses and useIncomes with useInfiniteQuery pattern
- `types/api.ts`: Add PaginatedResponse, CursorPaginationParams, OffsetPaginationParams types
- `app/dashboard/budget/page.tsx`: Update to use infinite scroll with "Load More" button
- `app/dashboard/budget/expenses/page.tsx`: Update to use cursor pagination with "Load More" button

**Database:**
- Add indexes on `budget_expenses(user_id, expense_date DESC, id)` for efficient cursor pagination
- Add indexes on `budget_incomes(user_id, created_at DESC)` for efficient offset pagination

**Breaking Changes:**
- None - pagination parameters are optional; existing API calls without pagination params will return first page (backward compatible)
