## Purpose

Display a recurring cash flow summary card on the Budget dashboard showing monthly equivalents of recurring income and expenses.

## ADDED Requirements

### Requirement: Display Recurring Summary Card
The Budget dashboard SHALL display a card showing total recurring income and expenses as monthly equivalents, along with net recurring cash flow.

#### Scenario: Card displays with data
- **WHEN** user navigates to the Budget dashboard and has recurring transactions
- **THEN** the card displays: Total Recurring Income (monthly), Total Recurring Expenses (monthly), Net Recurring Cash Flow

#### Scenario: Card displays with zero amounts
- **WHEN** user has no recurring transactions
- **THEN** the card displays ₱0 for all amounts with appropriate "No recurring transactions" message

#### Scenario: Card shows negative net cash flow
- **WHEN** recurring expenses exceed recurring income
- **THEN** net cash flow displays in red with negative sign

#### Scenario: Frequency conversion
- **WHEN** recurring income has frequency "weekly"
- **THEN** monthly equivalent calculated as amount × 4.33
- **AND** recurring expense with frequency "yearly" calculated as amount / 12
- **AND** recurring expense with frequency "daily" calculated as amount × 30
