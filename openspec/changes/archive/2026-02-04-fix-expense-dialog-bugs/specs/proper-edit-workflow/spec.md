## ADDED Requirements

### Requirement: Edit callback passes updated data to parent
The edit dialog callback SHALL pass the updated expense data to the parent component.

#### Scenario: Edit expense successfully
- **WHEN** user edits expense and clicks save
- **THEN** edit dialog closes
- **AND** parent component receives updated expense data
- **AND** expense detail dialog refreshes with new data

#### Scenario: Edit dialog closes without saving
- **WHEN** user clicks cancel in edit dialog
- **THEN** edit dialog closes
- **AND** expense detail dialog remains open
- **AND** no data changes occur

### Requirement: Parent page provides edit/delete callbacks
The budget page SHALL pass onEdit and onDelete callbacks to the expense detail dialog.

#### Scenario: Budget page handles edit
- **WHEN** user clicks edit in detail dialog
- **THEN** budget page's edit handler is called
- **AND** edit dialog opens with current expense data

#### Scenario: Budget page handles delete
- **WHEN** user confirms delete in detail dialog
- **THEN** budget page's delete handler is called
- **AND** expense is removed from list
- **AND** detail dialog closes
