## Why

The "Subscriptions" page currently only displays recurring expenses and provides no interactive actions (edit, skip, cancel). Meanwhile, recurring incomes are shown separately on the Budget dashboard with no unified view. Users need a single page to manage all recurring financial items -- both expenses and incomes -- with the ability to edit, skip occurrences, and cancel them.

## What Changes

- Rename and refactor the Subscriptions page into a unified "Recurring Tracker" page at the same route (`/dashboard/budget/subscriptions`)
- Display **both** recurring expenses and recurring incomes in a tabbed or sectioned layout
- Add **edit** action to each recurring item (opens existing edit dialogs for expenses/incomes)
- Add **skip occurrence** action for recurring items (extend existing skip dialog to also support expenses)
- Add **cancel** action to end a recurring item (sets `end_date` to today, effectively deactivating it)
- Update the summary card to show combined recurring totals (expenses + incomes + net)
- Update sidebar nav label from "Subscriptions" to "Recurring"

## Capabilities

### New Capabilities

- `recurring-tracker-page`: Unified page displaying all recurring expenses and incomes with management actions (edit, skip, cancel)
- `skip-recurring-expense`: Allow users to skip a single occurrence of a recurring expense (mirrors existing income skip functionality)
- `cancel-recurring-item`: Allow users to cancel/end a recurring expense or income by setting its end_date

### Modified Capabilities

- None -- existing specs remain unchanged; the recurring-income-list and skip-recurring-occurrence capabilities on the Budget dashboard page are unaffected

## Impact

- **Frontend**: Refactor `subscription-list.tsx`, `subscription-total-card.tsx`, and `subscriptions/page.tsx`; add new action dialogs/components; update sidebar nav
- **Backend**: New endpoint for skipping recurring expenses (create negative expense record); update endpoint or add new endpoint for canceling recurring items (set end_date)
- **Database**: No schema changes needed -- existing `end_date`, `recurring_type`, `start_date` fields are sufficient
