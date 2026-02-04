## ADDED Requirements

### Requirement: Expense cards are clickable
Expense cards in the Recent Expenses section SHALL be clickable and open the expense detail dialog.

#### Scenario: Click on expense card
- **WHEN** user clicks on an expense card in the Recent Expenses section
- **THEN** system opens the expense detail dialog showing full expense information

#### Scenario: Visual feedback on hover
- **WHEN** user hovers over an expense card
- **THEN** system displays visual feedback indicating the card is interactive (cursor change, border highlight)

### Requirement: Edit and delete buttons remain functional
The edit and delete buttons on expense cards SHALL continue to work independently of the card click action.

#### Scenario: Click edit button
- **WHEN** user clicks the edit button on an expense card
- **THEN** system stops event propagation and opens edit dialog without triggering card click

#### Scenario: Click delete button
- **WHEN** user clicks the delete button on an expense card
- **THEN** system stops event propagation and shows delete confirmation without triggering card click
