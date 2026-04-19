# Budget JSON Import/Export + Static Recurring Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add merge-mode JSON export/import for budget categories/tags/incomes/expenses while migrating recurring skip behavior from synthetic negative rows to persisted status/source-rule semantics in existing income/expense tables.

**Architecture:** Keep `budget_incomes` and `budget_expenses` as the single source of truth for both templates and materialized/manual rows. Add additive schema fields (`status`, `source_rule_id`) and update handlers/queries to use persisted state instead of `Skipped:` marker rows. Implement import/export as dedicated budget endpoints with deterministic merge matching (exact-date gate, description+amount priority) and row-level conflict reporting.

**Tech Stack:** Go (Echo, sqlc, pgx), PostgreSQL (goose migrations), Next.js/TypeScript (React Query, shadcn/ui), pnpm.

---

### Task 1: Add status/source-rule schema foundation

**Files:**
- Create: `web/apps/api-gateway/migrations/015_add_budget_status_source_rule.sql`
- Modify: `web/apps/api-gateway/sql/queries/income.sql`
- Modify: `web/apps/api-gateway/sql/queries/budget.sql`
- Test: `web/apps/api-gateway/migrations/015_add_budget_status_source_rule.sql` (up/down validated via migrate commands)

- [ ] **Step 1: Write migration file with additive columns, constraints, and indexes**

```sql
-- +goose Up
ALTER TABLE budget_incomes
  ADD COLUMN status text NOT NULL DEFAULT 'posted',
  ADD COLUMN source_rule_id uuid NULL;

ALTER TABLE budget_expenses
  ADD COLUMN status text NOT NULL DEFAULT 'posted',
  ADD COLUMN source_rule_id uuid NULL;

ALTER TABLE budget_incomes
  ADD CONSTRAINT budget_incomes_status_check
  CHECK (status IN ('pending', 'posted', 'skipped'));

ALTER TABLE budget_expenses
  ADD CONSTRAINT budget_expenses_status_check
  CHECK (status IN ('pending', 'posted', 'skipped'));

ALTER TABLE budget_incomes
  ADD CONSTRAINT budget_incomes_source_rule_id_fkey
  FOREIGN KEY (source_rule_id) REFERENCES budget_incomes(id) ON DELETE SET NULL;

ALTER TABLE budget_expenses
  ADD CONSTRAINT budget_expenses_source_rule_id_fkey
  FOREIGN KEY (source_rule_id) REFERENCES budget_expenses(id) ON DELETE SET NULL;

CREATE INDEX idx_budget_incomes_user_source_rule ON budget_incomes(user_id, source_rule_id);
CREATE INDEX idx_budget_expenses_user_source_rule ON budget_expenses(user_id, source_rule_id);
CREATE INDEX idx_budget_incomes_user_status_date ON budget_incomes(user_id, status, date DESC);
CREATE INDEX idx_budget_expenses_user_status_date ON budget_expenses(user_id, status, expense_date DESC);

-- +goose Down
DROP INDEX IF EXISTS idx_budget_expenses_user_status_date;
DROP INDEX IF EXISTS idx_budget_incomes_user_status_date;
DROP INDEX IF EXISTS idx_budget_expenses_user_source_rule;
DROP INDEX IF EXISTS idx_budget_incomes_user_source_rule;

ALTER TABLE budget_expenses DROP CONSTRAINT IF EXISTS budget_expenses_source_rule_id_fkey;
ALTER TABLE budget_incomes DROP CONSTRAINT IF EXISTS budget_incomes_source_rule_id_fkey;
ALTER TABLE budget_expenses DROP CONSTRAINT IF EXISTS budget_expenses_status_check;
ALTER TABLE budget_incomes DROP CONSTRAINT IF EXISTS budget_incomes_status_check;

ALTER TABLE budget_expenses DROP COLUMN IF EXISTS source_rule_id;
ALTER TABLE budget_expenses DROP COLUMN IF EXISTS status;
ALTER TABLE budget_incomes DROP COLUMN IF EXISTS source_rule_id;
ALTER TABLE budget_incomes DROP COLUMN IF EXISTS status;
```

