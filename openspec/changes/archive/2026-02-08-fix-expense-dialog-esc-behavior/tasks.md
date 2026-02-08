## 1. Fix ExpenseFormDialog Component

- [x] 1.1 Open `web/apps/core/src/components/budget/expense-form-dialog.tsx`
- [x] 1.2 Remove the `useEffect` that pushes history state when dialog opens
- [x] 1.3 Remove the `popstate` event listener and its cleanup function
- [x] 1.4 Remove the `handlePopState` function
- [x] 1.5 Keep the `onOpenChange` prop and Dialog component intact
- [x] 1.6 Verify the component still accepts `open`, `onOpenChange`, `onSubmit`, and `isLoading` props
- [x] 1.7 Run TypeScript check to ensure no errors

## 2. Test Fix on Budget Dashboard

- [x] 2.1 Navigate to `/dashboard/budget`
- [x] 2.2 Click "Add Expense" button to open dialog
- [x] 2.3 Press Escape key - verify dialog closes without page navigation
- [x] 2.4 Reopen dialog and click outside - verify dialog closes without navigation
- [x] 2.5 Reopen dialog and click X button - verify dialog closes without navigation
- [x] 2.6 Verify form submission still works correctly

## 3. Test Fix on Expenses List Page

- [x] 2.1 Navigate to `/dashboard/budget/expenses`
- [x] 2.2 Click "Add Expense" button to open dialog
- [x] 2.3 Press Escape key - verify dialog closes and user stays on expenses page
- [x] 2.4 Reopen dialog and click outside - verify dialog closes, no navigation
- [x] 2.5 Reopen dialog and click X button - verify dialog closes, no navigation
- [x] 2.6 Verify form submission still works correctly

## 4. Verification & Cleanup

- [x] 4.1 Run `npx tsc --noEmit` to verify no TypeScript errors
- [x] 4.2 Check that dialog behavior matches IncomeFormDialog (for consistency)
- [x] 4.3 Verify no console errors when opening/closing dialog
- [x] 4.4 Test keyboard navigation (Tab, Enter, Escape) still works correctly
