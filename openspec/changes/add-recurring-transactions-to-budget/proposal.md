## Why

The Budget dashboard currently lacks visibility into recurring income and expense patterns. Users cannot easily see their total recurring cash flow (monthly equivalents), and there's no way to handle one-time skips of recurring income (e.g., missing a weekly paycheck due to leave). This limits financial planning capabilities.

## What Changes

- Add a "Recurring Summary" card to the Budget dashboard showing total recurring income and expenses (monthly equivalents) and net cash flow
- Add a "Recurring Incomes" section displaying active recurring incomes with next expected date
- Integrate the existing subscriptions/recurring expenses view into the main Budget page
- Add "Skip Occurrence" functionality for recurring incomes (supports weekly, bi-weekly, monthly, yearly)
- Add ability to view/edit individual recurring income rules

## Capabilities

### New Capabilities

- `recurring-summary-card`: Display total recurring income and expenses with monthly equivalents on Budget dashboard
- `recurring-income-list`: Show list of all active recurring incomes with next expected date on Budget page
- `skip-recurring-occurrence`: Allow users to skip a single occurrence of recurring income (one-time deduction) with support for weekly, bi-weekly, monthly, yearly frequencies

### Modified Capabilities

- None - existing subscription page remains unchanged

## Impact

- Frontend: New components in `apps/core/src/components/budget/`
- Backend: May need new API endpoints for fetching recurring income rules with next dates
- Database: No changes (existing `recurring_type` and `exclude_from_calculations` fields are sufficient)