- [ ] **Step 2: Replace synthetic skip queries with status-based queries**

```sql
-- income.sql
-- name: CheckSkippedIncome :one
SELECT EXISTS(
  SELECT 1 FROM budget_incomes
  WHERE user_id = $1
    AND date = $2
    AND status = 'skipped'
);

-- budget.sql
-- name: CheckSkippedExpense :one
SELECT EXISTS(
  SELECT 1 FROM budget_expenses
  WHERE user_id = $1
    AND expense_date = $2
    AND status = 'skipped'
);
```

- [ ] **Step 3: Add period queries that return status-aware persisted rows**

```sql
-- income.sql
-- name: GetIncomeRowsForPeriod :many
SELECT * FROM budget_incomes
WHERE user_id = $1
  AND date >= $2
  AND date <= $3
ORDER BY date DESC, created_at DESC;

-- budget.sql
-- name: GetExpenseRowsForPeriod :many
SELECT * FROM budget_expenses
WHERE user_id = $1
  AND expense_date >= $2
  AND expense_date <= $3
ORDER BY expense_date DESC, created_at DESC;
```

- [ ] **Step 4: Run migration up/down locally to verify reversibility**

Run: `make migrate-up && make migrate-down && make migrate-up`
Expected: migration applies, rolls back cleanly, and reapplies without constraint/index conflicts.

- [ ] **Step 5: Commit Task 1 changes**

```bash
git add web/apps/api-gateway/migrations/015_add_budget_status_source_rule.sql web/apps/api-gateway/sql/queries/income.sql web/apps/api-gateway/sql/queries/budget.sql
git commit -m "feat(budget): add status and source-rule schema for recurring rows"
```

### Task 2: Regenerate sqlc artifacts and stabilize compile surface

**Files:**
- Modify (generated): `web/apps/api-gateway/internal/repository/sqlc/income.sql.go`
- Modify (generated): `web/apps/api-gateway/internal/repository/sqlc/budget.sql.go`
- Modify (generated): `web/apps/api-gateway/internal/repository/sqlc/models.go`
- Modify (generated): `web/apps/api-gateway/internal/repository/sqlc/querier.go`
- Test: `web/apps/api-gateway/internal/repository/sqlc/*.go` (generated compile)

- [ ] **Step 1: Regenerate sqlc from updated query definitions**

Run: `make sqlc-generate`
Expected: generated files under `internal/repository/sqlc/` include new query params/rows for status/source-rule fields.

- [ ] **Step 2: Verify generated API includes new query methods**

```go
// querier.go should now include signatures like:
CheckSkippedIncome(ctx context.Context, arg CheckSkippedIncomeParams) (bool, error)
CheckSkippedExpense(ctx context.Context, arg CheckSkippedExpenseParams) (bool, error)
GetIncomeRowsForPeriod(ctx context.Context, arg GetIncomeRowsForPeriodParams) ([]BudgetIncome, error)
GetExpenseRowsForPeriod(ctx context.Context, arg GetExpenseRowsForPeriodParams) ([]BudgetExpense, error)
```

- [ ] **Step 3: Run backend compile check before handler edits**

Run: `cd apps/api-gateway && go build ./...`
Expected: PASS (or compile failures limited to planned handler/model updates in next tasks).

- [ ] **Step 4: Commit regenerated sqlc files**

```bash
git add web/apps/api-gateway/internal/repository/sqlc/
git commit -m "chore(sqlc): regenerate budget queries for status-based recurring"
```

### Task 3: Update backend models and recurring read path to persisted status

