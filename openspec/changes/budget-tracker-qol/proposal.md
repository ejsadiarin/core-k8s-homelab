## Why

Recurring incomes (daily/weekly/monthly) are calculated by the backend at read-time but never materialized as individual records in the database. This means when a weekly Wednesday +500 PHP income fires, the total money increases but no corresponding entry appears in the "Recent Incomes" list or the Income List page -- creating a confusing "ghost addition" disparity. Users see their money go up with no visible explanation.

Additionally, there is no monthly summary view. Users cannot quickly see income vs expenses for the current month, last 7 days, last 30 days, etc. The existing date range picker only supports manual custom start/end dates with no quick presets.

## What Changes

- **Show recurring income occurrences in the UI**: Add a new backend endpoint that expands recurring income rules into individual virtual occurrence entries for a given date range. Display these expanded entries in both the Recent Incomes section on the dashboard and the Income List page, clearly marked as recurring-generated entries.
- **Add period preset filter buttons**: Add quick-select buttons (7D, 30D, 90D, This Month, This Year) alongside the existing custom date range picker on the budget dashboard. These presets auto-set the date range for analytics cards.
- **Create a Monthly Summary page**: A new page accessible from the sidebar that shows a comprehensive summary for a selected period -- total income (one-time + recurring), total expenses, net savings, and a transaction-level breakdown. Supports the same preset filters (7D, 30D, 90D, This Month, Custom).

## Capabilities

### New Capabilities
- `recurring-income-occurrences`: Backend endpoint to expand recurring income rules into individual occurrence entries for a date range, and frontend display of these virtual entries in income lists
- `monthly-summary`: Dedicated summary page showing income, expenses, net savings, and transaction breakdown for a configurable period with preset filters
- `period-preset-filters`: Reusable preset date filter buttons (7D, 30D, 90D, This Month, This Year, Custom) for analytics sections

### Modified Capabilities
- `budget-incomes`: Income list now includes virtual recurring occurrence entries alongside one-time entries
- `recurring-income-list`: Dashboard "Recent Incomes" section now shows expanded recurring occurrences

## Impact

- **Backend**: New API endpoint `GET /api/budget/incomes/occurrences?start_date=...&end_date=...` that returns expanded recurring income entries
- **Frontend pages**: Budget dashboard page (date filter presets), Income List page (recurring occurrences), new Monthly Summary page
- **Frontend components**: New `PeriodPresetFilter` component, new `MonthlySummaryPage`, modified `RecurringIncomeList`, modified income list display
- **Sidebar navigation**: Add "Summary" nav item under FINANCE section
- **No database changes**: All recurring expansion is computed at read-time
