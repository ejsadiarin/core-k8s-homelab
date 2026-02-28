## Context

The Subscriptions page currently only displays recurring expenses fetched from `GET /api/budget/subscriptions` and shows them in a read-only list. Recurring incomes are displayed separately on the Budget dashboard via `RecurringIncomeList`. Full CRUD exists for both expenses and incomes across the stack -- update/delete endpoints, edit dialogs with recurring field support, and mutation hooks are all in place. The skip-occurrence pattern is already implemented for incomes (creates a negative income record). The TopMerchantsTable on the current page is an independent component that can remain as-is.

## Goals / Non-Goals

**Goals:**
- Unify recurring expense and income management into a single page
- Add edit, skip, and cancel actions for all recurring items
- Reuse existing backend endpoints and frontend forms wherever possible
- Keep the TopMerchantsTable on the page (it's useful context alongside recurring items)

**Non-Goals:**
- No database schema changes
- No new recurring frequency types (e.g., bi-weekly, quarterly)
- No recurring item creation from this page (users create recurring items from the Expenses/Incomes pages)
- No changes to the Budget dashboard's RecurringIncomeList or RecurringSummaryCard components
- No changes to the forecast/upcoming bills functionality

## Decisions

### 1. Reuse existing edit dialogs instead of building new ones
**Decision**: Use `ExpenseEditDialog` and `IncomeEditDialog` directly on the recurring page.
**Rationale**: These dialogs already handle all fields including recurring_type, start_date, and end_date. Building new edit UI would duplicate effort and create maintenance burden.
**Alternative considered**: Build a simplified inline edit form -- rejected because the existing dialogs are complete and well-tested.

### 2. Mirror the income skip pattern for expenses (negative records)
**Decision**: Skip a recurring expense by creating a negative expense record, same pattern as income skips.
**Rationale**: Consistent approach across both types. No new database columns or tables needed. The existing `createExpense` endpoint can accept negative amounts.
**Alternative considered**: Add a `skipped_dates` column or separate skip tracking table -- rejected as over-engineering for this use case.

### 3. Cancel by setting end_date via existing update endpoints
**Decision**: Use the existing `PUT /api/budget/expenses/:id` and `PUT /api/budget/incomes/:id` endpoints to set `end_date` to today.
**Rationale**: No new backend endpoints needed. The cancel action is semantically just an update to end_date.
**Alternative considered**: Add a dedicated `POST /api/budget/expenses/:id/cancel` endpoint -- rejected as unnecessary; the update endpoint handles this.

### 4. Backend: add check-skipped-expense endpoint
**Decision**: Add a `GET /api/budget/expenses/check-skipped?date=YYYY-MM-DD` endpoint mirroring the existing `GET /api/budget/incomes/check-skipped?date=YYYY-MM-DD`.
**Rationale**: Needed for the skip dialog to check for duplicate skips. Same pattern as income side.

### 5. Backend: filter out expired recurring items from subscriptions endpoint
**Decision**: Modify the `GetUpcomingRecurringExpenses` SQL query to exclude items where `end_date < CURRENT_DATE`.
**Rationale**: Currently the query doesn't filter by end_date, so cancelled items would still appear. This is the minimal change to support the cancel feature.

### 6. Page layout: sectioned with Tabs component
**Decision**: Use shadcn/ui Tabs to separate "Expenses" and "Incomes" sections, with the summary card always visible above the tabs.
**Rationale**: Clean separation without overwhelming the user. Both sections are meaningful and users will likely want to focus on one type at a time.
**Alternative considered**: Single interleaved list with type indicators -- rejected because expenses and incomes have different shapes (expenses have categories, incomes don't) and different action sets.

### 7. Keep TopMerchantsTable on the page
**Decision**: Retain the TopMerchantsTable below the tabbed recurring items section.
**Rationale**: It provides useful spending context and removing it would reduce page utility. It's independent and doesn't interfere with the recurring tracker.

## Risks / Trade-offs

- **[Risk]** Negative expense amounts may confuse budget calculations that assume expenses are positive → **Mitigation**: The skip record is clearly labeled "Skipped: ..." and budget calculations should already handle this since the pattern exists for incomes.
- **[Risk]** Users may not understand that "Cancel" means setting an end date rather than deleting → **Mitigation**: The confirmation dialog will clearly explain that the recurring series will end, and the item can be re-activated by editing the end_date.
- **[Risk]** The subscriptions endpoint may need adjustment to properly filter expired items → **Mitigation**: Add end_date filter to the SQL query; test with items that have various end_date states.
