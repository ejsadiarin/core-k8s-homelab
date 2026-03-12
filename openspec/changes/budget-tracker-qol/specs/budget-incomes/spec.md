## MODIFIED Requirements

### Requirement: Income list displays both stored and virtual recurring entries
The income list page (`/dashboard/budget/incomes`) SHALL display virtual recurring income occurrences alongside stored one-time income records when a date filter is active. Virtual entries SHALL be visually distinguished with a "Recurring" badge and SHALL NOT have edit/delete actions (since they are computed, not stored). Clicking a virtual entry SHALL navigate to or show the source recurring income rule for editing.

When no date filter is active, the income list SHALL continue to show only stored DB records (current behavior preserved).

#### Scenario: Income list with date filter shows recurring occurrences
- **WHEN** user sets a date range filter on the income list page
- **THEN** the list shows both one-time income records and expanded recurring income occurrences within that date range, sorted by date descending

#### Scenario: Income list without date filter shows only DB records
- **WHEN** user views the income list with no date filters
- **THEN** only stored income records are shown (current behavior)

#### Scenario: Virtual entry interaction
- **WHEN** user clicks on a virtual recurring income entry
- **THEN** the edit dialog opens for the source recurring income rule (not the virtual entry)
