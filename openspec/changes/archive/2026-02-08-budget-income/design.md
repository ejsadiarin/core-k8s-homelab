## Context

The budget tracker currently tracks only expenses, providing users with spending history and categorization. The system is built with:
- **Backend**: Go with Echo framework, PostgreSQL with sqlc for type-safe queries, Goose migrations
- **Frontend**: Next.js 14+, React Query for data fetching, shadcn/ui components
- **Auth**: Session-based authentication with RBAC (guest/user/admin roles)
- **User isolation**: All budget data (categories, tags, expenses) already scoped by user_id

Users need to track income alongside expenses to assess overall budget health. The system needs to support both one-time income entries and recurring daily income rules, then calculate budget remaining (income - expenses) with visual indicators.

## Goals / Non-Goals

**Goals:**
- Add income management with one-time and recurring daily support
- Calculate budget remaining as running total (total income - total expenses)
- Replace "Period" stat card with "Budget Remaining" card showing green/red/neutral status
- Add visual indicators (+/- prefix) on expense/income amounts
- Support date filtering to view budget status for specific days
- Maintain user isolation (guest/users/admin access controls)

**Non-Goals:**
- Weekly/monthly/yearly recurring income patterns (only daily recurring supported)
- Income categories or tags (no categorization needed for income)
- Historical budget remaining snapshots (always calculated on-the-fly)
- Income editing for past periods (current and future only)

## Decisions

### Database Schema: Single `budget_incomes` table with recurring_type field

**Decision:** Store both one-time and recurring incomes in a single table with a `recurring_type` enum field.

**Rationale:**
- One-time entries: `recurring_type = NULL`
- Recurring daily: `recurring_type = 'daily'` with `start_date` indicating when recurring begins
- Single table simplifies queries and migrations vs separate tables
- Follows existing `budget_expenses` pattern (single table for all expenses)

**Alternative considered:** Separate `budget_incomes` and `budget_incomes_recurring` tables
- Rejected: Would require JOINs for income listing, adds complexity for minimal benefit

### Recurring Income Calculation: Application-layer prorated calculation

**Decision:** Calculate recurring income in the handler/service layer, not via generated SQL queries.

**Rationale:**
- Prorated calculation (amount × days) is application logic, not simple aggregation
- sqlc generates type-safe SQL but doesn't support dynamic date arithmetic easily
- Allows testing business logic independently
- Follows existing pattern where stats calculations happen in handlers

**Calculation logic:**
```
For date range X to Y:
  one_time_income = SUM(amount FROM budget_incomes WHERE date <= Y AND recurring_type IS NULL)
  recurring_income = SUM(amount * (Y - max(start_date, X) + 1) FROM budget_incomes WHERE start_date <= Y AND recurring_type = 'daily')
  total_income = one_time_income + recurring_income
```

**Alternative considered:** PostgreSQL stored procedure or view
- Rejected: Adds database complexity, harder to test, reduces sqlc type-safety benefits

### Budget Remaining Endpoint: Separate `/api/budget/remaining` endpoint

**Decision:** Create dedicated endpoint `GET /api/budget/remaining?date=` instead of adding to existing stats endpoints.

**Rationale:**
- Budget remaining is a calculated running total, not a period-based stat like current stats
- Keeps stats endpoints unchanged (backward compatible)
- Allows flexible date filtering without changing existing stats contracts
- Simpler to implement and test as a separate endpoint

**Alternative considered:** Add `budget_remaining` field to `/api/budget/stats/summary`
- Rejected: Stats are period-based (month/year), budget remaining is cumulative running total - different semantics

### Frontend: Update `ExpenseStats` component directly

**Decision:** Replace "Period" stat card with "Budget Remaining" in existing `ExpenseStats` component.

**Rationale:**
- Component already displays 4 stat cards in a grid
- Replacing "Period" maintains grid layout (no UI reflow)
- Reuses existing loading/skeleton states
- No new component needed for stat display

### Expense Display: Add "-" prefix via format function

**Decision:** Add `formatAmount(amount: number, type: 'income' | 'expense')` helper function to handle +/- prefix.

**Rationale:**
- Centralizes formatting logic (consistent across expense cards, income cards, stats)
- Type-safe (explicit income vs expense differentiation)
- Easy to test formatting independently
- Future-proof (can add currency, decimal precision, etc.)

**Alternative considered:** Add `amount_type` field to `Expense` interface
- Rejected: Expenses are always expenses - unnecessary data duplication

### Income UI: Integrate into existing budget page

