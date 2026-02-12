## Why

The backend API now supports recurring expenses with daily, weekly, monthly, and yearly intervals, but the frontend UI lacks the ability to create, view, and edit recurring expenses. Users need a consistent interface to manage recurring expenses similar to how recurring incomes are handled.

## What Changes

- Update TypeScript types in `api.ts` to include recurring fields (`recurring_type`, `start_date`, `end_date`) for Expense and request types
- Update `expense-form.tsx` to add recurring type selector with options: one-time, daily, weekly, monthly, yearly
- Add start date and optional end date fields when recurring type is selected
- Update `expense-card.tsx` to display recurring badge and date range for recurring expenses
- Update `expense-edit-dialog.tsx` to pass recurring fields when editing expenses
- Update `expense-detail-dialog.tsx` to display recurring expense information

## Capabilities

### New Capabilities
- `recurring-expense-ui`: Frontend UI components to create, display, and edit recurring expenses with type selection and date range configuration

### Modified Capabilities

## Impact

- Frontend: TypeScript types, form components, card display components, and dialog components in `web/apps/core/src/`
- Dependencies: Uses existing shadcn/ui components (Select, Badge, Calendar icons)
- Pattern follows existing income recurring implementation for consistency
