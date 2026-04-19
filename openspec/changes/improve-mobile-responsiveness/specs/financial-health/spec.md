## MODIFIED Requirements

### Requirement: Date range selection auto-fetches data
The Health page date range selector SHALL automatically fetch updated data when a date is selected, without requiring an "Apply" button. The system SHALL use URL search parameters to sync the selected date range, and React Query's query key changes SHALL trigger automatic refetching.

#### Scenario: User selects start date
- **WHEN** user selects a start date from the date picker
- **THEN** the URL SHALL update with the `start_date` query parameter
- **AND** all Health page components SHALL automatically fetch and display data for the new date range

#### Scenario: User selects end date
- **WHEN** user selects an end date from the date picker
- **THEN** the URL SHALL update with the `end_date` query parameter
- **AND** all Health page components SHALL automatically fetch and display data for the new date range

#### Scenario: URL-based date sync
- **WHEN** the URL contains `start_date` and `end_date` query parameters
- **THEN** the date picker inputs SHALL display those dates
- **AND** the data SHALL be fetched for that date range

## ADDED Requirements

### Requirement: Health page components render responsively on mobile
All Health page components (50/30/20 breakdown, spending patterns, health score, trend analysis) SHALL adapt their layout for mobile viewports while maintaining readability and functionality.

#### Scenario: Mobile 50/30/20 breakdown
- **WHEN** user views the Health page on mobile viewport (< 768px)
- **THEN** the 50/30/20 breakdown chart SHALL display in a vertically stacked layout
- **AND** percentage labels SHALL remain readable

#### Scenario: Mobile health score card
- **WHEN** user views the Health page on mobile viewport
- **THEN** the health score card SHALL display prominently at the top
- **AND** the score visualization SHALL scale appropriately for smaller screens
