## ADDED Requirements

### Requirement: Toast notifications for CRUD operations
The system SHALL display toast notifications to provide immediate feedback when expense CRUD operations complete.

#### Scenario: Create expense success
- **WHEN** user successfully creates a new expense
- **THEN** system displays a success toast with message "Expense created successfully"

#### Scenario: Update expense success
- **WHEN** user successfully updates an existing expense
- **THEN** system displays a success toast with message "Expense updated successfully"

#### Scenario: Delete expense success
- **WHEN** user successfully deletes an expense
- **THEN** system displays a success toast with message "Expense deleted successfully"

#### Scenario: Operation failure
- **WHEN** a CRUD operation fails
- **THEN** system displays an error toast with appropriate error message

### Requirement: Toast notifications for category and tag operations
The system SHALL display toast notifications when category and tag CRUD operations complete.

#### Scenario: Category created
- **WHEN** user successfully creates a category
- **THEN** system displays success toast with message "Category created successfully"

#### Scenario: Tag created
- **WHEN** user successfully creates a tag
- **THEN** system displays success toast with message "Tag created successfully"

#### Scenario: Deletion operations
- **WHEN** user successfully deletes a category or tag
- **THEN** system displays success toast with appropriate message

### Requirement: Toast notification persistence
Toast notifications SHALL appear for a reasonable duration and be dismissible by the user.

#### Scenario: Auto-dismiss
- **WHEN** toast notification appears
- **THEN** system automatically dismisses it after 5 seconds

#### Scenario: Manual dismiss
- **WHEN** user clicks dismiss button on toast
- **THEN** system immediately removes the toast notification