**Decision:** Integrate income management directly into existing `/dashboard/budget` page with a new card/section for incomes.

**Rationale:**
- Single-page view for both income and expenses (no navigation needed)
- Simpler UX for users - see everything at once
- Leverages existing budget page structure
- Future UI improvements can enhance layout without breaking integration

**Implementation approach:**
- Add "Recent Incomes" card alongside "Recent Expenses" on budget dashboard
- Add "Add Income" button in header (next to "Add Expense")
- Create `IncomeForm` component in a modal/dialog (similar to expense editing)
- Update budget page layout to accommodate income section

### Migration Strategy: Incremental Goose migration

**Decision:** Add Goose migration `005_create_budget_incomes.sql` with both Up and Down migrations.

**Rationale:**
- Existing project uses Goose for migrations
- Provides rollback path if needed
- Consistent with existing migration files (001-004 already exist)
- Can be applied independently without affecting other tables

**Migration schema:**
```sql
CREATE TABLE budget_incomes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    date DATE NOT NULL,
    description TEXT,
    recurring_type VARCHAR(10) CHECK (recurring_type IN ('daily') OR recurring_type IS NULL),
    start_date DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_incomes_user_date ON budget_incomes(user_id, date DESC);
CREATE INDEX idx_incomes_recurring ON budget_incomes(user_id) WHERE recurring_type IS NOT NULL;
```

**Alternative considered:** Add `user_id` via separate migration
- Rejected: Simpler to add in single migration since `budget_incomes` table doesn't exist yet

### Backend Handler Structure: Add income methods to existing `BudgetHandler`

**Decision:** Add income CRUD methods to `handlers/budget.go` (same file as expense handlers).

**Rationale:**
- Budget-related handlers already grouped in `BudgetHandler`
- Shares dependencies (queries, logger)
- Consistent with existing code organization
- No need for new handler type

**Methods to add:**
- `CreateIncome(c echo.Context) error`
- `ListIncomes(c echo.Context) error`
- `GetIncome(c echo.Context) error`
- `UpdateIncome(c echo.Context) error`
- `DeleteIncome(c echo.Context) error`
- `GetBudgetRemaining(c echo.Context) error`

## Risks / Trade-offs

[Risk] Recurring income calculation may be slow with many entries
**Mitigation:** Add indexes on `user_id` and `recurring_type`, consider caching for frequent date ranges

[Risk] Budget remaining calculation for long date ranges (years of data)
**Mitigation:** Default date filtering to current year/month, add query limits if performance issues arise

[Risk] Concurrent updates to income entries while calculating budget remaining
**Mitigation:** Use PostgreSQL transaction isolation level for calculations, data is eventually consistent

[Trade-off] No support for weekly/monthly recurring income
**Rationale:** Daily recurring covers most use cases (daily allowances, per diem), adding complexity for rare use cases not justified

[Trade-off] Income has no categories/tags
**Rationale:** Simpler UX, most users just need to track "money in" vs "money out", can add later if needed

## Migration Plan

**Database Migration:**
1. Create `005_create_budget_incomes.sql` with `budget_incomes` table schema
2. Run `goose -dir migrations postgres "$DATABASE_URL" up` to apply migration
3. Verify table created with correct indexes via `psql \d budget_incomes`

**Backend Rollout:**
1. Add income queries to `sql/queries/income.sql`
2. Run `sqlc generate` to regenerate Go code
3. Add income types to `models/income.go`
4. Add income handler methods to `handlers/budget.go`
5. Register routes in `main.go` under `/api/budget/incomes`
6. Test income CRUD endpoints manually (curl/postman)

**Frontend Rollout:**
1. Add Income interface to `types/api.ts`
2. Add income API functions to `lib/api.ts`
3. Create `IncomeForm` component (modal/dialog based)
4. Update `/dashboard/budget/page.tsx` to integrate income management:
   - Add "Recent Incomes" card section
   - Add "Add Income" button in header
   - Integrate IncomeForm modal for creating/editing incomes
5. Update `ExpenseStats` to show Budget Remaining instead of Period
6. Update expense cards to display `-` prefix
7. Add budget remaining calculation and display to dashboard with date filter

**Rollback Strategy:**
- Database: Run `goose down` to drop `budget_incomes` table
- Backend: Revert handler changes, revert route registration
- Frontend: Revert component changes, keep ExpenseStats as-is (Period card will reappear)

**Open Questions:**
- Should we add demo income data for guest users? (Currently demo user has expenses but no income)
- What should happen when recurring income start_date is changed? (Recalculate historical or apply forward only?)
