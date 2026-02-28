## Why

The "Health" page in the web UI currently lacks flexibility in time-based analysis and is missing key financial insights. The "spending by day" chart only supports monthly views, preventing users from analyzing shorter-term trends. Additionally, users want more financial analysis capabilities (like savings rate, spending velocity, and category trends) directly on the Health page to get a complete picture of their financial health.

## What Changes

1.  **Frontend - Health Page Refactor**:
    -   Add a week filter (dropdown) to the "Spending by Day" chart, allowing users to view daily spending for a specific week or the current month.
    -   Redesign the Health page layout to accommodate new analysis widgets.
    -   Add new visualization components for financial insights.
2.  **Backend - New/Enhanced Analytics Endpoints**:
    -   Potentially enhance existing `/budget/stats/trends` endpoint to accept week parameters if not already supported.
    -   Ensure endpoints for Savings Rate, Spending Velocity, and Category Trends are accessible and performant for the frontend.
3.  **New Analysis Widgets**:
    -   Add "Spending by Day" widget with weekly filtering.
    -   Add "Savings Rate" widget (gauge/progress).
    -   Add "Spending by Category" trend widget (month-over-month).

## Capabilities

### New Capabilities
-   `weekly-spending-trends`: Ability to view daily spending filtered by a specific week.
-   `financial-insights-widgets`: Set of small widgets displaying key financial metrics (Savings Rate, Spending Velocity).
-   `category-trend-analysis`: Month-over-month comparison of spending by category.

### Modified Capabilities
-   `health-page`: The existing Health page specification will be updated to include new widgets and filtering capabilities.

## Impact

-   **Frontend**: `web/apps/core/src/app/(dashboard)/health/` - Major updates to components and page layout.
-   **Backend**: `web/apps/api-gateway/internal/domain/budget/` - Potential minor enhancements to existing stats endpoints.
-   **Shared**: TypeScript types for new API responses.
