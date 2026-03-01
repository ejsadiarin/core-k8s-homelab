## Why

The recently introduced custom date range feature for budget analytics has some bugs that break data loading when partial dates are provided. Additionally, the tracking start date in the "Total Money" card is static instead of dynamic. Finally, we need to bring the new date range capabilities to the "Health" page for a consistent user experience across the dashboard.

## What Changes

- Fix a bug in the backend date parsing (`handler_stats.go`) where passing an `end_date` without a `start_date` breaks the "Total Money" and "Spending Velocity" data loading.
- Update the "Total Money" card to dynamically display the actual `start_date` used instead of a hardcoded "Jan 15, 2026".
- Ensure backend financial calculations strictly and accurately respect the provided date boundaries.
- Add the custom date range picker to the "Health" page.
- Refactor the Health page to use the provided date range instead of the existing week/month toggle.
- Set default boundaries for the Health page: `start_date` should default to Jan 15, 2026, and `end_date` to today.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `budget-stats`: The "Total Money" and "Spending Velocity" metrics now properly handle partial date ranges and accurately calculate within bounds. The UI reflects the dynamic start date.
- `financial-health`: The Health page now supports custom date ranges (start and end dates) instead of a simple week/month toggle, with default bounds from Jan 15, 2026 to today.

## Impact

- **Backend:** `web/apps/api-gateway/internal/domain/budget/handler_stats.go` and associated SQL queries for calculations.
- **Frontend Components:**
  - `web/apps/core/src/components/budget/current-total-money-card.tsx`
  - `web/apps/core/src/components/budget/spending-velocity-card.tsx`
- **Frontend Pages:**
  - `web/apps/core/src/app/dashboard/budget/health/page.tsx`
