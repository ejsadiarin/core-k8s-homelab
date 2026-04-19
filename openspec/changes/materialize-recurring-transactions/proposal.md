## Why

Recurring transactions (incomes and expenses) are currently expanded virtually at read-time — the system calculates `amount × periods_in_range` without storing individual occurrence rows. This makes it impossible to track per-occurrence state (skipped, amount overrides, notes), forces every query to re-derive occurrences from rules, and requires a hacky negative-amount workaround for skips. Materializing each occurrence as a real database row makes occurrences first-class entities that can be individually queried, annotated, skipped, and audited.

## What Changes

- **New `budget_income_occurrences` table** storing one row per materialized recurring income occurrence, linked to the parent recurring rule via `source_income_id`
- **New `budget_expense_occurrences` table** storing one row per materialized recurring expense occurrence, linked to the parent recurring rule via `source_expense_id`
- **Occurrence generation on rule creation/update** — when a recurring rule is created or its date range changes, generate all occurrence rows within the rule's effective period (up to a configurable horizon for open-ended rules)
- **Backfill migration** — one-time migration to generate occurrence rows for all existing recurring rules (4 income rules, 1 expense rule)
- **Skip mechanism refactor** — replace the negative-amount hack with an `is_skipped` boolean on occurrence rows; migrate existing "Skipped:" negative records to proper skipped occurrences
- **Stats/analytics refactored** — `calculateRecurringIncome`, `calculateRecurringExpenses`, and related period calculations now query materialized occurrence rows (with `SUM WHERE NOT is_skipped`) instead of deriving from rules
- **Occurrences endpoint refactored** — `GET /api/budget/incomes/occurrences` now queries real rows instead of virtual expansion
- **BREAKING**: Existing "Skipped:" negative income/expense records will be migrated to occurrence rows and deleted; any external tooling reading those negative records will break

## Capabilities

### New Capabilities

- `income-occurrence-materialization`: Materialized income occurrence rows with source rule linkage, skip tracking, and per-occurrence metadata
- `expense-occurrence-materialization`: Materialized expense occurrence rows with source rule linkage, skip tracking, and per-occurrence metadata
- `occurrence-generation`: Logic to generate occurrence rows from recurring rules (on creation, update, and backfill)

### Modified Capabilities

- `budget-incomes`: Recurring income calculations query materialized occurrences instead of virtual expansion
- `budget-expenses`: Recurring expense calculations query materialized occurrences instead of virtual expansion
- `budget-stats`: Period-based stats use occurrence table aggregation instead of rule-based calculation
- `skip-recurring-occurrence`: Skips toggle `is_skipped` on occurrence rows instead of creating negative records
- `recurring-income-periods`: Period income calculation queries occurrence rows instead of deriving from rules
- `recurring-income-list`: Next expected date derived from first future non-skipped occurrence row
- `recurring-summary-card`: Monthly equivalents still calculated from rules (unchanged), but validation against actual occurrences possible

## Impact

- **Database**: 2 new tables (`budget_income_occurrences`, `budget_expense_occurrences`), backfill migration, skip record migration
- **Backend**: `handler_stats.go` (calculation functions), `handler_income.go` (occurrences endpoint), `helpers.go` (generation logic), new SQL queries
- **Frontend**: Minimal — occurrence data shape stays similar; skip UI calls different endpoint logic but same UX
- **API**: Skip endpoint changes from "create negative record" to "PATCH occurrence `is_skipped=true`"; occurrences endpoint returns real rows
- **Risk**: Backfill must correctly reproduce historical occurrence dates matching the current virtual expansion logic
