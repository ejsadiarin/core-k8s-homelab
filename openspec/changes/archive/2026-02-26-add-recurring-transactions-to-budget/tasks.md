## 1. Backend - API for Recurring Incomes with Next Dates

- [x] 1.1 Review existing `GetRecurringIncomeRules` endpoint in handler
- [x] 1.2 Add next_occurrence calculation to recurring income response
- [x] 1.3 Create new endpoint GET `/api/budget/recurring-incomes` returning list with next dates
- [x] 1.4 Add SQL query to check for existing skip on a date
- [x] 1.5 Create endpoint GET `/api/budget/incomes/check-skipped?date=YYYY-MM-DD`
- [x] 1.6 Test new endpoints

## 2. Frontend - Hooks for Recurring Data

- [x] 2.1 Add `fetchRecurringIncomes` function in api.ts
- [x] 2.2 Add `checkSkippedIncome` function in api.ts
- [x] 2.3 Add `useRecurringIncomes` hook in use-budget.ts
- [x] 2.4 Add query key for recurring incomes

## 3. Frontend - RecurringSummaryCard Component

- [x] 3.1 Create `recurring-summary-card.tsx` component
- [x] 3.2 Implement monthly equivalent calculations (weekly × 4.33, yearly / 12, daily × 30)
- [x] 3.3 Style to match existing card components (SavingsRateCard, SpendingVelocityCard)
- [x] 3.4 Add to Budget dashboard page

## 4. Frontend - Recurring Income List Integration

- [x] 4.1 Update Budget page to fetch recurring incomes
- [x] 4.2 Add recurring income display section (integrated with or below Recent Incomes)
- [x] 4.3 Display frequency badges and next expected dates
- [x] 4.4 Add skip button to each recurring income item

## 5. Frontend - SkipOccurrenceDialog Component

- [x] 5.1 Create `skip-occurrence-dialog.tsx` component
- [x] 5.2 Show income details (description, amount, frequency)
- [x] 5.3 Auto-calculate next occurrence date based on frequency
- [x] 5.4 Allow manual date selection
- [x] 5.5 Add optional reason field
- [x] 5.6 Create negative income on confirm
- [x] 5.7 Add duplicate skip check when date changes
- [x] 5.8 Show warning if date is already skipped

## 6. Frontend - Skipped Income Display

- [x] 6.1 Update Recent Incomes to show negative amounts as skipped
- [x] 6.2 Add strikethrough or "(Skipped)" label to negative incomes
- [x] 6.3 Allow undo by deleting negative income record

## 7. Testing and Integration

- [x] 7.1 Test recurring summary card with various frequencies
- [x] 7.2 Test skip occurrence flow (weekly, monthly)
- [x] 7.3 Test duplicate skip prevention
- [x] 7.4 Test undo skip functionality
- [x] 7.5 Verify dashboard layout with new components
- [x] 7.6 Run lint and typecheck
