## ADDED Requirements

### Requirement: Unified recurring items display
The page SHALL display both recurring expenses and recurring incomes in a single unified view. Items SHALL be organized into two sections: "Recurring Expenses" and "Recurring Incomes", each showing the item description, amount, currency, frequency badge, category (expenses only), and next due date.

#### Scenario: Page loads with both recurring expenses and incomes
- **WHEN** user navigates to the Recurring page
- **THEN** the page SHALL display a section for recurring expenses and a section for recurring incomes, each listing all active recurring items

#### Scenario: No recurring items exist
- **WHEN** user navigates to the Recurring page and has no recurring expenses or incomes
- **THEN** each section SHALL display an appropriate empty state message

#### Scenario: Only recurring expenses exist
- **WHEN** user has recurring expenses but no recurring incomes
- **THEN** the expenses section SHALL display items and the incomes section SHALL show an empty state

### Requirement: Combined recurring summary card
The page SHALL display a summary card showing total monthly recurring expenses, total monthly recurring income, net recurring cash flow, and counts of active recurring items for each type.

#### Scenario: Summary card displays combined totals
- **WHEN** the page loads with recurring expenses and incomes
- **THEN** the summary card SHALL show monthly expense total, monthly income total, net cash flow (income minus expenses), count of recurring expenses, and count of recurring incomes

#### Scenario: Summary card with only expenses
- **WHEN** user has recurring expenses but no recurring incomes
- **THEN** the summary card SHALL show expense totals and zero for income, with net being negative

### Requirement: Edit action on recurring items
Each recurring item SHALL have an edit action that opens the corresponding edit dialog (expense edit dialog for expenses, income edit dialog for incomes) pre-populated with the item's current data.

#### Scenario: User edits a recurring expense
- **WHEN** user clicks the edit action on a recurring expense
- **THEN** the expense edit dialog SHALL open with the expense's current data pre-populated, including recurring fields (type, start date, end date)

#### Scenario: User edits a recurring income
- **WHEN** user clicks the edit action on a recurring income
- **THEN** the income edit dialog SHALL open with the income's current data pre-populated, including recurring fields

#### Scenario: Successful edit updates the list
- **WHEN** user saves changes in the edit dialog
- **THEN** the recurring items list SHALL refresh to reflect the updated data

### Requirement: Skip occurrence action on recurring items
Each recurring item SHALL have a skip action that opens a skip dialog allowing the user to skip a single occurrence.

#### Scenario: User skips a recurring expense occurrence
- **WHEN** user clicks the skip action on a recurring expense
- **THEN** a skip dialog SHALL open showing the expense details and allowing the user to confirm the skip

#### Scenario: User skips a recurring income occurrence
- **WHEN** user clicks the skip action on a recurring income
- **THEN** the existing skip occurrence dialog SHALL open for that income

### Requirement: Cancel action on recurring items
Each recurring item SHALL have a cancel action that allows the user to end the recurring series by setting its end_date to today.

#### Scenario: User cancels a recurring expense
- **WHEN** user clicks the cancel action on a recurring expense and confirms
- **THEN** the system SHALL set the expense's end_date to today's date and the item SHALL no longer appear in the active recurring list

#### Scenario: User cancels a recurring income
- **WHEN** user clicks the cancel action on a recurring income and confirms
- **THEN** the system SHALL set the income's end_date to today's date and the item SHALL no longer appear in the active recurring list

#### Scenario: Cancel confirmation dialog
- **WHEN** user clicks the cancel action on any recurring item
- **THEN** a confirmation dialog SHALL appear showing the item details and warning that the recurring series will end

### Requirement: Updated sidebar navigation
The sidebar navigation item SHALL be relabeled from "Subscriptions" to "Recurring" and SHALL use an appropriate icon (e.g., RefreshCw/Repeat).

#### Scenario: Sidebar shows updated label
- **WHEN** user views the sidebar navigation
- **THEN** the nav item for the recurring page SHALL display "Recurring" instead of "Subscriptions"

### Requirement: Page header reflects new purpose
The page header SHALL be updated from "SUBSCRIPTIONS & MERCHANTS" to "RECURRING TRACKER" with an updated description reflecting that it tracks both recurring expenses and incomes.

#### Scenario: Page displays updated header
- **WHEN** user navigates to the Recurring page
- **THEN** the header SHALL show "RECURRING TRACKER" with description "Manage recurring expenses and incomes"
