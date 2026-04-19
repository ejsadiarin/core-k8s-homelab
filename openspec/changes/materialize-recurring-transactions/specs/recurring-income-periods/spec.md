## MODIFIED Requirements

### Requirement: Weekly recurring income
Users SHALL create weekly recurring income entries. Income amounts for date ranges are calculated by querying materialized occurrence rows.

#### Scenario: Calculate weekly income for date range
- **WHEN** system calculates income for date range X to Y
- **WHEN** weekly recurring income exists with start_date S where S ≤ Y
- **WHEN** end_date is NULL or E ≥ X
- **THEN** system queries SUM(amount) FROM budget_income_occurrences WHERE source_income_id = rule.id AND occurrence_date BETWEEN X AND Y AND is_skipped = false

#### Scenario: Weekly income with end date
- **WHEN** weekly recurring income has start_date = Feb 1 and end_date = Feb 28
- **WHEN** user requests budget for March 15
- **THEN** no occurrence rows exist after Feb 28, so no income is included

#### Scenario: Weekly income without end date (indefinite)
- **WHEN** weekly recurring income has start_date = Feb 1 and end_date = NULL
- **THEN** occurrence rows exist from start_date up to start_date + 1 year (generation horizon)
- **THEN** system includes only occurrences within the queried date range

### Requirement: Monthly recurring income
Users SHALL create monthly recurring income entries. Income amounts for date ranges are calculated by querying materialized occurrence rows.

#### Scenario: Calculate monthly income for date range
- **WHEN** system calculates income for date range X to Y
- **WHEN** monthly recurring income exists with start_date S where S ≤ Y
- **WHEN** end_date is NULL or E ≥ X
- **THEN** system queries SUM(amount) FROM budget_income_occurrences WHERE source_income_id = rule.id AND occurrence_date BETWEEN X AND Y AND is_skipped = false

#### Scenario: Monthly income calculation inclusive
- **WHEN** monthly recurring income has start_date = Jan 15
- **WHEN** user requests budget for Jan 15 to Mar 31
- **THEN** system returns sum of 3 occurrence rows (Jan 15, Feb 15, Mar 15)
