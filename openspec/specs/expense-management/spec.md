## Purpose

Expense management capabilities for the budget tracking system.

## Requirements

### Requirement: Expense update preserves unprovided fields
The system SHALL preserve existing field values when they are not explicitly included in the expense update request. Only fields that are explicitly provided SHALL be updated.

#### Scenario: Update description without affecting priority_group_id
- **WHEN** user updates an expense with description only (no priority_group_id in request)
- **THEN** the expense description is updated
- **AND** the existing priority_group_id value is preserved

#### Scenario: Update amount without affecting end_date
- **WHEN** user updates an expense with amount only (no end_date in request)
- **THEN** the expense amount is updated
- **AND** the existing end_date value is preserved

#### Scenario: Explicitly clear optional field with null
- **WHEN** user updates an expense with priority_group_id explicitly set to null
- **THEN** the expense priority_group_id is cleared to null

#### Scenario: Explicitly set new end_date
- **WHEN** user updates an expense with a new end_date value
- **THEN** the expense end_date is updated to the new value

### Requirement: Expense save operations are non-blocking
The system SHALL allow users to continue working immediately after initiating an expense save operation. The dialog SHALL close immediately and the save operation SHALL continue in the background.

#### Scenario: Update expense with non-blocking save
- **WHEN** user edits an expense and clicks Save
- **THEN** the edit dialog closes immediately
- **AND** the save operation continues in the background
- **AND** a success toast is shown when the operation completes

#### Scenario: Create expense with non-blocking save
- **WHEN** user creates a new expense and clicks Save
- **THEN** the create dialog closes immediately
- **AND** the save operation continues in the background
- **AND** a success toast is shown when the operation completes

#### Scenario: Save fails with error toast
- **WHEN** user saves an expense and the operation fails
- **THEN** the dialog still closes immediately
- **AND** an error toast is shown with the error message
