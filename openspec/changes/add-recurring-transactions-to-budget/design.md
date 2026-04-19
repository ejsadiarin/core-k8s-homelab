## Context

The Budget dashboard needs enhancement to provide visibility into recurring income and expenses. Currently:
- `UpcomingBillsCard` shows recurring expenses only (next 7/30 days)
- No dedicated display for recurring income
- No way to handle one-time skips of recurring income
- The existing Subscriptions page exists but is separate from the main dashboard

The backend already has:
- `GetRecurringIncomeRules` - fetches active recurring incomes
- `GetRecurringIncomeForPeriod` - calculates recurring income for periods
- Existing calculation logic for weekly/monthly/daily frequencies

## Goals / Non-Goals

**Goals:**
- Display recurring summary (income, expenses, net) as monthly equivalents on Budget dashboard
- Show list of recurring incomes with next expected date
- Allow skipping individual occurrences of recurring income (one-time deduction)
- Integrate seamlessly with existing shadcn/ui components and card-based layout

**Non-Goals:**
- Not modifying the existing Subscriptions page (remains separate)
- Not adding automated transaction matching (future feature)
- Not supporting custom recurrence patterns beyond weekly/bi-weekly/monthly/yearly
- Not adding push notifications for upcoming recurrences

## Decisions

1. **Recurring Summary Card** - New card component in the analytics row
   - Shows: Total recurring income (monthly), Total recurring expenses (monthly), Net recurring cash flow
   - Conversion: weekly × 4.33, yearly / 12, daily × 30
   - Similar styling to SavingsRateCard and SpendingVelocityCard

2. **Recurring Incomes Section** - Integrated into the "Recent Incomes" area
   - Toggle between "Recent Incomes" and "Recurring Incomes" or show combined
   - Display: Description, Amount, Frequency badge, Next expected date
   - Action: "Skip" button per item

3. **Skip Occurrence UX** - Dialog-based confirmation
   - User clicks "Skip" on a recurring income
   - Dialog shows: Income details, Occurrence date to skip (auto-calculated next date)
   - Options: Confirm skip, or adjust date manually
   - Creates a negative income record (-amount) for that specific date

4. **Backend API Strategy**
   - Reuse existing `GetRecurringIncomeRules` with additional date calculation
   - May need new endpoint for "recurring income with next dates" (or compute on frontend)
   - No database changes - use existing `amount` field with negative values for skips

5. **Skip Storage Approach**
   - Option A: Create negative income record (existing approach, shows in history)
   - Option B: Add `skipped_dates` array to recurring income (hides from UI)
   - Chosen: Option A - creates visible negative income record so users can see/audit skips

## Risks / Trade-offs

- **[Risk]** Skipping might create confusion in historical records
  - **Mitigation**: Add clear labeling ("Skipped: [description]") and optionally exclude from certain stats

- **[Risk]** Bi-weekly frequency not natively supported in backend
  - **Mitigation**: Store as weekly with skip pattern, or add bi-weekly as new recurring type
  - **Decision**: Support weekly only initially; user can create two weekly entries offset by 1 week for bi-weekly

- **[Risk]** Duplicate negative entries if user skips same date twice
  - **Mitigation**: Backend validation to check if skip already exists for that date/income pair

## Migration Plan

1. Add new API endpoint (or extend existing) for recurring income with next dates
2. Create new React components:
   - `RecurringSummaryCard`
   - `RecurringIncomeList` (integrated into dashboard)
   - `SkipOccurrenceDialog`
3. Update Budget page to include new components
4. Deploy frontend + backend simultaneously

No rollback needed - no database schema changes.

## Open Questions

- Should skipped occurrences be included in "Recent Incomes" list? Likely yes, shown with strikethrough or different styling.
- Should there be an "Undo skip" feature? Yes, delete the negative income record.
- Should we show the total "skipped amount" in the recurring summary? Nice-to-have, add if time permits.
