## ADDED Requirements

### Requirement: Weighted multi-factor health score

The system SHALL calculate health score using weighted factors: savings rate (40%), debt-to-income (35%), emergency fund (25%).

#### Scenario: All factors excellent

- **WHEN** savings rate is 25%, debt-to-income is 20%, emergency fund is 6 months
- **THEN** health score is 100 (40 + 35 + 25)

#### Scenario: Mixed factor performance

- **WHEN** savings rate is 15%, debt-to-income is 40%, emergency fund is 2 months
- **THEN** health score reflects weighted combination of factor scores

### Requirement: Savings rate factor scoring

The system SHALL score savings rate factor (max 40 points) based on thresholds.

#### Scenario: Excellent savings rate

- **WHEN** savings rate is 20% or higher
- **THEN** savings rate factor contributes 40 points

#### Scenario: Good savings rate

- **WHEN** savings rate is between 15% and 20%
- **THEN** savings rate factor contributes 30 points

#### Scenario: Fair savings rate

- **WHEN** savings rate is between 10% and 15%
- **THEN** savings rate factor contributes 20 points

#### Scenario: Poor savings rate

- **WHEN** savings rate is below 10%
- **THEN** savings rate factor contributes 10 points

### Requirement: Debt-to-income factor scoring

The system SHALL score debt-to-income factor (max 35 points) based on ratio thresholds.

#### Scenario: Excellent debt ratio

- **WHEN** debt-to-income ratio is 20% or lower
- **THEN** debt factor contributes 35 points

#### Scenario: Good debt ratio

- **WHEN** debt-to-income ratio is between 20% and 35%
- **THEN** debt factor contributes 25 points

#### Scenario: Fair debt ratio

- **WHEN** debt-to-income ratio is between 35% and 50%
- **THEN** debt factor contributes 15 points

#### Scenario: Poor debt ratio

- **WHEN** debt-to-income ratio is above 50%
- **THEN** debt factor contributes 5 points

### Requirement: Emergency fund factor scoring

The system SHALL score emergency fund factor (max 25 points) based on months coverage.

#### Scenario: Excellent emergency fund

- **WHEN** emergency fund is 6 months or more
- **THEN** emergency fund factor contributes 25 points

#### Scenario: Good emergency fund

- **WHEN** emergency fund is between 3 and 6 months
- **THEN** emergency fund factor contributes 20 points

#### Scenario: Fair emergency fund

- **WHEN** emergency fund is between 1 and 3 months
- **THEN** emergency fund factor contributes 10 points

#### Scenario: Poor emergency fund

- **WHEN** emergency fund is less than 1 month
- **THEN** emergency fund factor contributes 5 points

### Requirement: Return factor breakdown

The system SHALL return individual factor scores in health score response.

#### Scenario: Full breakdown in response

- **WHEN** health score is calculated
- **THEN** response includes `factor_scores` object with savings_rate, debt_to_income, and emergency_fund scores
