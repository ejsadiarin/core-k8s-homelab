## Why

The budget tracker currently only tracks expenses, making it impossible to assess overall budget health or determine if users are overspending. Users need to track both income and expenses to get a complete picture of their financial status and make informed decisions about spending.

## What Changes

- Add income management system with support for:
  - One-time income entries on specific dates
  - Recurring daily income (single rule that auto-calculates daily amounts)
- Calculate "Budget Remaining" (total income - total expenses) with visual indicators:
  - Green when positive (money saved)
  - Red when negative (over budget)
- Replace "Period" stat card with "Budget Remaining" card
- Add visual indicators on expense/income amounts:
  - `+` prefix for income entries
  - `-` prefix for expense entries
- Add date filter to view budget status for specific days
- User-scoped income data with same isolation as budget expenses

## Capabilities

### New Capabilities

- `budget-incomes`: Core income CRUD operations including one-time entries and recurring daily income rules. User-scoped with authentication-based isolation.

- `budget-remaining`: Calculation of running budget balance (total income minus total expenses) with date filtering support. Provides real-time budget health indicators.

### Modified Capabilities

- `budget-stats`: Add "Budget Remaining" metric to replace existing "Period" stat card. Modify summary stats endpoint to include budget remaining calculation.

- `budget-expenses`: Update expense display to include `-` prefix indicators for amounts. No requirement changes to expense CRUD logic.

## Impact

- **Backend**: Add `budget_incomes` table with columns for amount, date, description, and recurring rule configuration. Add income CRUD endpoints (`POST /api/budget/incomes`, `GET /api/budget/incomes`, `GET /api/budget/incomes/:id`, `PUT /api/budget/incomes/:id`, `DELETE /api/budget/incomes/:id`). Add budget remaining calculation endpoint (`GET /api/budget/remaining?date=`). Update stats endpoints to include budget remaining.

- **Frontend**: Create income form component (`income-form.tsx`). Integrate income management into existing `/dashboard/budget` page with "Recent Incomes" card section. Update `ExpenseStats` component to show "Budget Remaining" instead of "Period". Update expense cards to display `-` prefix. Update dashboard page to calculate and display budget remaining with color indicators.

- **Database**: Add migration for `budget_incomes` table with user_id foreign key for user isolation.

- **API Client**: Add income CRUD functions and budget remaining calculation to `lib/api.ts`. Add TypeScript types for income entries.
