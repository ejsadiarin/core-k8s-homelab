## 1. TypeScript Types

- [x] 1.1 Update `Expense` interface to include `recurring_type?: "daily" | "weekly" | "monthly" | "yearly" | null`
- [x] 1.2 Update `Expense` interface to include `start_date?: string`
- [x] 1.3 Update `Expense` interface to include `end_date?: string`
- [x] 1.4 Update `CreateExpenseRequest` to include recurring fields
- [x] 1.5 Update `UpdateExpenseRequest` to include recurring fields
- [x] 1.6 Update `ExpenseFilters` to include `recurring_type?: string` for filtering

## 2. Expense Form Component

- [x] 2.1 Add recurring type state management to `expense-form.tsx`
- [x] 2.2 Add "Type" Select dropdown with options: one-time, daily, weekly, monthly, yearly
- [x] 2.3 Add conditional rendering for recurring date fields (only show when recurring type selected)
- [x] 2.4 Add "No end date (ongoing)" checkbox for recurring expenses
- [x] 2.5 Add end date input field with validation (min=start_date)
- [x] 2.6 Update form state to include recurring_type, start_date, end_date
- [x] 2.7 Update date field label to "Start Date" when recurring type is selected
- [x] 2.8 Sync expense_date with start_date when recurring type changes

## 3. Expense Card Component

- [x] 3.1 Add `getRecurringLabel` helper function to format recurring type display
- [x] 3.2 Add recurring badge with Repeat icon when `recurring_type` is set
- [x] 3.3 Add date range display with Calendar icon for recurring expenses
- [x] 3.4 Format dates using date-fns ("MMM dd, yyyy")
- [x] 3.5 Show "Ongoing" text when no end date is set
- [x] 3.6 Style recurring badge appropriately (variant based on recurring status)

## 4. Expense Edit Dialog

- [x] 4.1 Update `expense-edit-dialog.tsx` to pass recurring fields to ExpenseForm
- [x] 4.2 Map `recurring_type`, `start_date`, `end_date` from expense to initialData
- [x] 4.3 Ensure dialog handles both one-time and recurring expense editing

## 5. Expense Detail Dialog

- [x] 5.1 Update `expense-detail-dialog.tsx` to display recurring information
- [x] 5.2 Add recurring badge in detail view
- [x] 5.3 Add start date and end date display for recurring expenses

## 6. Testing & Validation

- [x] 6.1 Test creating one-time expense (no recurring fields visible)
- [x] 6.2 Test creating daily recurring expense
- [x] 6.3 Test creating weekly recurring expense with end date
- [x] 6.4 Test creating monthly recurring expense without end date
- [x] 6.5 Test creating yearly recurring expense
- [x] 6.6 Test editing expense to add recurring fields
- [x] 6.7 Test editing expense to remove recurring fields
- [x] 6.8 Test date validation (end date cannot be before start date)
- [x] 6.9 Test expense card displays recurring badge correctly
- [x] 6.10 Test expense card displays date range correctly