**Files:**
- Modify: `web/apps/api-gateway/internal/domain/budget/models.go`
- Modify: `web/apps/api-gateway/internal/domain/budget/handler_income.go`
- Modify: `web/apps/api-gateway/internal/domain/budget/handler.go`
- Create: `web/apps/api-gateway/internal/domain/budget/recurring_status_test.go`
- Test: `web/apps/api-gateway/internal/domain/budget/recurring_status_test.go`

- [ ] **Step 1: Add status/source rule fields to API response models**

```go
type IncomeResponse struct {
  ID            uuid.UUID  `json:"id"`
  Amount        float64    `json:"amount"`
  Currency      string     `json:"currency"`
  Date          string     `json:"date"`
  Description   *string    `json:"description,omitempty"`
  RecurringType *string    `json:"recurring_type,omitempty"`
  StartDate     *string    `json:"start_date,omitempty"`
  EndDate       *string    `json:"end_date,omitempty"`
  Status        string     `json:"status"`
  SourceRuleID  *uuid.UUID `json:"source_rule_id,omitempty"`
  CreatedAt     string     `json:"created_at"`
  UpdatedAt     string     `json:"updated_at"`
}

type IncomeOccurrence struct {
  ID             string  `json:"id"`
  SourceIncomeID string  `json:"source_income_id"`
  Amount         float64 `json:"amount"`
  Currency       string  `json:"currency"`
  Date           string  `json:"date"`
  Description    *string `json:"description,omitempty"`
  RecurringType  *string `json:"recurring_type,omitempty"`
  Status         string  `json:"status"`
}
```

- [ ] **Step 2: Remove virtual expansion from income occurrences endpoint**

```go
rows, err := h.queries.GetIncomeRowsForPeriod(ctx, sqlc.GetIncomeRowsForPeriodParams{
  UserID: userID,
  Date:   pgtype.Date{Time: startDate, Valid: true},
  Date_2: pgtype.Date{Time: endDate, Valid: true},
})

for _, inc := range rows {
  ruleID := inc.ID.String()
  if inc.SourceRuleID.Valid {
    ruleID = inc.SourceRuleID.Bytes.String()
  }
  allOccurrences = append(allOccurrences, IncomeOccurrence{
    ID:             inc.ID.String(),
    SourceIncomeID: ruleID,
    Amount:         numericToFloat64(inc.Amount),
    Currency:       getCurrency(inc.Currency),
    Date:           dateToString(inc.Date),
    Description:    textToStringPtr(inc.Description),
    RecurringType:  textToStringPtr(inc.RecurringType),
    Status:         inc.Status,
  })
}
```

- [ ] **Step 3: Update skip-check handlers to use status-based query results**

```go
exists, err := h.queries.CheckSkippedIncome(ctx, sqlc.CheckSkippedIncomeParams{ ... })
return c.JSON(http.StatusOK, exists)

exists, err := h.queries.CheckSkippedExpense(ctx, sqlc.CheckSkippedExpenseParams{ ... })
return c.JSON(http.StatusOK, exists)
```

- [ ] **Step 4: Add tests proving non-virtual status-based behavior**

```go
func TestMapIncomeRowsToOccurrences_PreservesStatus(t *testing.T) {
  rows := []sqlc.BudgetIncome{
    {ID: mustUUID("11111111-1111-1111-1111-111111111111"), Status: "skipped"},
  }
  got := mapIncomeRowsToOccurrences(rows)
  if got[0].Status != "skipped" {
    t.Fatalf("expected skipped, got %s", got[0].Status)
  }
}
```

- [ ] **Step 5: Run focused budget tests**

Run: `cd apps/api-gateway && go test -v ./internal/domain/budget -run Recurring`
Expected: PASS with new recurring-status tests.

- [ ] **Step 6: Commit Task 3 changes**

```bash
git add web/apps/api-gateway/internal/domain/budget/models.go web/apps/api-gateway/internal/domain/budget/handler_income.go web/apps/api-gateway/internal/domain/budget/handler.go web/apps/api-gateway/internal/domain/budget/recurring_status_test.go
git commit -m "refactor(budget): use persisted status for recurring occurrence reads"
```

