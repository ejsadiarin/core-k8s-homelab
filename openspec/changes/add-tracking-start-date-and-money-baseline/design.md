## Context

Currently, financial calculations (Savings Rate, 50/30/20, Health Score) use cumulative income from the beginning of time, making period-based analysis incorrect. User wants to start tracking from Jan 15, 2026, but also maintain visibility of actual total money (₱12,345.60 as of Feb 17, 2026). 

**Current State:**
- Income queries: `GetOneTimeIncomeToDate` sums ALL income up to date (cumulative)
- Expenses: Correctly filtered by date range
- Result: Savings rate calculation is wrong (e.g., 5% when should be 40%)

**Constraints:**
- User has existing income entries before Jan 15 for record-keeping
- Current total money known: Bank ₱9,872.78 + GCash ₱1,277.82 + Cash ₱1,195 = ₱12,345.60
- Investments excluded from total money tracking
- All amounts in Philippine Pesos (PHP)

## Goals / Non-Goals

**Goals:**
- Establish tracking start date (Jan 15, 2026) for all financial calculations
- Calculate money baseline by working backwards from current total
- Display actual total money alongside budget metrics
- Mark pre-tracking income entries as excluded from calculations
- Fix period-based income bugs (separate but related)

**Non-Goals:**
- Full account balance tracking system (bank/wallet reconciliation)
- Multi-currency support
- Investment account tracking
- Historical data backfill before Jan 15

## Decisions

