## Why

The expenses page has broken pagination functionality - clicking on page 2 doesn't retrieve different data (always returns page 1 data). Additionally, there are UI issues and TypeScript type errors that need to be fixed.

## What Changes

- **Root Cause Fix**: Backend `PaginationParams` struct uses `form` tags instead of `query` tags, causing page/limit params to not bind from URL query string
- Fix pagination UI to use local `page` state instead of API response `pagination.page`
- Update the limit from 10 to 5 items per page
- Improve UI alignment by adding `align-items: center` to filter container
- Fix TypeScript type errors in the component
- Enhance Pagination component with better UX (first/last buttons, ARIA labels)

## Capabilities

### New Capabilities
- None (this is a bug fix)

### Modified Capabilities
- None (this is a bug fix to existing implementation)

## Impact

- `web/apps/api-gateway/models/pagination.go` - Fix struct tags from `form` to `query`
- `web/apps/core/src/app/dashboard/budget/expenses/page.tsx` - Fix pagination currentPage prop
- `web/apps/core/src/components/ui/pagination.tsx` - Enhanced pagination UI component
- No database changes required

## Root Cause Analysis

The pagination wasn't working because:

1. **Backend Issue**: The `PaginationParams` struct in Go used `form:"page"` and `form:"limit"` tags. In Echo framework:
   - `form` tags bind from POST form data
   - `query` tags bind from URL query parameters
   
   Since the frontend sends GET requests with query params (`?page=2&limit=5`), the parameters were never binding, causing page to always default to 1.

2. **Frontend Issue**: The Pagination component used `pagination.page` from the API response instead of the local `page` state, causing UI inconsistency during data loading.
