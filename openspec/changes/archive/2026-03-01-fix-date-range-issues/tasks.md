## 1. Backend Fixes

- [x] 1.1 Update `parseDateRange` in `web/apps/api-gateway/internal/domain/budget/handler_stats.go` to handle missing `start_date` by defaulting to epoch (`0001-01-01` or similar).
- [x] 1.2 Verify that SQL calculations for "Total Money" and "Spending Velocity" correctly use the parsed date boundaries without error.

## 2. Frontend Total Money Card Fixes

- [x] 2.1 Update `web/apps/core/src/components/budget/current-total-money-card.tsx` to read the dynamic date range from API metadata or URL search params.
- [x] 2.2 Remove the hardcoded "Jan 15, 2026" and format the actual start date for the "Since <date>" label.

## 3. Frontend Health Page Updates

- [x] 3.1 Modify `web/apps/core/src/app/dashboard/budget/health/page.tsx` to read `start_date` and `end_date` from `useSearchParams`.
- [x] 3.2 Add the custom date picker inputs (Start Date and End Date) to the Health page, replacing the old week/month toggle UI.
- [x] 3.3 Set default values for the date pickers: Jan 15, 2026 for start, today for end.
- [x] 3.4 Ensure the hooks (e.g. `useBudget`) correctly pass down these custom date parameters so all charts/components update appropriately.

## 4. Verification

- [x] 4.1 Test the Total Money card dynamically updating based on date selection.
- [x] 4.2 Test the Health page rendering and updating correctly with custom date ranges.
- [x] 4.3 Verify there are no backend panics or SQL errors when partially formed dates are sent.
