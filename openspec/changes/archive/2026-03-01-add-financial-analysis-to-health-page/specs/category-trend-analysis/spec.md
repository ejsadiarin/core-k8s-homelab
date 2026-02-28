## ADDED Requirements

### Requirement: Category Trend Analysis
The system SHALL display a comparison of spending by category for the current month versus the previous month.

#### Scenario: User views Category Trends widget
- **WHEN** the Health page loads
- **THEN** the widget displays a bar chart or list showing each category's total for the current month
- **AND** shows the percentage change (+/-) compared to the previous month

#### Scenario: Spending increased in a category
- **WHEN** a category's current month total is higher than the previous month
- **THEN** the change is displayed with a positive indicator (e.g., "+$50 (+15%)")

#### Scenario: Spending decreased in a category
- **WHEN** a category's current month total is lower than the previous month
- **THEN** the change is displayed with a negative indicator (e.g., "-$20 (-10%)")
