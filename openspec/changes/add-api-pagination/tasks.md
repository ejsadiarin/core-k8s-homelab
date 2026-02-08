# Implementation Tasks: API Pagination

## Overview
Implement cursor-based pagination for expenses and offset-based pagination for incomes to improve performance with large datasets.

**Target Performance:** P95 < 100ms for paginated queries with 10,000+ records

---

## 1. Database Layer - Migrations & Indexes

### 1.1 Create migration for composite indexes
- [ ] Create new migration file `web/apps/api-gateway/migrations/007_add_pagination_indexes.sql`
- [ ] Add composite index: `CREATE INDEX CONCURRENTLY idx_expenses_pagination ON budget_expenses(user_id, expense_date DESC, id)`
- [ ] Add composite index: `CREATE INDEX CONCURRENTLY idx_incomes_pagination ON budget_incomes(user_id, created_at DESC)`
- [ ] Add migration down statements for index removal
- [ ] Run migration on local database
- [ ] Verify indexes exist: `\d+ budget_expenses` and `\d+ budget_incomes`

**Files:**
- `web/apps/api-gateway/migrations/007_add_pagination_indexes.sql` (NEW)

---

## 2. Database Layer - SQL Queries

### 2.1 Add paginated expense queries
- [ ] Open `web/apps/api-gateway/sql/queries/budget.sql`
- [ ] Add query `-- name: ListExpensesPaginated :many` with cursor-based WHERE clause:
  - Query: `WHERE user_id = $1 AND (expense_date < $2 OR (expense_date = $2 AND id > $3))`
  - ORDER BY: `expense_date DESC, id ASC`
  - LIMIT: `$4 + 1` (fetch LIMIT+1 to determine hasMore)
- [ ] Add support for optional category filter in WHERE clause
- [ ] Add support for optional date range filters (start_date, end_date)

### 2.2 Add paginated income queries
- [ ] Open `web/apps/api-gateway/sql/queries/income.sql`
- [ ] Add query `-- name: ListIncomesPaginated :many` with offset/limit:
  - WHERE: `user_id = $1`
  - ORDER BY: `created_at DESC`
  - OFFSET: `$2`
  - LIMIT: `$3 + 1`
- [ ] Add query `-- name: CountIncomes :one` for total count
  - SELECT COUNT(*) WHERE user_id = $1
- [ ] Add support for optional recurring_type filter
- [ ] Add support for optional date range filters

### 2.3 Generate sqlc code
- [ ] Run `sqlc generate` in `web/apps/api-gateway` directory
- [ ] Verify generated methods in `internal/sqlc/budget.sql.go` and `internal/sqlc/income.sql.go`
- [ ] Check function signatures match expected pagination params

**Files:**
- `web/apps/api-gateway/sql/queries/budget.sql` (MODIFIED)
- `web/apps/api-gateway/sql/queries/income.sql` (MODIFIED)
- `web/apps/api-gateway/internal/sqlc/*.go` (GENERATED)

---

## 3. Backend - Models & DTOs

### 3.1 Add pagination request models
- [ ] Open `web/apps/api-gateway/models/requests.go`
- [ ] Add `ExpensePaginationParams` struct:
  ```go
  type ExpensePaginationParams struct {
      Cursor   string `json:"cursor" form:"cursor"`
      Limit    int    `json:"limit" form:"limit" binding:"omitempty,min=1,max=100"`
  }
  ```
- [ ] Add `IncomePaginationParams` struct:
  ```go
  type IncomePaginationParams struct {
      Offset int `json:"offset" form:"offset" binding:"omitempty,min=0"`
      Page   int `json:"page" form:"page" binding:"omitempty,min=1"`
      Limit  int `json:"limit" form:"limit" binding:"omitempty,min=1,max=100"`
  }
  ```
- [ ] Add default values constants: `DefaultExpenseLimit = 20`, `DefaultIncomeLimit = 10`

