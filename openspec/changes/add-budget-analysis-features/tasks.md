## 1. Database Schema

- [x] 1.1 Create migration for `category_budgets` table
- [x] 1.2 Create migration to add `category_type` column to `budget_categories`
- [x] 1.3 Create migration for `savings_goals` table
- [ ] 1.4 Run migrations and verify schema

## 2. SQL Queries (sqlc)

- [x] 2.1 Add query to create/get/update/delete category budgets
- [x] 2.2 Add query to get category budgets by month
- [x] 2.3 Add query to update category type (need/want/savings)
- [x] 2.4 Add query to calculate savings rate (income - expenses)
- [x] 2.5 Add query to get upcoming recurring expenses (7/30 days)
- [x] 2.6 Add query to calculate daily spending for velocity
- [x] 2.7 Add query to get spending by day of week
- [x] 2.8 Add query to aggregate spending by merchant/pattern
- [x] 2.9 Run `sqlc generate` to regenerate Go code

## 3. Backend - Budget Analytics API

- [x] 3.1 Create endpoint `GET /api/budget/stats/savings-rate`
- [x] 3.2 Create endpoint `GET /api/budget/velocity`
- [x] 3.3 Create endpoint `GET /api/budget/forecast/upcoming`
- [x] 3.4 Add models for savings rate and velocity responses
- [x] 3.5 Add helper functions for date calculations

## 4. Backend - Budget Setting API

- [x] 4.1 Create endpoint `POST /api/budget/category-budgets`
- [x] 4.2 Create endpoint `PUT /api/budget/category-budgets/:id`
- [x] 4.3 Create endpoint `GET /api/budget/category-budgets`
- [x] 4.4 Create endpoint `DELETE /api/budget/category-budgets/:id`
- [x] 4.5 Add endpoint `PUT /api/budget/categories/:id/type` for classification
- [x] 4.6 Add models for budget request/response types

## 5. Backend - Financial Health API

- [x] 5.1 Create endpoint `GET /api/budget/stats/health-score`
- [x] 5.2 Create endpoint `GET /api/budget/analysis/503020`
- [x] 5.3 Create endpoint `GET /api/budget/analysis/weekday-pattern`
- [x] 5.4 Create endpoint `GET /api/budget/trends/month-over-month`
- [x] 5.5 Add models for health score and 50/30/20 responses

## 6. Backend - Merchant Analysis API

- [x] 6.1 Create endpoint `GET /api/budget/analysis/merchants`
- [x] 6.2 Create endpoint `GET /api/budget/subscriptions`
- [x] 6.3 Add models for merchant breakdown and subscription responses

## 7. Frontend - Types & API Client

- [x] 7.1 Add TypeScript types for savings rate, velocity, forecasts
- [x] 7.2 Add types for category budgets and variance
- [x] 7.3 Add types for health score and 50/30/20 data
- [x] 7.4 Add API functions for new endpoints in `lib/api.ts`

## 8. Frontend - Budget Analytics Components

- [x] 8.1 Create `SavingsRateCard` component with color indicators
- [x] 8.2 Create `SpendingVelocityCard` with warning states
- [x] 8.3 Create `UpcomingBillsCard` component
- [x] 8.4 Add components to budget dashboard

## 9. Frontend - Budget Setting Components

- [x] 9.1 Create `CategoryBudgetForm` component
- [x] 9.2 Create `BudgetVarianceTable` with progress bars
- [x] 9.3 Create `CategoryTypeSelector` (need/want/savings)
- [x] 9.4 Add budget setting UI to settings page

## 10. Frontend - Financial Health Components

- [x] 10.1 Create `HealthScoreCard` component
- [x] 10.2 Create `FiftyThirtyTwentyChart` (pie/donut chart)
- [x] 10.3 Create `WeekdaySpendingChart` (bar chart)
- [x] 10.4 Create `SpendingTrendCard` with trend indicators
- [x] 10.5 Add health dashboard page

## 11. Frontend - Merchant Analysis Components

- [x] 11.1 Create `TopMerchantsTable` component
- [x] 11.2 Create `SubscriptionList` component
- [x] 11.3 Create `SubscriptionTotalCard` component
- [x] 11.4 Add subscriptions page

## 12. Frontend - React Query Hooks

- [x] 12.1 Add `useSavingsRate` hook
- [x] 12.2 Add `useSpendingVelocity` hook
- [x] 12.3 Add `useUpcomingBills` hook
- [x] 12.4 Add `useCategoryBudgets` hook with mutations
- [x] 12.5 Add `useHealthScore` hook
- [x] 12.6 Add `useFiftyThirtyTwenty` hook
- [x] 12.7 Add `useSubscriptions` hook

## 13. Integration & Testing

- [ ] 13.1 Test all new API endpoints with curl/Postman
- [x] 13.2 Verify calculations manually with sample data
- [ ] 13.3 Test frontend components with sample data
- [ ] 13.4 Run `make lint` and fix any issues
- [x] 13.5 Run `go test ./...` for backend
- [ ] 13.6 Update Swagger documentation
- [x] 13.7 Verify TypeScript compilation with `npx tsc --noEmit`

## 14. Documentation

- [ ] 14.1 Update API documentation with new endpoints
- [ ] 14.2 Add usage examples to README
- [ ] 14.3 Update AGENTS.md with new patterns if needed
