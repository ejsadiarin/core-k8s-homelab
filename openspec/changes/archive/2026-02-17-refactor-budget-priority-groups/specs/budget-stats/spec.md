## MODIFIED Requirements

### Requirement: Stats scoped to user
Budget statistics SHALL be calculated for the authenticated user's data only. The 50/30/20 analysis SHALL use expense-level priority group classification instead of category-level type.

#### Scenario: User requests summary
- **WHEN** user requests /api/budget/stats/summary
- **THEN** system calculates stats from user's expenses only

#### Scenario: User requests category breakdown
- **WHEN** user requests /api/budget/stats/category-breakdown
- **THEN** system calculates breakdown from user's expenses and categories

#### Scenario: User requests trends
- **WHEN** user requests /api/budget/stats/trends
- **THEN** system calculates trends from user's expenses only

#### Scenario: 50/30/20 analysis uses expense priority
- **WHEN** user requests GET /api/budget/analysis/503020
- **THEN** system aggregates spending by budget_expenses.priority_group_id
- **THEN** system maps priority group slugs (need/want/savings) to 50/30/20 targets
- **THEN** system ignores expenses without priority_group_id in percentage calculations
- **THEN** system returns count of unclassified expenses for user awareness

#### Scenario: Health score uses expense priority
- **WHEN** user requests GET /api/budget/stats/health-score
- **THEN** system uses expense-level priority groups for need/want/savings scoring
- **THEN** system calculates based on classified expenses only

## ADDED Requirements

### Requirement: Unclassified expense awareness
The 50/30/20 response SHALL include a count of unclassified expenses to encourage users to classify their spending.

#### Scenario: Some expenses unclassified
- **WHEN** user has expenses without priority_group_id
- **THEN** 50/30/20 response includes unclassified_count field with the count
- **THEN** 50/30/20 response includes unclassified_amount field with the total

#### Scenario: All expenses classified
- **WHEN** all user expenses have priority_group_id assigned
- **THEN** 50/30/20 response shows unclassified_count as 0 and unclassified_amount as 0
