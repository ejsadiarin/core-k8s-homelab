## 1. Backend / API Preparation (Optional check)

- [x] 1.1 Verify `/budget/stats/trends` accepts date range parameters (start_date, end_date)
- [x] 1.2 Verify `/budget/stats/savings-rate` endpoint returns required data
- [x] 1.3 Verify `/budget/velocity` endpoint returns projected spend

## 2. Frontend - Data Layer

- [x] 2.1 Explore existing API types in `web/apps/core/src/types/`
- [x] 2.2 Create or update TypeScript interfaces for new API responses (SavingsRate, Velocity, CategoryTrends)
- [x] 2.3 Create React Query hooks: `useSpendingTrends(startDate, endDate)`, `useSavingsRate()`, `useSpendingVelocity()`, `useCategoryTrends()`

## 3. Frontend - Components (Widgets)

- [x] 3.1 Create `SpendingByDayChart` component with date range props
- [x] 3.2 Create `SavingsRateWidget` component (percentage display with color)
- [x] 3.3 Create `SpendingVelocityWidget` component (projected spend + status)
- [x] 3.4 Create `CategoryTrendWidget` component (bar chart or list with +/- indicators)

## 4. Frontend - Health Page Integration

- [x] 4.1 Refactor `app/(dashboard)/health/page.tsx` layout using Grid
- [x] 4.2 Add Week/Month filter control to the page (DatePicker or Dropdown)
- [x] 4.3 Integrate `SpendingByDayChart` with the new filter
- [x] 4.4 Integrate new widgets (Savings Rate, Velocity, Category Trends)
- [x] 4.5 Verify responsiveness and empty states

## 5. Verification

- [x] 5.1 Run `make lint` and fix any issues
- [x] 5.2 Verify the page renders with mock data or in dev environment
