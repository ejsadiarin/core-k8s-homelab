## MODIFIED Requirements

### Requirement: System analyzes spending patterns
The system SHALL provide financial health metrics that can be filtered by an explicit custom date range (`start_date` and `end_date`), replacing the hardcoded week/month periods. The default period SHALL be from the user's tracking start date (e.g. Jan 15, 2026) to today.

#### Scenario: Health page with default dates
- **WHEN** user navigates to the Health page without query parameters
- **THEN** system defaults the date range from Jan 15, 2026 to today

#### Scenario: Health page with custom dates
- **WHEN** user selects a custom date range in the UI
- **THEN** the URL updates with `start_date` and `end_date` parameters
- **THEN** all health components recalculate based on this specific range
