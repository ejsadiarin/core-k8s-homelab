## MODIFIED Requirements

### Requirement: Running total calculation
The budget remaining SHALL be calculated as a running total from the beginning of user's data to the specified date, including all recurring income types.

#### Scenario: Calculate running total
- **WHEN** user requests budget remaining for date D
- **THEN** system sums all one-time incomes with date ≤ D
- **THEN** system sums all recurring incomes (daily, weekly, monthly) prorated from start_date to min(end_date or D, D)
- **THEN** system sums all expenses with expense_date ≤ D
- **THEN** system returns running total = (one-time_income + recurring_income) - expenses

#### Scenario: Recurring income prorated correctly
- **WHEN** recurring income is ₱500/day starting Feb 1 with no end_date
- **WHEN** user requests budget remaining for Feb 5
- **THEN** system includes 5 days × ₱500 = ₱2,500 from recurring income

#### Scenario: Weekly recurring income in calculation
- **WHEN** weekly recurring income is ₱3000/week starting Feb 1
- **WHEN** user requests budget remaining for Feb 21
- **THEN** system includes 3 weeks × ₱3000 = ₱9,000 from recurring income

#### Scenario: Monthly recurring income in calculation
- **WHEN** monthly recurring income is ₱15000/month starting Jan 1
- **WHEN** user requests budget remaining for Mar 15
- **THEN** system includes 3 months × ₱15000 = ₱45,000 from recurring income

#### Scenario: Recurring income with end_date in calculation
- **WHEN** recurring income has end_date = Feb 28
- **WHEN** user requests budget remaining for Mar 15
- **THEN** system only includes income from start_date to Feb 28, not beyond

## ADDED Requirements

### Requirement: Budget remaining UI displays readable colors
The budget remaining card SHALL use accessible color combinations for all status states.

#### Scenario: Over budget color scheme
- **WHEN** budget_remaining_status = 'red'
- **THEN** UI displays light red background (bg-red-50)
- **THEN** UI displays dark red text (text-red-900)
- **THEN** UI displays red border (border-red-200)

#### Scenario: On track color scheme
- **WHEN** budget_remaining_status = 'green'
- **THEN** UI displays light green background (bg-green-50)
- **THEN** UI displays dark green text (text-green-900)
- **THEN** UI displays green border (border-green-200)

#### Scenario: Neutral color scheme
- **WHEN** budget_remaining_status = 'neutral'
- **THEN** UI displays gray text (text-gray-600)
- **THEN** UI uses default background and border

#### Scenario: Color contrast meets WCAG AA
- **WHEN** budget remaining card displays any status
- **THEN** text-to-background contrast ratio is at least 4.5:1
