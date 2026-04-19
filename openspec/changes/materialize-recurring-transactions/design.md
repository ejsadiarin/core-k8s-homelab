## Context

Recurring transactions (incomes and expenses) are calculated at read time via arithmetic period counting (`amount × periods_in_range`) or occurrence expansion (stepping forward from `start_date` by the recurrence interval). Neither approach persists individual occurrence rows in the database.

**Current state:**
- 4 active weekly recurring income rules (₱500 each, Wed/Thu/Fri/Sat), 1 monthly recurring expense (₱85 Spotify)
- Two separate calculation codepaths: **arithmetic counting** (`calculateRecurringIncomeForPeriod` — fast but approximate, doesn't align to actual dates or account for skips) and **occurrence expansion** (`expandRecurringOccurrences` — correct date alignment but only used for the occurrences display endpoint)
- Skips stored as negative-amount one-time records with `"Skipped:"` description prefix — a workaround that doesn't integrate with calculations
- The `GetIncomeOccurrences` endpoint generates virtual occurrence IDs like `"{ruleID}:{date}"` that aren't stable DB references

**Constraints:**
- PostgreSQL database, Goose migrations, sqlc for query generation
- Single user (personal homelab), so scalability is not a primary concern
- Must preserve all historical financial data accurately during migration

## Goals / Non-Goals

**Goals:**
- Materialize each recurring occurrence as a real row in dedicated occurrence tables
- Replace the negative-amount skip hack with an `is_skipped` boolean on occurrence rows
- Refactor stats/analytics calculations to query materialized rows (`SUM WHERE NOT is_skipped`) instead of deriving from rules
- Backfill all historical occurrences for existing recurring rules
- Migrate existing "Skipped:" negative records to proper skipped occurrence rows
- Generate future occurrences when recurring rules are created or updated

**Non-Goals:**
- Automated scheduled occurrence generation (cron job, pg_cron, etc.) — out of scope; occurrences are generated eagerly on rule create/update
- Modifying the recurring rule CRUD itself (rules table stays as-is)
- Supporting custom recurrence patterns beyond daily/weekly/monthly/yearly
- Building an "undo materialization" rollback path in the application layer (DB migration rollback is sufficient)

## Decisions

### 1. Separate occurrence tables (not reusing existing income/expense tables)

**Chosen:** Create `budget_income_occurrences` and `budget_expense_occurrences` as new tables with FK to the parent rule.

**Alternatives considered:**
- *Add columns to existing tables* — mixing rules and occurrences in one table creates ambiguity (is this row a rule or an occurrence?), complicates queries, and makes it harder to enforce constraints
- *Single polymorphic occurrences table* — would need `source_type` discriminator and lose FK integrity

**Rationale:** Separate tables give clean FK references, clear data semantics, and don't pollute existing queries that operate on rules.

### 2. Occurrence table schema

```sql
CREATE TABLE budget_income_occurrences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_income_id UUID NOT NULL REFERENCES budget_incomes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'PHP',
    occurrence_date DATE NOT NULL,
    description TEXT,
    is_skipped BOOLEAN NOT NULL DEFAULT false,
    skip_reason TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(source_income_id, occurrence_date)
);

CREATE TABLE budget_expense_occurrences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_expense_id UUID NOT NULL REFERENCES budget_expenses(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'PHP',
    occurrence_date DATE NOT NULL,
    description TEXT,
    category_id UUID REFERENCES budget_categories(id),
    is_skipped BOOLEAN NOT NULL DEFAULT false,
    skip_reason TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(source_expense_id, occurrence_date)
);
```

**Key design choices:**
- `amount` is denormalized onto each occurrence (copied from rule at generation time) to allow per-occurrence amount overrides in the future
- `UNIQUE(source_income_id, occurrence_date)` prevents duplicate occurrences for the same rule+date
- `ON DELETE CASCADE` — deleting a rule removes all its occurrences
- `user_id` denormalized for efficient per-user queries without joining rules
- `description` copied from rule at generation time for independent auditability
- Expense occurrences include `category_id` copied from the rule

### 3. Eager generation on rule create/update (no cron)

**Chosen:** When a recurring rule is created or its date range changes, generate all occurrences from `start_date` to `min(end_date, start_date + 1 year)` immediately.

**Alternatives considered:**
- *Cron job* — adds operational complexity (scheduling, failure handling, monitoring) for a single-user app
- *Lazy generation on read* — defeats the purpose of materialization; reads would still need expansion logic
- *Database trigger* — less visible/testable than application-level logic

**Rationale:** For a personal homelab with < 1000 occurrences total, eager generation is simple and correct. The 1-year horizon cap prevents unbounded generation for rules with no end date. Users can extend the horizon by updating the rule or adding a manual "regenerate" action later.

### 4. Skip mechanism: `is_skipped` boolean on occurrence rows

**Chosen:** Toggle `is_skipped = true` on the specific occurrence row. Store optional `skip_reason`.

**Replaces:** Creating a separate negative-amount income/expense record with `"Skipped:"` prefix.

**Migration:** Existing 6 "Skipped:" negative income records will be matched to their corresponding occurrence rows (by date and source rule description), the occurrence's `is_skipped` set to true, and the negative records deleted.

### 5. Stats calculations: query occurrence tables

**Chosen:** Replace `calculateRecurringIncomeForPeriod` and related functions with SQL queries:
```sql
SELECT COALESCE(SUM(amount), 0) FROM budget_income_occurrences
WHERE user_id = $1 AND occurrence_date >= $2 AND occurrence_date <= $3
AND is_skipped = false;
```

**Rationale:** This is the whole point — calculations become simple aggregation queries on real data, no more arithmetic period counting or occurrence expansion in Go code.

### 6. Occurrences endpoint: query real rows

The `GET /api/budget/incomes/occurrences` endpoint will query `budget_income_occurrences` directly instead of virtual expansion. The response shape stays the same (`IncomeOccurrence` struct) but `IsVirtual` becomes always `false` (or the field is removed).

### 7. Recurring summary card: derive from rules (unchanged)

Monthly equivalent calculations (weekly × 4.33, etc.) still derive from rules since they represent the *expected* recurring amount, not actual historical data. This is intentional — the summary shows projected cash flow, while stats show actual.

## Risks / Trade-offs

- **[Risk]** Backfill migration generates incorrect occurrence dates that don't match the current virtual expansion logic
  - **Mitigation**: Use the exact same `expandRecurringOccurrences` date alignment logic (weekday for weekly, day-of-month for monthly) in the migration SQL/Go code. Verify by comparing old `GetIncomeOccurrences` output against new occurrence table rows for a known date range.

- **[Risk]** Deleting "Skipped:" negative records breaks historical audit trail
  - **Mitigation**: The migration is reversible (Goose `-- +goose Down` recreates the negative records from occurrence rows where `is_skipped = true`).

- **[Risk]** Occurrence generation horizon (1 year) means users need to trigger regeneration for longer-running rules
  - **Mitigation**: Acceptable for now. Can add a periodic "extend horizon" job or manual button later.

- **[Trade-off]** Denormalized `amount`/`description` on occurrences means updates to the rule don't automatically update existing occurrences
  - **Mitigation**: This is a feature, not a bug — historical occurrences preserve the amount at the time they were expected. Rule updates regenerate only future occurrences.

- **[Trade-off]** More storage (rows in DB) vs. simpler queries
  - **Mitigation**: Negligible for a personal app. ~2000 rows/year for 4 weekly rules.

## Migration Plan

### Phase 1: Schema + Backfill
1. Create new migration with occurrence tables
2. Backfill occurrences for all existing recurring rules using `expandRecurringOccurrences` logic in SQL
3. Match existing "Skipped:" negative records to occurrence rows and set `is_skipped = true`
4. Delete the migrated "Skipped:" negative records
5. Verify: count occurrences matches expected virtual expansion count

### Phase 2: Backend Refactor
1. Add sqlc queries for occurrence CRUD and aggregation
2. Refactor `calculateRecurringIncome*` functions to query occurrence tables
3. Refactor `GetIncomeOccurrences` to query occurrence table
4. Refactor skip mechanism to PATCH occurrence `is_skipped`
5. Add occurrence generation logic on rule create/update
6. Remove old virtual expansion code

### Phase 3: Frontend Updates (Minimal)
1. Update skip UI to call new endpoint (PATCH instead of POST negative record)
2. Remove `IsVirtual` handling if field is dropped
3. Verify all existing pages work with new data source

### Rollback
Goose `-- +goose Down` drops the occurrence tables. The old virtual expansion code can be restored from git. No data loss since rules are preserved.

## Open Questions

- Should occurrence generation happen in a database transaction with rule creation, or is eventual consistency acceptable? (Recommendation: same transaction for simplicity)
- Should we add an index on `(user_id, occurrence_date)` for occurrence tables, or is the unique constraint index sufficient? (Recommendation: add composite index since most queries filter by user + date range)
- Should the recurring summary card validate its projections against actual occurrence data? (Recommendation: not now, add as a future enhancement)
