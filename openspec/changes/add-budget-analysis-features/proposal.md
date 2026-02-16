## Why

The current budget tracker provides basic CRUD operations for expenses and income, but lacks advanced analytics that help users understand their financial health and make better decisions. Industry-standard budgeting tools provide insights like savings rates, budget variance tracking, spending velocity, and the 50/30/20 rule analysis. These features transform the app from a simple expense logger into a comprehensive financial planning tool.

## What Changes

### Phase 1: Core Budget Analytics
- **Savings Rate Tracking**: Calculate and display (Income - Expenses) / Income × 100 with color-coded health indicators (target: 15-20%)
- **Upcoming Bills & Cash Flow Forecasting**: Show recurring expenses due in the next 7/30 days with projected cash flow
- **Spending Velocity**: Display "At current pace, you'll spend $X this month" with over/under budget warnings

### Phase 2: Budget Setting & Variance
- **Category Budget Setting**: Allow users to set monthly budget limits per category
- **Budget vs Actual Variance**: Track actual spending vs budget with visual progress bars and alerts at 80% threshold
- **Variance Trends**: Month-over-month budget compliance tracking

### Phase 3: Financial Health Insights
- **50/30/20 Rule Tracker**: Categorize expenses as Needs/Wants/Savings and visualize the ideal 50/30/20 split
- **Subscription/Merchant Analysis**: Detect recurring merchants (Netflix, Spotify, etc.) and show subscription totals
- **Weekday vs Weekend Spending**: Compare spending patterns by day of week to identify lifestyle habits

### Database Changes
- New table: `category_budgets` - store monthly budget limits per category
- New column: `budget_categories.category_type` - classify as 'need', 'want', or 'savings'
- New table: `savings_goals` - track progress toward financial goals

## Capabilities

### New Capabilities
- `budget-analytics`: Core analytics engine for savings rate, velocity, and forecasting calculations
- `budget-setting`: CRUD operations for category budget limits and variance tracking
- `financial-health`: 50/30/20 rule tracking, spending pattern analysis, and health scoring
- `merchant-analysis`: Pattern detection for recurring merchants and subscription tracking

### Modified Capabilities
- None (this is a pure addition of new features)

## Impact

### Affected Code
- **Backend**: New endpoints in `/api/budget/stats/*`, new SQL queries in `sql/queries/budget.sql`, new models
- **Frontend**: New dashboard widgets, budget setting UI, analytics charts using recharts
- **Database**: New migrations for `category_budgets` and `savings_goals` tables

### APIs
- New endpoints:
  - `GET /api/budget/stats/savings-rate` - Monthly/quarterly savings rate
  - `GET /api/budget/forecast/upcoming` - Upcoming recurring expenses
  - `GET /api/budget/velocity` - Spending velocity projection
  - `POST/PUT/GET/DELETE /api/budget/category-budgets` - Budget setting CRUD
  - `GET /api/budget/stats/health-score` - Composite financial health score
  - `GET /api/budget/analysis/merchant-breakdown` - Top merchants and subscriptions
  - `GET /api/budget/analysis/weekday-pattern` - Day-of-week spending patterns

### Dependencies
- Uses existing `budget_expenses`, `budget_incomes`, `budget_categories` tables
- Leverages existing recurring expense/income patterns
- Frontend uses existing shadcn/ui components and recharts for visualizations

### Migration Notes
- Category types ('need', 'want', 'savings') will default to NULL; users can classify existing categories
- Budget amounts are optional; existing behavior unchanged until budgets are set