### 3.2 Add pagination response models
- [ ] Create `web/apps/api-gateway/models/pagination.go` (NEW)
- [ ] Add `CursorPagination` struct:
  ```go
  type CursorPagination struct {
      HasMore    bool    `json:"hasMore"`
      NextCursor *string `json:"nextCursor"`
      Limit      int     `json:"limit"`
  }
  ```
- [ ] Add `OffsetPagination` struct:
  ```go
  type OffsetPagination struct {
      Total   int  `json:"total"`
      Page    int  `json:"page"`
      Limit   int  `json:"limit"`
      HasMore bool `json:"hasMore"`
  }
  ```
- [ ] Add generic response wrapper:
  ```go
  type PaginatedResponse[T any] struct {
      Data       []T         `json:"data"`
      Pagination interface{} `json:"pagination"`
  }
  ```

### 3.3 Add cursor encoding/decoding utilities
- [ ] In `models/pagination.go`, add `ExpenseCursor` struct:
  ```go
  type ExpenseCursor struct {
      Date time.Time `json:"date"`
      ID   string    `json:"id"`
  }
  ```
- [ ] Add `EncodeCursor(cursor ExpenseCursor) (string, error)` - marshals to JSON, base64 encodes
- [ ] Add `DecodeCursor(encoded string) (ExpenseCursor, error)` - base64 decodes, unmarshals JSON
- [ ] Add error handling for malformed cursors

**Files:**
- `web/apps/api-gateway/models/requests.go` (MODIFIED)
- `web/apps/api-gateway/models/pagination.go` (NEW)

---

## 4. Backend - Handlers

### 4.1 Update ListExpenses handler for cursor pagination
- [ ] Open `web/apps/api-gateway/handlers/budget.go`
- [ ] Find `ListExpenses` handler function
- [ ] Add pagination params binding: `var paginationParams models.ExpensePaginationParams`
- [ ] Set default limit if not provided: `if paginationParams.Limit == 0 { paginationParams.Limit = models.DefaultExpenseLimit }`
- [ ] Decode cursor if provided, otherwise use zero values (time.Now(), "")
- [ ] Call `queries.ListExpensesPaginated` with cursor params
- [ ] Fetch LIMIT+1 records to determine `hasMore`
- [ ] If len(expenses) > limit, set hasMore=true and trim last record
- [ ] Encode nextCursor from last expense in result set
- [ ] Build `PaginatedResponse` with `CursorPagination` metadata
- [ ] Return response with 200 OK

### 4.2 Update ListIncomes handler for offset pagination
- [ ] Open `web/apps/api-gateway/handlers/budget.go` (or separate income handler file)
- [ ] Find `ListIncomes` handler function
- [ ] Add pagination params binding: `var paginationParams models.IncomePaginationParams`
- [ ] Set default limit if not provided
- [ ] Calculate offset: if page provided, `offset = (page - 1) * limit`
- [ ] Call `queries.CountIncomes` for total count
- [ ] Call `queries.ListIncomesPaginated` with offset and limit
- [ ] Calculate hasMore: `hasMore = (offset + len(incomes) < total)`
- [ ] Calculate current page: `page = (offset / limit) + 1`
- [ ] Build `PaginatedResponse` with `OffsetPagination` metadata
- [ ] Return response with 200 OK

### 4.3 Add input validation
- [ ] Validate cursor format (catch decode errors, return 400)
- [ ] Validate limit bounds (1-100)
- [ ] Validate offset >= 0
- [ ] Validate page >= 1
- [ ] Return proper error messages for validation failures

### 4.4 Maintain backward compatibility
- [ ] Ensure handlers work when NO pagination params provided
- [ ] Default behavior: return first page with default limits
- [ ] Include pagination metadata in all responses (legacy calls too)

**Files:**
- `web/apps/api-gateway/handlers/budget.go` (MODIFIED)

---

