## Why

The `category_type` column on `budget_categories` is flawed — a category like "Food" can be both a Need (groceries) and a Want (restaurant dining). The current design forces a single classification per category, making the 50/30/20 budget analysis inaccurate. Moving priority classification to the expense level allows per-transaction flexibility and accurate financial health analysis.

## What Changes

- **BREAKING**: Remove `category_type` column from `budget_categories` table
- Create new `budget_priority_groups` reference table with default rows: Need, Want, Savings
- Add `priority_group_id` nullable FK column to `budget_expenses` table
- Update 50/30/20 analysis to aggregate by expense-level priority instead of category-level type
- Update `GetSpendingByCategoryType` query to use new expense-level priority
- Update `CategoryTypeSelector` UI to work on individual expenses instead of categories
- Remove category type assignment endpoint (`PUT /categories/:id/type`)
- Add priority group CRUD endpoints and expense priority assignment
- Update budget variance and health score calculations to use expense-level priority
- Clean up unused `FiftyThirtyTwentyData` type and duplicate `fetchCategoryTypeSpending` API function

## Capabilities

### New Capabilities
- `budget-priority-groups`: Reference table for priority classification (Need/Want/Savings) with CRUD management and expense-level assignment

### Modified Capabilities
- `budget-expenses`: Expenses gain an optional `priority_group_id` FK for Need/Want/Savings classification
- `budget-categories`: Remove `category_type` column — categories no longer carry priority classification
- `budget-stats`: 50/30/20 analysis and health score recalculated from expense-level priority groups instead of category-level types

## Impact

- **Database**: New table + migration to move data, drop column
- **Backend**: `handler_stats.go` (50/30/20, health score), `handler_budget.go` (remove category type endpoint, add priority group endpoints), SQL queries, sqlc regeneration
- **Frontend**: `category-type-selector.tsx` refactored to expense-level, `fifty-thirty-twenty-chart.tsx` data shape may change, `types/api.ts`, `lib/api.ts`, `use-budget.ts` hooks, expense form/detail dialogs gain priority picker
- **API**: Breaking change to `PUT /categories/:id/type` (removed), new endpoints for priority groups
