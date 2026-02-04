## Why

The budget tracker UI has several responsiveness and UX issues that negatively impact the user experience. Long text content overflows in the expense detail dialog, there is no feedback for CRUD operations, expense cards in the Recent Expenses section are not interactive, and there is a noticeable delay when navigating back to pages after data changes. These issues create a frustrating experience and reduce the perceived quality of the application.

## What Changes

- Fix text overflow in expense detail dialog for long titles, descriptions, and tags
- Make expense detail dialog larger and handle long text with proper wrapping and truncation
- Add collapsible tag display with "+N" indicator in detail dialog
- Make expense cards in Recent Expenses section clickable to open detail view
- Add toast notifications for CRUD operations (create, update, delete expenses)
- Implement data refresh/invalidation on page navigation to eliminate stale data delays

## Capabilities

### New Capabilities
- `toast-feedback`: Toast notification system for user feedback on CRUD operations
- `clickable-expense-cards`: Interactive expense cards that open detail dialogs

### Modified Capabilities
- `expense-detail-dialog`: Enhanced responsiveness and text overflow handling
- `data-refresh`: Improved cache invalidation and data fetching strategy

## Impact

- **Frontend Components**: `expense-detail-dialog.tsx`, `expense-card.tsx`, budget dashboard page
- **React Query Hooks**: Cache invalidation logic in `use-budget.ts`
- **UI/UX**: Better responsiveness, immediate user feedback, reduced perceived latency
- **Dependencies**: May need to verify shadcn/ui toast component is available