## 5. Backend - Testing

### 5.1 Unit tests for cursor encoding/decoding
- [ ] Create `web/apps/api-gateway/models/pagination_test.go`
- [ ] Test `EncodeCursor` produces valid base64 JSON
- [ ] Test `DecodeCursor` correctly decodes valid cursor
- [ ] Test `DecodeCursor` returns error for malformed base64
- [ ] Test `DecodeCursor` returns error for invalid JSON
- [ ] Test round-trip encoding/decoding preserves data

### 5.2 Integration tests for expense pagination
- [ ] Create/update `web/apps/api-gateway/handlers/budget_test.go`
- [ ] Test first page request (no cursor) returns default limit
- [ ] Test subsequent page request with cursor
- [ ] Test hasMore=true when more pages exist
- [ ] Test hasMore=false on last page
- [ ] Test custom limit parameter
- [ ] Test pagination with category filter
- [ ] Test pagination with date range filter
- [ ] Test invalid cursor returns 400
- [ ] Test limit > 100 returns 400

### 5.3 Integration tests for income pagination
- [ ] Test first page request (no params) returns default limit
- [ ] Test page parameter calculates correct offset
- [ ] Test offset parameter works correctly
- [ ] Test total count is accurate
- [ ] Test hasMore calculation
- [ ] Test pagination with recurring_type filter
- [ ] Test invalid page/offset returns 400

### 5.4 Database performance tests
- [ ] Seed test database with 10,000 expenses
- [ ] Seed test database with 1,000 incomes
- [ ] Run `EXPLAIN ANALYZE` on paginated expense query
- [ ] Verify index `idx_expenses_pagination` is used
- [ ] Run `EXPLAIN ANALYZE` on paginated income query
- [ ] Verify index `idx_incomes_pagination` is used
- [ ] Measure query times: target P95 < 100ms
- [ ] Test concurrent insert scenario (no page drift for cursor pagination)

**Files:**
- `web/apps/api-gateway/models/pagination_test.go` (NEW)
- `web/apps/api-gateway/handlers/budget_test.go` (MODIFIED)

---

## 6. Frontend - Types

### 6.1 Add pagination type definitions
- [ ] Open `web/apps/core/src/types/api.ts`
- [ ] Add `CursorPagination` interface:
  ```typescript
  export interface CursorPagination {
    hasMore: boolean;
    nextCursor: string | null;
    limit: number;
  }
  ```
- [ ] Add `OffsetPagination` interface:
  ```typescript
  export interface OffsetPagination {
    total: number;
    page: number;
    limit: number;
    hasMore: boolean;
  }
  ```
- [ ] Add `PaginatedResponse<T>` generic type:
  ```typescript
  export interface PaginatedResponse<T> {
    data: T[];
    pagination: CursorPagination | OffsetPagination;
  }
  ```

### 6.2 Add pagination parameter types
- [ ] Add `ExpensePaginationParams`:
  ```typescript
  export interface ExpensePaginationParams {
    cursor?: string;
    limit?: number;
  }
  ```
- [ ] Add `IncomePaginationParams`:
  ```typescript
  export interface IncomePaginationParams {
    offset?: number;
    page?: number;
    limit?: number;
  }
  ```

**Files:**
- `web/apps/core/src/types/api.ts` (MODIFIED)

---

## 7. Frontend - API Client

### 7.1 Update fetchExpenses for pagination
- [ ] Open `web/apps/core/src/lib/api.ts`
- [ ] Find `fetchExpenses` function
- [ ] Add `params: ExpensePaginationParams` argument
- [ ] Add cursor and limit to query string if provided
- [ ] Update return type to `Promise<PaginatedResponse<Expense>>`
- [ ] Parse pagination metadata from response

### 7.2 Update fetchIncomes for pagination
- [ ] Find `fetchIncomes` function
- [ ] Add `params: IncomePaginationParams` argument
- [ ] Add offset/page and limit to query string if provided
- [ ] Update return type to `Promise<PaginatedResponse<Income>>`
- [ ] Parse pagination metadata from response

