## 1. Update Expense Edit Dialog

- [x] 1.1 Update `expense-edit-dialog.tsx` to close dialog immediately on submit (remove await, fire mutation without blocking)

## 2. Update Expense Form Dialog

- [x] 2.1 Update `expense-form-dialog.tsx` to close dialog immediately on submit

## 3. Update Page Handlers

- [x] 3.1 Update `expenses/page.tsx` handleUpdate to close dialog immediately and show toast on completion
- [x] 3.2 Update `expenses/page.tsx` handleCreateExpense to close dialog immediately and show toast on completion

## 4. Cleanup

- [x] 4.1 Remove isLoading prop usage from form submit buttons (no longer needed)
