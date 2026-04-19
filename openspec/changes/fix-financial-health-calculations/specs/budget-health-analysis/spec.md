## MODIFIED Requirements

### Requirement: Health score endpoint returns actual calculations

The system SHALL return calculated values for all health metrics instead of hardcoded zeros.

#### Scenario: Debt-to-income returned

- **WHEN** health score endpoint is called
- **THEN** response includes calculated `debt_to_income` value (not hardcoded 0.0)

#### Scenario: Emergency fund returned

- **WHEN** health score endpoint is called
- **THEN** response includes calculated `emergency_fund_months` value (not hardcoded 0.0)

#### Scenario: Factor scores in response

- **WHEN** health score endpoint is called
- **THEN** response includes breakdown of factor scores

### Requirement: Database errors are properly handled

The system SHALL return HTTP 500 error with descriptive message when database queries fail.

#### Scenario: Income query failure

- **WHEN** income query fails
- **THEN** system returns HTTP 500 with message "Failed to retrieve income data"

#### Scenario: Expense query failure

- **WHEN** expense query fails
- **THEN** system returns HTTP 500 with message "Failed to retrieve expense data"

#### Scenario: No silent failures

- **WHEN** any database operation fails
- **THEN** error is logged and returned to client (not silently ignored)

### Requirement: Recommendations based on factor analysis

The system SHALL provide targeted recommendations based on which factors are underperforming.

#### Scenario: High debt recommendation

- **WHEN** debt-to-income factor is poor (< 15 points)
- **THEN** recommendations include debt reduction advice

#### Scenario: Low emergency fund recommendation

- **WHEN** emergency fund factor is poor (< 10 points)
- **THEN** recommendations include emergency fund building advice

#### Scenario: Multiple poor factors

- **WHEN** multiple factors are underperforming
- **THEN** recommendations prioritize highest impact improvement
