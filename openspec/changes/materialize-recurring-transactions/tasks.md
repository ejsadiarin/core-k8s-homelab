## 1. Database Migration — Occurrence Tables

- [ ] 1.1 Create migration file `015_create_occurrence_tables.sql` with `budget_income_occurrences` table (id, source_income_id FK, user_id FK, amount, currency, occurrence_date, description, is_skipped, skip_reason, created_at, updated_at, UNIQUE(source_income_id, occurrence_date))
- [ ] 1.2 Add `budget_expense_occurrences` table to the same migration (id, source_expense_id FK, user_id FK, amount, currency, occurrence_date, description, category_id FK, is_skipped, skip_reason, created_at, updated_at, UNIQUE(source_expense_id, occurrence_date))
- [ ] 1.3 Add composite indexes on (user_id, occurrence_date) for both tables
- [ ] 1.4 Write `-- +goose Down` to drop both tables
- [ ] 1.5 Run migration and verify schema

## 2. Database Migration — Backfill Existing Rules

- [ ] 2.1 Create migration file `016_backfill_occurrences.sql` with Go-based backfill logic (or SQL procedural block)
- [ ] 2.2 Implement weekly occurrence generation: align to rule's start_date weekday, step by 7 days from start_date to min(end_date, now + 1 year)
- [ ] 2.3 Implement monthly occurrence generation: align to rule's day-of-month with end-of-month clamping, step monthly from start_date to min(end_date, now + 1 year)
- [ ] 2.4 Implement daily occurrence generation: step by 1 day from start_date to min(end_date, now + 1 year)
- [ ] 2.5 Backfill all 4 existing weekly income rules and verify occurrence count matches expected virtual expansion
- [ ] 2.6 Backfill the 1 existing monthly expense rule (Spotify) and verify occurrence count

## 3. Database Migration — Migrate Skip Records

- [ ] 3.1 In the same migration (or a new `017_migrate_skip_records.sql`), match existing "Skipped:" negative income records to occurrence rows by date and source rule description
- [ ] 3.2 Set is_skipped = true on matched occurrence rows
- [ ] 3.3 Delete the matched "Skipped:" negative income records from budget_incomes
- [ ] 3.4 Log/preserve any unmatched skip records
- [ ] 3.5 Write `-- +goose Down` to reverse: recreate negative records from is_skipped occurrences and set is_skipped = false

## 4. Backend — SQL Queries for Occurrences

- [ ] 4.1 Add `GetIncomeOccurrencesForPeriod` query: SELECT from budget_income_occurrences WHERE user_id, occurrence_date range, ordered by occurrence_date DESC
- [ ] 4.2 Add `GetRecurringIncomeTotal` query: SELECT SUM(amount) from budget_income_occurrences WHERE user_id, occurrence_date range, is_skipped = false
- [ ] 4.3 Add `GetExpenseOccurrencesForPeriod` query: SELECT from budget_expense_occurrences WHERE user_id, occurrence_date range
- [ ] 4.4 Add `GetRecurringExpenseTotal` query: SELECT SUM(amount) from budget_expense_occurrences WHERE user_id, occurrence_date range, is_skipped = false
- [ ] 4.5 Add `SkipIncomeOccurrence` query: UPDATE budget_income_occurrences SET is_skipped = true, skip_reason = $3 WHERE id = $1 AND user_id = $2
- [ ] 4.6 Add `UnskipIncomeOccurrence` query: UPDATE budget_income_occurrences SET is_skipped = false, skip_reason = NULL WHERE id = $1 AND user_id = $2
- [ ] 4.7 Add `SkipExpenseOccurrence` and `UnskipExpenseOccurrence` queries (same pattern)
- [ ] 4.8 Add `GetNextIncomeOccurrence` query: SELECT first non-skipped occurrence WHERE occurrence_date >= today, LIMIT 1
- [ ] 4.9 Add `CreateIncomeOccurrence` and `CreateExpenseOccurrence` insert queries for generation logic
- [ ] 4.10 Add `DeleteFutureIncomeOccurrences` and `DeleteFutureExpenseOccurrences` queries for rule update regeneration
- [ ] 4.11 Run `sqlc generate` and verify generated code

## 5. Backend — Occurrence Generation Logic

