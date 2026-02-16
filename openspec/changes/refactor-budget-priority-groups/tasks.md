## 1. Database Migration

- [x] 1.1 Create migration file: create `budget_priority_groups` table with columns (id UUID PK, name VARCHAR(50), slug VARCHAR(20) UNIQUE, display_order INT, created_at TIMESTAMP)
- [x] 1.2 Seed default rows: Need (slug: need, order: 1), Want (slug: want, order: 2), Savings (slug: savings, order: 3)
- [x] 1.3 Add `priority_group_id UUID REFERENCES budget_priority_groups(id)` nullable column to `budget_expenses`
- [x] 1.4 Backfill: update `budget_expenses.priority_group_id` from `budget_categories.category_type` for existing data
- [x] 1.5 Drop `category_type` column and `idx_budget_categories_type` index from `budget_categories`
- [x] 1.6 Add index `idx_budget_expenses_priority_group` on `budget_expenses(priority_group_id)`
- [x] 1.7 User runs `make migrate-up` to apply migration

## 2. SQL Queries

- [x] 2.1 Add query `ListPriorityGroups` — select all from `budget_priority_groups` ordered by display_order
- [x] 2.2 Add query `GetPriorityGroupBySlug` — select by slug
- [x] 2.3 Modify expense create query to include `priority_group_id` parameter
- [x] 2.4 Modify expense update query to include `priority_group_id` parameter
- [x] 2.5 Modify expense list/get queries to JOIN `budget_priority_groups` and return priority group fields
- [x] 2.6 Rewrite `GetSpendingByCategoryType` → `GetSpendingByPriorityGroup` to aggregate by `budget_expenses.priority_group_id`
- [x] 2.7 Add query `GetUnclassifiedExpenseCount` — count expenses where `priority_group_id IS NULL` for a user and date range
- [x] 2.8 Remove `UpdateCategoryType`, `GetCategoriesByType` queries
- [x] 2.9 Remove `category_type` from `GetBudgetVariance` query results
- [x] 2.10 Run `sqlc generate` to regenerate Go code

## 3. Backend — Priority Groups API

- [x] 3.1 Add `PriorityGroupResponse` model in `models.go`
- [x] 3.2 Create `GetPriorityGroups` handler in a new or existing handler file
- [x] 3.3 Register route `GET /api/budget/priority-groups` in `routes.go`

## 4. Backend — Expense API Updates

- [x] 4.1 Update `CreateExpenseRequest` model to include optional `priority_group_id`
- [x] 4.2 Update `UpdateExpenseRequest` model to include optional `priority_group_id`
- [x] 4.3 Update `ExpenseResponse` model to include `priority_group` object (id, name, slug) or null
- [x] 4.4 Update expense create handler to pass `priority_group_id` to query
- [x] 4.5 Update expense update handler to pass `priority_group_id` to query
- [x] 4.6 Update expense list/get response mapping to include priority group data

## 5. Backend — Remove Category Type

- [x] 5.1 Remove `UpdateCategoryType` handler from `handler_budget.go`
- [x] 5.2 Remove `PUT /api/budget/categories/:id/type` route from `routes.go`
- [x] 5.3 Remove `UpdateCategoryTypeRequest` model from `models.go`
- [x] 5.4 Remove `category_type` from `CategoryBudgetWithVarianceResponse` model
- [x] 5.5 Remove `CategoryResponse.CategoryType` if present, or clean up related response fields
- [x] 5.6 Clean up any helper functions related to category type

## 6. Backend — Update 50/30/20 and Health Score

- [x] 6.1 Rewrite `GetFiftyThirtyTwenty` handler to use `GetSpendingByPriorityGroup` query
- [x] 6.2 Add `unclassified_count` and `unclassified_amount` fields to `FiftyThirtyTwentyResponse`
- [x] 6.3 Update `GetHealthScore` handler to use expense-level priority groups
- [x] 6.4 Update any related Swagger annotations

## 7. Backend — Build & Test

- [x] 7.1 Run `go build ./...` and fix compilation errors
- [x] 7.2 Run `go vet ./...`
- [x] 7.3 Regenerate Swagger docs with `make swagger`

## 8. Frontend — Types & API Client

- [ ] 8.1 Add `PriorityGroup` type (id, name, slug, display_order)
- [ ] 8.2 Add `fetchPriorityGroups()` API function
- [ ] 8.3 Update `Expense` type to include optional `priority_group` object
- [ ] 8.4 Update `CreateExpenseRequest` / `UpdateExpenseRequest` types to include optional `priority_group_id`
- [ ] 8.5 Update `FiftyThirtyTwentyResponse` type to include `unclassified_count` and `unclassified_amount`
- [ ] 8.6 Remove `UpdateCategoryTypeRequest` type and `updateCategoryType()` API function
- [ ] 8.7 Remove duplicate `fetchCategoryTypeSpending()` function
- [ ] 8.8 Remove unused `FiftyThirtyTwentyData` and `CategoryTypeSpending` types

## 9. Frontend — React Query Hooks

- [ ] 9.1 Add `usePriorityGroups()` hook
- [ ] 9.2 Remove `useUpdateCategoryType` mutation hook
- [ ] 9.3 Update expense mutation hooks to pass `priority_group_id`

## 10. Frontend — Expense Forms

- [ ] 10.1 Add priority group dropdown to `ExpenseFormDialog` (optional field)
- [ ] 10.2 Add priority group dropdown to `ExpenseDetailDialog` edit mode
- [ ] 10.3 Show priority group badge on expense cards and detail view

## 11. Frontend — Refactor Category Type Selector

- [ ] 11.1 Remove or repurpose `CategoryTypeSelector` component (no longer needed for categories)
- [ ] 11.2 Update `CategoryTypeBadge` to show priority from expense level if still used, or remove
- [ ] 11.3 Remove category type column from settings page category list if present

## 12. Frontend — Update 50/30/20 Chart

- [ ] 12.1 Update `FiftyThirtyTwentyChart` to display unclassified count/amount if > 0
- [ ] 12.2 Verify data flow still works with updated response shape

## 13. Frontend — Lint & Verify

- [ ] 13.1 Run `npx tsc --noEmit` and fix TypeScript errors
- [ ] 13.2 Run `pnpm lint` and fix ESLint errors (in modified files only)
- [ ] 13.3 Verify no remaining references to `category_type` in frontend code (except in migration-related comments)
