# Capability: Custom Date Range Analytics

## Purpose

This capability provides optional custom date range filtering for all financial analytics features, allowing users to perform ad-hoc analysis over arbitrary time periods without modifying their baseline tracking configuration.

## Requirements

### Requirement: API accepts custom date range parameters
The system SHALL accept optional `start_date` and `end_date` query parameters on analytics endpoints.

#### Scenario: Request savings rate with custom date range
- **WHEN** user requests GET /api/budget/analytics/savings-rate?start_date=2026-01-01&end_date=2026-01-31
- **THEN** system calculates savings rate using only income and expenses from Jan 1-31, 2026
- **AND** response includes metadata indicating custom date range was used

#### Scenario: Request spending velocity with custom date range
- **WHEN** user requests GET /api/budget/analytics/spending-velocity?start_date=2026-01-01&end_date=2026-01-31
- **THEN** system calculates spending velocity for the specified date range

#### Scenario: Omit date range parameters
- **WHEN** user requests analytics endpoint without start_date and end_date
- **THEN** system uses tracking_start_date configuration as the default filter

#### Scenario: Partial date range (start only)
- **WHEN** user requests analytics with start_date but no end_date
- **THEN** system uses start_date through current date as the range

#### Scenario: Partial date range (end only)
- **WHEN** user requests analytics with end_date but no start_date
- **THEN** system uses tracking_start_date through end_date as the range

### Requirement: Date validation
The system SHALL validate date parameters and return appropriate errors for invalid input.

#### Scenario: Invalid date format
- **WHEN** user requests analytics with start_date=invalid
- **THEN** system returns 400 Bad Request with error message about invalid date format

#### Scenario: end_date before start_date
- **WHEN** user requests analytics with start_date=2026-01-31&end_date=2026-01-01
- **THEN** system returns 400 Bad Request with error message about invalid date range

### Requirement: Spending by Day accepts custom date range
The system SHALL calculate daily spending averages for any specified date range.

#### Scenario: Daily spending breakdown for custom range
- **WHEN** user requests GET /api/budget/analytics/spending-by-day?start_date=2026-01-01&end_date=2026-01-31
- **THEN** system returns average spending per day of week for January 2026

### Requirement: Total Money accepts custom date range
The system SHALL calculate total money (income - expenses) for any specified date range.

#### Scenario: Total money for custom range
- **WHEN** user requests GET /api/budget/analytics/total-money?start_date=2026-01-01&end_date=2026-01-31
- **THEN** system returns total income minus total expenses for Jan 1-31, 2026

### Requirement: Response metadata indicates date range used
The system SHALL include metadata in analytics responses indicating which date range was used for calculation.

#### Scenario: Metadata shows custom range
- **WHEN** user requests analytics with custom start_date and end_date
- **THEN** response includes metadata: { "dateRange": { "start": "2026-01-01", "end": "2026-01-31", "source": "custom" } }

#### Scenario: Metadata shows default range
- **WHEN** user requests analytics without date parameters
- **THEN** response includes metadata: { "dateRange": { "start": "2026-01-15", "end": "2026-02-15", "source": "tracking_start_date" } }
