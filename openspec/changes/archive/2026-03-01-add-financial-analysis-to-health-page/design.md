## Context

The "Health" page in the web UI (`web/apps/core/src/app/(dashboard)/health/`) currently displays a "Spending by Day" chart that defaults to the current month. It lacks granular time filtering and advanced financial insights. The backend already provides most necessary analytics endpoints (Savings Rate, Velocity, Trends, Category Breakdown).

## Goals / Non-Goals

**Goals:**
-   Implement a week filter for the "Spending by Day" chart on the Health page.
-   Add a "Savings Rate" widget to the Health page.
-   Add a "Spending by Category" trend widget (month-over-month).
-   Improve the overall layout of the Health page to accommodate these new widgets.
-   Ensure data fetching is efficient using React Query.

**Non-Goals:**
-   Building a completely new analytics engine (backend already supports most features).
-   Implementing complex predictive analytics (e.g., AI forecasting).
-   Modifying the database schema.

## Decisions

1.  **Frontend Filtering Strategy**:
    -   Use a date picker or a preset dropdown (This Week, Last Week, This Month) to filter the "Spending by Day" chart.
    -   The backend endpoint `/budget/stats/trends` will be called with date range parameters (start_date, end_date) to fetch specific week's data.

2.  **Widget Architecture**:
    -   Create reusable widget components in `web/apps/core/src/components/health/`.
    -   Use `recharts` for visualizations (already a dependency or standard choice for this project).

3.  **Data Fetching**:
    -   Utilize `@tanstack/react-query` hooks.
    -   Create or reuse hooks for `useSavingsRate`, `useSpendingTrends`, `useCategoryTrends`.

4.  **Layout**:
    -   Adopt a grid layout (CSS Grid) for the widgets on the Health page.
    -   Primary focus: "Spending by Day" chart takes prominence.
    -   Secondary widgets: "Savings Rate" (Gauge/Simple Percentage), "Category Breakdown" (Pie/Bar), "Top Expenses".

## Risks / Trade-offs

-   **[Risk] Backend Performance**: Fetching daily trends for a specific week might be slow if not indexed properly.
    -   *Mitigation*: Rely on existing backend optimizations. If slow, implement client-side caching.
-   **[Risk] Data Granularity**: "Spending by Day" might look sparse for a single week if data is limited.
    -   *Mitigation*: Ensure the chart handles empty states gracefully.
-   **[Risk] API Contract Changes**: The existing endpoints might return data in a format not ideal for the new widgets.
    -   *Mitigation*: Use a thin adapter layer in the frontend API client to transform data if necessary.
