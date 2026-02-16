## ADDED Requirements

### Requirement: User can set category budget
The system SHALL allow users to set a monthly budget limit for each category.

#### Scenario: Set category budget for current month
- **WHEN** user sets $500 budget for "Food" category for March 2026
- **THEN** system stores the budget and returns success confirmation

#### Scenario: Set category budget for future month
- **WHEN** user sets $600 budget for "Food" category for April 2026
- **THEN** system stores the budget for future month

#### Scenario: Update existing category budget
- **GIVEN** user has $500 budget for "Food" in March 2026
- **WHEN** user updates budget to $400
- **THEN** system updates the budget amount

### Requirement: System tracks budget vs actual variance
The system SHALL calculate and display variance between budgeted amount and actual spending per category.

#### Scenario: Under budget variance
- **GIVEN** user budgeted $500 for "Food" and spent $400
- **WHEN** user views category breakdown
- **THEN** system shows $100 under budget with green indicator

#### Scenario: Over budget variance
- **GIVEN** user budgeted $500 for "Food" and spent $600
- **WHEN** user views category breakdown
- **THEN** system shows $100 over budget with red indicator and alert

#### Scenario: Budget progress visualization
- **GIVEN** user has set budgets for multiple categories
- **WHEN** user views budget dashboard
- **THEN** system displays progress bars showing percentage of budget consumed

### Requirement: System provides budget alerts
The system SHALL alert users when spending reaches 80% of category budget.

#### Scenario: 80% threshold warning
- **GIVEN** user has $500 budget and spent $400
- **WHEN** user adds another expense in that category
- **THEN** system shows warning notification

#### Scenario: Over budget alert
- **GIVEN** user has $500 budget and spent $500
- **WHEN** user attempts to add another expense
- **THEN** system shows over-budget alert but allows the expense

### Requirement: User can view budget compliance history
The system SHALL track month-over-month budget compliance percentage.

#### Scenario: View last 6 months compliance
- **WHEN** user views budget history
- **THEN** system shows percentage of categories that stayed under budget each month
