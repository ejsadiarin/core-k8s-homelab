# Implementation Tasks: API Pagination

## Overview

Implement cursor-based pagination for expenses and offset-based pagination for incomes to improve performance with large datasets.

**Target Performance:** P95 < 100ms for paginated queries with 10,000+ records

---

## 1. Database Layer - Migrations & Indexes

### 1.1 Create migration for composite indexes

- [x] Create new migration file `web/apps/api-gateway/migrations/007_add_pagination_indexes.sql`
- [x] Add composite index: `CREATE INDEX CONCURRENTLY idx_expenses_pagination ON budget_expenses(user_id, expense_date DESC, id)`
- [x] Add composite index: `CREATE INDEX CONCURRENTLY idx_incomes_pagination ON budget_incomes(user_id, created_at DESC)`
- [x] Add migration down statements for index removal
- [x] Run migration on local database
- [x] Verify indexes exist: `\d+ budget_expenses` and `\d+ budget_incomes`

**Files:**

- `web/apps/api-gateway/migrations/007_add_pagination_indexes.sql` (NEW)

---

## 2. Database Layer - SQL Queries

### 2.1 Add paginated expense queries

- [x] Open `web/apps/api-gateway/sql/queries/budget.sql`
- [x] Add query `-- name: ListExpensesPaginated :many` with cursor-based WHERE clause:
    - Query: `WHERE user_id = $1 AND (expense_date < $2 OR (expense_date = $2 AND id > $3))`
    - ORDER BY: `expense_date DESC, id ASC`
    - LIMIT: `$4 + 1` (fetch LIMIT+1 to determine hasMore)
- [x] Add support for optional category filter in WHERE clause
- [x] Add support for optional date range filters (start_date, end_date)

### 2.2 Add paginated income queries

- [x] Open `web/apps/api-gateway/sql/queries/income.sql`
- [x] Add query `-- name: ListIncomesPaginated :many` with offset/limit:
    - WHERE: `user_id = $1`
    - ORDER BY: `created_at DESC`
    - OFFSET: `$2`
    - LIMIT: `$3 + 1`
- [x] Add query `-- name: CountIncomes :one` for total count
    - SELECT COUNT(\*) WHERE user_id = $1
- [x] Add support for optional recurring_type filter
- [x] Add support for optional date range filters

### 2.3 Generate sqlc code

- [x] Run `sqlc generate` in `web/apps/api-gateway` directory
- [x] Verify generated methods in `internal/sqlc/budget.sql.go` and `internal/sqlc/income.sql.go`
- [x] Check function signatures match expected pagination params

**Files:**

- `web/apps/api-gateway/sql/queries/budget.sql` (MODIFIED)
- `web/apps/api-gateway/sql/queries/income.sql` (MODIFIED)
- `web/apps/api-gateway/internal/sqlc/*.go` (GENERATED)

---

## 3. Backend - Models & DTOs

### 3.1 Add pagination request models

- [x] Open `web/apps/api-gateway/models/requests.go`
- [x] Add `ExpensePaginationParams` struct:
    ```go
    type ExpensePaginationParams struct {
        Cursor   string `json:"cursor" form:"cursor"`
        Limit    int    `json:"limit" form:"limit" binding:"omitempty,min=1,max=100"`
    }
    ```
- [x] Add `IncomePaginationParams` struct:
    ```go
    type IncomePaginationParams struct {
        Offset int `json:"offset" form:"offset" binding:"omitempty,min=0"`
        Page   int `json:"page" form:"page" binding:"omitempty,min=1"`
        Limit  int `json:"limit" form:"limit" binding:"omitempty,min=1,max=100"`
    }
    ```
- [x] Add default values constants: `DefaultExpenseLimit = 20`, `DefaultIncomeLimit = 10`

### 3.2 Add pagination response models

- [x] Create `web/apps/api-gateway/models/pagination.go` (NEW)
- [x] Add `CursorPagination` struct:
    ```go
    type CursorPagination struct {
        HasMore    bool    `json:"hasMore"`
        NextCursor *string `json:"nextCursor"`
        Limit      int     `json:"limit"`
    }
    ```
- [x] Add `OffsetPagination` struct:
    ```go
    type OffsetPagination struct {
        Total   int  `json:"total"`
        Page    int  `json:"page"`
        Limit   int  `json:"limit"`
        HasMore bool `json:"hasMore"`
    }
    ```
