# Capability: Budget Analytics (Delta Spec)

## MODIFIED Requirements

### Requirement: System calculates savings rate
The system SHALL calculate the savings rate as (Total Income - Total Expenses) / Total Income × 100 for any given period. The system SHALL accept optional start_date and end_date query parameters to calculate savings rate for custom date ranges.

#### Scenario: Calculate monthly savings rate
- **WHEN** user requests savings rate for current month
- **THEN** system returns percentage with color-coded health indicator

#### Scenario: Calculate quarterly savings rate
- **WHEN** user requests savings rate for custom date range (e.g., last 90 days)
- **THEN** system returns aggregated savings rate for that period

#### Scenario: Calculate savings rate with custom date parameters
- **WHEN** user requests GET /api/budget/analytics/savings-rate?start_date=2025-11-01&end_date=2025-11-30
- **THEN** system calculates savings rate using only income and expenses from Nov 1-30, 2025

### Requirement: System provides spending velocity projection
The system SHALL calculate spending velocity as (Amount Spent to Date / Days Elapsed) × Days in Month. The system SHALL accept optional start_date and end_date parameters.

#### Scenario: On-track spending projection
- **GIVEN** user has spent $500 in 10 days of a 30-day month with $1500 budget
- **WHEN** user views spending velocity
- **THEN** system projects $1500 monthly spend with "On Track" status

#### Scenario: Over-pace spending warning
- **GIVEN** user has spent $800 in 10 days of a 30-day month with $1500 budget
- **WHEN** user views spending velocity
- **THEN** system projects $2400 monthly spend with "Over Pace" warning

#### Scenario: Spending velocity with custom date range
- **GIVEN** user has spent $1000 in first 15 days of a custom period with $2000 budget
- **WHEN** user requests spending velocity with start_date and end_date parameters
- **THEN** system calculates velocity for the specified period

### Requirement: System forecasts upcoming bills
The system SHALL identify recurring expenses due within the next 7 and 30 days.

#### Scenario: Upcoming weekly bills
- **WHEN** user requests upcoming bills for next 7 days
- **THEN** system returns list of recurring expenses with due dates and total amount

#### Scenario: Upcoming monthly bills
- **WHEN** user requests upcoming bills for next 30 days
- **THEN** system returns aggregated recurring expenses with cash flow impact

### Requirement: System provides cash flow forecast
The system SHALL calculate projected cash flow as (Expected Income - Expected Expenses) for upcoming period.

#### Scenario: 30-day cash flow projection
- **GIVEN** user has recurring income of $5000/month and recurring expenses of $3500/month
- **WHEN** user views cash flow forecast
- **THEN** system projects +$1500 cash flow for next 30 days
