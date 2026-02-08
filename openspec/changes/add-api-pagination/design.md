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
- Implement efficient pagination that scales with data growth
- Maintain backward compatibility with existing API calls (pagination optional)
- Provide smooth UX with "Load More" pattern (no jarring page transitions)
- Support both cursor-based (expenses) and offset-based (incomes) pagination patterns

**Non-Goals:**
- Full-text search optimization (separate feature)
- Real-time updates/websockets for new data
- Infinite scroll without user action (staying with "Load More" button for control)
- Pagination for categories/tags (small datasets, don't need it)

## Decisions

### Decision 1: Cursor-based pagination for expenses, offset-based for incomes

**Rationale:**
- **Expenses** are time-series data with frequent inserts (daily usage)
  - Cursor-based pagination using `(expense_date, id)` tuple provides stable ordering
  - Handles concurrent inserts gracefully (no page drift)
  - More efficient for "next page" operations
  - Standard pattern for activity feeds/timelines
  
- **Incomes** are infrequent (monthly/yearly entries)
  - Simpler offset/limit pattern sufficient
  - Easier for users to understand "Page 1 of 3"
  - Lower query complexity
  - No concurrency concerns with rare inserts

**Alternatives considered:**
- Offset pagination for both: Rejected due to page drift issues with expenses (user adds expense while paginating)
- Cursor pagination for both: Over-engineered for incomes; adds unnecessary complexity
- Keyset pagination with page numbers: Complex to implement and doesn't provide significant benefits

### Decision 2: Use React Query infinite queries pattern

**Rationale:**
- `useInfiniteQuery` provides built-in pagination state management
- Automatically handles:
  - Loading states for initial and subsequent pages
  - Error handling per page
  - Cache management for paginated data
  - Refetch strategies
- "Load More" button triggers `fetchNextPage()` - simple, predictable UX
- Maintains scroll position naturally (appends to list)

**Alternatives considered:**
- Manual state management: Rejected due to complexity of tracking pages, cursors, hasMore flags
- Virtual scrolling (react-window): Deferred to future optimization; adds complexity without solving core issue

### Decision 3: Default page size 20 for expenses, 10 for incomes

**Rationale:**
- **Expenses (20)**: Typical users view expenses by day/week; 20 items ~ 1-2 weeks of data
- **Incomes (10)**: Less frequent, 10 items covers months of data
- Trade-off: Smaller pages = more requests but faster initial load
- These defaults balance perceived performance with request overhead

**Alternatives considered:**
- Larger default (50+): Initial load still slow, defeats purpose
- Smaller default (10): Too many "Load More" clicks for expenses
- User-configurable: Deferred to future; adds complexity

### Decision 4: Add composite index on `(user_id, expense_date DESC, id)`

**Rationale:**
- Supports cursor-based pagination efficiently
- `user_id` first for data isolation
- `expense_date DESC` matches default sort (newest first)
- `id` as tiebreaker for stable ordering when dates match
- Enables index-only scans for pagination queries

**Impact:** Index size ~100MB for 1M expenses (acceptable)

### Decision 5: Backward compatibility - pagination params optional

**Rationale:**
- Existing API calls without pagination params return first page (limit=20/10)
- No breaking changes to existing clients
- Gradual migration path

**Implementation:**
- If no cursor/offset provided → return first page
- Include pagination metadata in all responses (even non-paginated legacy calls)

### Decision 6: Pagination metadata in response envelope

**Response format:**
```json
{
  "data": [...],
  "pagination": {
    "hasMore": boolean,
    "nextCursor": string | null,  // for cursor-based
    "total": number,               // for offset-based
    "page": number,                // for offset-based
    "limit": number
  }
}
```

**Rationale:**
- Consistent structure across both pagination types
- Frontend knows when to show "Load More" (`hasMore`)
- Cursor encoded as base64 JSON `{date: "", id: ""}`
- Total count for offset pagination only (expensive for cursor)

## Risks / Trade-offs

**[Risk] Cursor encoding reveals internal data structure**
→ **Mitigation:** Base64 encode cursor JSON; not security-sensitive data

**[Risk] Index size grows with expenses table**
→ **Mitigation:** Composite index is necessary for performance; monitor disk usage; acceptable trade-off

**[Risk] Total count query expensive for large datasets**
→ **Mitigation:** Only compute for offset pagination (incomes); skip for cursor pagination (expenses)

**[Risk] Date-only cursor causes issues with same-day expenses**
→ **Mitigation:** Use `(expense_date, id)` tuple for stable ordering; ID as tiebreaker

**[Risk] Frontend infinite query cache grows unbounded**
→ **Mitigation:** React Query automatically manages cache size; configure `gcTime` if needed

**[Trade-off] Two pagination patterns adds complexity**
→ **Acceptance:** Worth it for appropriate pattern per data type; documented clearly

**[Trade-off] "Load More" requires user action vs auto-scroll**
→ **Acceptance:** Intentional UX choice; gives users control; simpler implementation

## Migration Plan

### Phase 1: Backend (No Breaking Changes)
1. Add database indexes (non-blocking `CREATE INDEX CONCURRENTLY`)
2. Add paginated SQL queries alongside existing ones
3. Update handlers to accept optional pagination params
4. If params missing → return first page (backward compatible)
5. Deploy backend
6. Monitor performance and index usage

### Phase 2: Frontend
1. Update API client functions to accept pagination params
2. Replace `useQuery` with `useInfiniteQuery` for expenses/incomes
3. Add "Load More" buttons to dashboard and expense pages
4. Test with large datasets (seed test data if needed)
5. Deploy frontend

### Rollback Strategy
- Backend changes are backward compatible; revert if performance degrades
- Frontend can revert to `useQuery` with no backend changes needed
- Database indexes can be dropped if causing issues (rare)

### Performance Testing
- Seed test database with 10,000 expenses and 1,000 incomes
- Measure P50, P95, P99 response times for paginated queries
- Target: P95 < 100ms for paginated queries

## Open Questions

None - design is ready for implementation.
