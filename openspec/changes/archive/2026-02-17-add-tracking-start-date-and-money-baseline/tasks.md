## 1. Database Migration

- [x] 1.1 Create migration file `013_add_tracking_baseline.sql` with +goose Up/Down
- [x] 1.2 Add `tracking_start_date DATE DEFAULT '2026-01-15'` to users table
- [x] 1.3 Add `money_baseline DECIMAL(10, 2) DEFAULT 0` to users table
- [x] 1.4 Add `exclude_from_calculations BOOLEAN DEFAULT false` to budget_incomes table
- [x] 1.5 Create index `idx_budget_incomes_exclude` on budget_incomes(exclude_from_calculations)
- [x] 1.6 Calculate baseline for primary user: `12345.60 - (income_since_jan15 - expenses_since_jan15)`
- [x] 1.7 Mark all income entries before Jan 15 with `exclude_from_calculations = true`
- [x] 1.8 User runs `make migrate-up` to apply migration

## 2. SQL Queries - Period-Based Income

- [x] 2.1 Add query `GetIncomeForPeriod` to get one-time income within date range (start_date, end_date)
- [x] 2.2 Add query `GetRecurringIncomeForPeriod` to get recurring rules active in period
- [x] 2.3 Update `GetOneTimeIncomeToDate` to filter `WHERE exclude_from_calculations = false`
- [x] 2.4 Add query `GetTotalExpensesForPeriod` for consistency (already filtered by date, just formalize)
- [x] 2.5 Run `sqlc generate` to regenerate Go code

## 3. Backend - Recurring Income Helper

- [x] 3.1 Create new helper `calculateRecurringIncomeForPeriod(rules, startDate, endDate)` in handler_stats.go
- [x] 3.2 Implement period overlap logic (handle rule start/end within period)
- [x] 3.3 Handle partial month proration for monthly recurring income
- [x] 3.4 Add unit tests for edge cases (rule starts mid-period, ends mid-period)

## 4. Backend - Update Savings Rate Handler

- [x] 4.1 Get user's tracking_start_date from users table
- [x] 4.2 Enforce startDate >= tracking_start_date (error or auto-adjust)
- [x] 4.3 Replace `GetOneTimeIncomeToDate` with `GetIncomeForPeriod(startDate, endDate)`
- [x] 4.4 Replace `calculateRecurringIncome` with `calculateRecurringIncomeForPeriod(rules, startDate, endDate)`
- [x] 4.5 Update response to include tracking_period_start in response

## 5. Backend - Update 50/30/20 Handler

- [x] 5.1 Get user's tracking_start_date from users table
- [x] 5.2 Enforce current month startDate >= tracking_start_date
- [x] 5.3 Update income calculation to use `GetIncomeForPeriod` for current month
- [x] 5.4 Update recurring income to use `calculateRecurringIncomeForPeriod`
- [x] 5.5 Add note if current month partially overlaps tracking start (e.g., Jan 15-31)

## 6. Backend - Update Health Score Handler

- [x] 6.1 Get user's tracking_start_date from users table
- [x] 6.2 Filter all income queries: `WHERE date >= tracking_start_date AND exclude_from_calculations = false`
- [x] 6.3 Filter all expense queries: `WHERE expense_date >= tracking_start_date`
- [x] 6.4 Update emergency fund calculation to use tracking period only

## 7. Backend - Current Total Money Endpoint

- [x] 7.1 Create `GetCurrentTotalMoney` handler in handler_stats.go
- [x] 7.2 Fetch user's money_baseline and tracking_start_date
- [x] 7.3 Calculate total income since tracking_start_date (exclude_from_calculations = false)
- [x] 7.4 Calculate total expenses since tracking_start_date
- [x] 7.5 Return: `current_total = baseline + (income - expenses)`, include breakdown in response
- [x] 7.6 Add route `GET /api/budget/current-total-money` in routes.go
- [x] 7.7 Add Swagger annotations

## 8. Backend - User Settings Endpoints (Future Enhancement - Deferred)

- [ ] ~~8.1 Add endpoint to GET user baseline settings: `GET /api/users/me/baseline`~~
- [ ] ~~8.2 Add endpoint to UPDATE baseline manually: `PUT /api/users/me/baseline` (admin only for now)~~
- [ ] ~~8.3 Validate tracking_start_date is immutable (return error if trying to change)~~

## 9. Backend - Build & Test

- [x] 9.1 Run `go build ./...` and fix compilation errors
- [x] 9.2 Run `go vet ./...`
- [x] 9.3 Test savings rate calculation with sample data (verify period filtering works)
- [x] 9.4 Test 50/30/20 with sample data (verify percentages correct for period)
- [x] 9.5 Regenerate Swagger docs with `make swagger`

## 10. Frontend - Types & API Client

- [x] 10.1 Add `CurrentTotalMoneyResponse` type (current_total, baseline, net_change, income_since, expenses_since, tracking_start_date)
- [x] 10.2 Add `fetchCurrentTotalMoney()` API function in lib/api.ts
- [x] 10.3 Update `SavingsRateResponse` to include tracking_period_start (optional for now)
- [x] 10.4 Update `FiftyThirtyTwentyResponse` to include tracking_period_start

## 11. Frontend - React Query Hooks

- [x] 11.1 Add `useCurrentTotalMoney()` hook in use-budget.ts
- [x] 11.2 Add query key: `budgetKeys.currentTotalMoney()`

## 12. Frontend - Current Total Money Card

- [x] 12.1 Create `CurrentTotalMoneyCard` component in components/budget/
- [x] 12.2 Display current total in large text with ₱ symbol
- [x] 12.3 Show breakdown: baseline, income since tracking, expenses since tracking, net change
- [x] 12.4 Show tracking start date: "Tracking since Jan 15, 2026"
- [x] 12.5 Add loading and error states
- [x] 12.6 Export from components/budget/index.ts

## 13. Frontend - Dashboard Integration

- [x] 13.1 Add CurrentTotalMoneyCard to dashboard page (top row, prominent position)
- [x] 13.2 Verify it displays correct data from API
- [x] 13.3 Add tooltip explaining baseline concept

## 14. Frontend - Income List Visual Indicator

- [x] 14.1 Update income list component to check `exclude_from_calculations` field
- [x] 14.2 Add grey badge "[Historical]" next to excluded entries
- [x] 14.3 Add tooltip: "Excluded from budget calculations (before tracking start date)"

## 15. Frontend - Lint & Verify

- [x] 15.1 Run `npx tsc --noEmit` and fix TypeScript errors
- [x] 15.2 Run `pnpm lint` and fix ESLint errors in modified files only
- [x] 15.3 Verify dashboard displays current total money correctly
- [x] 15.4 Verify savings rate shows correct percentage for tracking period
