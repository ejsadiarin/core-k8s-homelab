## ADDED Requirements

### Requirement: Savings Rate Widget
The system SHALL display a widget showing the user's current savings rate as a percentage.

#### Scenario: User views Savings Rate widget
- **WHEN** the Health page loads
- **THEN** the widget displays the calculated savings rate percentage (Income - Expenses) / Income * 100
- **AND** displays a visual indicator (color-coded) based on the rate (e.g., Green > 20%, Yellow 10-20%, Red < 10%)

### Requirement: Spending Velocity Widget
The system SHALL display a widget projecting the total spending for the current month based on the current daily average.

#### Scenario: User views Spending Velocity widget
- **WHEN** the Health page loads
- **AND** there are expenses in the current month
- **THEN** the widget displays the projected total spend for the month
- **AND** displays a status indicating if the user is "On Track" or "Over Pace" based on any defined budget (or simply current average vs last month)
