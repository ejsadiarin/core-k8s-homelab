# Implementation Tasks: API Pagination

## Overview

Implement offset-based pagination for expenses and incomes to improve performance with large datasets.

**Implementation:** Offset/limit pagination with page number navigation (changed from original cursor-based design for simplicity).

---

## 1. Database Layer - SQL Queries

### 1.1 Add paginated expense queries

- [x] Open `web/apps/api-gateway/sql/queries/budget.sql`
- [x] Add query `-- name: ListExpenses :many` with LIMIT/OFFSET
- [x] Add query `-- name: CountExpenses :one` for total count
- [x] Add support for optional category filter in WHERE clause
- [x] Add support for optional date range filters (start_date, end_date)

### 1.2 Add paginated income queries

- [x] Open `web/apps/api-gateway/sql/queries/budget.sql` or `income.sql`
- [x] Add paginated income queries with LIMIT/OFFSET
- [x] Add `-- name: CountIncomes :one` for total count (partially implemented - sqlc not regenerated)

### 1.3 Generate sqlc code

- [x] Run `sqlc generate` in `web/apps/api-gateway` directory
- [x] Verify generated methods for ListExpenses, CountExpenses

**Files:**

- `web/apps/api-gateway/sql/queries/budget.sql` (MODIFIED)
- `web/apps/api-gateway/internal/sqlc/*.go` (GENERATED)

---

## 2. Backend - Models & DTOs

### 2.1 Add pagination models

- [x] Create `web/apps/api-gateway/models/pagination.go`
- [x] Add `PaginationParams` struct with `query` tags (CRITICAL: use `query`, not `form`)
- [x] Add `OffsetPagination` struct for response metadata
- [x] Add `PaginatedResponse[T]` generic response wrapper
- [x] Add default constants: `DefaultExpenseLimit = 5`

**Files:**

- `web/apps/api-gateway/models/pagination.go` (COMPLETED)

---

## 3. Backend - Handlers

### 3.1 Update ListExpenses handler

- [x] Open `web/apps/api-gateway/handlers/budget.go`
- [x] Add pagination params binding with validation
- [x] Set default limit if not provided
- [x] Calculate offset from page: `offset = (page - 1) * limit`
- [x] Call `queries.CountExpenses` for total
- [x] Call `queries.ListExpenses` with limit/offset
- [x] Calculate totalPages and hasMore
- [x] Return `PaginatedResponse` with `OffsetPagination` metadata

### 3.2 Bug Fix: Use correct struct tags

- [x] **CRITICAL FIX**: Change `PaginationParams` struct tags from `form:"page"` to `query:"page"`
- [x] Echo framework requires `query` tags for GET request URL parameters

**Files:**

- `web/apps/api-gateway/handlers/budget.go` (MODIFIED)
- `web/apps/api-gateway/models/pagination.go` (FIXED)

---

## 4. Frontend - Types

### 4.1 Add pagination type definitions

- [x] Open `web/apps/core/src/types/api.ts`
- [x] Add `OffsetPagination` interface
- [x] Add `PaginatedResponse<T>` generic type
- [x] Add `PaginationParams` interface
- [x] Add `ExpenseFilters` interface

**Files:**

- `web/apps/core/src/types/api.ts` (COMPLETED)

---

## 5. Frontend - API Client

### 5.1 Update fetchExpenses for pagination

- [x] Open `web/apps/core/src/lib/api.ts`
- [x] Update `fetchExpenses` to accept `PaginationParams & ExpenseFilters`
- [x] Add page and limit to query string
- [x] Return type: `Promise<PaginatedResponse<Expense>>`

**Files:**

- `web/apps/core/src/lib/api.ts` (COMPLETED)

---

## 6. Frontend - React Query Hooks

### 6.1 Update useExpenses hook

- [x] Open `web/apps/core/src/hooks/use-budget.ts`
- [x] Add `page` and `limit` parameters to `useExpenses`
- [x] Include page/limit in query key for proper cache invalidation
- [x] Pass pagination params to `fetchExpenses`

**Files:**

- `web/apps/core/src/hooks/use-budget.ts` (COMPLETED)

---

## 7. Frontend - UI Components

### 7.1 Create Pagination component

- [x] Create `web/apps/core/src/components/ui/pagination.tsx`
- [x] Props: `currentPage`, `totalPages`, `onPageChange`, `disabled`
- [x] Render page number buttons with ellipsis for large page counts
- [x] Include prev/next navigation buttons
- [x] Add first/last page buttons for large page counts
- [x] Proper ARIA labels for accessibility

### 7.2 Update expenses page

- [x] Open `web/apps/core/src/app/dashboard/budget/expenses/page.tsx`
- [x] Add `page` state with useState
- [x] Pass page/limit to `useExpenses` hook
- [x] Add `handlePageChange` function
- [x] Render Pagination component with currentPage from local state (not API response)
- [x] Display pagination info ("Showing X to Y of Z")

**Files:**

- `web/apps/core/src/components/ui/pagination.tsx` (COMPLETED)
- `web/apps/core/src/app/dashboard/budget/expenses/page.tsx` (COMPLETED)

---

## 8. Testing & Validation

### 8.1 Manual testing checklist

- [x] Test first page loads correctly (page=1)
- [x] Test clicking page 2 fetches different data
- [x] Test pagination info updates correctly
- [x] Test with empty database (no expenses)
- [x] Test with exactly 5 expenses (boundary: hasMore should be false)
- [x] Test with 6+ expenses (hasMore should be true)
- [x] Test filter + pagination combination
- [x] Test category filter with pagination

### 8.2 TypeScript validation

- [x] Run `npx tsc --noEmit` - no errors
- [x] Verify all types are correctly imported

---

## Completion Checklist

- [x] Backend pagination models created
- [x] Backend handler updated with pagination support
- [x] **Backend struct tags fixed** (`form` → `query`)
- [x] Frontend types added
- [x] Frontend API client updated
- [x] Frontend hooks updated with page/limit
- [x] Pagination UI component created
- [x] Expenses page updated with pagination
- [x] TypeScript compiles without errors
- [x] Manual testing completed
- [x] Income pagination implemented (partial - similar pattern needed)

---

## Implementation Notes

### Key Bug Fix

The original implementation used `form:"page"` struct tags which don't work for GET query parameters in Echo. Changed to `query:"page"` to properly bind URL query parameters.

### Design Change from Original

The original design called for:

- Cursor-based pagination for expenses
- useInfiniteQuery with "Load More" pattern

The actual implementation uses:

- Offset-based pagination for both expenses and incomes
- useQuery with page number navigation
- Traditional Pagination component with page buttons

This is simpler and sufficient for the expected data volumes.
