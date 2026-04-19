## ADDED Requirements

### Requirement: Expense can be marked as debt payment

The system SHALL allow marking expenses as debt payments for debt-to-income calculation.

#### Scenario: User marks recurring expense as debt

- **WHEN** user creates or edits a recurring expense
- **THEN** system provides option to mark it as a debt payment

#### Scenario: Debt flag persisted

- **WHEN** user saves expense with debt flag enabled
- **THEN** system stores `is_debt = true` for that expense

### Requirement: Calculate total monthly debt payments

The system SHALL calculate total monthly debt payments from all expenses marked as debt.

#### Scenario: Sum recurring debt payments

- **WHEN** system calculates debt payments for a month
- **THEN** system sums all recurring expenses where `is_debt = true`

#### Scenario: Convert to monthly equivalent

- **WHEN** debt expense has non-monthly recurring type
- **THEN** system converts to monthly equivalent (weekly × 4.33, daily × 30)

### Requirement: Calculate debt-to-income ratio

The system SHALL calculate debt-to-income ratio as monthly debt payments divided by monthly income.

#### Scenario: Normal debt-to-income calculation

- **WHEN** user has $2000 monthly debt payments and $5000 monthly income
- **THEN** system returns debt-to-income ratio of 0.4 (40%)

#### Scenario: Zero income edge case

- **WHEN** user has zero income for the period
- **THEN** system returns debt-to-income ratio of 0.0 with no error

#### Scenario: No debt payments

- **WHEN** user has no debt payments marked
- **THEN** system returns debt-to-income ratio of 0.0
