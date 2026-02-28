## 1. Backend - Skip Recurring Expense Support

- [x] 1.1 Add SQL query `CheckSkippedExpense` in `sql/queries/budget.sql` to check if a negative expense record exists for a given date (mirrors `CheckSkippedIncome`)
- [x] 1.2 Add SQL query `GetUpcomingRecurringExpenses` end_date filter: modify existing query to exclude recurring expenses where `end_date IS NOT NULL AND end_date < CURRENT_DATE`
- [x] 1.3 Run `sqlc generate` to regenerate repository code
- [x] 1.4 Add `CheckSkippedExpense` handler in `handler_stats.go` at `GET /api/budget/expenses/check-skipped?date=YYYY-MM-DD`
- [x] 1.5 Register the new route in `routes.go`
- [x] 1.6 Verify existing `CreateExpense` handler accepts negative amounts (no validation blocking negative values)

## 2. Backend - Filter Expired Recurring Incomes

- [x] 2.1 Verify `GetRecurringIncomeRules` SQL query excludes incomes where `end_date < CURRENT_DATE` (add filter if missing)
- [x] 2.2 Run `sqlc generate` if query was modified
- [x] 2.3 Run `go test ./internal/domain/budget/...` to ensure existing tests pass

## 3. Frontend - API & Types

- [x] 3.1 Add `checkSkippedExpense(date: string): Promise<boolean>` function in `lib/api.ts`
- [x] 3.2 Add `SubscriptionItem` type extension to include `id` field usable for update/cancel operations (verify current type is sufficient)
- [x] 3.3 Add `cancelRecurringExpense(id: string): Promise<Expense>` helper in `lib/api.ts` that calls `updateExpense` with `end_date: today`
- [x] 3.4 Add `cancelRecurringIncome(id: string): Promise<Income>` helper in `lib/api.ts` that calls `updateIncome` with `end_date: today`

## 4. Frontend - Skip Expense Dialog Component

- [x] 4.1 Create `skip-expense-dialog.tsx` component mirroring `skip-occurrence-dialog.tsx` but for expenses (uses `createExpense` mutation with negative amount)
- [x] 4.2 Wire up duplicate skip check using `checkSkippedExpense` API
- [x] 4.3 Export component from `components/budget/index.ts`

## 5. Frontend - Cancel Recurring Dialog Component

- [x] 5.1 Create `cancel-recurring-dialog.tsx` component that shows confirmation with item details and calls the appropriate cancel helper based on item type (expense vs income)
- [x] 5.2 Component SHALL accept a generic recurring item (expense or income) and a type discriminator
- [x] 5.3 On confirm, invalidate relevant React Query caches (subscriptions, recurring-incomes)
- [x] 5.4 Export component from `components/budget/index.ts`

## 6. Frontend - Refactor Summary Card

- [x] 6.1 Refactor `subscription-total-card.tsx` into `recurring-summary-card-page.tsx` (or modify in-place) to display combined totals: monthly expenses, monthly incomes, net cash flow, and counts for both types
- [x] 6.2 Fetch both `useSubscriptions()` and `useRecurringIncomes()` data
- [x] 6.3 Calculate monthly equivalent for incomes (daily x 30, weekly x 4.33, monthly x 1)

## 7. Frontend - Refactor Recurring Items List

- [x] 7.1 Create `recurring-expenses-list.tsx` by refactoring `subscription-list.tsx` to add edit, skip, and cancel action buttons per item
- [x] 7.2 Create `recurring-incomes-list.tsx` by adapting `recurring-income-list.tsx` for the recurring page with edit and cancel action buttons (skip already exists)
- [x] 7.3 Wire edit action to open `ExpenseEditDialog` / `IncomeEditDialog` respectively
- [x] 7.4 Wire skip action to open `SkipExpenseDialog` / `SkipOccurrenceDialog` respectively
- [x] 7.5 Wire cancel action to open `CancelRecurringDialog`

## 8. Frontend - Refactor Subscriptions Page

- [x] 8.1 Refactor `subscriptions/page.tsx` to display the new recurring summary card, Tabs (Expenses / Incomes) with the respective list components, and TopMerchantsTable below
- [x] 8.2 Update page header from "SUBSCRIPTIONS & MERCHANTS" to "RECURRING TRACKER" with updated description
- [x] 8.3 Update sidebar nav item in `sidebar-nav-items.ts`: change label from "Subscriptions" to "Recurring", change icon from `Store` to `RefreshCw`

## 9. Verification

- [x] 9.1 Run `go test ./internal/domain/budget/...` to verify backend tests pass
- [x] 9.2 Run `pnpm lint` in `apps/core` to verify no lint errors
- [x] 9.3 Run `npx tsc --noEmit` in `apps/core` to verify no TypeScript errors
- [x] 9.4 Manually verify page loads and displays both recurring expenses and incomes sections
