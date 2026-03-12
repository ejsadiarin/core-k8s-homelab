## ADDED Requirements

### Requirement: Period preset filter buttons for quick date range selection
The system SHALL provide a reusable `PeriodPresetFilter` component that displays preset buttons: 7D, 30D, 90D, This Month, This Year, alongside the existing custom date range inputs.

When a preset is selected:
- 7D: start_date = today - 6 days, end_date = today
- 30D: start_date = today - 29 days, end_date = today
- 90D: start_date = today - 89 days, end_date = today
- This Month: start_date = first day of current month, end_date = last day of current month
- This Year: start_date = January 1 of current year, end_date = December 31 of current year

#### Scenario: User selects 7D preset
- **WHEN** user clicks the "7D" preset button
- **THEN** the date range is set to the last 7 days and analytics cards update to reflect this period

#### Scenario: User selects custom date range after preset
- **WHEN** user has a preset active and then manually enters custom start/end dates
- **THEN** the preset is deselected and the custom dates take effect

#### Scenario: User clears filters
- **WHEN** user clicks "Clear" with a preset or custom dates active
- **THEN** both preset and custom dates are cleared, reverting to default (no date filtering)

### Requirement: Preset filter integrated on budget dashboard
The system SHALL replace the current standalone date range inputs on the budget dashboard with the `PeriodPresetFilter` component, maintaining backward compatibility with the existing custom date range functionality.

#### Scenario: Dashboard analytics cards respect preset filter
- **WHEN** user selects "This Month" preset on the budget dashboard
- **THEN** CurrentTotalMoneyCard, SavingsRateCard, and SpendingVelocityCard all update to show data for the current month only
