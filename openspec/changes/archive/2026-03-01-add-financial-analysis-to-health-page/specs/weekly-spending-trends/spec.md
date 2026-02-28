## ADDED Requirements

### Requirement: Weekly Spending Trends Display
The system SHALL display a chart showing daily spending amounts, filtered by a selected week or defaulting to the current month.

#### Scenario: User views Spending by Day for current month
- **WHEN** user navigates to the Health page
- **THEN** the "Spending by Day" chart displays daily totals for the current month

#### Scenario: User filters by specific week
- **WHEN** user selects a specific week from the date filter
- **THEN** the "Spending by Day" chart updates to show daily totals only for that selected week
- **AND** the chart X-axis labels correspond to the days of the selected week

#### Scenario: No data for selected week
- **WHEN** user selects a week with no expenses
- **THEN** the chart displays empty state or zero values without error
