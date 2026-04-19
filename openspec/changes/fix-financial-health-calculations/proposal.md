## Why

The Financial Health feature produces incomplete and potentially misleading assessments. The health score calculation only considers savings rate while returning hardcoded zeros for debt-to-income ratio and emergency fund months. Additionally, critical database errors are silently ignored during calculations, and the 50/30/20 analysis uses confusing terminology. These issues compromise the accuracy and trustworthiness of financial health insights presented to users.

## What Changes

- **Fix health score calculation** to include multiple factors (savings rate, debt-to-income ratio, emergency fund status)
- **Add proper error handling** for all database queries in health calculations (no silent failures)
- **Implement debt-to-income ratio** calculation based on recurring debt payments vs income
- **Implement emergency fund months** calculation based on savings divided by monthly expenses
- **Rename "savings" category** in 50/30/20 to "investments" to avoid confusion with actual savings rate
- **Add comprehensive test coverage** for health-related handlers
- **Fix edge cases** in spending velocity (division by zero, unusual date ranges)

## Capabilities

### New Capabilities

- `debt-tracking`: Track recurring debt payments (credit cards, loans, mortgages) for debt-to-income ratio calculation
- `emergency-fund-metrics`: Calculate emergency fund coverage in months based on savings vs monthly expenses
- `multi-factor-health-score`: Health score algorithm using multiple financial health indicators

### Modified Capabilities

- `budget-health-analysis`: Update to use multi-factor scoring and proper error handling
- `fifty-thirty-twenty`: Rename "savings" expense category to "investments" for clarity

## Impact

- **Backend**: `handler_stats.go`, `models.go`, SQL queries in `budget.sql` and `income.sql`
- **Frontend**: `HealthScoreCard` component to display new metrics, `FiftyThirtyTwentyChart` for category rename
- **Database**: Potential new tables/columns for debt tracking
- **API**: Enhanced response payloads with actual calculations instead of hardcoded zeros
- **Tests**: New test file or additions to `handler_stats_test.go`
