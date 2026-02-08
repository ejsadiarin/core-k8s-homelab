## MODIFIED Requirements

### Requirement: React Query cache invalidation strategy
The system SHALL properly invalidate React Query cache keys after mutations to ensure consistency and immediate UI updates.

#### Scenario: Expense mutation invalidates queries
- **WHEN** expense CRUD operation succeeds
- **THEN** system invalidates all expense-related queries (list, stats, summary)
- **THEN** system invalidates budget remaining queries

#### Scenario: Category mutation invalidates queries
- **WHEN** category CRUD operation succeeds
- **THEN** system invalidates category queries and expense queries that depend on categories

#### Scenario: Tag mutation invalidates queries
- **WHEN** tag CRUD operation succeeds
- **THEN** system invalidates tag queries and expense queries that depend on tags

#### Scenario: Income mutation invalidates queries
- **WHEN** income CRUD operation succeeds
- **THEN** system invalidates all income-related queries
- **THEN** system invalidates budget remaining queries
- **THEN** system invalidates summary stats queries

## ADDED Requirements

### Requirement: Budget remaining immediate cache invalidation
The budget remaining query SHALL be invalidated immediately when income or expense data changes.

#### Scenario: Create income invalidates budget remaining
- **WHEN** user creates new income entry
- **THEN** system invalidates budgetRemaining query key
- **THEN** React Query refetches budget remaining data automatically

#### Scenario: Update income invalidates budget remaining
- **WHEN** user updates existing income entry
- **THEN** system invalidates budgetRemaining query key
- **THEN** UI shows updated budget remaining value immediately

#### Scenario: Delete income invalidates budget remaining
- **WHEN** user deletes income entry
- **THEN** system invalidates budgetRemaining query key
- **THEN** UI reflects deleted income in budget remaining calculation

#### Scenario: Create expense invalidates budget remaining
- **WHEN** user creates new expense
- **THEN** system invalidates budgetRemaining query key
- **THEN** budget remaining updates to reflect new expense

#### Scenario: Update expense invalidates budget remaining
- **WHEN** user updates existing expense
- **THEN** system invalidates budgetRemaining query key
- **THEN** budget remaining recalculates with updated expense amount

#### Scenario: Delete expense invalidates budget remaining
- **WHEN** user deletes expense
- **THEN** system invalidates budgetRemaining query key
- **THEN** budget remaining updates to exclude deleted expense

### Requirement: Reduced stale time for budget remaining
The budget remaining query SHALL use minimal stale time to ensure fresh data.

#### Scenario: Budget remaining stale time configuration
- **WHEN** useBudgetRemaining hook is initialized
- **THEN** staleTime is set to 0 or removed (use default)
- **THEN** data refetches on window focus and component mount

#### Scenario: Background refetch after mutation
- **WHEN** income or expense mutation completes
- **WHEN** budget remaining query is invalidated
- **THEN** React Query fetches fresh data in background
- **THEN** UI updates when fresh data arrives (typically \u003c100ms)

#### Scenario: No loading spinner during refetch
- **WHEN** budget remaining is being refetched after mutation
- **THEN** UI continues showing previous cached value
- **THEN** UI updates seamlessly when new data arrives
- **THEN** no loading spinner is shown (background refetch)
