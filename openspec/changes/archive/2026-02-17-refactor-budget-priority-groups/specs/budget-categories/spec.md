## REMOVED Requirements

### Requirement: Category type classification
Categories no longer carry Need/Want/Savings classification. The `category_type` column SHALL be removed from `budget_categories`.

**Reason**: Priority classification moved to expense level via `budget_priority_groups` to allow per-expense flexibility (e.g., "Food" category can be Need for groceries, Want for dining out).

**Migration**: Existing `category_type` values are backfilled to `budget_expenses.priority_group_id` during migration. The `PUT /api/budget/categories/:id/type` endpoint is removed. Use priority_group_id on expenses instead.
