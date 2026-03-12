## 1. Backend - Recurring Income Occurrences Endpoint

- [x] 1.1 Add `IncomeOccurrence` response struct to `models.go` with fields: id, source_income_id, amount, currency, date, description, recurring_type, is_virtual, is_skipped
- [x] 1.2 Add SQL query in `income.sql` to fetch one-time incomes within a date range (for merging with virtual entries)
- [x] 1.3 Run `sqlc generate` to regenerate repository code
- [x] 1.4 Implement `handleGetIncomeOccurrences` handler in `handler_income.go` that expands recurring rules into virtual entries for a date range, merges with one-time incomes, sorts by date desc, and paginates
- [x] 1.5 Register `GET /api/budget/incomes/occurrences` route in the budget domain router
- [x] 1.6 Verify backend compiles with `go build ./...`

## 2. Frontend - TypeScript Types and API Client

- [x] 2.1 Add `IncomeOccurrence` interface and `IncomeOccurrencesResponse` type to `types/api.ts`
- [x] 2.2 Add `getIncomeOccurrences(params)` function to `lib/api.ts`
- [x] 2.3 Add `useIncomeOccurrences(startDate, endDate)` React Query hook to `hooks/use-budget.ts`

## 3. Frontend - PeriodPresetFilter Component

- [x] 3.1 Create `period-preset-filter.tsx` component with preset buttons (7D, 30D, 90D, This Month, This Year) and custom date inputs
- [x] 3.2 Export `PeriodPresetFilter` from `components/budget/index.ts` barrel

## 4. Frontend - Budget Dashboard Integration

- [x] 4.1 Replace standalone date range inputs on budget dashboard (`page.tsx`) with `PeriodPresetFilter` component
- [x] 4.2 Update "Recent Incomes" section on dashboard to fetch and display virtual recurring occurrences from the last 7 days, merged with recent stored incomes

## 5. Frontend - Income List Page Integration

- [x] 5.1 Update income list page (`/dashboard/budget/incomes/page.tsx`) to fetch occurrences from the new endpoint when date filter is active, showing virtual entries with "Recurring" badge and no edit/delete actions

## 6. Frontend - Monthly Summary Page

- [x] 6.1 Create `/dashboard/budget/summary/page.tsx` with PeriodPresetFilter, summary cards (total income, total expenses, net savings, savings rate), and itemized income/expense lists
- [x] 6.2 Add "Summary" navigation item to sidebar nav items (`sidebar-nav-items.ts`) in the FINANCE section

## 7. Lint, Build, and Verify

- [x] 7.1 Run `pnpm lint` and `npx tsc --noEmit` in the frontend app and fix any errors
- [x] 7.2 Run `go vet ./...` on the backend and fix any errors
- [x] 7.3 Commit all changes
