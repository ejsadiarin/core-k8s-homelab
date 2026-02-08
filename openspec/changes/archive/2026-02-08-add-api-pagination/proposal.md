## Why

The budget tracker currently loads all expenses and incomes without pagination, causing slow performance with large datasets. Dashboard and expense list pages experience noticeable delays when users have hundreds or thousands of records. Implementing pagination will improve load times, reduce memory usage, and provide better UX for users with extensive financial data.

## What Changes

- Add offset/limit pagination to expenses API with page number navigation
- Add offset/limit pagination to incomes API with page number navigation
- Update backend SQL queries to support pagination parameters (page, limit) and return metadata
- Add pagination response metadata (total count, page, limit, totalPages, hasMore)
- Update frontend hooks to support paginated data fetching
- Add Pagination UI component for page number navigation
- Add pagination params to API types (page, limit)

## Capabilities

### New Capabilities

- `expense-pagination`: Offset/limit pagination for expense listings with page number navigation
- `income-pagination`: Offset/limit pagination for income listings with page number navigation

### Modified Capabilities

- `budget-expenses`: Update list endpoint to support pagination parameters (page, limit) and return pagination metadata
- `budget-incomes`: Update list endpoint to support pagination parameters (page, limit) and return pagination metadata

## Impact

**Backend:**
- `models/pagination.go`: Add PaginationParams, OffsetPagination, PaginatedResponse DTOs
- `sql/queries/budget.sql`: Add paginated ListExpenses with LIMIT/OFFSET
- `sql/queries/income.sql`: Add paginated ListIncomes with LIMIT/OFFSET  
- `handlers/budget.go`: Update expense and income list handlers to parse pagination params and return metadata

**Frontend:**
- `lib/api.ts`: Update fetchExpenses and fetchIncomes to accept pagination params
- `hooks/use-budget.ts`: Update useExpenses and useIncomes to pass page/limit params
- `types/api.ts`: Add PaginatedResponse, OffsetPagination, PaginationParams types
- `components/ui/pagination.tsx`: Pagination component with page number buttons
- `app/dashboard/budget/expenses/page.tsx`: Update to use pagination with page buttons

**Database:**
- No additional indexes required - existing indexes sufficient for offset pagination

**Breaking Changes:**
- None - pagination parameters are optional; existing API calls without pagination params will return first page (backward compatible)

## Implementation Notes

The original design called for cursor-based pagination for expenses and offset-based for incomes. The actual implementation uses **offset-based pagination for both** with page number navigation UI, which:
- Is simpler to implement and maintain
- Works well for the expected data volumes
- Provides familiar page number UX
- Uses existing database indexes effectively