**Files:**
- `web/apps/core/src/lib/api.ts` (MODIFIED)

---

## 8. Frontend - React Query Hooks

### 8.1 Convert useExpenses to infinite query
- [ ] Open `web/apps/core/src/hooks/use-budget.ts`
- [ ] Find `useExpenses` hook
- [ ] Replace `useQuery` with `useInfiniteQuery`
- [ ] Configure query:
  ```typescript
  useInfiniteQuery({
    queryKey: budgetKeys.expensesList(filters),
    queryFn: ({ pageParam }) => fetchExpenses({ cursor: pageParam, limit: 20, ...filters }),
    getNextPageParam: (lastPage) => {
      const pagination = lastPage.pagination as CursorPagination;
      return pagination.hasMore ? pagination.nextCursor : undefined;
    },
    initialPageParam: undefined
  })
  ```
- [ ] Return helper values: `expenses` (flattened pages), `fetchNextPage`, `hasNextPage`, `isFetchingNextPage`

### 8.2 Convert useIncomes to infinite query
- [ ] Find `useIncomes` hook
- [ ] Replace `useQuery` with `useInfiniteQuery`
- [ ] Configure query similar to expenses but with offset pagination:
  ```typescript
  getNextPageParam: (lastPage) => {
    const pagination = lastPage.pagination as OffsetPagination;
    return pagination.hasMore ? pagination.page + 1 : undefined;
  }
  ```
- [ ] Pass page number to `fetchIncomes`

### 8.3 Update query keys for pagination
- [ ] Update `budgetKeys` to support paginated queries
- [ ] Ensure cache invalidation works correctly with new structure

**Files:**
- `web/apps/core/src/hooks/use-budget.ts` (MODIFIED)

---

## 9. Frontend - UI Components

### 9.1 Create LoadMoreButton component
- [ ] Create `web/apps/core/src/components/budget/LoadMoreButton.tsx` (NEW)
- [ ] Props: `onClick`, `isLoading`, `disabled`
- [ ] Render button with loading spinner when `isLoading=true`
- [ ] Style to match existing button components
- [ ] Add "Load More" text (or "Loading..." when active)

### 9.2 Update dashboard budget page
- [ ] Open `web/apps/core/src/app/dashboard/budget/page.tsx`
- [ ] Update to use `useInfiniteQuery` version of `useExpenses`
- [ ] Flatten pages: `const expenses = expenseQuery.data?.pages.flatMap(p => p.data) ?? []`
- [ ] Keep existing `.slice(0, 5)` for display
- [ ] Add "Load More" button below expense list (if hasNextPage)
- [ ] Call `fetchNextPage()` on button click
- [ ] Show loading state when `isFetchingNextPage=true`
- [ ] Repeat for incomes section

### 9.3 Update expenses page
- [ ] Open `web/apps/core/src/app/dashboard/budget/expenses/page.tsx`
- [ ] Update to use infinite query
- [ ] Display all expenses from flattened pages
- [ ] Add LoadMoreButton at bottom of list
- [ ] Show "No more expenses" message when `!hasNextPage`
- [ ] Handle loading states for initial load vs pagination

### 9.4 Add pagination loading states
- [ ] Show skeleton loaders for initial page load
- [ ] Show inline spinner for "Load More" button when fetching next page
- [ ] Disable "Load More" button during fetch
- [ ] Handle error states gracefully

**Files:**
- `web/apps/core/src/components/budget/LoadMoreButton.tsx` (NEW)
- `web/apps/core/src/app/dashboard/budget/page.tsx` (MODIFIED)
- `web/apps/core/src/app/dashboard/budget/expenses/page.tsx` (MODIFIED)

---

## 10. Documentation & API Specs

