# Capability: Income Tracking

## Purpose

This capability manages the tracking logic for income entries, specifically focusing on how income data is filtered, excluded, and aggregated for financial analysis, distinct from the basic CRUD operations.

## Requirements

### Requirement: Income entry exclusion flag
The system SHALL support marking income entries as excluded from financial calculations via exclude_from_calculations boolean flag.

#### Scenario: Create income entry excluded from calculations
- **WHEN** user creates income entry with exclude_from_calculations = true
- **THEN** system stores entry but excludes it from all financial metric calculations

#### Scenario: Mark existing pre-tracking income as excluded
- **WHEN** migration runs for tracking_start_date = Jan 15, 2026
- **THEN** system sets exclude_from_calculations = true for all income entries where date < Jan 15, 2026

#### Scenario: Display excluded income in income list
- **WHEN** user views income list
- **THEN** system shows all entries including excluded ones with visual indicator

### Requirement: Income filtering by tracking period
The system SHALL filter income queries to exclude entries before tracking_start_date when calculating financial metrics.

#### Scenario: Query income for savings rate calculation
- **WHEN** system calculates savings rate with tracking_start_date = Jan 15, 2026
- **THEN** query filters WHERE (date >= tracking_start_date AND exclude_from_calculations = false)

#### Scenario: Show all income including historical
- **WHEN** user views complete income history
- **THEN** system shows all income entries regardless of tracking_start_date or exclusion flag
