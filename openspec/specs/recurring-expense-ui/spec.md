## ADDED Requirements

### Requirement: Expense form recurring type selection
Users SHALL select whether an expense is one-time or recurring when creating or editing expenses.

#### Scenario: Create one-time expense
- **WHEN** user opens expense creation form
- **THEN** form shows "Type" dropdown with "One-time" selected by default
- **THEN** only basic fields are shown (description, amount, currency, category, date, tags, notes)

#### Scenario: Select recurring type
- **WHEN** user selects "Daily", "Weekly", "Monthly", or "Yearly" from Type dropdown
- **THEN** form reveals additional fields for start date and end date configuration
- **THEN** the expense date field label changes to "Start Date"

#### Scenario: Recurring expense without end date
- **WHEN** user selects a recurring type
- **THEN** form shows "No end date (ongoing)" checkbox
- **WHEN** user checks the checkbox
- **THEN** end date field is hidden
- **THEN** expense is marked as ongoing/indefinite

#### Scenario: Recurring expense with end date
- **WHEN** user selects a recurring type and leaves checkbox unchecked
- **THEN** end date field is visible
- **THEN** end date must be equal to or after start date
- **THEN** validation error shows if end date is before start date

### Requirement: Expense card recurring display
Expense cards SHALL clearly indicate when an expense is recurring and show the recurrence period.

#### Scenario: Display one-time expense
- **WHEN** expense is one-time (no recurring_type)
- **THEN** card shows no recurring badge
- **THEN** only expense date is displayed

#### Scenario: Display recurring expense
- **WHEN** expense has recurring_type set
- **THEN** card shows recurring badge with type (Daily, Weekly, Monthly, Yearly)
- **THEN** badge includes Repeat icon
- **THEN** badge uses appropriate variant styling

#### Scenario: Display recurring date range
- **WHEN** recurring expense has start_date
- **THEN** card shows date range: "Start Date - End Date" or "Start Date - Ongoing"
- **THEN** date range includes Calendar icon
- **THEN** dates are formatted as "MMM dd, yyyy"

### Requirement: Edit recurring expense
Users SHALL be able to view and modify recurring settings when editing an expense.

#### Scenario: Edit dialog shows recurring data
- **WHEN** user opens edit dialog for recurring expense
- **THEN** form is pre-populated with recurring_type, start_date, and end_date
- **THEN** "No end date" checkbox reflects whether end_date is set

#### Scenario: Change from one-time to recurring
- **WHEN** user edits one-time expense
- **THEN** user can select a recurring type
- **THEN** form expands to show recurring configuration
- **THEN** start date defaults to the original expense date

#### Scenario: Change from recurring to one-time
- **WHEN** user edits recurring expense
- **THEN** user can select "One-time" type
- **THEN** recurring fields are hidden
- **THEN** start_date and end_date are cleared

### Requirement: TypeScript type updates
TypeScript types SHALL include recurring fields to match backend API.

#### Scenario: Expense interface includes recurring fields
- **WHEN** frontend fetches expense data
- **THEN** Expense type includes recurring_type?: "daily" | "weekly" | "monthly" | "yearly" | null
- **THEN** Expense type includes start_date?: string
- **THEN** Expense type includes end_date?: string

#### Scenario: CreateExpenseRequest includes recurring fields
- **WHEN** creating expense
- **THEN** CreateExpenseRequest accepts recurring_type, start_date, end_date

#### Scenario: UpdateExpenseRequest includes recurring fields
- **WHEN** updating expense
- **THEN** UpdateExpenseRequest accepts recurring_type, start_date, end_date

#### Scenario: ExpenseFilters includes recurring_type filter
- **WHEN** filtering expenses
- **THEN** ExpenseFilters accepts optional recurring_type for filtering
