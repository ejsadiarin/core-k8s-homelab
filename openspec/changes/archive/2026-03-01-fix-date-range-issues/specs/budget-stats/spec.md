## MODIFIED Requirements

### Requirement: Budget remaining defaults to current date
The budget remaining calculation SHALL accept optional `start_date` and `end_date` parameters. If `end_date` is provided without `start_date`, the system MUST NOT fail and SHALL calculate from the beginning of the user's tracking period (or epoch) to the `end_date`.

#### Scenario: Summary stats without date
- **WHEN** user requests GET /api/budget/stats/summary without date filter
- **THEN** system calculates budget remaining from start to current date

#### Scenario: Summary stats with full date filter
- **WHEN** user requests GET /api/budget/stats/summary?start_date=2026-01-01&end_date=2026-02-07
- **THEN** system calculates budget remaining strictly between those dates

#### Scenario: Summary stats with only end_date filter
- **WHEN** user requests GET /api/budget/stats/summary?end_date=2026-02-07
- **THEN** system calculates budget remaining from the beginning of time/tracking to the specified end date without error
