## Context

The budget tracker currently loads all expenses and incomes without pagination. With hundreds or thousands of records, this causes:
- Slow initial page loads (multi-second delays)
- High memory usage on both backend and frontend
- Poor UX as users wait for complete dataset fetch
- Unnecessary database load fetching unused records

Current implementation:
- Backend: `ListExpenses` and `ListIncomes` return all records for a user with optional filters
- Frontend: React Query fetches complete datasets and caches them
- Dashboard shows `.slice(0, 5)` but fetches everything
- Expenses page renders full list but loads entire dataset upfront

## Goals / Non-Goals

**Goals:**
- Reduce initial load time for expense and income lists to <500ms even with 10,000+ records
- Implement pagination that scales with data growth
- Maintain backward compatibility with existing API calls (pagination optional)
- Provide familiar page number navigation UX
- Support offset-based pagination for both expenses and incomes

**Non-Goals:**
- Full-text search optimization (separate feature)
- Real-time updates/websockets for new data
- Infinite scroll / "Load More" pattern (using traditional page navigation instead)
- Cursor-based pagination (offset-based is sufficient for expected data volumes)
- Pagination for categories/tags (small datasets, don't need it)

## Decisions

### Decision 1: Offset-based pagination for both expenses and incomes

**Rationale:**
- Simpler implementation and maintenance
- Familiar UX with page numbers (1, 2, 3... N)
- Works well for expected data volumes (<100k records per user)
- Allows direct navigation to any page
- Existing database indexes are sufficient

**Original Design Consideration:**
The original design proposed cursor-based pagination for expenses to handle concurrent inserts gracefully. However, offset-based pagination was implemented because:
- Concurrent insert scenarios are rare in practice
- Users typically view recent expenses, not archive data
- Page number navigation is more intuitive
- Simpler frontend implementation with useQuery vs useInfiniteQuery

### Decision 2: Use React Query useQuery with page state

**Rationale:**
- `useQuery` provides simple pagination state management
- Query key includes page/limit for proper cache management
- Page numbers displayed in Pagination component
- Users can navigate directly to any page

**Implementation:**
```typescript
const { data } = useExpenses(filters, page, limit);
// Query key: [...expensesList(filters), page, limit]
```

### Decision 3: Default page size 5 for expenses

**Rationale:**
- Compact view shows more context per page
- Faster page loads
- Mobile-friendly display
- Users can see full expense cards without scrolling

### Decision 4: Pagination metadata response

**Response format:**
```json
{
  "data": [...],
  "pagination": {
    "total": 150,
    "page": 1,
    "limit": 5,
    "totalPages": 30,
    "hasMore": true
  }
}
```

### Decision 5: Use `query` struct tags for URL parameters

**Critical implementation detail:**
Go Echo framework requires `query:"param"` struct tags for GET request query parameters, not `form:"param"`. The `form` tag is for POST form data.

```go
// CORRECT - for GET query params
type PaginationParams struct {
    Page  int `json:"page" query:"page"`
    Limit int `json:"limit" query:"limit"`
}

// INCORRECT - this was the bug!
type PaginationParams struct {
    Page  int `json:"page" form:"page"`
    Limit int `json:"limit" form:"limit"`
}
```

## Risks / Trade-offs

**[Trade-off] Offset pagination vs cursor pagination**
→ **Acceptance:** Offset is simpler and sufficient for expected data volumes. If concurrent insert issues arise, can migrate to cursor-based later.

**[Risk] Page drift with concurrent inserts**
→ **Mitigation:** Low risk for expense tracking app. Users typically view recent data. If needed, can add created_at stability.

**[Risk] Large offset performance degradation**
→ **Mitigation:** Most users won't have >1000 pages. Can optimize with keyset pagination if needed later.

## Implementation Summary

### Backend
- `models/pagination.go`: PaginationParams, OffsetPagination, PaginatedResponse
- `sql/queries/budget.sql`: ListExpenses with LIMIT/OFFSET and CountExpenses
- `handlers/budget.go`: ListExpenses handler with pagination support

### Frontend
- `types/api.ts`: OffsetPagination, PaginatedResponse, PaginationParams types
- `lib/api.ts`: fetchExpenses with page/limit query params
- `hooks/use-budget.ts`: useExpenses with page/limit in query key
- `components/ui/pagination.tsx`: Page number navigation component
- `app/dashboard/budget/expenses/page.tsx`: Page state management and Pagination component
