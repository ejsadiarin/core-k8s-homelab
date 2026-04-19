## 1. Database Migration

- [x] 1.1 Create migration to add `is_debt` boolean column to `budget_expenses` table
- [x] 1.2 Create migration to add `is_debt` boolean column to `budget_recurring_expenses` table
- [x] 1.3 Run migrations and verify schema changes

## 2. Backend - Debt Tracking

- [x] 2.1 Update expense creation/edit endpoints to accept `is_debt` parameter
- [x] 2.2 Add SQL query `GetDebtPaymentsForPeriod` in `budget.sql`
- [x] 2.3 Implement `calculateMonthlyDebtPayments` function in `handler_stats.go`
- [x] 2.4 Run `sqlc generate` to regenerate repository code

## 3. Backend - Emergency Fund Metrics

- [x] 3.1 Add SQL query `GetAverageMonthlyExpenses` (last 3 months) in `budget.sql`
- [x] 3.2 Add SQL query `GetTotalSavings` in `budget.sql`
- [x] 3.3 Implement `calculateEmergencyFundMonths` function in `handler_stats.go`
- [x] 3.4 Run `sqlc generate` to regenerate repository code

## 4. Backend - Multi-Factor Health Score

- [x] 4.1 Add `FactorScores` struct to `models.go` with SavingsRate, DebtToIncome, EmergencyFund fields
- [x] 4.2 Update `HealthScoreResponse` struct to include `FactorScores` field
- [x] 4.3 Implement `calculateSavingsRateScore` function (max 40 points)
- [x] 4.4 Implement `calculateDebtToIncomeScore` function (max 35 points)
- [x] 4.5 Implement `calculateEmergencyFundScore` function (max 25 points)
- [x] 4.6 Refactor `GetHealthScore` handler to use weighted multi-factor calculation
- [x] 4.7 Update recommendations logic to use factor analysis

## 5. Backend - Error Handling

- [x] 5.1 Replace `_` error assignments with proper error handling in `GetHealthScore`
- [x] 5.2 Replace `_` error assignments with proper error handling in `GetSavingsRate`
- [x] 5.3 Add error logging with zerolog for all database failures
- [x] 5.4 Return HTTP 500 with descriptive messages for query failures

## 6. Backend - 50/30/20 Terminology

- [x] 6.1 Update `FiftyThirtyTwentyResponse` to use `investments` key instead of `savings`
- [x] 6.2 Update `GetFiftyThirtyTwenty` handler response mapping
- [x] 6.3 Keep database `slug = "savings"` for backward compatibility

## 7. Backend - Tests

- [x] 7.1 Add tests for `calculateMonthlyDebtPayments` function
- [x] 7.2 Add tests for `calculateEmergencyFundMonths` function
- [x] 7.3 Add tests for `calculateSavingsRateScore` function
- [x] 7.4 Add tests for `calculateDebtToIncomeScore` function
- [x] 7.5 Add tests for `calculateEmergencyFundScore` function
- [ ] 7.6 Add integration tests for `GetHealthScore` handler
- [ ] 7.7 Add integration tests for `GetSavingsRate` handler

## 8. Frontend - Health Score Card

- [x] 8.1 Update `HealthScoreCard` component to display factor breakdown
- [x] 8.2 Add visual indicators for each factor score
- [x] 8.3 Update recommendations display to show factor-based advice

## 9. Frontend - 50/30/20 Chart

- [x] 9.1 Update `FiftyThirtyTwentyChart` to display "Investments" label
- [x] 9.2 Update type definitions for `investments` key
- [x] 9.3 Add tooltip/hint explaining difference between savings rate and investment expenses

## 10. Verification

- [ ] 10.1 Manual test: Create debt payment expense and verify calculation
- [ ] 10.2 Manual test: Verify emergency fund months calculated correctly
- [ ] 10.3 Manual test: Verify health score reflects all three factors
- [ ] 10.4 Manual test: Verify error handling returns proper HTTP 500
- [ ] 10.5 Manual test: Verify 50/30/20 displays "Investments" label
