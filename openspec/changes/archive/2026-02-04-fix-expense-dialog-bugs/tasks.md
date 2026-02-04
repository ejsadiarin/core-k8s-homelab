## 1. Fix Delete Workflow

- [x] 1.1 Add isGuest prop to ExpenseDetailDialog interface
- [x] 1.2 Add delete confirmation state (deleteDialogOpen)
- [x] 1.3 Import AlertDialog components
- [x] 1.4 Add AlertDialog for delete confirmation
- [x] 1.5 Fix handleDeleteClick to check isGuest state properly
- [x] 1.6 Remove incorrect showToast check that triggers guest warning

## 2. Fix Edit Workflow

- [x] 2.1 Add handleEdit function to budget/page.tsx - Edit handler passed via props
- [x] 2.2 Add handleDelete function to budget/page.tsx - Delete handler passed via props
- [x] 2.3 Pass onEdit and onDelete callbacks to ExpenseDetailDialog
- [x] 2.4 Update EditExpenseDialog onSubmit to properly call parent callback
- [x] 2.5 Ensure edit success triggers data refresh - Closes dialogs on success

## 3. Improve Dialog UI

- [x] 3.1 Redesign header layout: category beside price, not above
- [x] 3.2 Add proper flex layout with gap spacing
- [x] 3.3 Improve text truncation with title tooltips
- [x] 3.4 Clean up overflow styling (remove max-h if causing issues)
- [x] 3.5 Ensure responsive behavior on mobile

## 4. Testing

- [x] 4.1 Test delete as authenticated user
- [x] 4.2 Test delete as guest user
- [x] 4.3 Test edit workflow completes properly
- [x] 4.4 Verify data refreshes after edit/delete
- [x] 4.5 Test UI on desktop and mobile
