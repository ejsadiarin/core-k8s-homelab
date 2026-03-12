## Context

The budget tracker backend calculates recurring income at read-time using Go code (`calculateRecurringIncome` / `calculateRecurringIncomeForPeriod`). A single `budget_incomes` row with `recurring_type` set represents the rule, and occurrences are never materialized as individual DB rows. Stats endpoints correctly prorate these into totals, but the income listing endpoints (`GET /api/budget/incomes`) only return raw DB rows -- so recurring income shows as a single rule entry rather than individual occurrences.

The frontend currently has a custom date range picker (two date inputs + clear button) for analytics cards but no quick preset buttons. There is no dedicated summary page -- income/expense totals are scattered across analytics cards (SavingsRateCard, CurrentTotalMoneyCard, SpendingVelocityCard).

**Tech stack**: Go (chi router, sqlc, zerolog) backend, Next.js 14 (App Router, React Query, Tailwind, shadcn/ui) frontend.

## Goals / Non-Goals

**Goals:**
- Make recurring income occurrences visible in income listings so users can see exactly which recurring entries contributed to their balance on specific dates
- Provide quick date range preset filters (7D, 30D, 90D, This Month, This Year) alongside existing custom date range
- Create a monthly summary page showing income, expenses, net savings, and transaction breakdown for any period

**Non-Goals:**
- Materializing recurring income occurrences into the database (keep read-time computation)
- Changing how recurring income is calculated in existing stats endpoints
- Adding recurring expense occurrence expansion (can be a follow-up)
- Editing or deleting individual virtual occurrences (they are computed, not stored)

## Decisions

### 1. New backend endpoint for recurring income occurrences

**Decision**: Create `GET /api/budget/incomes/occurrences?start_date=...&end_date=...` that returns expanded virtual entries.

**Rationale**: The existing `GET /api/budget/incomes` returns paginated raw DB rows. Rather than modifying that endpoint (which would break pagination semantics and existing consumers), a separate endpoint cleanly separates "show me DB records" from "show me what happened in this period." The new endpoint computes occurrences for each recurring rule that overlaps the date range, aligns them to actual dates (respecting day-of-week for weekly, day-of-month for monthly), and returns them as virtual income entries.

**Alternative considered**: Modifying `GET /api/budget/incomes` to include virtual entries. Rejected because it complicates pagination, breaks existing behavior, and mixes stored vs computed data.

### 2. Frontend-only period presets (no backend changes for presets)

**Decision**: Period presets are computed entirely in the frontend. Clicking "7D" sets `startDate = today - 7 days` and `endDate = today`, then passes these to existing endpoints.

**Rationale**: All analytics endpoints already accept `start_date`/`end_date` parameters. No backend work needed for presets.

### 3. Monthly Summary as a new page, not embedded in dashboard

**Decision**: Create `/dashboard/budget/summary` as a new page in the sidebar nav.

**Rationale**: The dashboard is already dense with cards. A summary page provides a focused view where the user can drill into period-specific details without cluttering the main dashboard. The dashboard's existing analytics cards continue to serve as quick glances.

### 4. Reusable PeriodPresetFilter component

**Decision**: Build a shared `PeriodPresetFilter` component that emits `{ startDate, endDate, preset }` and can be used on both the budget dashboard (for analytics cards) and the monthly summary page.

**Rationale**: Avoids duplicating date calculation logic. The component maintains both preset state and custom date state, with custom dates overriding presets.

### 5. Virtual occurrence entries marked distinctly

**Decision**: Virtual occurrence entries returned by the new endpoint include a `is_virtual: true` field and a `source_income_id` pointing back to the recurring rule. The frontend renders these with a distinct badge ("Recurring" or frequency label) and they are non-editable/non-deletable inline.

**Rationale**: Users need to distinguish between manually entered one-time incomes and computed recurring occurrences. Clicking a virtual entry can navigate to the source recurring rule for editing.

## Risks / Trade-offs

- **Performance of occurrence expansion**: For daily recurring incomes over large date ranges, the number of virtual entries could be large (e.g., 365 entries for a year). Mitigation: Default to short ranges (30 days), cap at 366 entries per rule, paginate the results.
- **Consistency between occurrence expansion and stats calculation**: The occurrence endpoint must use the same date-alignment logic as the stats calculations to avoid discrepancies. Mitigation: Share or closely mirror the Go calculation logic.
- **No editing virtual entries**: Users may want to adjust a single occurrence. Mitigation: Out of scope; they can skip occurrences (existing feature) or edit the recurring rule. Document this in the UI.
