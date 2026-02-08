## 1. Backend - Database Schema

- [x] 1.1 Create migration to add `end_date TIMESTAMP NULL` column to `incomes` table
- [x] 1.2 Create migration to add 'weekly' and 'monthly' values to `recurring_type` enum
- [x] 1.3 Add CHECK constraint `(recurring_type IS NULL OR start_date IS NOT NULL)` to incomes table
- [x] 1.4 Run migrations on local development database

## 2. Backend - SQL Queries and Models

- [x] 2.1 Update `sql/queries/incomes.sql` to include `end_date` in SELECT, INSERT, and UPDATE queries
- [x] 2.2 Add weekly calculation logic to budget remaining query (weeks between dates)
- [x] 2.3 Add monthly calculation logic to budget remaining query (months between dates)
- [x] 2.4 Update recurring income calculation to respect `end_date` constraint
- [x] 2.5 Run `sqlc generate` to regenerate Go types from updated queries

## 3. Backend - Request/Response Models

- [x] 3.1 Update `models/requests.go` to add `EndDate *time.Time` field to CreateIncomeRequest
- [x] 3.2 Update `models/requests.go` to add `EndDate *time.Time` field to UpdateIncomeRequest
- [x] 3.3 Expand `RecurringType` validation to include 'weekly' and 'monthly' values
- [x] 3.4 Add validation tag for `EndDate >= StartDate` constraint
- [x] 3.5 Update Swagger annotations to document new fields

## 4. Backend - Handlers

- [x] 4.1 Update income CRUD handlers in `handlers/budget.go` to handle `end_date` field
- [x] 4.2 Add validation logic to ensure end_date >= start_date when provided
- [x] 4.3 Test backend endpoints with Postman/curl for weekly/monthly income creation
- [x] 4.4 Run `swag init` to regenerate Swagger documentation (skipped - no routes.go file found)

## 5. Frontend - TypeScript Types

- [x] 5.1 Update `types/api.ts` to add `end_date?: string` to Income interface
- [x] 5.2 Update `types/api.ts` to expand RecurringType union type: `'daily' | 'weekly' | 'monthly'`
- [x] 5.3 Update CreateIncomeRequest and UpdateIncomeRequest interfaces with end_date field

## 6. Frontend - React Query Hooks (Cache Invalidation)

- [x] 6.1 Update `useCreateIncome` onSuccess to invalidate budgetRemaining queries
- [x] 6.2 Update `useUpdateIncome` onSuccess to invalidate budgetRemaining queries
- [x] 6.3 Update `useDeleteIncome` onSuccess to invalidate budgetRemaining queries
- [x] 6.4 Update `useCreateExpense` onSuccess to invalidate budgetRemaining queries
- [x] 6.5 Update `useUpdateExpense` onSuccess to invalidate budgetRemaining queries
- [x] 6.6 Update `useDeleteExpense` onSuccess to invalidate budgetRemaining queries
- [x] 6.7 Remove or reduce `staleTime` for `useBudgetRemaining` hook (change from 60000 to 0)

## 7. Frontend - Income Form Component

- [x] 7.1 Update `income-form.tsx` recurring type select to include 'Weekly Recurring' and 'Monthly Recurring' options
- [x] 7.2 Add end_date input field to income form (date picker)
- [x] 7.3 Add "No end date" checkbox to toggle indefinite recurring income
- [x] 7.4 Add conditional logic to show/hide end_date field based on recurring type selection
- [x] 7.5 Add form validation to ensure end_date >= start_date
- [x] 7.6 Update form state to handle end_date field (null when checkbox checked)
- [x] 7.7 Display "Ongoing" badge when editing income with end_date = null

## 8. Frontend - Budget Remaining Card Colors

- [x] 8.1 Update budget remaining card in `page.tsx` to use `bg-red-50 text-red-900 border-red-200` when status is 'red'
- [x] 8.2 Update budget remaining card to use `bg-green-50 text-green-900 border-green-200` when status is 'green'
- [x] 8.3 Keep neutral status using `text-gray-600` with default background
- [x] 8.4 Test color contrast meets WCAG AA standards (manually verify readability)

## 9. Frontend - Expense Creation Dialog Component

- [x] 9.1 Create new `expense-form-dialog.tsx` component in `components/budget/`
- [x] 9.2 Copy ExpenseForm from existing page and wrap in Dialog component from shadcn/ui
- [x] 9.3 Add dialog state management (open/close handlers)
- [x] 9.4 Implement auto-close on successful expense creation
- [x] 9.5 Add ESC key handler to close dialog
- [x] 9.6 Add click-outside handler to close dialog (built-in Dialog feature)
- [x] 9.7 Implement focus trap within dialog (built-in Dialog feature)
- [x] 9.8 Add loading state (disable submit button, show "Creating..." text)
- [x] 9.9 Add error handling (keep dialog open on error, display error message)

## 10. Frontend - Budget Dashboard Integration

- [x] 10.1 Add expense dialog state to budget dashboard `page.tsx`
- [x] 10.2 Update "Add Expense" button to open dialog instead of navigating to page
- [x] 10.3 Add ExpenseFormDialog component to dashboard render
- [x] 10.4 Pass expense creation handlers to dialog component
- [x] 10.5 Test dialog opens/closes correctly from dashboard

## 11. Frontend - Expense Page Refactor

- [x] 11.1 Update `/dashboard/budget/expenses/new/page.tsx` to redirect to budget dashboard with query param
- [x] 11.2 Implement deep linking pattern (query param detection in dashboard)
- [x] 11.3 Test deep linking (direct URL navigation to /expenses/new opens dialog)
- [x] 11.4 Test browser back button closes dialog and returns to budget dashboard
- [x] 11.5 Add redirect handling for backward compatibility (query param approach)

## 12. Testing and Validation

- [ ] 12.1 Test creating weekly recurring income with end_date
- [ ] 12.2 Test creating monthly recurring income without end_date (indefinite)
- [ ] 12.3 Test budget remaining calculation includes weekly/monthly income correctly
- [ ] 12.4 Test budget remaining updates immediately after adding income
- [ ] 12.5 Test budget remaining updates immediately after deleting expense
- [ ] 12.6 Test expense dialog keyboard navigation (Tab, ESC, Enter)
- [ ] 12.7 Test expense dialog on mobile (responsive behavior)
- [ ] 12.8 Test backward compatibility with existing daily recurring incomes
- [ ] 12.9 Verify color contrast of budget remaining card in different states
- [ ] 12.10 Test form validation (end_date >= start_date)

## 13. Documentation and Cleanup

- [ ] 13.1 Update API documentation/Swagger with new fields
- [ ] 13.2 Add code comments for weekly/monthly calculation logic
- [ ] 13.3 Remove unused imports from refactored components
- [ ] 13.4 Verify no console errors or warnings in browser
- [ ] 13.5 Create commit with conventional format following AGENTS.md guidelines
