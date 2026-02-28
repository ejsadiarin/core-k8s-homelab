## ADDED Requirements

### Requirement: Cancel recurring expense
The system SHALL allow users to cancel a recurring expense by setting its end_date to today's date via the existing update expense endpoint.

#### Scenario: User cancels a recurring expense
- **WHEN** user confirms cancellation of a recurring expense
- **THEN** the system SHALL update the expense's end_date to today's date using the PUT /api/budget/expenses/:id endpoint

#### Scenario: Cancelled expense no longer appears in active list
- **WHEN** a recurring expense has end_date set to today or earlier
- **THEN** the subscriptions/recurring expenses API SHALL exclude it from the active recurring list

### Requirement: Cancel recurring income
The system SHALL allow users to cancel a recurring income by setting its end_date to today's date via the existing update income endpoint.

#### Scenario: User cancels a recurring income
- **WHEN** user confirms cancellation of a recurring income
- **THEN** the system SHALL update the income's end_date to today's date using the PUT /api/budget/incomes/:id endpoint

#### Scenario: Cancelled income no longer appears in active list
- **WHEN** a recurring income has end_date set to today or earlier
- **THEN** the recurring incomes API SHALL exclude it from the active recurring list

### Requirement: Cancel confirmation dialog
The system SHALL display a confirmation dialog before cancelling any recurring item to prevent accidental cancellation.

#### Scenario: Confirmation dialog for expense cancellation
- **WHEN** user clicks the cancel action on a recurring expense
- **THEN** a dialog SHALL appear showing the expense description, amount, frequency, and a warning that the recurring series will end today

#### Scenario: Confirmation dialog for income cancellation
- **WHEN** user clicks the cancel action on a recurring income
- **THEN** a dialog SHALL appear showing the income description, amount, frequency, and a warning that the recurring series will end today

#### Scenario: User dismisses confirmation
- **WHEN** user clicks "Keep Active" or closes the confirmation dialog
- **THEN** the recurring item SHALL remain unchanged
