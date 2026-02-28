## Purpose

Allow users to skip a single occurrence of a recurring income or expense, creating a negative record for that specific date.

## ADDED Requirements

### Requirement: Skip Recurring Income Occurrence
The system SHALL allow users to skip a single occurrence of a recurring income, creating a negative income record for that specific date.

#### Scenario: User skips weekly recurring income
- **WHEN** user clicks "Skip" on a weekly recurring income (e.g., 500 PHP every Wednesday)
- **THEN** dialog appears showing: Income description, Amount, Date to skip (auto-calculated next Wednesday)
- **AND** user confirms skip
- **THEN** negative income record created with amount -500 PHP on that date

#### Scenario: User skips with custom date
- **WHEN** user clicks "Skip" and selects a different date
- **THEN** negative income created for the selected date instead of auto-calculated date

#### Scenario: Skip creates visible record
- **WHEN** user skips a recurring income
- **THEN** negative income appears in Recent Incomes list with strikethrough or "(Skipped)" label

#### Scenario: Duplicate skip prevented
- **WHEN** user attempts to skip the same date for the same recurring income twice
- **THEN** system shows error "This occurrence has already been skipped"

#### Scenario: Undo skip
- **WHEN** user views a skipped (negative) income
- **THEN** user can delete the negative income to undo the skip
- **AND** recurring income schedule continues unaffected

#### Scenario: Skip does not affect future occurrences
- **WHEN** user skips one occurrence of a recurring income
- **THEN** subsequent occurrences continue as scheduled (skip does not change the recurring rule)

#### Scenario: Skip with reason (optional)
- **WHEN** user skips an occurrence
- **THEN** optional "reason" field available (e.g., "vacation", "sick leave")
- **AND** reason stored in notes field of negative income record

### Requirement: Skip Recurring Expense Occurrence
The system SHALL allow users to skip a single occurrence of a recurring expense by creating a negative expense record (mirroring the existing income skip pattern).

#### Scenario: User skips a recurring expense occurrence
- **WHEN** user confirms skipping a recurring expense occurrence for a specific date
- **THEN** the system SHALL create a new expense record with a negative amount equal to the recurring expense amount, the specified date, and a description prefixed with "Skipped: "

#### Scenario: Skip dialog shows expense details
- **WHEN** the skip expense dialog opens
- **THEN** it SHALL display the expense description, the negative amount, the frequency, and a date picker defaulting to the next due date

#### Scenario: User provides an optional reason
- **WHEN** user enters a reason for skipping
- **THEN** the system SHALL store the reason in the notes field of the negative expense record

#### Scenario: Duplicate skip prevention
- **WHEN** user attempts to skip an expense for a date that has already been skipped
- **THEN** the dialog SHALL display a warning and disable the skip button

### Requirement: Backend endpoint for checking skipped expenses
The system SHALL provide an API endpoint to check if a recurring expense has been skipped for a given date.

#### Scenario: Check for existing skip
- **WHEN** a GET request is made to check if an expense skip exists for a given date
- **THEN** the system SHALL return whether a negative expense record exists for that date

### Requirement: Backend creates negative expense for skip
The existing create expense endpoint SHALL accept negative amounts to support the skip functionality.

#### Scenario: Create negative expense record
- **WHEN** a POST request creates an expense with a negative amount and "Skipped: " prefix
- **THEN** the system SHALL store the record normally in budget_expenses
