## ADDED Requirements

### Requirement: Income occurrence table
The system SHALL store each recurring income occurrence as a row in the `budget_income_occurrences` table, linked to the parent recurring income rule via `source_income_id`.

#### Scenario: Occurrence row structure
- **WHEN** a recurring income occurrence is materialized
- **THEN** the system stores: `id` (UUID), `source_income_id` (FK to budget_incomes), `user_id` (FK to users), `amount` (copied from rule), `currency`, `occurrence_date`, `description` (copied from rule), `is_skipped` (boolean, default false), `skip_reason` (optional text), `created_at`, `updated_at`

#### Scenario: Unique constraint per rule and date
- **WHEN** the system attempts to create an occurrence for a source_income_id + occurrence_date combination that already exists
- **THEN** the system SHALL reject the insert with a unique constraint violation

#### Scenario: Cascade delete on rule deletion
- **WHEN** a recurring income rule is deleted from budget_incomes
- **THEN** all associated occurrence rows in budget_income_occurrences SHALL be deleted via ON DELETE CASCADE

### Requirement: Query occurrences by user and date range
The system SHALL support querying income occurrences filtered by user_id and occurrence_date range.

#### Scenario: Fetch occurrences for period
- **WHEN** user requests income occurrences for a date range [start, end]
- **THEN** the system returns all rows from budget_income_occurrences WHERE user_id = current user AND occurrence_date >= start AND occurrence_date <= end
- **THEN** results are ordered by occurrence_date DESC

#### Scenario: Aggregate non-skipped occurrences for period
- **WHEN** the system calculates total recurring income for a period
- **THEN** the system returns SUM(amount) FROM budget_income_occurrences WHERE user_id = $1 AND occurrence_date >= $2 AND occurrence_date <= $3 AND is_skipped = false

### Requirement: Skip occurrence via boolean flag
The system SHALL allow marking an occurrence as skipped by setting `is_skipped = true` with an optional `skip_reason`.

#### Scenario: Skip an occurrence
- **WHEN** user skips a specific income occurrence
- **THEN** the system sets is_skipped = true and optionally stores skip_reason on that occurrence row

#### Scenario: Unskip an occurrence
- **WHEN** user undoes a skip on an income occurrence
- **THEN** the system sets is_skipped = false and clears skip_reason on that occurrence row

#### Scenario: Skipped occurrences excluded from totals
- **WHEN** the system calculates recurring income totals
- **THEN** occurrences with is_skipped = true SHALL NOT be included in the SUM
