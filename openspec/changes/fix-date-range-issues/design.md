## Context

The custom date range analytics feature was recently implemented, allowing users to filter budget statistics by start and end dates. However, there are bugs in how the backend parses partial dates (e.g. `end_date` without `start_date`) which breaks the SQL queries and frontend rendering. Furthermore, the frontend is hardcoded to show "Jan 15, 2026" in the Total Money card instead of the dynamic start date. Finally, the "Health" page needs to be updated to use this custom date range picker for consistency.

## Goals / Non-Goals

**Goals:**
- Fix the backend date parsing logic in `handler_stats.go` to safely handle missing `start_date` or `end_date` query parameters.
- Ensure the backend SQL calculations accurately bound their results by the provided dates.
- Update the Total Money and Spending Velocity components to use the dynamic date range returned by the API.
- Introduce the custom date picker component to the Health page, replacing the old week/month toggle.

**Non-Goals:**
- Completely overhauling the backend SQL queries (just fixing the bounds).
- Adding new charts or metrics to the Health page.

## Decisions

- **Backend Date Parsing**: The `parseDateRange` utility will be updated. If `end_date` is provided but `start_date` is omitted, it should default the `start_date` to an appropriate early bound (or the beginning of the month/epoch), or throw a clear validation error. Given the previous implementation, defaulting to the epoch (or a sensible default like 30 days prior if only end date is given, but probably epoch is safer for "all time up to X") is best. Actually, a better approach is to make `start_date` default to the first of the current month if not provided, but since the requirement says "Set default boundaries for Health page: Jan 15 to today", maybe we just ensure the frontend always sends both, and backend handles missing ones gracefully. Let's make the backend handle missing `start_date` by defaulting it to `0001-01-01` (zero time) or similar so it doesn't break SQL.
- **Frontend Health Page State**: We will use the existing `useSearchParams` approach to read/write `start_date` and `end_date` to the URL on the Health page, just like on the main dashboard. This allows bookmarking and consistency.

## Risks / Trade-offs

- **Risk**: Backend date parsing changes might affect other endpoints using the same utility.
- **Mitigation**: Ensure `parseDateRange` changes are isolated or safe for all consumers. Write tests if possible, or manually verify all pages.
