## 1. Database Migration

- [x] 1.1 Create migration file `005_create_budget_incomes.sql` with budget_incomes table schema
- [x] 1.2 Add user_id foreign key to budget_incomes table with ON DELETE CASCADE
- [x] 1.3 Add recurring_type enum column with CHECK constraint (NULL, 'daily')
- [x] 1.4 Add indexes on user_id/date and recurring_type for query optimization
- [x] 1.5 Run `goose -dir migrations postgres "$DATABASE_URL" up` to apply migration

## 2. Backend - SQL Queries

- [x] 2.1 Add income queries to `sql/queries/income.sql` (list, create, get, update, delete by user)
- [x] 2.2 Add budget remaining calculation query to `sql/queries/income.sql`
- [x] 2.3 Add income.sql to sqlc.yaml and run `sqlc generate` to regenerate Go code from SQL queries

## 3. Backend - Types and Models

- [x] 3.1 Add Income type to `types/api.ts` (id, amount, currency, date, description, recurring_type, start_date, created_at, updated_at)
- [x] 3.2 Add CreateIncomeRequest type to `types/api.ts`
- [x] 3.3 Add UpdateIncomeRequest type to `types/api.ts`
- [x] 3.4 Add BudgetRemainingResponse type to `types/api.ts` (budget_remaining, budget_remaining_status)
- [x] 3.5 Updated SummaryStats type to include budget_remaining and budget_remaining_status
- [x] 3.6 Add income DTOs to `models/budget.go` (CreateIncomeRequest, UpdateIncomeRequest, IncomeResponse, BudgetRemainingResponse)
- [x] 3.7 Run `sqlc generate` to generate Go types from income.sql queries (YOU NEED TO DO THIS)

## 4. Backend - Handler Implementation

- [x] 4.1 Implement `CreateIncome` handler method in `handlers/budget.go`
- [x] 4.2 Implement `ListIncomes` handler method in `handlers/budget.go`
- [x] 4.3 Implement `GetIncome` handler method in `handlers/budget.go`
- [x] 4.4 Implement `UpdateIncome` handler method in `handlers/budget.go`
- [x] 4.5 Implement `DeleteIncome` handler method in `handlers/budget.go`
- [x] 4.6 Implement `GetBudgetRemaining` handler method with recurring income calculation logic in `handlers/budget.go`

## 5. Backend - Route Registration

- [x] 5.1 Register income CRUD routes in `main.go` (`POST /api/budget/incomes`, `GET /api/budget/incomes`, `GET /api/budget/incomes/:id`, `PUT /api/budget/incomes/:id`, `DELETE /api/budget/incomes/:id`)
- [x] 5.2 Register budget remaining route in `main.go` (`GET /api/budget/remaining`)
- [x] 5.3 Apply auth middleware to all income routes (RequireAuth - already applied to /api group)
- [x] 5.4 Add guest/user/admin access control for income endpoints (handled in handlers)

## 6. Frontend - API Client

- [x] 6.1 Add income API functions to `lib/api.ts` (createIncome, listIncomes, getIncome, updateIncome, deleteIncome)
- [x] 6.2 Add budget remaining API function to `lib/api.ts` (getBudgetRemaining)
- [x] 6.3 Add guest/user/admin access checks in income API functions (inherited from fetch with credentials: 'include')

## 7. Frontend - React Query Hooks

- [x] 7.1 Create `use-incomes.ts` hook with useIncomes, useCreateIncome, useUpdateIncome, useDeleteIncome
- [x] 7.2 Add useBudgetRemaining hook to `use-incomes.ts`
- [x] 7.3 Add query invalidation for incomes after CRUD operations

## 8. Frontend - Components

- [x] 8.1 Create `IncomeForm` component in `components/budget/income-form.tsx` (modal/dialog based)
- [x] 8.2 Add form validation for amount, date, description, recurring_type, start_date
- [x] 8.3 Add currency formatting helper function `formatAmount(amount, type)` to lib/utils.ts

## 9. Frontend - Budget Page Integration

- [x] 9.1 Add "Add Income" button to budget page header
- [x] 9.2 Add "Recent Incomes" card section to budget page (alongside Recent Expenses)
- [x] 9.3 Integrate IncomeForm modal for creating/editing incomes
- [x] 9.4 Add income list display with + prefix on amounts
- [x] 9.5 Add date picker/filter for budget remaining calculation
- [x] 9.6 Update budget page to fetch and display budget remaining with color indicators (green/red/neutral)

## 10. Frontend - Update Existing Components

- [x] 10.1 Update `ExpenseStats` component: replace "Period" stat card with "Budget Remaining"
- [x] 10.2 Update "Budget Remaining" card to show budget_remaining value and status color
- [x] 10.3 Update expense cards in budget page to display amounts with `-` prefix
- [x] 10.4 Update expense list page to display amounts with `-` prefix

## 11. Backend - Update Stats Endpoint

- [x] 11.1 Add budget_remaining calculation to summary stats endpoint handler
- [x] 11.2 Add budget_remaining_status ('green', 'red', 'neutral') to summary stats response
- [x] 11.3 Update SummaryStats type in frontend to include budget_remaining and budget_remaining_status

## 12. Testing and Validation (Manual - You need to test these)

- [x] 12.1 Test income CRUD operations manually (create one-time, create recurring daily, update, delete)
  - FIXED: Delete now closes dialog automatically (@setEditingIncome(null) added)
- [x] 12.2 Test budget remaining calculation with various date ranges
- [x] 12.3 Test user isolation (guest cannot modify, users see only own data, admin sees all)
  - FIXED: React Query cache now clears on logout (queryClient.clear() in auth-context)
- [x] 12.4 Test recurring income proration logic (start_date before today, start_date in future)
- [x] 12.5 Test budget remaining status indicators (positive=green, negative=red, zero=neutral)
  - FIXED: Added visual indicators to ExpenseStats card (red border/background when over budget)
- [x] 12.6 Verify frontend UI displays income/expense amounts with correct +/- prefixes
- [x] 12.7 Verify date filter works correctly for budget remaining calculation
  - FIXED: Added date picker to budget page header with budget remaining display
