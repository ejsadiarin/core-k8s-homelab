# Capability: Tracking Baseline

## Purpose

This capability enables users to configure a tracking start date and money baseline to separate historical record-keeping from active budget analysis. This allows users to maintain historical records while focusing financial calculations on a defined tracking period.

## Requirements

### Requirement: User tracking baseline configuration
The system SHALL allow users to configure a tracking start date and money baseline to separate historical record-keeping from active budget analysis.

#### Scenario: Set tracking baseline from current total money
- **WHEN** user sets tracking_start_date to Jan 15, 2026 with current total money ₱12,345.60
- **THEN** system calculates money_baseline by subtracting net change since Jan 15 from current total

#### Scenario: View current total money
- **WHEN** user views dashboard
- **THEN** system displays current total money as money_baseline + (total_income - total_expenses) since tracking_start_date

### Requirement: Pre-tracking income exclusion
The system SHALL support marking income entries as excluded from financial calculations while retaining them for record-keeping purposes.

#### Scenario: Exclude pre-tracking income from calculations
- **WHEN** income entry has exclude_from_calculations = true
- **THEN** income is not included in Savings Rate, 50/30/20, or Health Score calculations

#### Scenario: Include pre-tracking income in historical view
- **WHEN** user views all income entries
- **THEN** system displays both included and excluded entries with visual distinction

### Requirement: Baseline calculation from current state
The system SHALL calculate the tracking baseline by working backwards from current total money.

#### Scenario: Calculate Jan 15 baseline from Feb 17 total
- **WHEN** user has current total ₱12,345.60 with ₱8,000 income and ₱5,000 expenses since Jan 15
- **THEN** system calculates baseline as ₱12,345.60 - (₱8,000 - ₱5,000) = ₱9,345.60

#### Scenario: Handle multiple currency accounts
- **WHEN** user has Bank ₱9,872.78, GCash ₱1,277.82, Cash ₱1,195.00
- **THEN** system sums to ₱12,345.60 as total current money

### Requirement: Tracking start date enforced in queries
The system SHALL filter all financial calculation queries to only include data from tracking_start_date forward.

#### Scenario: Calculate savings rate for tracking period only
- **WHEN** user requests savings rate with tracking_start_date = Jan 15, 2026
- **THEN** system only includes income and expenses where date >= Jan 15, 2026

#### Scenario: Exclude pre-tracking data from 50/30/20
- **WHEN** system calculates 50/30/20 analysis
- **THEN** only expenses where expense_date >= tracking_start_date are included
