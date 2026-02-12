## 1. Database Migration

- [x] 1.1 Create migration file `008_add_recurring_expense_features.sql` in `web/apps/api-gateway/migrations/`
- [x] 1.2 Add `recurring_type` TEXT column to `budget_expenses` table
- [x] 1.3 Add `start_date` DATE column to `budget_expenses` table
- [x] 1.4 Add `end_date` DATE column to `budget_expenses` table
- [x] 1.5 Add CHECK constraint for valid recurring_type values ('daily', 'weekly', 'monthly', 'yearly') or NULL
- [x] 1.6 Add CHECK constraint ensuring recurring_type IS NULL OR start_date IS NOT NULL
- [x] 1.7 Write Goose Down migration to remove columns and constraints
- [x] 1.8 Run `goose up` to apply migration locally

## 2. SQL Queries

- [x] 2.1 Add `recurring_type`, `start_date`, `end_date` columns to `ListExpenses` query in `sql/queries/budget.sql`
- [x] 2.2 Add `recurring_type`, `start_date`, `end_date` columns to `GetExpense` query in `sql/queries/budget.sql`
- [x] 2.3 Add `recurring_type`, `start_date`, `end_date` parameters to `CreateExpense` query in `sql/queries/budget.sql`
- [x] 2.4 Add `recurring_type`, `start_date`, `end_date` parameters to `UpdateExpense` query in `sql/queries/budget.sql`
- [x] 2.5 Add optional `recurring_type` filter parameter to `ListExpenses` query
- [x] 2.6 Add `CountExpenses` query with recurring_type filter support
- [x] 2.7 Run `sqlc generate` to regenerate repository code

## 3. API Models

- [x] 3.1 Add `RecurringType *string` field to `CreateExpenseRequest` struct in `models.go`
- [x] 3.2 Add `StartDate *string` field to `CreateExpenseRequest` struct
- [x] 3.3 Add `EndDate *string` field to `CreateExpenseRequest` struct
- [x] 3.4 Add validation tags: `recurring_type` with `oneof=daily weekly monthly yearly`, `start_date` and `end_date` with `datetime=2006-01-02`
- [x] 3.5 Add `RecurringType *string` field to `UpdateExpenseRequest` struct
- [x] 3.6 Add `StartDate *string` field to `UpdateExpenseRequest` struct
- [x] 3.7 Add `EndDate *string` field to `UpdateExpenseRequest` struct
- [x] 3.8 Add `RecurringType *string` field to `ExpenseResponse` struct
- [x] 3.9 Add `StartDate *string` field to `ExpenseResponse` struct
- [x] 3.10 Add `EndDate *string` field to `ExpenseResponse` struct
- [x] 3.11 Add `RecurringType *string` field to `ExpenseFilters` struct with query tag

## 4. Handler Implementation

- [x] 4.1 Update `CreateExpense` handler to include recurring fields in `CreateExpenseParams`
- [x] 4.2 Add validation in `CreateExpense` to ensure `end_date >= start_date` when both provided
- [x] 4.3 Update `CreateExpense` response to include recurring fields
- [x] 4.4 Update `ListExpenses` handler to pass `RecurringType` filter to query
- [x] 4.5 Update `ListExpenses` response mapping to include recurring fields
- [x] 4.6 Update `GetExpense` response mapping to include recurring fields
- [x] 4.7 Update `UpdateExpense` handler to include recurring fields in `UpdateExpenseParams`
- [x] 4.8 Add validation in `UpdateExpense` to ensure `end_date >= start_date` when both provided
- [x] 4.9 Update `UpdateExpense` response to include recurring fields
- [x] 4.10 Update `getExpenseResponse` helper to include recurring fields in response

## 5. Documentation

- [x] 5.1 Run `swag init` to regenerate Swagger documentation
- [x] 5.2 Verify Swagger UI shows new recurring fields in request/response schemas
- [x] 5.3 Verify API endpoint documentation includes recurring_type filter parameter

## 6. Testing

- [x] 6.1 Test creating one-time expense (no recurring fields)
- [x] 6.2 Test creating daily recurring expense with start_date
- [x] 6.3 Test creating weekly recurring expense with start_date and end_date
- [x] 6.4 Test creating monthly recurring expense with start_date
- [x] 6.5 Test creating yearly recurring expense with start_date and end_date
- [x] 6.6 Test validation: reject recurring expense without start_date
- [x] 6.7 Test validation: reject end_date < start_date
- [x] 6.8 Test filtering expenses by recurring_type=daily
- [x] 6.9 Test filtering expenses by recurring_type=monthly
- [x] 6.10 Test updating expense to add recurring fields
- [x] 6.11 Test listing expenses includes recurring fields in response
- [x] 6.12 Test backward compatibility: old expense creation still works
