## Why

The budget income feature currently only supports daily recurring income without end dates, making it inflexible for real-world scenarios like weekly/monthly salaries or time-bound contracts. Additionally, the budget remaining display has poor UX with a 60-second cache delay after adding income/expenses and unreadable color combinations when over budget. The expense creation workflow also differs from the income pattern (full page vs dialog), creating UI inconsistency.

## What Changes

- Add weekly and monthly recurring income types with configurable start/end dates
- Support indefinite recurring income (null end_date) with clear UI indicators
- Improve budget remaining cache invalidation to update immediately when income/expense is added/updated/deleted
- Fix budget remaining card color scheme when over budget (currently green background + red text)
- Refactor expense creation from dedicated page to dialog component matching income workflow
- Add proper UX for expense dialog (auto-closing on success, keyboard shortcuts, proper form validation)

## Capabilities

### New Capabilities

- `recurring-income-periods`: Support for weekly and monthly recurring income with start/end date ranges
- `expense-creation-dialog`: Dialog-based expense creation workflow with proper UX patterns

### Modified Capabilities

- `budget-incomes`: MODIFIED to add weekly/monthly recurring types and end_date support (currently only supports daily)
- `budget-remaining`: MODIFIED to invalidate cache immediately when data changes (currently uses 60s stale time)
- `data-refresh`: MODIFIED to optimize cache revalidation strategy for budget remaining calculations

## Impact

### Backend (Go API)
- `apps/api-gateway/sql/queries/incomes.sql` - add end_date column, update queries for weekly/monthly calculation
- `apps/api-gateway/models/requests.go` - add RecurringType enum (daily/weekly/monthly), add EndDate field
- `apps/api-gateway/handlers/budget.go` - update income CRUD to handle new fields
- Database migration needed for `incomes` table schema change

### Frontend (Next.js/React)
- `web/apps/core/src/hooks/use-budget.ts` - update cache invalidation strategy, remove/reduce staleTime for budgetRemaining
- `web/apps/core/src/types/api.ts` - add weekly/monthly to RecurringType, add end_date field
- `web/apps/core/src/components/budget/income-form.tsx` - add recurring period selector, start/end date pickers
- `web/apps/core/src/app/dashboard/budget/page.tsx` - fix budget remaining card colors, add expense dialog trigger
- `web/apps/core/src/app/dashboard/budget/expenses/new/page.tsx` - DELETE (migrate to dialog)
- `web/apps/core/src/components/budget/expense-dialog.tsx` - NEW dialog component for expense creation

### Database
- Migration to add `end_date TIMESTAMP NULL` to `incomes` table
- Migration to modify `recurring_type` enum to include 'weekly' and 'monthly'

### Dependencies
- No new external dependencies required
