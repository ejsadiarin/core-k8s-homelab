## MODIFIED Requirements

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
