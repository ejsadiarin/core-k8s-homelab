# Purpose

Defines pagination fixes and improvements for the expenses list page.

## MODIFIED Requirements

### Requirement: Backend pagination parameter binding
The backend SHALL use correct struct tags to bind URL query parameters.

#### Scenario: Binding page parameter from GET request
- **WHEN** frontend sends GET /api/budget/expenses?page=2&limit=5
- **THEN** backend uses `query:"page"` struct tag (not `form:"page"`)
- **THEN** PaginationParams.Page correctly binds to value 2

#### Scenario: Default pagination when no params provided
- **WHEN** frontend sends GET /api/budget/expenses without pagination params
- **THEN** backend defaults Page=1 and Limit=5
- **THEN** system returns first page of results

### Requirement: Frontend pagination state management
The frontend Pagination component SHALL use local React state for currentPage display.

#### Scenario: Page change UI responsiveness
- **WHEN** user clicks page 2 button
- **THEN** Pagination component immediately shows page 2 as current (using local state)
- **THEN** loading indicator shows while data fetches
- **THEN** data updates when API response arrives

#### Scenario: Pagination with stale data
- **WHEN** page state changes but API hasn't responded yet
- **THEN** UI shows new page number immediately
- **THEN** old data remains visible with loading state
- **THEN** new data replaces old when response arrives

## ADDED Requirements

### Requirement: Enhanced Pagination component UX
The Pagination component SHALL provide improved navigation for large page counts.

#### Scenario: First/last page navigation
- **WHEN** totalPages > 5
- **THEN** show first page (<<) and last page (>>) buttons
- **THEN** buttons hidden on mobile for space efficiency

#### Scenario: Accessible pagination
- **WHEN** pagination renders
- **THEN** all buttons have appropriate aria-labels
- **THEN** current page has aria-current="page"

## Files Modified

- `web/apps/api-gateway/models/pagination.go` - Changed struct tags from `form` to `query`
- `web/apps/core/src/app/dashboard/budget/expenses/page.tsx` - Fixed Pagination currentPage prop
- `web/apps/core/src/components/ui/pagination.tsx` - Enhanced with first/last buttons, ARIA labels