### Task 4: Add backend import/export models and merge matcher core

**Files:**
- Create: `web/apps/api-gateway/internal/domain/budget/import_export_models.go`
- Create: `web/apps/api-gateway/internal/domain/budget/import_export_matcher.go`
- Create: `web/apps/api-gateway/internal/domain/budget/import_export_matcher_test.go`
- Modify: `web/apps/api-gateway/internal/domain/budget/models.go`
- Test: `web/apps/api-gateway/internal/domain/budget/import_export_matcher_test.go`

- [ ] **Step 1: Define JSON payload and result contracts**

```go
type BudgetExportPayload struct {
  Meta       BudgetExportMeta      `json:"meta"`
  Categories []ExportCategory      `json:"categories"`
  Tags       []ExportTag           `json:"tags"`
  Incomes    []ExportIncomeRow     `json:"incomes"`
  Expenses   []ExportExpenseRow    `json:"expenses"`
}

type BudgetImportResult struct {
  Created         int                    `json:"created"`
  SkippedExisting int                    `json:"skipped_existing"`
  Conflicts       int                    `json:"conflicts"`
  Errors          int                    `json:"errors"`
  ConflictDetails []BudgetImportConflict `json:"conflict_details"`
}
```

- [ ] **Step 2: Implement exact-date + description/amount-priority matcher**

```go
func MatchIncomingIncome(incoming ExportIncomeRow, candidates []sqlc.BudgetIncome) MatchResult {
  sameDate := filterByDate(candidates, incoming.Date)
  if len(sameDate) == 0 {
    return MatchResult{Action: MatchCreate}
  }
  if exact := findExactDescriptionAmount(sameDate, incoming.Description, incoming.Amount); exact != nil {
    return MatchResult{Action: MatchSkipExisting, ExistingID: exact.ID}
  }
  return MatchResult{Action: MatchConflict, ExistingID: sameDate[0].ID, Reason: "exact-date mismatch on key fields"}
}
```

- [ ] **Step 3: Write table-driven matcher tests for the approved rules**

```go
func TestMatchIncomingIncome_ExactDateAndDescriptionAmountPriority(t *testing.T) {
  tests := []struct {
    name string
    incoming ExportIncomeRow
    candidates []sqlc.BudgetIncome
    wantAction MatchAction
  }{
    {name: "non exact date creates", wantAction: MatchCreate},
    {name: "exact date + desc + amount skips", wantAction: MatchSkipExisting},
    {name: "exact date mismatch conflicts", wantAction: MatchConflict},
  }
  // iterate and assert
}
```

- [ ] **Step 4: Run matcher tests**

Run: `cd apps/api-gateway && go test -v ./internal/domain/budget -run MatchIncoming`
Expected: PASS with all three conflict-policy scenarios.

- [ ] **Step 5: Commit Task 4 changes**

```bash
git add web/apps/api-gateway/internal/domain/budget/import_export_models.go web/apps/api-gateway/internal/domain/budget/import_export_matcher.go web/apps/api-gateway/internal/domain/budget/import_export_matcher_test.go web/apps/api-gateway/internal/domain/budget/models.go
git commit -m "feat(budget): add import/export payloads and merge matcher rules"
```

### Task 5: Implement backend export/import handlers and route wiring

**Files:**
- Create: `web/apps/api-gateway/internal/domain/budget/handler_import_export.go`
- Modify: `web/apps/api-gateway/internal/domain/budget/handler.go`
- Modify: `web/apps/api-gateway/internal/app/routes.go`
- Modify: `web/apps/api-gateway/sql/queries/income.sql`
- Modify: `web/apps/api-gateway/sql/queries/budget.sql`
- Test: `web/apps/api-gateway/internal/domain/budget/handler_import_export_test.go`

- [ ] **Step 1: Add export queries for all entities in scope**