### 10.1 Update Swagger/OpenAPI docs
- [ ] Update expense list endpoint documentation with pagination params
- [ ] Document `cursor` query param (string, optional)
- [ ] Document `limit` query param (number, 1-100, default 20)
- [ ] Update response schema to include `CursorPagination`
- [ ] Repeat for income endpoint with offset/page params
- [ ] Add example requests/responses for paginated calls
- [ ] Run `swag init` to regenerate docs (if using swaggo)

### 10.2 Update API README
- [ ] Document pagination patterns (cursor vs offset)
- [ ] Provide example API calls with curl
- [ ] Explain cursor encoding format
- [ ] Document default limits and max limits

**Files:**
- `web/apps/api-gateway/docs/*.go` (MODIFIED - if using swaggo annotations)
- API documentation markdown files (if they exist)

---

## 11. Testing & Validation

### 11.1 End-to-end testing
- [ ] Seed staging database with large dataset (10,000+ expenses)
- [ ] Test complete flow: load first page → click Load More → verify second page loads
- [ ] Test with network throttling (3G) to verify performance improvement
- [ ] Test pagination with various filters (category, date range)
- [ ] Verify no duplicate expenses appear across pages
- [ ] Test concurrent insert scenario: add expense while paginating, verify no duplicates

### 11.2 Performance validation
- [ ] Measure Time To First Byte (TTFB) for paginated requests
- [ ] Compare before/after: full dataset load vs first page
- [ ] Verify P95 latency < 100ms for paginated queries
- [ ] Monitor database query execution times
- [ ] Check index usage with `EXPLAIN ANALYZE`

### 11.3 Manual testing checklist
- [ ] Test on Dashboard: verify first 5 expenses load quickly
- [ ] Click "Load More" on dashboard, verify next 20 load
- [ ] Navigate to Expenses page, verify pagination works
- [ ] Test with empty database (no expenses/incomes)
- [ ] Test with exactly 20 expenses (boundary: hasMore should be false)
- [ ] Test with 21 expenses (boundary: hasMore should be true)
- [ ] Test filter + pagination combination
- [ ] Test browser back/forward buttons maintain state

### 11.4 Rollback testing
- [ ] Test backward compatibility: call API without pagination params
- [ ] Verify response includes pagination metadata even for legacy calls
- [ ] Verify old frontend code (if not updated yet) still works

---

## 12. Deployment

### 12.1 Backend deployment
- [ ] Run database migration to add indexes (non-blocking)
- [ ] Verify indexes created successfully in production
- [ ] Deploy updated backend API with pagination support
- [ ] Monitor API response times and error rates
- [ ] Verify no increase in 500 errors

### 12.2 Frontend deployment
- [ ] Build frontend with pagination support
- [ ] Deploy to staging environment
- [ ] Smoke test on staging
- [ ] Deploy to production
- [ ] Monitor user interactions with "Load More" buttons

### 12.3 Rollback plan
- [ ] Document rollback steps for frontend (revert to previous build)
- [ ] Document rollback steps for backend (revert to previous version)
- [ ] Indexes can remain (won't harm performance)
- [ ] Prepare quick rollback if issues detected

---

## Completion Checklist

- [ ] All backend tests pass
- [ ] All frontend tests pass (if applicable)
- [ ] Database indexes verified in production
- [ ] API response times meet target (P95 < 100ms)
- [ ] No page drift issues observed
- [ ] Pagination works with all existing filters
- [ ] Documentation updated
- [ ] Code reviewed and approved
- [ ] Deployed to production
- [ ] Monitoring shows improved performance

---

## Success Metrics

**Before:**
- Full expense list load: 2-5 seconds (1000+ records)
- Initial page render blocked on full dataset

**After:**
- First page load: <500ms (20 records)
- Subsequent pages: <200ms
- P95 API latency: <100ms
- User can interact with UI immediately (first page)

**Implementation estimate:** 2-3 days
