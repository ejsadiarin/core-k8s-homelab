## Context

The Financial Health dashboard currently displays a health score that is calculated using only the savings rate metric. The backend returns hardcoded `0.0` values for `debt_to_income` and `emergency_fund_months` fields. Database errors are silently ignored during calculations, potentially returning incorrect results to users.

Current state:
- Health score: Base 50 + up to 30 points based on savings rate only
- Debt-to-income: Hardcoded to 0.0
- Emergency fund months: Hardcoded to 0.0
- Error handling: Database errors silently ignored with `_` assignment

## Goals / Non-Goals

**Goals:**
- Implement multi-factor health score using savings rate, debt-to-income ratio, and emergency fund status
- Add proper error handling for all database queries
- Calculate actual debt-to-income ratio from recurring debt payments
- Calculate actual emergency fund months from savings vs monthly expenses
- Rename 50/30/20 "savings" category to "investments" for clarity
- Add comprehensive test coverage for health handlers

**Non-Goals:**
- Changing the health score threshold values (excellent ≥80, good ≥60, fair ≥40)
- Adding new UI components for debt management
- Modifying the frontend date range handling
- Changing the spending velocity calculation algorithm

## Decisions

### D1: Health Score Weighting Algorithm

**Decision:** Use weighted scoring across three factors:
- Savings Rate: 40% weight (max 40 points)
- Debt-to-Income: 35% weight (max 35 points)
- Emergency Fund: 25% weight (max 25 points)

**Rationale:** Savings rate remains important but shouldn't dominate. Debt is critical for financial health. Emergency fund provides short-term security indicator.

**Alternatives considered:**
- Equal weighting (33/33/33): Doesn't reflect relative importance
- Savings-only: Current approach, inadequate
- 50/30/20: Overweights savings

### D2: Debt Tracking Implementation

**Decision:** Use existing recurring expense infrastructure with `is_debt` boolean flag.

**Rationale:** Minimizes schema changes, leverages existing patterns for recurring expenses.

**Alternatives considered:**
- New `budget_debts` table: More complex, requires new CRUD endpoints
- Manual debt input per health check: Not sustainable, no tracking history
- External debt API integration: Out of scope, adds external dependency

### D3: Emergency Fund Calculation

**Decision:** Calculate as `total_savings / average_monthly_expenses` using last 3 months average.

**Rationale:** Using average smooths out irregular expenses. Last 3 months is recent enough to be relevant.

**Alternatives considered:**
- Current month only: Too volatile
- 6-month average: May include outdated spending patterns
- User-set goal: Requires additional input, adds complexity

### D4: Error Handling Strategy

**Decision:** Return explicit errors to client with HTTP 500 and descriptive message.

**Rationale:** Silent failures hide problems and return incorrect data. Users deserve to know when calculations fail.

**Alternatives considered:**
- Default to zero on error: Hides issues, misleading
- Partial data return: Inconsistent, hard to reason about

## Risks / Trade-offs

1. **Data migration required** → Migration script to add `is_debt` column with default false
2. **Health scores will change** → Users may see different scores after deployment (communication needed)
3. **Debt tracking relies on user input** → Provide clear UI guidance for marking debts
4. **Emergency fund needs historical data** → Gracefully handle new users with limited history

## Migration Plan

1. **Phase 1: Database Migration**
   - Add `is_debt` boolean column to `budget_expenses` (default: false)
   - Add `is_debt` column to `budget_recurring_expenses` (default: false)

2. **Phase 2: Backend Deployment**
   - Deploy new calculation logic
   - Health scores will immediately reflect new algorithm

3. **Phase 3: Frontend Update**
   - Update HealthScoreCard to show all three factors
   - Update FiftyThirtyTwentyChart labels

4. **Rollback Strategy**
   - Revert backend deployment (calculations revert to old algorithm)
   - Database columns are additive, no data loss on rollback
