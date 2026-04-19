## Why

The web UI has several mobile responsiveness issues that degrade user experience on smaller screens: the "Spending by Day" chart overflows and becomes unreadable with large date ranges, the mobile navigation bar is missing icons for key pages (Health, Recurring), the Health page layout is not optimized for mobile, and the date range selector requires an unnecessary "Apply" button instead of auto-fetching on selection.

## What Changes

- **Spending by Day chart**: Replace current layout with horizontally scrollable container; ensure price labels don't condense/collide on wide date ranges
- **Mobile navigation**: Add icons for Health, Recurring, and other missing pages in the bottom navigation bar
- **Health page mobile layout**: Ensure all components render responsively on mobile viewports
- **Date range auto-fetch**: Remove "Apply" button; fetch data automatically when date is selected in the calendar picker (Health page)

## Capabilities

### New Capabilities

None - all changes are modifications to existing components.

### Modified Capabilities

- `dashboard-sidebar`: Mobile navigation bar missing icons for Health and Recurring pages
- `financial-health`: Mobile responsiveness issues and date range selector behavior
- `budget-analytics`: "Spending by Day" chart overflow and label condensation on wide date ranges

## Impact

- **Frontend Components**:
  - `weekday-spending-chart.tsx` - horizontal scroll implementation
  - `dashboard-sidebar.tsx` or mobile nav component - add missing icons
  - `health/page.tsx` - remove Apply button, auto-fetch on date select
  - Various layout components for mobile responsiveness

- **User Experience**: Improved mobile usability, clearer data visualization, faster interaction flow