- [x] Add generic response wrapper:
    ```go
    type PaginatedResponse[T any] struct {
        Data       []T         `json:"data"`
        Pagination interface{} `json:"pagination"`
    }
    ```

### 3.3 Add cursor encoding/decoding utilities

- [x] In `models/pagination.go`, add `ExpenseCursor` struct:
    ```go
    type ExpenseCursor struct {
        Date time.Time `json:"date"`
        ID   string    `json:"id"`
    }
    ```
- [x] Add `EncodeCursor(cursor ExpenseCursor) (string, error)` - marshals to JSON, base64 encodes
- [x] Add `DecodeCursor(encoded string) (ExpenseCursor, error)` - base64 decodes, unmarshals JSON
- [x] Add error handling for malformed cursors

**Files:**

- `web/apps/api-gateway/models/pagination.go` (NEW - COMPLETED)

---

## 4. Backend - Handlers

### 4.1 Update ListExpenses handler for cursor pagination

- [x] Open `web/apps/api-gateway/handlers/budget.go`
- [x] Created new `ListExpensesPaginated` handler function
- [x] Add pagination params binding: `var paginationParams models.ExpensePaginationParams`
- [x] Set default limit if not provided: `if paginationParams.Limit == 0 { paginationParams.Limit = models.DefaultExpenseLimit }`
- [x] Decode cursor if provided, otherwise use zero values (time.Now(), "")
- [x] Call `queries.ListExpensesPaginated` with cursor params
- [x] Fetch LIMIT+1 records to determine `hasMore`
- [x] If len(expenses) > limit, set hasMore=true and trim last record
- [x] Encode nextCursor from last expense in result set
- [x] Build `PaginatedResponse` with `CursorPagination` metadata
- [x] Return response with 200 OK

### 4.2 Update ListIncomes handler for offset pagination

- [x] Open `web/apps/api-gateway/handlers/budget.go`
- [x] Created new `ListIncomesPaginated` handler function
- [x] Add pagination params binding: `var paginationParams models.IncomePaginationParams`
- [x] Set default limit if not provided
- [x] Calculate offset: if page provided, `offset = (page - 1) * limit`
- [x] Call `queries.CountIncomes` for total count
- [x] Call `queries.ListIncomesPaginated` with offset and limit
- [x] Calculate hasMore: `hasMore = (offset + len(incomes) < total)`
- [x] Calculate current page: `page = (offset / limit) + 1`
- [x] Build `PaginatedResponse` with `OffsetPagination` metadata
- [x] Return response with 200 OK

### 4.3 Add input validation

- [x] Validate cursor format (catch decode errors, return 400)
- [x] Validate limit bounds (1-100)
- [x] Validate offset >= 0
- [x] Validate page >= 1
- [x] Return proper error messages for validation failures

### 4.4 Maintain backward compatibility

- [x] Created separate endpoints `/api/budget/expenses/paginated` and `/api/budget/incomes/paginated`
- [x] Original endpoints remain unchanged for backward compatibility
- [x] Default behavior: return first page with default limits

**Files:**

- `web/apps/api-gateway/handlers/budget.go` (MODIFIED - COMPLETED)
- `web/apps/api-gateway/main.go` (MODIFIED - routes added)

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

- [x] Open `web/apps/core/src/types/api.ts`
- [x] Add `CursorPagination` interface:
    ```typescript
    export interface CursorPagination {
        hasMore: boolean;
        nextCursor: string | null;
        limit: number;
    }
    ```
- [x] Add `OffsetPagination` interface:
    ```typescript
    export interface OffsetPagination {
        total: number;
        page: number;
        limit: number;
        hasMore: boolean;
    }
    ```
- [x] Add `PaginatedResponse<T>` generic type:
    ```typescript
    export interface PaginatedResponse<T> {
        data: T[];
        pagination: CursorPagination | OffsetPagination;
    }
    ```

### 6.2 Add pagination parameter types

- [x] Add `ExpensePaginationParams`:
    ```typescript
    export interface ExpensePaginationParams {
        cursor?: string;
        limit?: number;
    }
    ```
