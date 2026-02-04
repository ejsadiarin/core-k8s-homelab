## Why

The expense detail dialog in the budget dashboard page has two critical bugs that break functionality:
1. The delete button incorrectly shows "Guest user is read-only" toast for non-guest users
2. The edit workflow doesn't properly complete - the edit dialog closes but changes aren't reflected

Additionally, the UI needs improvement:
- Dialog overflow handling looks broken
- Category badge should be positioned beside the price, not above it
- Long text should show "..." truncation indicator

## What Changes

- Fix the delete button logic to check the actual guest state, not just whether showToast exists
- Pass proper onEdit and onDelete callbacks from budget page to ExpenseDetailDialog
- Implement proper edit flow that updates the expense data after save
- Redesign dialog layout with category beside price
- Improve text truncation with proper ellipsis indicators
- Clean up overflow styling

## Capabilities

### New Capabilities
- `proper-delete-workflow`: Fixed delete confirmation and execution flow
- `proper-edit-workflow`: Fixed edit dialog with data refresh after save

### Modified Capabilities
- `expense-detail-dialog-ui`: Improved layout and text truncation

## Impact

- `expense-detail-dialog.tsx`: Fix delete logic, improve UI
- `budget/page.tsx`: Pass proper callbacks to dialog
- `expense-edit-dialog.tsx`: Ensure data refresh after edit
