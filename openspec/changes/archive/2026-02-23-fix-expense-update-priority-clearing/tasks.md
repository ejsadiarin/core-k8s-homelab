## 1. Fix SQL Query

- [x] 1.1 Update `apps/api-gateway/sql/queries/budget.sql` UpdateExpense query to add COALESCE for `end_date` and `priority_group_id` fields

## 2. Regenerate Code

- [x] 2.1 Run `make sqlc-generate` to regenerate sqlc code from updated SQL

## 3. Verification

- [x] 3.1 Build backend to verify no compilation errors (`cd apps/api-gateway && go build ./...`)
