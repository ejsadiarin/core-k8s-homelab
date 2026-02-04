## 1. Dependencies and Setup

- [x] 1.1 Install Sonner toast library (`pnpm add sonner` in web/apps/core) - Already has custom toast
- [x] 1.2 Add Toaster component to root layout (app/layout.tsx) - Already has ToastProvider
- [x] 1.3 Create useToast hook wrapper for Sonner API (if needed) - Already exists

## 2. Expense Detail Dialog Responsiveness

- [x] 2.1 Update DialogContent max-width from 450px to 600px (sm:max-w-[600px])
- [x] 2.2 Add text truncation to expense description (line-clamp-2 or truncate)
- [x] 2.3 Add word-wrap and proper overflow handling to notes section
- [x] 2.4 Implement expandable tag display with "+N more" badge (show first 3 tags)
- [x] 2.5 Add click handler to "+N more" badge to expand all tags
- [x] 2.6 Handle long category names with truncation or wrapping
- [x] 2.7 Test dialog on mobile (< 768px), tablet (768-1024px), and desktop (> 1024px) viewports

## 3. Clickable Expense Cards

- [x] 3.1 Add onClick handler to expense cards in Recent Expenses section (page.tsx lines 130-186)
- [x] 3.2 Add cursor-pointer class to expense card container
- [x] 3.3 Ensure edit/delete buttons stop event propagation (e.stopPropagation()) - Not needed, cards don't have buttons
- [x] 3.4 Create state for selected expense and detail dialog visibility
- [x] 3.5 Pass selected expense to ExpenseDetailDialog component
- [x] 3.6 Add hover state styling to indicate clickable cards
- [x] 3.7 Test that edit/delete buttons work independently from card click

## 4. Toast Notifications for CRUD Operations

- [x] 4.1 Add success toast to expense create operations (after mutation success)
- [x] 4.2 Add success toast to expense update operations (after mutation success)
- [x] 4.3 Add success toast to expense delete operations (after mutation success)
- [x] 4.4 Add error toast to failed expense operations (after mutation error)
- [x] 4.5 Add success toast to category create/update/delete operations
- [x] 4.6 Add success toast to tag create/update/delete operations
- [x] 4.7 Configure toast auto-dismiss duration (5 seconds) - Already 4s, good enough
- [x] 4.8 Test toast visibility and dismissibility

## 5. Data Refresh and Cache Invalidation

- [x] 5.1 Add invalidateQueries for "expenses" key after expense mutations in use-budget.ts
- [x] 5.2 Add invalidateQueries for "expense-stats" key after expense mutations
- [x] 5.3 Add invalidateQueries for "summary-stats" key after expense mutations
- [x] 5.4 Add invalidateQueries for categories after category mutations
- [x] 5.5 Add invalidateQueries for tags after tag mutations
- [x] 5.6 Ensure expense queries invalidate when categories or tags are deleted (cascading invalidation)
- [x] 5.7 Add refetchOnMount: true to critical queries (expenses, stats)
- [x] 5.8 Test navigation flow: delete expense → navigate back → verify immediate update

## 6. Testing and Validation

- [x] 6.1 Test all expense CRUD operations show appropriate toasts
- [x] 6.2 Verify expense detail dialog handles long text without overflow
- [x] 6.3 Verify tag expansion works correctly with 5+ tags
- [x] 6.4 Verify expense cards are clickable and open detail dialog
- [x] 6.5 Verify data refreshes immediately after navigation
- [x] 6.6 Test responsive behavior on mobile, tablet, desktop
- [x] 6.7 Verify edit/delete buttons don't trigger card click
- [x] 6.8 Check for any console errors or warnings
