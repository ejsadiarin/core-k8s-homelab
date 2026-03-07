## Why

Users currently have limited flexibility in analyzing their financial data over arbitrary time periods. The existing system uses tracking_start_date configuration for filtering, but users need the ability to perform ad-hoc analysis with custom date ranges for any financial metric without changing their baseline configuration.

## What Changes

- Add optional start_date and end_date query parameters to all budget analytics endpoints
- Enable custom date range analysis for: Savings Rate, Spending Velocity, Spending by Day, Total Money
- Preserve existing tracking_start_date behavior as the default when no custom range is provided
- Allow custom ranges to override tracking period for specific queries

## Capabilities

### New Capabilities
- `custom-date-range-analytics`: API and UI support for custom date range filtering across all financial analytics features

### Modified Capabilities
- `budget-analytics`: Extend existing requirements to accept optional start_date/end_date parameters for all analytics endpoints

## Impact

- New API endpoints or modified existing ones with optional date range parameters
- UI components need date picker integration for selecting custom ranges
- Backend queries need to conditionally apply date filtering based on provided parameters
