## ADDED Requirements

### Requirement: API endpoint expands recurring income rules into individual occurrences
The system SHALL provide a `GET /api/budget/incomes/occurrences` endpoint that accepts `start_date` and `end_date` query parameters and returns individual occurrence entries for all recurring income rules that overlap the requested period.

Each occurrence entry SHALL include:
- `id`: a deterministic virtual ID derived from the source income ID and occurrence date (e.g., `{income_id}:{date}`)
- `source_income_id`: the ID of the recurring income rule
- `amount`: the per-occurrence amount from the rule
- `currency`: the currency from the rule
- `date`: the specific occurrence date
- `description`: the description from the rule
- `recurring_type`: the frequency from the rule
- `is_virtual`: boolean `true` indicating this is a computed entry
- `is_skipped`: boolean indicating whether a skip record exists for this date

#### Scenario: Weekly recurring income expanded for a 30-day period
- **WHEN** user has a weekly Wednesday recurring income of +500 PHP starting 2026-01-01, and requests occurrences from 2026-03-01 to 2026-03-31
- **THEN** the endpoint returns individual entries for each Wednesday in March (e.g., Mar 4, Mar 11, Mar 18, Mar 25) with `is_virtual: true`

#### Scenario: Daily recurring income with end date
- **WHEN** user has a daily recurring income of +100 PHP starting 2026-01-01 ending 2026-03-15, and requests occurrences from 2026-03-01 to 2026-03-31
- **THEN** the endpoint returns entries for Mar 1 through Mar 15 only

#### Scenario: No recurring incomes in period
- **WHEN** user has no recurring income rules overlapping the requested date range
- **THEN** the endpoint returns an empty array

#### Scenario: One-time incomes included in results
- **WHEN** user requests occurrences for a date range
- **THEN** the response also includes one-time income records whose `date` falls within the range, with `is_virtual: false`

### Requirement: Occurrence results are paginated
The system SHALL paginate occurrence results using the standard offset pagination pattern (page, limit parameters) to prevent unbounded response sizes.

#### Scenario: Large date range with daily recurring
- **WHEN** user requests a 365-day range for a daily recurring income
- **THEN** results are paginated with default limit, and pagination metadata is included in the response
