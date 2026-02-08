## Context

The budget tracker currently has three UX issues that need addressing:

1. **Limited recurring income**: Only supports daily recurrence without end dates, making it inflexible for real-world scenarios (weekly/monthly salaries, time-bound contracts)
2. **Stale cache behavior**: Budget remaining uses 60s stale time, causing UI to show outdated values after adding/editing income or expenses
3. **Inconsistent UX patterns**: Income uses dialog pattern while expense uses full page, and budget remaining card uses unreadable color combinations when over budget

Current state:
- Backend: `incomes` table has `recurring_type` (only 'daily') and `start_date`, no end date support
- Frontend: Income form hardcoded to 'daily' only, React Query hooks use 60s staleTime for budget remaining
- Database: PostgreSQL with sqlc for type-safe queries, goose for migrations

Constraints:
- Must maintain backward compatibility with existing daily recurring incomes
- Cannot break existing API contracts (maintain same endpoint structure)
- Must follow existing patterns: sqlc for SQL, go-playground/validator for validation, shadcn/ui for components

## Goals / Non-Goals

**Goals:**
- Add weekly and monthly recurring income types with optional end dates
- Immediate cache invalidation when budget data changes (income/expense CRUD)
- Fix budget remaining card readability (proper color scheme for over-budget state)
- Unify expense creation UX with income pattern (dialog instead of page)
- Maintain backward compatibility with existing daily recurring incomes

**Non-Goals:**
- Complex recurring patterns (bi-weekly, quarterly, yearly) - out of scope for now
- Recurring expenses - only income gets this feature
- Changing the budget remaining calculation logic itself
- Migration of existing data - schema changes are additive only

## Decisions

### Decision 1: Database schema for end_date

**Choice:** Add nullable `end_date TIMESTAMP` column to `incomes` table

**Rationale:**
- Nullable allows both indefinite (NULL) and time-bound recurring income
- TIMESTAMP type matches existing `start_date` column for consistency
- Simple schema change with minimal migration risk

**Alternatives considered:**
- Separate table for recurring rules: Rejected - adds complexity for minimal benefit
- Store duration instead of end_date: Rejected - harder to query and display
- Use flags/boolean for indefinite: Rejected - NULL is more database-idiomatic

### Decision 2: Recurring type enum expansion

**Choice:** Extend existing enum to include 'weekly' and 'monthly' values

**Rationale:**
- Keeps validation at database level
- Type-safe in Go via sqlc generation
- Simple migration: `ALTER TYPE recurring_type ADD VALUE 'weekly'; ADD VALUE 'monthly'`

**Alternatives considered:**
- String field with application-level validation: Rejected - loses database type safety
- Separate boolean columns: Rejected - doesn't scale, harder to query

### Decision 3: Cache invalidation strategy

**Choice:** Invalidate `budgetRemaining` query key on all income/expense mutations

**Rationale:**
- React Query's `invalidateQueries` provides immediate, automatic refetch
- Already implemented for other mutations (expenses, stats) - consistent pattern
- No additional API calls needed, uses existing query infrastructure

**Implementation:**
```typescript
// In useCreateIncome, useUpdateIncome, useDeleteIncome:
onSuccess: () => {
  queryClient.invalidateQueries({ queryKey: budgetKeys.budgetRemaining() });
  queryClient.invalidateQueries({ queryKey: budgetKeys.incomes() });
  queryClient.invalidateQueries({ queryKey: budgetKeys.stats() });
}

// Same for expense mutations
```

**Alternatives considered:**
- Polling with reduced interval: Rejected - wastes resources, still has delay
- WebSocket real-time updates: Rejected - over-engineering for single-user budget app
- Optimistic updates: Rejected - complex calculation logic makes it error-prone

### Decision 4: Budget remaining color scheme fix

**Choice:** Use card background to indicate status, maintain text legibility

**Color scheme:**
- **Over budget (red status)**: `bg-red-50 text-red-900 border-red-200` (light red bg, dark red text)
- **On track (green status)**: `bg-green-50 text-green-900 border-green-200` (light green bg, dark green text)
- **Neutral (gray status)**: Keep existing `text-gray-600`

**Rationale:**
- Follows accessibility guidelines (WCAG AA contrast ratio)
- Consistent with shadcn/ui design system (uses -50 for bg, -900 for text)
- Visual hierarchy: status color is noticeable but not overwhelming

**Alternatives considered:**
- Use icons instead of color: Rejected - color provides faster visual scanning
- Remove color coding: Rejected - loses important at-a-glance status indication
- Invert current scheme (red bg, white text): Rejected - too alarming, accessibility concerns

### Decision 5: Expense creation dialog pattern

**Choice:** Convert `/dashboard/budget/expenses/new` page to dialog component, keep URL for deep linking

**Implementation approach:**
1. Create new `ExpenseFormDialog` component (mirrors `IncomeForm` pattern)
2. Keep route but render dialog instead of full page
3. Use Next.js intercepting routes pattern: `/dashboard/budget/@modal/(.)expenses/new`
4. Dialog auto-closes on success, redirects on direct navigation

**Rationale:**
- Maintains URL structure (bookmarkable, shareable links)
- Provides consistent UX with income workflow
- Next.js parallel routes enable both dialog and full page modes
- User can Cmd/Ctrl+click to open in new tab (full page), or click normally (dialog)

**Alternatives considered:**
- Delete page entirely, dialog only: Rejected - breaks deep linking and page refresh
- Keep both page and dialog separately: Rejected - code duplication
- Use query param (?modal=true): Rejected - doesn't leverage Next.js routing features

### Decision 6: Recurring income calculation for weekly/monthly

