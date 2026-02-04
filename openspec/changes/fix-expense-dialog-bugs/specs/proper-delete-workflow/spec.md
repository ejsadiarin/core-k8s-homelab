## ADDED Requirements

### Requirement: Delete button checks actual guest state
The delete button in the expense detail dialog SHALL check the actual guest state from auth context, not just whether showToast callback exists.

#### Scenario: Delete as authenticated user
- **WHEN** authenticated user clicks delete button
- **THEN** system shows delete confirmation dialog
- **AND** after confirmation, executes delete and closes detail dialog

#### Scenario: Delete as guest user
- **WHEN** guest user clicks delete button
- **THEN** system shows "Guest user is read-only" toast warning
- **AND** delete operation is not executed

### Requirement: Delete confirmation uses AlertDialog
The delete confirmation SHALL use the AlertDialog component for consistent UX.

#### Scenario: Delete confirmation dialog
- **WHEN** user clicks delete button
- **THEN** system shows AlertDialog with "Delete Expense" title
- **AND** description says "Are you sure you want to delete this expense?"
- **AND** options are "Cancel" and "Delete"

#### Scenario: Cancel delete
- **WHEN** user clicks Cancel in delete confirmation
- **THEN** dialog closes without deleting expense
