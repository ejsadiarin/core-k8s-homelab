## Why

When updating an expense, the `priority_group_id` and `end_date` fields are being cleared even when they are not included in the update request. This happens because the SQL UPDATE query does not use `COALESCE` for these fields, causing any null values from the frontend to overwrite existing data instead of preserving it.

## What Changes

- Fix `budget.sql` UpdateExpense query to use `COALESCE` for `end_date` and `priority_group_id` fields
- Regenerate sqlc code to reflect the SQL fix

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `expense-management`: Fix UPDATE query to properly preserve existing `end_date` and `priority_group_id` values when not explicitly provided in update request.

## Impact

- **Backend**: `apps/api-gateway/sql/queries/budget.sql` - SQL query fix
- **Generated code**: `apps/api-gateway/internal/repository/sqlc/budget.sql.go` - regenerated via `make sqlc-generate`
- **API behavior**: Expense updates will now correctly preserve existing `priority_group_id` and `end_date` values when not provided in the request