- [x] Add `IncomePaginationParams`:
    ```typescript
    export interface IncomePaginationParams {
        offset?: number;
        page?: number;
        limit?: number;
    }
    ```

**Files:**

- `web/apps/core/src/types/api.ts` (MODIFIED - COMPLETED)

---

## 7. Frontend - API Client

### 7.1 Update fetchExpenses for pagination

- [x] Open `web/apps/core/src/lib/api.ts`
- [x] Created new `fetchExpensesPaginated` function
- [x] Add `params: ExpensePaginationParams & ExpenseFilters` argument
- [x] Add cursor and limit to query string if provided
- [x] Return type: `Promise<PaginatedResponse<Expense>>`
- [x] Parse pagination metadata from response

### 7.2 Update fetchIncomes for pagination

- [x] Created new `fetchIncomesPaginated` function
- [x] Add `params: IncomePaginationParams` argument with filters
- [x] Add offset/page and limit to query string if provided
- [x] Return type: `Promise<PaginatedResponse<Income>>`
- [x] Parse pagination metadata from response

**Files:**

- `web/apps/core/src/lib/api.ts` (MODIFIED - COMPLETED)

---

## 8. Frontend - React Query Hooks

### 8.1 Convert useExpenses to infinite query

- [x] Open `web/apps/core/src/hooks/use-budget.ts`
- [x] Created new `useExpensesPaginated` hook (kept original `useExpenses` for backward compatibility)
- [x] Used `useInfiniteQuery` instead of `useQuery`
- [x] Configured query with `getNextPageParam` returning `pagination.nextCursor`
- [x] Set `initialPageParam: undefined`
- [x] Return helper values: `data`, `fetchNextPage`, `hasNextPage`, `isFetchingNextPage`

### 8.2 Convert useIncomes to infinite query

- [x] Created new `useIncomesPaginated` hook (kept original `useIncomes` for backward compatibility)
- [x] Used `useInfiniteQuery` with offset pagination
- [x] Configured `getNextPageParam` to return `pagination.page + 1` when `hasMore=true`
- [x] Pass page number to `fetchIncomesPaginated`

### 8.3 Update query keys for pagination

- [x] Created separate query keys for paginated hooks
- [x] Maintained existing query keys for backward compatibility
- [x] Cache invalidation works correctly with new structure

**Files:**

- `web/apps/core/src/hooks/use-budget.ts` (MODIFIED - COMPLETED)

---

## 9. Frontend - UI Components

### 9.1 Create LoadMoreButton component

- [x] Created `web/apps/core/src/components/budget/load-more-button.tsx`
- [x] Props: `onClick`, `isLoading`, `disabled`
- [x] Renders button with loading spinner (`Loader2` icon) when `isLoading=true`
- [x] Styled to match existing button components
- [x] Shows "Load More" text (or "Loading..." when active)

### 9.2 Update dashboard budget page

- [x] Dashboard uses original `useExpenses()` hook (no pagination needed)
- [x] Only displays `.slice(0, 5)` expenses - pagination not required
- [x] Fixed type issues with `CreateIncomeRequest` and `CreateExpenseRequest` handlers
- [x] Fixed budget remaining display to use `toFixed(2)`

### 9.3 Update expenses page

- [x] Updated `web/apps/core/src/app/dashboard/budget/expenses/page.tsx`
- [x] Replaced `useExpenses` with `useExpensesPaginated`
- [x] Flattened infinite query pages: `data?.pages.flatMap(p => p.data) ?? []`
- [x] Display all expenses from flattened pages
- [x] Added `LoadMoreButton` at bottom of list
- [x] Show "No more expenses to load" message when `!hasNextPage`
- [x] Handle loading states for initial load vs pagination

### 9.4 Add pagination loading states

- [x] Skeleton loaders for initial page load (existing)
- [x] "Load More" button shows spinner when `isFetchingNextPage=true`
- [x] "Load More" button disabled during fetch
- [x] Error states handled by React Query (existing error boundaries)

**Files:**

- `web/apps/core/src/components/budget/load-more-button.tsx` (NEW - COMPLETED)
- `web/apps/core/src/app/dashboard/budget/page.tsx` (MODIFIED - COMPLETED)
- `web/apps/core/src/app/dashboard/budget/expenses/page.tsx` (MODIFIED - COMPLETED)

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