```sql
-- income.sql
-- name: ListExportIncomes :many
SELECT * FROM budget_incomes
WHERE user_id = $1
ORDER BY date ASC, created_at ASC;

-- budget.sql
-- name: ListExportExpenses :many
SELECT * FROM budget_expenses
WHERE user_id = $1
ORDER BY expense_date ASC, created_at ASC;
```

- [ ] **Step 2: Implement `ExportBudgetJSON` handler**

```go
func (h *Handler) ExportBudgetJSON(c echo.Context) error {
  userID, err := h.getUserID(c)
  if err != nil { ... }

  cats, _ := h.queries.ListCategories(c.Request().Context(), userID)
  tags, _ := h.queries.ListTags(c.Request().Context(), userID)
  incomes, _ := h.queries.ListExportIncomes(c.Request().Context(), userID)
  expenses, _ := h.queries.ListExportExpenses(c.Request().Context(), userID)

  payload := buildBudgetExportPayload(cats, tags, incomes, expenses)
  return c.JSON(http.StatusOK, payload)
}
```

- [ ] **Step 3: Implement `ImportBudgetJSON` merge-only handler**

```go
func (h *Handler) ImportBudgetJSON(c echo.Context) error {
  userID, err := h.requireUser(c)
  if err != nil { ... }

  var payload BudgetExportPayload
  if err := c.Bind(&payload); err != nil {
    return c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "invalid import payload"})
  }

  result := BudgetImportResult{}
  if err := h.applyBudgetMergeImport(c.Request().Context(), userID, payload, &result); err != nil {
    return c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "import failed"})
  }
  return c.JSON(http.StatusOK, result)
}
```

- [ ] **Step 4: Register new budget endpoints**

```go
budget.GET("/export", a.BudgetHandler.ExportBudgetJSON)
budget.POST("/import", a.BudgetHandler.ImportBudgetJSON)
```

- [ ] **Step 5: Add integration-style handler tests for export and merge import**

```go
func TestImportBudgetJSON_SkipsExistingOnExactDateMatch(t *testing.T) {
  // seed one income row
  // import same date/description/amount
  // assert skipped_existing incremented, created unchanged
}

func TestImportBudgetJSON_ConflictsOnExactDateMismatch(t *testing.T) {
  // same date but different amount/description
  // assert conflicts incremented and conflict_details populated
}
```

- [ ] **Step 6: Run backend package tests**

Run: `cd apps/api-gateway && go test -v ./internal/domain/budget`
Expected: PASS including new import/export handler tests.

- [ ] **Step 7: Commit Task 5 changes**

```bash
git add web/apps/api-gateway/internal/domain/budget/handler_import_export.go web/apps/api-gateway/internal/domain/budget/handler.go web/apps/api-gateway/internal/app/routes.go web/apps/api-gateway/sql/queries/income.sql web/apps/api-gateway/sql/queries/budget.sql web/apps/api-gateway/internal/domain/budget/handler_import_export_test.go
git commit -m "feat(budget): add merge-mode JSON export and import endpoints"
```

### Task 6: Replace synthetic skip writes with status-based skip actions

**Files:**
- Modify: `web/apps/api-gateway/internal/domain/budget/handler_income.go`
- Modify: `web/apps/api-gateway/internal/domain/budget/handler.go`
- Modify: `web/apps/api-gateway/sql/queries/income.sql`
- Modify: `web/apps/api-gateway/sql/queries/budget.sql`
- Test: `web/apps/api-gateway/internal/domain/budget/skip_status_test.go`

- [ ] **Step 1: Add upsert-style skip queries keyed by user/date/source_rule_id**

```sql
-- income.sql
-- name: MarkIncomeSkipped :one
INSERT INTO budget_incomes (user_id, amount, currency, date, description, recurring_type, status, source_rule_id)
VALUES ($1, $2, $3, $4, $5, $6, 'skipped', $7)
ON CONFLICT (user_id, date, source_rule_id)
DO UPDATE SET status = 'skipped', updated_at = NOW()
RETURNING *;
```

