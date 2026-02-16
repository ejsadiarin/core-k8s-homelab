# Capability: Financial Health

## Purpose

This capability provides financial health metrics and analysis, including savings rates, 50/30/20 rule breakdown, and an overall health score. It respects the user's tracking period configuration to ensure analysis is performed on relevant data.

## Requirements

### Requirement: Savings rate calculation period
The system SHALL calculate savings rate using only income and expenses within the tracking period, not cumulative all-time data.

#### Scenario: Calculate monthly savings rate
- **WHEN** user requests savings rate for December 2025 with tracking_start_date = Jan 15, 2026
- **THEN** system returns error or empty data (no data before tracking start)

#### Scenario: Calculate savings rate within tracking period
- **WHEN** user requests savings rate for February 2026 with tracking_start_date = Jan 15, 2026
- **THEN** system calculates using only income and expenses from Jan 15 - Feb 28, 2026

#### Scenario: Exclude pre-tracking income from calculation
- **WHEN** income entry dated Jan 1, 2026 has exclude_from_calculations = true
- **THEN** income is not included in savings rate calculation even if within date range

### Requirement: 50/30/20 analysis period filtering
The system SHALL calculate 50/30/20 budget analysis using only current month data from tracking_start_date forward.

#### Scenario: Calculate current month 50/30/20 after tracking start
- **WHEN** current date is Feb 15, 2026 with tracking_start_date = Jan 15, 2026
- **THEN** system calculates using income and expenses from Feb 1 - Feb 15, 2026

#### Scenario: Skip 50/30/20 for months before tracking start
- **WHEN** user views December 2025 with tracking_start_date = Jan 15, 2026
- **THEN** system shows no data or indicates period is before tracking start

### Requirement: Health score calculation respects tracking period
The system SHALL calculate financial health score using only data from tracking_start_date forward.

#### Scenario: Calculate health score for tracking period
- **WHEN** user requests health score with tracking_start_date = Jan 15, 2026
- **THEN** system uses only income, expenses, and savings data >= Jan 15, 2026
