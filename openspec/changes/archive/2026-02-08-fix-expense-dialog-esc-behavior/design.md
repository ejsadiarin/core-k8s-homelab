## Context

The ExpenseFormDialog component uses a custom implementation that handles browser history state when the dialog opens. This was initially designed to support deep linking (updating URL when dialog opens), but it's causing an unintended side effect: when the user presses Escape to close the dialog, it triggers the browser's back navigation because the dialog pushed a state to history when it opened.

The current implementation in `expense-form-dialog.tsx` uses `window.history.pushState()` when the dialog opens and listens for `popstate` events to handle the back button. However, the Escape key handling is also triggering this history navigation in some cases.

**Current behavior:**
- Dialog opens → pushes history state
- User presses Escape → triggers popstate → navigates to previous page
- Expected: Dialog should close, user stays on current page

**Affected pages:**
- `/dashboard/budget` - Budget dashboard
- `/dashboard/budget/expenses` - Expenses list

## Goals / Non-Goals

**Goals:**
- Fix Escape key behavior to close dialog without browser navigation
- Maintain existing keyboard accessibility (Escape still closes dialog)
- Preserve deep linking functionality if still needed
- Fix on both budget dashboard and expenses list pages

**Non-Goals:**
- Changing dialog styling or layout
- Adding new dialog features
- Modifying form validation behavior
- Changing how dialogs are triggered/opened

## Decisions

### Decision 1: Remove or fix history state management in ExpenseFormDialog

**Rationale:** The current implementation pushes a history state when the dialog opens and closes it on popstate. This was designed for deep linking but causes the Escape key bug. 

**Options considered:**
1. **Option A - Remove history state entirely:** Simplest fix, removes the root cause. Dialog will work like other dialogs in the app (IncomeFormDialog, etc.) which don't use this pattern.
2. **Option B - Add Escape key detection before popstate:** More complex, would require distinguishing between Escape key and actual back button navigation.

**Chosen: Option A** - The deep linking feature isn't critical for expense creation, and consistency with other dialogs is more important. The budget dashboard already has a separate route `/dashboard/budget/expenses/new` for deep linking if needed.

### Decision 2: Ensure consistent onOpenChange behavior

**Rationale:** The Dialog component's `onOpenChange` callback should properly handle both explicit closes (clicking X, clicking outside) and Escape key presses.

**Implementation approach:**
- Keep the `onOpenChange` prop as the single source of truth for dialog state
- Remove the custom `useEffect` that pushes history state
- Ensure the parent components pass proper `onOpenChange` handlers

## Risks / Trade-offs

**[Risk] Breaking deep linking to expense creation** → The `/dashboard/budget/expenses/new` route won't auto-open the dialog anymore. **Mitigation:** This route appears to redirect to the dashboard anyway based on current code. If deep linking is needed in the future, it can be implemented via query params (e.g., `?openExpense=true`) which is already supported in the budget dashboard.

**[Risk] Browser back button behavior changes** → Previously, clicking back while dialog was open would close it. After fix, dialog won't track history so back button will navigate away from the page. **Mitigation:** This is actually more consistent with standard web UX. Most users expect back button to go to previous page, not close a dialog.

**[Trade-off] Loss of "dialog state in URL"** → Users can't bookmark or share a link that opens directly to expense creation. **Mitigation:** This feature wasn't fully implemented anyway (no dedicated route exists for the dialog). Can be added later if needed.

## Migration Plan

1. **Modify `expense-form-dialog.tsx`:**
   - Remove the `useEffect` that pushes/pops history state
   - Keep the `onOpenChange` callback for parent-controlled state
   - Ensure Dialog's built-in Escape handling works correctly

2. **Verify parent components:**
   - Check `/dashboard/budget/page.tsx` - uses `showExpenseDialog` state
   - Check `/dashboard/budget/expenses/page.tsx` - uses `showExpenseDialog` state
   - Both already pass proper `onOpenChange` handlers

3. **Test scenarios:**
   - Open dialog → Press Escape → Should close, stay on page
   - Open dialog → Click outside → Should close, stay on page
   - Open dialog → Click X button → Should close, stay on page
   - Open dialog → Navigate to another page → Should work normally

## Open Questions

None - straightforward bug fix with clear implementation path.
