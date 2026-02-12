## Context

The budget tracker currently supports recurring income entries with the following schema (from migration 006):

- `recurring_type` column with values: 'daily', 'weekly', 'monthly', or NULL
- `start_date` column (required when recurring_type is set)
- `end_date` column (optional, for time-bound recurring entries)
- CHECK constraints for valid types and start_date requirement

The expense tracking system currently only supports one-time expenses. This design adds the same recurring capability to expenses, enabling users to track subscriptions, rent, utilities, and other predictable recurring costs.

## Goals / Non-Goals

**Goals:**

- Add recurring expense support mirroring the existing income implementation
- Support all recurring types: daily, weekly, monthly, and yearly
- Maintain data integrity through database constraints
- Ensure API consistency with income endpoints
- Support pagination filtering by recurring_type

**Non-Goals:**

- Automatic expense generation/updating (future enhancement)
- Complex recurrence patterns (e.g., "every 2 weeks")
- Frontend implementation (covered separately)
- Budget calculation changes (future enhancement)

## Decisions

**Decision: Mirror income recurring pattern exactly**

- Rationale: Consistent API reduces cognitive load and ensures predictable behavior
- Alternative: Custom expense-specific pattern - rejected due to inconsistency risk

**Decision: Add 'yearly' recurring type (not in income)**

- Rationale: Expenses commonly have yearly cycles (insurance, subscriptions) that incomes rarely have
- Alternative: Keep same as income (daily/weekly/monthly) - rejected as it limits usefulness

**Decision: Use Goose migration following existing pattern**

- Rationale: Consistent with existing migration 006 for income
- Steps: ALTER TABLE ADD COLUMN, ADD CONSTRAINT, modify CHECK constraint

**Decision: Store recurring_type as TEXT with CHECK constraint**

- Rationale: Matches income implementation exactly; allows easy extension; database-enforced validity
- Alternative: ENUM type - rejected for PostgreSQL portability and migration simplicity

**Decision: Reuse existing helper functions for date/text conversion**

- Rationale: Handler already has `stringToDate`, `stringPtrToDate`, `dateToString`, `textToStringPtr`, `getCurrency` utilities
- Location: `internal/domain/budget/helpers.go`

**Decision: Add filter parameter `recurring_type` to ListExpenses endpoint**

- Rationale: User may want to view only recurring expenses or only one-time expenses
- Implementation: Query parameter with optional validation

## Risks / Trade-offs

**[Risk] Migration on large expense table may lock table briefly**

- **Mitigation**: ALTER TABLE ADD COLUMN with DEFAULT NULL is fast; migration runs during deployment window with minimal data currently

**[Risk] API response size increases for all expense endpoints**

- **Mitigation**: New fields are pointers/nullable, so JSON overhead is minimal for one-time expenses

**[Trade-off] Yearly type adds inconsistency with income types**

- **Acceptance**: Income can be enhanced later to include yearly; user need justifies the difference

## Migration Plan

1. Create database migration file (008_add_recurring_expense_features.sql)
2. Run `goose up` to apply migration
3. Update sqlc queries in sql/queries/budget.sql
4. Run `sqlc generate` to regenerate repository code
5. Update API models in internal/domain/budget/models.go
6. Update handler functions in internal/domain/budget/handler.go
7. Update Swagger documentation with `swag init`
8. Test all CRUD operations with recurring and non-recurring expenses

**Rollback:**

- Run `goose down` to revert migration
- Revert code changes via git
