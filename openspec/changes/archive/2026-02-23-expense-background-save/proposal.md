## Why

Expense updates block the UI with "Saving..." state while waiting for the API response. With NeonDB's serverless architecture causing occasional cold start latency (1-3 seconds), users experience the app as sluggish. Background save will close the dialog immediately and provide non-blocking toast feedback, improving perceived performance.

## What Changes

- Expense edit dialogs close immediately on submit (optimistic UI)
- Toast notifications show success/error after background operation completes
- Loading state removed from form submit button
- React Query handles cache invalidation automatically

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `expense-management`: Update expense operations to use non-blocking background save pattern with toast feedback instead of blocking UI state.

## Impact

- **Frontend**: `apps/core/src/app/dashboard/budget/expenses/page.tsx` - handleUpdate and handleCreateExpense functions
- **Frontend**: `apps/core/src/components/budget/expense-edit-dialog.tsx` - remove blocking behavior
- **Frontend**: `apps/core/src/components/budget/expense-form-dialog.tsx` - remove blocking behavior
- **UX**: Users can continue working immediately while save happens in background
