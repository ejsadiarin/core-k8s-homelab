## MODIFIED Requirements

### Requirement: Display Recurring Summary Card
The Budget dashboard SHALL display a card showing total recurring income and expenses as monthly equivalents, along with net recurring cash flow. Monthly equivalents continue to be derived from recurring rules (not occurrence rows).

#### Scenario: Card displays with data
- **WHEN** user navigates to the Budget dashboard and has recurring transactions
- **THEN** the card displays: Total Recurring Income (monthly), Total Recurring Expenses (monthly), Net Recurring Cash Flow
- **THEN** monthly equivalents are calculated from active recurring rules using frequency conversion (weekly × 4.33, yearly / 12, daily × 30)
- **THEN** the card does NOT use occurrence rows for this calculation (rules represent projected cash flow)

#### Scenario: Frequency conversion unchanged
- **WHEN** recurring income has frequency "weekly"
- **THEN** monthly equivalent calculated as amount × 4.33 (from the rule, not from occurrence count)
