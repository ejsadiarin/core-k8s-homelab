## ADDED Requirements

### Requirement: Weekly recurring income
Users SHALL create weekly recurring income entries that calculate income based on number of weeks in a date range.

#### Scenario: Create weekly recurring income
- **WHEN** user creates income entry with recurring_type set to 'weekly'
- **THEN** system stores amount, start_date, end_date (optional), description, and user_id
- **THEN** system marks entry as recurring with type 'weekly'

#### Scenario: Calculate weekly income for date range
- **WHEN** system calculates income for date range X to Y
- **WHEN** weekly recurring income exists with start_date S where S ≤ Y
- **WHEN** end_date is NULL or E ≥ X
- **THEN** system includes amount × number of weeks from max(S, X) to min(E or Y, Y)

#### Scenario: Weekly income with end date
- **WHEN** weekly recurring income has start_date = Feb 1 and end_date = Feb 28
- **WHEN** user requests budget for March 15
- **THEN** system does not include this income (ended before requested date)

#### Scenario: Weekly income without end date (indefinite)
- **WHEN** weekly recurring income has start_date = Feb 1 and end_date = NULL
- **WHEN** user requests budget for any future date
- **THEN** system includes weekly amount for all weeks from start_date to requested date

### Requirement: Monthly recurring income
Users SHALL create monthly recurring income entries that calculate income based on number of months in a date range.

#### Scenario: Create monthly recurring income
- **WHEN** user creates income entry with recurring_type set to 'monthly'
- **THEN** system stores amount, start_date, end_date (optional), description, and user_id
- **THEN** system marks entry as recurring with type 'monthly'

#### Scenario: Calculate monthly income for date range
- **WHEN** system calculates income for date range X to Y
- **WHEN** monthly recurring income exists with start_date S where S ≤ Y
- **WHEN** end_date is NULL or E ≥ X
- **THEN** system includes amount × number of months from max(S, X) to min(E or Y, Y)

#### Scenario: Monthly income calculation inclusive
- **WHEN** monthly recurring income has start_date = Jan 15
- **WHEN** user requests budget for Mar 31
- **THEN** system includes 3 months × amount (January, February, March)

#### Scenario: Monthly income with end date before request date
- **WHEN** monthly recurring income has end_date = Feb 28
- **WHEN** user requests budget for March 15
- **THEN** system only includes months from start_date to Feb 28

### Requirement: End date support for recurring income
Users SHALL optionally specify an end date for recurring income to support time-bound contracts or temporary income sources.

#### Scenario: Create recurring income with end date
- **WHEN** user creates recurring income with end_date specified
- **THEN** system validates end_date ≥ start_date
- **THEN** system stores end_date value

#### Scenario: Create recurring income without end date
- **WHEN** user creates recurring income with end_date = NULL
- **THEN** system stores NULL indicating indefinite recurrence

#### Scenario: End date validation
- **WHEN** user creates recurring income with end_date \u003c start_date
- **THEN** system returns 400 Bad Request with error message

#### Scenario: Update end date on existing income
- **WHEN** user updates recurring income to add end_date
- **THEN** system accepts change and recalculates future budget values

#### Scenario: Remove end date from income
- **WHEN** user updates recurring income to set end_date = NULL
- **THEN** system accepts change and marks income as indefinite

### Requirement: UI indicates indefinite recurring income
The frontend SHALL clearly display when recurring income has no end date.

#### Scenario: Display indefinite income in list
- **WHEN** income list shows recurring income with end_date = NULL
- **THEN** UI displays "Ongoing" badge or indicator

#### Scenario: Display time-bound income in list
- **WHEN** income list shows recurring income with end_date set
- **THEN** UI displays start and end dates clearly

#### Scenario: Form shows indefinite option
- **WHEN** user creates or edits recurring income
- **THEN** form provides checkbox or toggle for "No end date" / "Ongoing"

### Requirement: Backward compatibility with daily recurring income
Existing daily recurring income entries SHALL continue to work without modification.

#### Scenario: Existing daily income without end_date
- **WHEN** system encounters daily recurring income created before this feature
- **THEN** system treats NULL end_date as indefinite recurrence
- **THEN** calculations continue to work as before

#### Scenario: Daily income can have end_date added
- **WHEN** user edits existing daily recurring income
- **THEN** form allows adding end_date value
- **THEN** system applies end_date constraint to future calculations