### Decision 1: Backwards Baseline Calculation
**Choice:** Calculate Jan 15 baseline from current total money (Feb 17)
**Rationale:** User knows current total (₱12,345.60) but not Jan 15 balance
**Formula:** `baseline = current_total - (income_since_jan15 - expenses_since_jan15)`
**Alternative Considered:** Ask user to manually enter Jan 15 balance → Rejected (user doesn't remember)

### Decision 2: Exclusion Flag vs Date Filtering
**Choice:** Add `exclude_from_calculations` boolean to `budget_incomes`
**Rationale:** 
- Preserves historical records while excluding from calculations
- More explicit than date-based filtering alone
- Allows future flexibility (e.g., exclude specific entries regardless of date)
**Alternative Considered:** Only use date filtering (`WHERE date >= tracking_start_date`) → Rejected (less flexible, harder to debug)

### Decision 3: User-Level vs System-Level Tracking Start
**Choice:** Store `tracking_start_date` per user in `users` table
**Rationale:** Different users may start tracking at different times
**Alternative Considered:** Global system setting → Rejected (not multi-tenant friendly)

### Decision 4: Migration Strategy for Existing Data
**Choice:** Automated migration sets baseline and marks pre-Jan 15 income
**Steps:**
1. Query total income since Jan 15: `SUM(amount) WHERE date >= '2026-01-15'`
2. Query total expenses since Jan 15: `SUM(amount) WHERE expense_date >= '2026-01-15'`
3. Calculate: `baseline = 12345.60 - (income - expenses)`
4. Mark all income entries: `UPDATE budget_incomes SET exclude_from_calculations = true WHERE date < '2026-01-15'`

**Alternative Considered:** Manual baseline entry via UI → Rejected for initial implementation (can add later)

### Decision 5: Current Total Money Calculation
**Choice:** Always calculate dynamically: `baseline + (Σincome - Σexpenses) since tracking_start_date`
**Rationale:** 
- Single source of truth (baseline)
- Auto-updates as transactions added
- No sync issues
**Alternative Considered:** Store `current_total` and update on each transaction → Rejected (race conditions, sync complexity)

### Decision 6: Display Strategy
**Choice:** Separate "Current Total Money" card from budget metrics
**Rationale:** 
- Clear distinction between "what I have" vs "how I'm budgeting"
- Total money includes baseline (pre-tracking)
- Budget metrics only show tracking period
**Alternative Considered:** Combine into one card → Rejected (confusing to users)

## Risks / Trade-offs

### Risk 1: Baseline Calculation Accuracy
**Risk:** If user has unrecorded income/expenses between Jan 15 - Feb 17, baseline will be wrong
**Mitigation:** 
- Document assumption: All income/expenses since Jan 15 are recorded
- Add UI note: "Baseline calculated from recorded transactions - ensure all Jan 15+ entries are complete"
- Allow manual baseline adjustment in settings (future enhancement)

### Risk 2: Date Filtering Performance
**Risk:** Adding date filters to all queries may impact performance
**Mitigation:** 
- Existing indexes on `budget_incomes.date` and `budget_expenses.expense_date`
- Add index on `exclude_from_calculations` if query performance degrades
- Monitor query performance after deployment

### Risk 3: Breaking Change to Existing Metrics
**Risk:** Users with historical data will see different financial metrics after migration
**Trade-off:** Accepted - this is intentional and fixes incorrect calculations
**Mitigation:** 
- Add release notes explaining the change
- Display tracking start date prominently on dashboard
- Keep old income entries visible (just excluded from calculations)

### Risk 4: Multi-User Data Integrity
**Risk:** Migration runs for all users, but only one user (you) has verified the baseline amount
**Mitigation:** 
- Migration only sets baseline for users who have data
- Add WHERE clause: `WHERE id = 'your-user-id'` for baseline calculation
- Other users can set baseline via settings later (manual)

## Migration Plan

### Step 1: Database Migration (013_add_tracking_baseline.sql)
```sql
-- Add columns
ALTER TABLE users ADD COLUMN tracking_start_date DATE DEFAULT '2026-01-15';
ALTER TABLE users ADD COLUMN money_baseline DECIMAL(10, 2) DEFAULT 0;
ALTER TABLE budget_incomes ADD COLUMN exclude_from_calculations BOOLEAN DEFAULT false;

-- Create index for performance
CREATE INDEX idx_budget_incomes_exclude ON budget_incomes(exclude_from_calculations) WHERE exclude_from_calculations = true;

-- For primary user only (replace user_id):
-- Calculate baseline from current total
WITH income_sum AS (
    SELECT COALESCE(SUM(amount), 0) as total 
    FROM budget_incomes 
    WHERE user_id = 'USER_ID' AND date >= '2026-01-15'
),
expense_sum AS (
    SELECT COALESCE(SUM(amount), 0) as total 
    FROM budget_expenses 
    WHERE user_id = 'USER_ID' AND expense_date >= '2026-01-15'
)
UPDATE users 
SET money_baseline = 12345.60 - (
    (SELECT total FROM income_sum) - (SELECT total FROM expense_sum)
)
WHERE id = 'USER_ID';

-- Mark pre-tracking income as excluded
UPDATE budget_incomes
SET exclude_from_calculations = true
WHERE date < '2026-01-15';
```

### Step 2: Backend Updates
1. Add tracking_start_date filter to all financial queries
2. Add exclude_from_calculations filter to income queries
3. Create `GET /api/budget/current-total-money` endpoint
4. Update existing endpoints to respect tracking date

### Step 3: Frontend Updates
1. Add "Current Total Money" card to dashboard
2. Add baseline/tracking date settings to user profile
3. Update all financial metric displays to show tracking period

### Step 4: Rollback Strategy
**If something goes wrong:**
```sql
-- Rollback migration
ALTER TABLE users DROP COLUMN tracking_start_date;
ALTER TABLE users DROP COLUMN money_baseline;
ALTER TABLE budget_incomes DROP COLUMN exclude_from_calculations;
```
**Note:** Rollback loses baseline data - document baseline value externally before migration

## Open Questions

1. **Should we add manual baseline adjustment UI?** 
   - Allows user to correct baseline if calculation wrong
   - Adds complexity to initial implementation
   - **Decision:** Defer to future enhancement

2. **How to handle tracking_start_date changes?**
   - What if user wants to change from Jan 15 to Jan 1?
   - Recalculate baseline? Re-mark exclusions?
   - **Decision:** Disallow changes for v1 (immutable after set)

3. **Should excluded income be visually distinct in income list?**
   - Badge? Greyed out? Separate section?
   - **Decision:** Add grey badge "[Historical]" next to excluded entries
