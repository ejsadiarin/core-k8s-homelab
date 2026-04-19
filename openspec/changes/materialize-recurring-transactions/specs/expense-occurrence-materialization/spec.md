## ADDED Requirements

### Requirement: Expense occurrence table
The system SHALL store each recurring expense occurrence as a row in the `budget_expense_occurrences` table, linked to the parent recurring expense rule via `source_expense_id`.

#### Scenario: Occurrence row structure
- **WHEN** a recurring expense occurrence is materialized
- **THEN** the system stores: `id` (UUID), `source_expense_id` (FK to budget_expenses), `user_id` (FK to users), `amount` (copied from rule), `currency`, `occurrence_date`, `description` (copied from rule), `category_id` (copied from rule), `is_skipped` (boolean, default false), `skip_reason` (optional text), `created_at`, `updated_at`

#### Scenario: Unique constraint per rule and date
- **WHEN** the system attempts to create an occurrence for a source_expense_id + occurrence_date combination that already exists
- **THEN** the system SHALL reject the insert with a unique constraint violation

#### Scenario: Cascade delete on rule deletion
- **WHEN** a recurring expense rule is deleted from budget_expenses
- **THEN** all associated occurrence rows in budget_expense_occurrences SHALL be deleted via ON DELETE CASCADE

### Requirement: Query expense occurrences by user and date range
The system SHALL support querying expense occurrences filtered by user_id and occurrence_date range.

#### Scenario: Fetch expense occurrences for period
- **WHEN** user requests expense occurrences for a date range [start, end]
- **THEN** the system returns all rows from budget_expense_occurrences WHERE user_id = current user AND occurrence_date >= start AND occurrence_date <= end
- **THEN** results are ordered by occurrence_date DESC

#### Scenario: Aggregate non-skipped expense occurrences for period
- **WHEN** the system calculates total recurring expenses for a period
- **THEN** the system returns SUM(amount) FROM budget_expense_occurrences WHERE user_id = $1 AND occurrence_date >= $2 AND occurrence_date <= $3 AND is_skipped = false

### Requirement: Skip expense occurrence via boolean flag
The system SHALL allow marking an expense occurrence as skipped by setting `is_skipped = true` with an optional `skip_reason`.

#### Scenario: Skip an expense occurrence
- **WHEN** user skips a specific expense occurrence
- **THEN** the system sets is_skipped = true and optionally stores skip_reason on that occurrence row

#### Scenario: Unskip an expense occurrence
- **WHEN** user undoes a skip on an expense occurrence
- **THEN** the system sets is_skipped = false and clears skip_reason on that occurrence row

#### Scenario: Skipped expense occurrences excluded from totals
- **WHEN** the system calculates recurring expense totals
- **THEN** occurrences with is_skipped = true SHALL NOT be included in the SUM
