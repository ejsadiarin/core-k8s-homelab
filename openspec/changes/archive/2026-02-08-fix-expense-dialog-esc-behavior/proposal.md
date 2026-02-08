## Why

The ExpenseFormDialog component has a UX bug where pressing the Escape key navigates the user to a different page instead of simply closing the dialog. This happens on both the budget dashboard and expenses list pages. This creates a confusing user experience and interrupts the workflow when users expect the dialog to close and remain on the current page.

## What Changes

- Fix ExpenseFormDialog to prevent browser navigation when Escape key is pressed
- Ensure dialog closes properly without triggering unwanted page navigation
- Maintain proper dialog state management on both budget dashboard and expenses pages
- Preserve existing keyboard accessibility (Escape should still close the dialog)

## Capabilities

### New Capabilities
<!-- No new capabilities - this is a bug fix -->

### Modified Capabilities
- `expense-creation-dialog`: Fix Esc key behavior to close dialog without triggering browser navigation

## Impact

**Affected Files:**
- `web/apps/core/src/components/budget/expense-form-dialog.tsx` - Root cause fix in dialog component
- `web/apps/core/src/app/dashboard/budget/page.tsx` - Dialog usage verification
- `web/apps/core/src/app/dashboard/budget/expenses/page.tsx` - Dialog usage verification

**No Breaking Changes:** This is a UX bug fix that only corrects unintended behavior.

**Dependencies:** None - pure frontend fix within existing component structure.
