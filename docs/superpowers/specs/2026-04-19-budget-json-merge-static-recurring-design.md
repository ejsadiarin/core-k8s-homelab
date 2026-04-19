# Budget JSON Merge + Static Recurring Design

## Scope

Design the v1 budget data export/import flow with merge behavior and static recurring history, focused on:

- Export/import for budget incomes, expenses, categories, and tags as JSON.
- Merge import policy with conflict reporting.
- Reworking recurring skip/history behavior to persisted status-based records.

This design intentionally excludes the dashboard calculation investigation and recurring skip UI redesign details.

## Goals

- Preserve historical correctness for recurring records when templates change later.
- Replace synthetic skip hacks with explicit status state.
- Support safe merge imports that avoid duplicate inserts.
- Keep implementation aligned with existing schema shape and table usage.

## Non-Goals (v1)

- No replace-mode import.
- No automatic conflict resolution.
- No fuzzy date matching for conflicts.
- No new standalone occurrences table.

## Architecture

Use a hybrid model in existing tables:

- `budget_incomes` and `budget_expenses` continue to store template rows and materialized rows.
- Recurring templates remain rows with recurrence fields (`recurring_type`, `start_date`, `end_date`) and no parent link.
- Materialized recurring instances are persisted rows that reference their template via `source_rule_id`.
- Skips are modeled as state changes with `status='skipped'` on materialized rows.

This keeps compatibility with current domain models while introducing immutable historical snapshots.

## Data Model Changes

Apply migrations under `web/apps/api-gateway/migrations/` to both `budget_incomes` and `budget_expenses`:

- Add `status` column with allowed values: `pending`, `posted`, `skipped`.
- Add nullable `source_rule_id uuid` self-reference to same table.

Recommended constraints/indexes:

- `CHECK (status IN ('pending','posted','skipped'))`.
- Foreign key: `source_rule_id -> id` with `ON DELETE SET NULL`.
- Index on `(user_id, source_rule_id)` for template/instance joins.
- Keep existing recurrence indexes; add status/date indexes only if query plans need them after verification.

Backfill/default behavior:

- Existing rows become `status='posted'`.
- Existing rows keep `source_rule_id=NULL`.

## Row Semantics

- **Template row**
  - Defines recurrence schedule and defaults.
  - `source_rule_id=NULL`.
  - Usually not used as historical event rows.
- **Materialized row**
  - Immutable snapshot for a specific date with copied amount/description/category/tag at creation time.
  - `source_rule_id=<template id>` for recurring-derived items.
  - `status` transitions: `pending -> posted` or `pending -> skipped`.
- **One-time/manual row**
  - `recurring_type=NULL`, `source_rule_id=NULL`, typically `status='posted'`.

## Export Design (v1)

Single JSON payload with metadata and normalized entities:

- `meta`: export version, exported_at, user email hint.
- `categories`: name-based identity entities.
- `tags`: name-based identity entities.
- `incomes`: includes templates and materialized/manual rows.
- `expenses`: includes templates and materialized/manual rows.

Each exported row should include:

- `external_id` (portable record id for intra-file references).
- Snapshot/business fields (`date`, `description`, `amount`, currency, notes, etc.).
- Recurring/template fields when applicable.
- `status`.
- `source_rule_ref` (external id of template when row is materialized recurring instance).

Do not export runtime-virtual occurrences.

## Import Design (v1)

Mode: `merge` only.

Behavior:

- Create missing categories/tags by normalized name.
- Import templates and materialized/manual rows into existing tables.
- Resolve `source_rule_ref` to inserted/found template rows.
- Do not overwrite existing rows in v1.

Matching and conflict policy:

1. Conflict evaluation requires exact date match (`date` or `expense_date`).
2. Within exact-date candidates, prioritize identical `description` + `amount`.
3. Use type context (income vs expense and template/materialized/manual shape) as tie-breaker.
4. If exact-date high-confidence existing row differs on key fields, mark as conflict.
5. Conflict action: skip incoming row and add conflict report entry.
6. Non-exact-date rows are never conflicts in v1.

Import result payload:

- `created`
- `skipped_existing`
- `conflicts`
- `errors`
- `conflict_details[]`

## Data Flow

- Recurring generator creates future materialized rows as `pending` with `source_rule_id` set.
- Skip action updates targeted materialized row `status='skipped'`.
- Posting/actualization updates `pending` to `posted` as needed by current flows.
- Read/reporting endpoints use persisted rows instead of synthetic skip records.

## Error Handling

- Reject invalid JSON/schema early with clear errors.
- Use transactional batch processing where practical.
- Continue-on-row-error for import rows to maximize salvage and return detailed row-level errors.
- Return conflict reasons referencing matched existing row ids and differing fields.

## Backward Compatibility and Transition

- Existing endpoints should continue to function with additive schema changes.
- Replace `Skipped:` synthetic record logic with status-based handling.
- If needed, support short-lived hybrid read path during rollout while old and new representations coexist.

## Testing Strategy

- Migration tests: up/down integrity, defaults, constraints, FK behavior.
- Repository/query tests for template/materialized selection and status filtering.
- Import matcher tests for exact-date gate and description+amount priority.
- Idempotency tests: repeated same-file import should produce skips, not duplicates.
- Integration tests for recurring skip flow and export->import round-trip.

## Open Questions Resolved

- Occurrence storage: use existing `budget_incomes` and `budget_expenses`, not new tables.
- Conflict scope: only on exact-date matches, then prioritize same description and amount.
- Import behavior on conflict: skip existing and report.
