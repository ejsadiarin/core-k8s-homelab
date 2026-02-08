## Context

The expenses page at `web/apps/core/src/app/dashboard/budget/expenses/page.tsx` has pagination that doesn't work - clicking page 2 always returns the same data as page 1.

## Goals / Non-Goals

**Goals:**
- Fix pagination to correctly fetch different pages of data
- Update items per page from 10 to 5
- Improve filter UI alignment
- Fix all TypeScript type errors
- Enhance Pagination component UX

**Non-Goals:**
- No changes to pagination strategy (offset-based is correct)
- No changes to database schema
- No new features or UI redesign

## Decisions

### Root Cause: Backend Struct Tag Bug

The `PaginationParams` struct in `models/pagination.go` used incorrect struct tags:

```go
// BEFORE (Bug):
type PaginationParams struct {
    Page  int `json:"page" form:"page" validate:"omitempty,min=1"`
    Limit int `json:"limit" form:"limit" validate:"omitempty,min=1,max=100"`
}

// AFTER (Fix):
type PaginationParams struct {
    Page  int `json:"page" query:"page" validate:"omitempty,min=1"`
    Limit int `json:"limit" query:"limit" validate:"omitempty,min=1,max=100"`
}
```

**Why this matters:**
- In Echo framework, `form` tags bind from POST form data (request body)
- `query` tags bind from URL query parameters (GET requests)
- The frontend sends `GET /api/budget/expenses?page=2&limit=5`
- Without `query` tags, page/limit were always 0, defaulting to page 1

### Frontend Fix: Use Local State for UI

The Pagination component was using `pagination.page` from the API response, which caused UI lag:

```tsx
// BEFORE (Bug):
<Pagination currentPage={pagination.page} ... />

// AFTER (Fix):
<Pagination currentPage={page} ... />  // Local React state
```

**Why this matters:**
- When user clicks page 2, `setPage(2)` updates immediately
- But UI showed `pagination.page` from stale API data
- Now UI updates instantly while data loads

### Type Fixes

- Changed `handleUpdate` parameter from `any` to `UpdateExpenseRequest`
- Added proper import for `UpdateExpenseRequest` from `@/types/api`

### UI Alignment

- Added `items-center` class to filter container for proper vertical alignment

### Pagination Component Enhancement

Enhanced `components/ui/pagination.tsx` with:
- First/last page buttons for large page counts
- Configurable sibling count
- Proper ARIA labels for accessibility
- Responsive design (hide first/last on mobile)
- Returns null when totalPages <= 1

## Risks / Trade-offs

**Risk: Breaking other endpoints using PaginationParams**
→ **Impact:** All endpoints using PaginationParams with GET requests were affected by the same bug. The fix benefits all of them.

**Trade-off: Immediate UI update vs waiting for data**
→ **Resolution:** Using local state for currentPage gives instant feedback; loading state shows data is refreshing.