```sql
-- budget.sql
-- name: MarkExpenseSkipped :one
INSERT INTO budget_expenses (user_id, description, amount, currency, expense_date, recurring_type, status, source_rule_id)
VALUES ($1, $2, $3, $4, $5, $6, 'skipped', $7)
ON CONFLICT (user_id, expense_date, source_rule_id)
DO UPDATE SET status = 'skipped', updated_at = NOW()
RETURNING *;
```

- [ ] **Step 2: Add explicit skip handlers instead of negative amount creation**

```go
func (h *Handler) SkipIncomeOccurrence(c echo.Context) error {
  userID, err := h.requireUser(c)
  if err != nil { ... }
  var req SkipIncomeRequest
  if err := validator.BindAndValidate[SkipIncomeRequest](c); err != nil { ... }
  row, err := h.queries.MarkIncomeSkipped(c.Request().Context(), toMarkIncomeSkippedParams(userID, req))
  if err != nil { ... }
  return c.JSON(http.StatusOK, mapIncome(row))
}
```

- [ ] **Step 3: Wire skip endpoints in routes**

```go
incomes.POST("/skip", a.BudgetHandler.SkipIncomeOccurrence)
expenses.POST("/skip", a.BudgetHandler.SkipExpenseOccurrence)
```

- [ ] **Step 4: Add tests ensuring skip updates status rather than creating marker hacks**

```go
func TestSkipIncomeOccurrence_SetsSkippedStatus(t *testing.T) {
  // call handler with source_rule_id/date
  // assert persisted row status == "skipped"
  // assert description does not require "Skipped:" prefix
}
```

- [ ] **Step 5: Run targeted skip tests**

Run: `cd apps/api-gateway && go test -v ./internal/domain/budget -run Skip`
Expected: PASS with status-based skip semantics.

- [ ] **Step 6: Commit Task 6 changes**

```bash
git add web/apps/api-gateway/internal/domain/budget/handler_income.go web/apps/api-gateway/internal/domain/budget/handler.go web/apps/api-gateway/sql/queries/income.sql web/apps/api-gateway/sql/queries/budget.sql web/apps/api-gateway/internal/domain/budget/skip_status_test.go
git commit -m "feat(budget): switch recurring skip flow to status-based rows"
```

### Task 7: Add frontend API/types/hooks for budget import/export and status-aware skip

**Files:**
- Modify: `web/apps/core/src/types/api.ts`
- Modify: `web/apps/core/src/lib/api.ts`
- Modify: `web/apps/core/src/hooks/use-budget.ts`
- Test: `web/apps/core/src/types/api.ts` (type-check via `npx tsc --noEmit`)

- [ ] **Step 1: Add import/export payload/result TypeScript types**

```ts
export interface BudgetExportPayload {
  meta: { version: string; exported_at: string; user_email_hint?: string };
  categories: ExportCategory[];
  tags: ExportTag[];
  incomes: ExportIncomeRow[];
  expenses: ExportExpenseRow[];
}

export interface BudgetImportResult {
  created: number;
  skipped_existing: number;
  conflicts: number;
  errors: number;
  conflict_details: BudgetImportConflict[];
}
```

- [ ] **Step 2: Add API client methods for export/import and skip actions**

```ts
export async function exportBudgetJSON(): Promise<BudgetExportPayload> {
  const res = await fetch(url + '/api/budget/export', { credentials: 'include' });
  if (!res.ok) throw new Error(`Error exporting budget data: ${res.status}`);
  return res.json();
}

export async function importBudgetJSON(payload: BudgetExportPayload): Promise<BudgetImportResult> {
  const res = await fetch(url + '/api/budget/import', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',
    body: JSON.stringify(payload)
  });
  if (!res.ok) throw new Error(`Error importing budget data: ${res.status}`);
  return res.json();
}
```