**Choice:** Backend SQL calculates prorated amounts based on recurring type

**Weekly calculation:**
```sql
-- Number of weeks from start to end (inclusive)
FLOOR((EXTRACT(EPOCH FROM end_date) - EXTRACT(EPOCH FROM start_date)) / 604800) + 1
-- Multiply by weekly amount
```

**Monthly calculation:**
```sql
-- Number of months from start to end
(EXTRACT(YEAR FROM end_date) - EXTRACT(YEAR FROM start_date)) * 12 
  + (EXTRACT(MONTH FROM end_date) - EXTRACT(MONTH FROM start_date)) + 1
-- Multiply by monthly amount
```

**Rationale:**
- Database calculates values for consistency and performance
- Matches existing daily calculation pattern
- Single source of truth (backend) prevents frontend/backend divergence

**Alternatives considered:**
- Frontend calculates: Rejected - inconsistent with daily pattern, harder to test
- Store individual occurrences: Rejected - explosion of rows for long-term recurring income

## Risks / Trade-offs

### Risk: Weekly/monthly calculation edge cases
**Description:** Month boundaries and partial periods could cause confusion (e.g., "monthly from Jan 31" on Feb 28)

**Mitigation:** 
- Use inclusive month count (start month to end month)
- Document behavior in UI tooltips
- Consider "day of month" alignment in future iteration if users request it

### Risk: Migration backward compatibility
**Description:** Existing daily recurring incomes might behave differently after schema change

**Mitigation:**
- Default `end_date` to NULL for all new and existing records
- NULL explicitly means "indefinite" in both old and new code
- Test migration on staging database with real data copy
- Add database constraint: `CHECK (recurring_type IS NULL OR start_date IS NOT NULL)`

### Risk: Cache invalidation race conditions
**Description:** Rapid successive mutations could cause stale reads between invalidation and refetch

**Mitigation:**
- React Query handles this automatically with request deduplication
- Mutations are sequential (button disabled during pending state)
- Worst case: user sees stale data for <100ms until refetch completes

### Trade-off: Deleted /expenses/new page route
**Impact:** Direct links to old page URL will no longer work after deployment

**Mitigation:**
- Use Next.js redirects in `next.config.js` to point old route to dialog version
- Add redirect from `/dashboard/budget/expenses/new` → `/dashboard/budget?action=add-expense`
- Dialog opens automatically via URL parameter detection

### Trade-off: Dialog vs page UX for mobile
**Impact:** Dialogs on mobile take full screen anyway, so benefit is reduced

**Mitigation:**
- Use shadcn/ui Dialog component which is responsive by default
- On mobile, dialog renders as full-screen overlay (acceptable UX)
- Maintain semantic difference: dialogs are non-blocking, pages are destinations

## Migration Plan

### Phase 1: Backend changes
1. Create migration: `ALTER TABLE incomes ADD COLUMN end_date TIMESTAMP NULL`
2. Create migration: `ALTER TYPE recurring_type ADD VALUE IF NOT EXISTS 'weekly'; ADD VALUE IF NOT EXISTS 'monthly'`
3. Update sqlc queries in `sql/queries/incomes.sql` to handle new fields
4. Run `sqlc generate` to regenerate Go types
5. Update `models/requests.go` to add `EndDate *time.Time` and expand `RecurringType`
6. Update handlers in `handlers/budget.go` to accept new fields (backward compatible)
7. Update Swagger docs with `swag init`

### Phase 2: Frontend types and hooks
1. Update `types/api.ts`: add `end_date?: string` to Income interface
2. Update `types/api.ts`: expand `RecurringType` to include 'weekly' | 'monthly'
3. Update `use-budget.ts`: add `budgetRemaining` to invalidation lists in income/expense mutations
4. Remove or reduce `staleTime` for `useBudgetRemaining` hook (from 60s to 0 or 5s)

### Phase 3: UI components
1. Update `income-form.tsx`:
   - Add weekly/monthly options to recurring type select
   - Add end_date input field (conditional on recurring type)
   - Add "Indefinite" checkbox or indicator when end_date is null
2. Update `page.tsx` (budget dashboard):
   - Fix budget remaining card colors (bg-red-50, text-red-900, etc.)
   - Add expense dialog state management
3. Create `expense-form-dialog.tsx` component
4. Update `/dashboard/budget/expenses/new/page.tsx` to render dialog instead

### Phase 4: Testing and deployment
1. Test migration on staging database
2. Verify existing daily recurring incomes still calculate correctly
3. Test new weekly/monthly incomes with various start/end dates
4. Verify cache invalidation works (budget remaining updates immediately)
5. Test mobile responsiveness of expense dialog
6. Deploy backend first (backward compatible)
7. Deploy frontend (uses new features)

### Rollback strategy
- Backend rollback: Revert migrations (down migrations provided)
- Frontend rollback: Revert commit, redeploy previous version
- Data rollback: `end_date` column can remain (NULL values are ignored by old code)
- No data loss: All changes are additive

## Open Questions

1. **UI indicator for indefinite income**: Should we show "∞" symbol, "Ongoing" badge, or just omit end date?
   - **Proposal**: Use badge with "Ongoing" text for clarity
   
2. **End date validation**: Should we prevent end_date < start_date at database or application level?
   - **Proposal**: Both - CHECK constraint in DB, validator in Go, validation in React form
   
3. **Budget remaining refetch behavior**: Should we show loading spinner during refetch or optimistic update?
   - **Proposal**: No spinner (uses cached data during background refetch per React Query defaults)

4. **Expense dialog route pattern**: Keep separate route or use query param?
   - **Proposal**: Use intercepting route pattern for best DX and UX
