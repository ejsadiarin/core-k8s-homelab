## MODIFIED Requirements

### Requirement: Data refreshes on page navigation
The system SHALL invalidate cached data when navigating to a page to ensure fresh data is displayed.

#### Scenario: Navigate to budget overview after delete
- **WHEN** user deletes an expense and navigates back to budget overview
- **THEN** system invalidates expense cache and fetches fresh data immediately

#### Scenario: Navigate to expense list after create
- **WHEN** user creates an expense and navigates to expense list page
- **THEN** system shows updated list without visible delay

#### Scenario: Page mount triggers refetch
- **WHEN** user navigates to any budget-related page
- **THEN** system checks if data is stale and triggers refetch if needed

### Requirement: Optimistic updates reduce perceived latency
The system SHALL use optimistic updates for CRUD operations to provide instant feedback.

#### Scenario: Delete expense optimistic update
- **WHEN** user deletes an expense
- **THEN** system immediately removes it from UI before server response completes

#### Scenario: Create expense optimistic update
- **WHEN** user creates an expense
- **THEN** system immediately adds it to local cache before server response completes

#### Scenario: Update expense optimistic update
- **WHEN** user updates an expense
- **THEN** system immediately updates local cache before server response completes

### Requirement: React Query cache invalidation strategy
The system SHALL properly invalidate React Query cache keys after mutations to ensure consistency.

#### Scenario: Expense mutation invalidates queries
- **WHEN** expense CRUD operation succeeds
- **THEN** system invalidates all expense-related queries (list, stats, summary)

#### Scenario: Category mutation invalidates queries
- **WHEN** category CRUD operation succeeds
- **THEN** system invalidates category queries and expense queries that depend on categories

#### Scenario: Tag mutation invalidates queries
- **WHEN** tag CRUD operation succeeds
- **THEN** system invalidates tag queries and expense queries that depend on tags