- [ ] **Step 3: Add React Query hooks and cache invalidation strategy**

```ts
export function useImportBudgetJSON() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: importBudgetJSON,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: budgetKeys.all });
    }
  });
}

export function useExportBudgetJSON() {
  return useMutation({ mutationFn: exportBudgetJSON });
}
```

- [ ] **Step 4: Run frontend type-check**

Run: `cd apps/core && npx tsc --noEmit`
Expected: PASS with new budget import/export and status fields.

- [ ] **Step 5: Commit Task 7 changes**

```bash
git add web/apps/core/src/types/api.ts web/apps/core/src/lib/api.ts web/apps/core/src/hooks/use-budget.ts
git commit -m "feat(core): add budget import/export API and hooks"
```

### Task 8: Add budget settings UI for JSON export/import and update skip dialogs

**Files:**
- Modify: `web/apps/core/src/app/dashboard/budget/settings/page.tsx`
- Modify: `web/apps/core/src/components/budget/skip-occurrence-dialog.tsx`
- Modify: `web/apps/core/src/components/budget/skip-expense-dialog.tsx`
- Test: `web/apps/core/src/app/dashboard/budget/settings/page.tsx` (lint/build verification)

- [ ] **Step 1: Add export button and JSON download flow to settings page**

```tsx
const handleExport = async () => {
  const payload = await exportMutation.mutateAsync();
  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: 'application/json' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = `budget-export-${new Date().toISOString().slice(0, 10)}.json`;
  link.click();
  URL.revokeObjectURL(link.href);
};
```

- [ ] **Step 2: Add JSON import file input and conflict summary rendering**

```tsx
<Input type="file" accept="application/json" onChange={handleImportFile} />

{importResult && (
  <div className="rounded-lg border p-3 text-sm">
    <p>Created: {importResult.created}</p>
    <p>Skipped existing: {importResult.skipped_existing}</p>
    <p>Conflicts: {importResult.conflicts}</p>
    <p>Errors: {importResult.errors}</p>
  </div>
)}
```

- [ ] **Step 3: Switch skip dialogs to call skip endpoints (not negative create)**

```tsx
await skipIncomeMutation.mutateAsync({
  source_rule_id: income.id,
  date: skipDate,
  description: income.description
});
```

```tsx
await skipExpenseMutation.mutateAsync({
  source_rule_id: expense.id,
  expense_date: skipDate,
  description: expense.description
});
```

- [ ] **Step 4: Run frontend lint and build checks**

Run: `cd apps/core && pnpm lint && pnpm build`
Expected: lint/build pass; settings page and skip dialogs compile with new hooks/types.

- [ ] **Step 5: Commit Task 8 changes**

```bash
git add web/apps/core/src/app/dashboard/budget/settings/page.tsx web/apps/core/src/components/budget/skip-occurrence-dialog.tsx web/apps/core/src/components/budget/skip-expense-dialog.tsx
git commit -m "feat(core): add budget JSON import/export UI and status-based skip actions"
```

### Task 9: End-to-end verification and docs sync

**Files:**
- Modify: `docs/superpowers/specs/2026-04-19-budget-json-merge-static-recurring-design.md` (only if implementation-level clarifications are needed)
- Test: backend and frontend command outputs (no new file required)

- [ ] **Step 1: Run full backend test suite**

Run: `cd apps/api-gateway && go test ./...`
Expected: PASS.

- [ ] **Step 2: Run full frontend quality gates**

Run: `cd apps/core && npx tsc --noEmit && pnpm lint`
Expected: PASS.

- [ ] **Step 3: Run workspace build check**

Run: `cd /home/eisen/personal/core-k8s-homelab/web && make build`
Expected: backend and frontend build successfully.

- [ ] **Step 4: Add final commit for verification/doc touch-ups (if any)**

```bash
git add -A
git commit -m "chore(budget): verify import/export and recurring status migration"
```
