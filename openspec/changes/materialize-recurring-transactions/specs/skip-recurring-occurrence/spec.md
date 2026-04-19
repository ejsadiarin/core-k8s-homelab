## MODIFIED Requirements

### Requirement: Skip Recurring Income Occurrence
The system SHALL allow users to skip a single occurrence of a recurring income by toggling `is_skipped` on the materialized occurrence row.

#### Scenario: User skips weekly recurring income
- **WHEN** user clicks "Skip" on a weekly recurring income occurrence
- **THEN** dialog appears showing: Income description, Amount, Date of occurrence
- **AND** user confirms skip
- **THEN** system sets is_skipped = true on the occurrence row in budget_income_occurrences
- **THEN** system optionally stores skip_reason

#### Scenario: User skips with custom date
- **WHEN** user clicks "Skip" and selects a different date
- **THEN** system finds the occurrence row matching the selected date and sets is_skipped = true

#### Scenario: Skip creates visible record
- **WHEN** user skips a recurring income occurrence
- **THEN** the occurrence appears in the occurrences list with is_skipped = true and "(Skipped)" label

#### Scenario: Duplicate skip prevented
- **WHEN** user attempts to skip an occurrence that already has is_skipped = true
- **THEN** system shows error "This occurrence has already been skipped"

#### Scenario: Undo skip
- **WHEN** user views a skipped occurrence
- **THEN** user can unskip by setting is_skipped = false
- **AND** recurring income schedule continues unaffected

#### Scenario: Skip does not affect future occurrences
- **WHEN** user skips one occurrence of a recurring income
- **THEN** other occurrence rows remain unaffected (is_skipped stays false)

#### Scenario: Skip with reason (optional)
- **WHEN** user skips an occurrence
- **THEN** optional "reason" field available (e.g., "vacation", "sick leave")
- **AND** reason stored in skip_reason field on the occurrence row

### Requirement: Skip Recurring Expense Occurrence
The system SHALL allow users to skip a single occurrence of a recurring expense by toggling `is_skipped` on the materialized occurrence row.

#### Scenario: User skips a recurring expense occurrence
- **WHEN** user confirms skipping a recurring expense occurrence for a specific date
- **THEN** the system sets is_skipped = true on the occurrence row in budget_expense_occurrences
- **THEN** system optionally stores skip_reason

#### Scenario: Skip dialog shows expense details
- **WHEN** the skip expense dialog opens
- **THEN** it SHALL display the expense description, the amount, the frequency, and a date picker defaulting to the occurrence date

#### Scenario: User provides an optional reason
- **WHEN** user enters a reason for skipping
- **THEN** the system stores the reason in the skip_reason field on the occurrence row

#### Scenario: Duplicate skip prevention
- **WHEN** user attempts to skip an expense occurrence that already has is_skipped = true
- **THEN** the dialog SHALL display a warning and disable the skip button

## REMOVED Requirements

### Requirement: Backend creates negative expense for skip
**Reason**: Replaced by toggling `is_skipped` on materialized occurrence rows. Negative-amount records are no longer created for skips.
**Migration**: Existing "Skipped:" negative records are migrated to is_skipped = true on corresponding occurrence rows during the backfill migration.

### Requirement: Backend endpoint for checking skipped expenses
**Reason**: Skip state is now a boolean field on the occurrence row itself. No separate check endpoint needed — the occurrence query returns is_skipped directly.
**Migration**: Frontend reads is_skipped from occurrence data instead of calling a separate check endpoint.
