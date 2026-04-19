## ADDED Requirements

### Requirement: Spending by Day chart supports horizontal scroll
The "Spending by Day" chart (weekday-spending-chart) SHALL display data bars with fixed minimum widths inside a horizontally scrollable container. This ensures chart readability regardless of the date range size.

#### Scenario: Chart with many data points
- **WHEN** the date range contains 30+ days of data
- **THEN** each bar SHALL have a minimum width of 32px
- **AND** the chart container SHALL be horizontally scrollable
- **AND** vertical overflow SHALL be hidden to prevent label collision

#### Scenario: Chart with few data points
- **WHEN** the date range contains 7 or fewer days of data
- **THEN** bars SHALL expand to fill available width
- **AND** no horizontal scroll SHALL be needed

### Requirement: Price labels remain readable at all date ranges
Price labels displayed above each bar in the "Spending by Day" chart SHALL remain readable without collision or overflow, using abbreviated formats when necessary.

#### Scenario: Large amount display
- **WHEN** a bar has a total amount >= 10,000
- **THEN** the price label SHALL display an abbreviated format (e.g., "₱12.5k" instead of "₱12,500")

#### Scenario: Label positioning
- **WHEN** the chart renders price labels
- **THEN** labels SHALL not overlap with adjacent labels
- **AND** labels SHALL not overflow vertically beyond their container
