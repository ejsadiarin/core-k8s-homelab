## MODIFIED Requirements

### Requirement: Rename savings expense category to investments

The system SHALL use "investments" terminology for the third 50/30/20 category instead of "savings".

#### Scenario: Display label change

- **WHEN** 50/30/20 chart is rendered
- **THEN** third category displays as "Investments" not "Savings"

#### Scenario: API response terminology

- **WHEN** 50/30/20 endpoint is called
- **THEN** response uses `investments` key instead of `savings`

#### Scenario: Database slug unchanged

- **WHEN** querying priority groups
- **THEN** database slug remains "savings" (backward compatibility)

### Requirement: Clear distinction between savings rate and investment expenses

The system SHALL clearly distinguish between actual savings rate and expense categorization.

#### Scenario: Different metrics

- **WHEN** user views financial health dashboard
- **THEN** savings rate metric shows percentage of income saved
- **AND** 50/30/20 investments shows percentage spent on investment expenses

#### Scenario: Avoid user confusion

- **WHEN** both metrics are displayed
- **THEN** clear labels differentiate "Savings Rate" from "Investment Spending"
