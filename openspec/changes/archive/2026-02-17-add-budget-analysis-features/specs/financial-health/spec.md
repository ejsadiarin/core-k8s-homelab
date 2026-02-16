## ADDED Requirements

### Requirement: User can classify categories by type
The system SHALL allow users to classify categories as 'need', 'want', or 'savings' for 50/30/20 rule tracking.

#### Scenario: Classify category as need
- **WHEN** user classifies "Rent" category as 'need'
- **THEN** system stores classification and includes in 50/30/20 calculation

#### Scenario: Classify category as want
- **WHEN** user classifies "Entertainment" category as 'want'
- **THEN** system stores classification and includes in 50/30/20 calculation

#### Scenario: Classify category as savings
- **WHEN** user classifies "Investment" category as 'savings'
- **THEN** system stores classification and includes in 50/30/20 calculation

### Requirement: System tracks 50/30/20 rule compliance
The system SHALL calculate and display spending distribution across needs, wants, and savings.

#### Scenario: Monthly 50/30/20 breakdown
- **GIVEN** user has classified all categories
- **WHEN** user views financial health dashboard
- **THEN** system shows percentage split (e.g., 55% needs, 25% wants, 20% savings)

#### Scenario: Ideal vs actual comparison
- **GIVEN** user spending is 60% needs, 35% wants, 5% savings
- **WHEN** user views 50/30/20 chart
- **THEN** system shows deviation from ideal with recommendations

### Requirement: System analyzes weekday vs weekend spending
The system SHALL compare spending patterns between weekdays and weekends.

#### Scenario: Weekday spending average
- **WHEN** user views spending patterns
- **THEN** system shows average spend per weekday (Monday-Friday)

#### Scenario: Weekend spending average
- **WHEN** user views spending patterns
- **THEN** system shows average spend per weekend day (Saturday-Sunday)

#### Scenario: Day-of-week breakdown
- **WHEN** user views detailed patterns
- **THEN** system shows bar chart with average spend for each day of week

### Requirement: System calculates financial health score
The system SHALL calculate a composite financial health score based on multiple metrics.

#### Scenario: Calculate health score
- **GIVEN** user has savings rate >20%, budget compliance >80%, spending trending down
- **WHEN** user views health score
- **THEN** system displays score (0-100) with color coding

#### Scenario: Health score components
- **WHEN** user views detailed health breakdown
- **THEN** system shows individual scores for: savings rate, budget compliance, spending trend, emergency fund

### Requirement: System provides spending trend analysis
The system SHALL identify month-over-month spending trends by category.

#### Scenario: Category trend comparison
- **GIVEN** "Food" spending was $400 last month and $500 this month
- **WHEN** user views trends
- **THEN** system shows +25% increase with trend arrow

#### Scenario: Overall spending trend
- **GIVEN** total spending has decreased for 3 consecutive months
- **WHEN** user views dashboard
- **THEN** system shows positive downward trend indicator
