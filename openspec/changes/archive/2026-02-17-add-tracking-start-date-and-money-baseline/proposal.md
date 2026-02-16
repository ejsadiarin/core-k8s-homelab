## Why

The current financial tracking system calculates metrics (Savings Rate, 50/30/20) using cumulative income from the beginning of time, making period-based analysis inaccurate. Additionally, users cannot see their actual total money across accounts. We need to establish a tracking start date (Jan 15, 2026) for clean budget calculations while maintaining visibility into total wealth.

## What Changes

- Add `tracking_start_date` to users table to establish when budget tracking begins
- Add `money_baseline` to users table to store total money at tracking start date
- Add `exclude_from_calculations` flag to `budget_incomes` to mark pre-tracking entries
- Create migration to backfill baseline from current total money (₱12,345.60 as of Feb 17, 2026)
- Update all financial calculation queries to filter by `tracking_start_date`
- Add "Current Total Money" display showing baseline + net change since tracking start
- Fix period-based income calculation bugs (separate issue but related)

## Capabilities

### New Capabilities
- `tracking-baseline`: User can set a tracking start date and money baseline, allowing separation of historical record-keeping from active budget analysis

### Modified Capabilities
- `financial-health`: Financial health metrics (Savings Rate, 50/30/20, Health Score) now calculate only from tracking_start_date forward, not from all-time data
- `income-tracking`: Income entries can be marked as excluded from calculations (pre-tracking period entries kept for records)

## Impact

**Database:**
- `users` table: +2 columns (`tracking_start_date`, `money_baseline`)
- `budget_incomes` table: +1 column (`exclude_from_calculations`)
- Migration `013_add_tracking_baseline.sql`

**Backend:**
- All financial stat handlers: Add date filters
- New endpoint: `GET /api/budget/current-total-money`
- Modified endpoints: `/api/budget/stats/savings-rate`, `/api/budget/analysis/503020`, `/api/budget/stats/health-score`

**Frontend:**
- New dashboard card: "Current Total Money"
- Settings page: Add baseline/tracking date configuration
- All financial metric components: Now filtered to tracking period

**Data Migration:**
- Calculate Jan 15 baseline from current total: `₱12,345.60 - (income since Jan 15 - expenses since Jan 15)`
- Mark all income entries before Jan 15 with `exclude_from_calculations = true`
