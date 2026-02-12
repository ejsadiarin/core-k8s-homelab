## Why

The budget tracker currently supports recurring income entries (daily, weekly, monthly) with start/end dates, allowing users to track regular income sources. However, expenses lack this capability - they can only be one-time entries. Users need the ability to track recurring expenses (subscriptions, rent, utilities) to get accurate budget projections and avoid manual entry of predictable costs.

## What Changes

- Add recurring expense support to the `budget_expenses` table with the same pattern used for incomes
- Add `recurring_type` column supporting: `daily`, `weekly`, `monthly`, `yearly`, or `NULL` (one-time)
- Add `start_date` column for recurring expenses (required when recurring_type is set)
- Add `end_date` column for time-bound recurring expenses (optional)
- Add database constraints to enforce data integrity (CHECK constraints for valid recurring types, start_date required for recurring)
- Update API models to include recurring fields in Create/Update/Expense request/response structs
- Update SQL queries to include recurring fields
- Update API handlers to support recurring expense CRUD operations
- Add validation: end_date must be >= start_date when both are provided
- Add pagination filter support for `recurring_type`

## Capabilities

### New Capabilities
- `recurring-expenses`: Support for recurring expense entries with daily, weekly, monthly, and yearly intervals, including start/end date tracking for accurate budget calculations

### Modified Capabilities
- `budget-expenses`: Add recurring fields to expense data model and API

## Impact

- Database: New migration to alter `budget_expenses` table
- API: Updated request/response models in `internal/domain/budget/models.go`
- Handlers: Updated expense handlers in `internal/domain/budget/handler.go`
- SQL: New queries in `sql/queries/budget.sql`
- Generated code: sqlc will regenerate repository code
- API documentation: Swagger docs will be updated
