## ADDED Requirements

### Requirement: Calculate emergency fund in months

The system SHALL calculate emergency fund coverage as total savings divided by average monthly expenses.

#### Scenario: Standard emergency fund calculation

- **WHEN** user has $6000 total savings and $2000 average monthly expenses
- **THEN** system returns emergency fund of 3.0 months

#### Scenario: Zero expenses edge case

- **WHEN** user has zero expenses in the averaging period
- **THEN** system returns emergency fund months of 0.0

#### Scenario: Limited expense history

- **WHEN** user has less than 3 months of expense data
- **THEN** system uses available months for average calculation

### Requirement: Use 3-month expense average

The system SHALL calculate average monthly expenses using the last 3 months of expense data.

#### Scenario: Full 3-month history

- **WHEN** user has expenses for last 3 months: $1800, $2000, $2200
- **THEN** system calculates average monthly expenses as $2000

#### Scenario: Partial history handling

- **WHEN** user has only 2 months of expense data
- **THEN** system averages those 2 months instead of failing

#### Scenario: No expense history

- **WHEN** user has no expense history
- **THEN** system returns 0.0 months and logs warning

### Requirement: Track total savings

The system SHALL use total savings from savings accounts or accumulated savings amount.

#### Scenario: Calculate from transactions

- **WHEN** user has no explicit savings account balance
- **THEN** system calculates savings as sum of (income - expenses) over tracking period
