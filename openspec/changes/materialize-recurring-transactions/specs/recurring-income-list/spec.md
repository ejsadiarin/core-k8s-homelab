## MODIFIED Requirements

### Requirement: Display Recurring Income List
The Budget dashboard SHALL display a list of active recurring incomes showing description, amount, frequency, and next expected date derived from materialized occurrence rows.

#### Scenario: Next date calculation
- **WHEN** recurring income is displayed
- **THEN** next date is derived from the first non-skipped occurrence row in budget_income_occurrences WHERE occurrence_date >= today AND is_skipped = false, ordered by occurrence_date ASC, LIMIT 1

#### Scenario: Skip button present
- **WHEN** recurring income is displayed
- **THEN** each item has a "Skip" button that toggles is_skipped on the next occurrence row (instead of creating a negative record)
