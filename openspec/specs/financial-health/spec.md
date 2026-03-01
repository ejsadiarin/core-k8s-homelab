# Capability: Financial Health

## Purpose

This capability provides financial health metrics and analysis, including savings rates, 50/30/20 rule breakdown, and an overall health score. It respects the user's tracking period configuration to ensure analysis is performed on relevant data.

## Requirements

### Requirement: User can classify categories by type
The system SHALL allow users to classify categories as 'need', 'want', or 'savings' for 50/30/20 rule tracking.

#### Scenario: Classify category as need
- **WHEN** user classifies "Rent" category as 'need'
- **THEN** system stores classification and includes in 50/30/20 calculation

#### Scenario: Classify category as want
- **WHEN** user classifies "Entertainment" category as 'want'
- **THEN** system stores classification and includes in 50/30/20 calculation

#### Scenario: Classify category as savings
- **WHEN** user classifies "Investment" category as 'savings'
- **THEN** system stores classification and includes in 50/30/20 calculation

### Requirement: System tracks 50/30/20 rule compliance
The system SHALL calculate and display spending distribution across needs, wants, and savings.

#### Scenario: Monthly 50/30/20 breakdown
- **GIVEN** user has classified all categories
- **WHEN** user views financial health dashboard
- **THEN** system shows percentage split (e.g., 55% needs, 25% wants, 20% savings)

#### Scenario: Ideal vs actual comparison
- **GIVEN** user spending is 60% needs, 35% wants, 5% savings
- **WHEN** user views 50/30/20 chart
- **THEN** system shows deviation from ideal with recommendations

### Requirement: System analyzes spending patterns
The system SHALL provide financial health metrics that can be filtered by an explicit custom date range (`start_date` and `end_date`), replacing the hardcoded week/month periods. The default period SHALL be from the user's tracking start date (e.g. Jan 15, 2026) to today.

#### Scenario: Health page with default dates
- **WHEN** user navigates to the Health page without query parameters
- **THEN** system defaults the date range from Jan 15, 2026 to today

#### Scenario: Health page with custom dates
- **WHEN** user selects a custom date range in the UI
- **THEN** the URL updates with `start_date` and `end_date` parameters
- **THEN** all health components recalculate based on this specific range

### Requirement: System analyzes weekday vs weekend spending
The system SHALL compare spending patterns between weekdays and weekends within the specified date range.

#### Scenario: Weekday spending average
- **WHEN** user views spending patterns
- **THEN** system shows average spend per weekday (Monday-Friday)

#### Scenario: Weekend spending average
- **WHEN** user views spending patterns
- **THEN** system shows average spend per weekend day (Saturday-Sunday)

#### Scenario: Day-of-week breakdown
- **WHEN** user views detailed patterns
- **THEN** system shows bar chart with average spend for each day of week

### Requirement: System calculates financial health score
The system SHALL calculate a composite financial health score based on multiple metrics.

#### Scenario: Calculate health score
- **GIVEN** user has savings rate >20%, budget compliance >80%, spending trending down
- **WHEN** user views health score
- **THEN** system displays score (0-100) with color coding

#### Scenario: Health score components
- **WHEN** user views detailed health breakdown
- **THEN** system shows individual scores for: savings rate, budget compliance, spending trend, emergency fund

### Requirement: System provides spending trend analysis
The system SHALL identify month-over-month spending trends by category.

#### Scenario: Category trend comparison
- **GIVEN** "Food" spending was $400 last month and $500 this month
- **WHEN** user views trends
- **THEN** system shows +25% increase with trend arrow

#### Scenario: Overall spending trend
- **GIVEN** total spending has decreased for 3 consecutive months
- **WHEN** user views dashboard
- **THEN** system shows positive downward trend indicator

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
