## ADDED Requirements

### Requirement: Skip recurring expense occurrence
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