- [ ] 5.1 Create `occurrence_generator.go` with `GenerateIncomeOccurrences(rule, horizon)` function implementing date alignment (weekday for weekly, day-of-month for monthly)
- [ ] 5.2 Create `GenerateExpenseOccurrences(rule, horizon)` function (same logic, different table)
- [ ] 5.3 Wire occurrence generation into income create handler: after inserting rule, generate occurrences in same transaction
- [ ] 5.4 Wire occurrence generation into expense create handler
- [ ] 5.5 Wire occurrence regeneration into income update handler: delete future occurrences, regenerate from today
- [ ] 5.6 Wire occurrence regeneration into expense update handler

## 6. Backend — Refactor Stats Calculations

- [ ] 6.1 Replace `calculateRecurringIncome` with query to `GetRecurringIncomeTotal` (cumulative from start to target date)
- [ ] 6.2 Replace `calculateRecurringIncomeForPeriod` with query to `GetRecurringIncomeTotal` (for period range)
- [ ] 6.3 Replace `calculateRecurringExpenses`/`calculateRecurringExpensesForPeriod` with occurrence table queries
- [ ] 6.4 Update `GetBudgetRemaining` handler to use occurrence-based totals
- [ ] 6.5 Update `GetSavingsRate` handler to use occurrence-based totals
- [ ] 6.6 Update `GetHealthScore` handler to use occurrence-based totals
- [ ] 6.7 Update `GetSpendingVelocity` handler if it uses recurring calculations

## 7. Backend — Refactor Occurrences Endpoint

- [ ] 7.1 Refactor `GetIncomeOccurrences` to query budget_income_occurrences instead of virtual expansion
- [ ] 7.2 Combine one-time incomes with occurrence rows in the response (same IncomeOccurrence struct)
- [ ] 7.3 Update `IsVirtual` field: set to false for all occurrence rows (or remove the field)
- [ ] 7.4 Update pagination to use SQL-level OFFSET/LIMIT instead of in-memory slicing

## 8. Backend — Refactor Skip Endpoints

- [ ] 8.1 Add `PATCH /api/budget/incomes/occurrences/:id/skip` endpoint to set is_skipped = true
- [ ] 8.2 Add `PATCH /api/budget/incomes/occurrences/:id/unskip` endpoint to set is_skipped = false
- [ ] 8.3 Add `PATCH /api/budget/expenses/occurrences/:id/skip` and `/unskip` endpoints
- [ ] 8.4 Remove or deprecate the "create negative record" skip flow
- [ ] 8.5 Remove `CheckSkippedIncome` and `CheckSkippedExpense` queries (no longer needed)
- [ ] 8.6 Update routes.go with new skip endpoints

## 9. Backend — Cleanup

- [ ] 9.1 Remove `calculateRecurringIncome`, `calculateRecurringIncomeForPeriod`, `calculateRecurringExpenses`, `calculateRecurringExpensesForPeriod` functions
- [ ] 9.2 Remove `expandRecurringOccurrences` function
- [ ] 9.3 Remove `calculateNextOccurrence` function (replaced by occurrence table)
- [ ] 9.4 Remove `GetSkippedIncomeDatesForPeriod` query
- [ ] 9.5 Update/remove any dead code referencing virtual expansion

## 10. Frontend — Skip UI Updates

- [ ] 10.1 Update skip income handler to call PATCH occurrence skip endpoint instead of POST negative record
- [ ] 10.2 Update skip expense handler similarly
- [ ] 10.3 Update undo-skip to call PATCH unskip endpoint instead of DELETE negative record
- [ ] 10.4 Remove `CheckSkippedIncome`/`CheckSkippedExpense` API calls from frontend
- [ ] 10.5 Update TypeScript types if response shape changes (is_virtual removal, etc.)

## 11. Testing and Verification

- [ ] 11.1 Run `go build ./...` and verify no compilation errors
- [ ] 11.2 Run existing tests and fix any failures
- [ ] 11.3 Add unit tests for occurrence generation logic (weekly alignment, monthly clamping, daily)
- [ ] 11.4 Add unit tests for occurrence regeneration on rule update
- [ ] 11.5 Verify backfill migration: occurrence count matches expected virtual expansion for all 4 income rules
- [ ] 11.6 Verify skip migration: all 6 "Skipped:" records converted to is_skipped occurrences
- [ ] 11.7 Run frontend typecheck (`npx tsc --noEmit`)
- [ ] 11.8 Run frontend lint
