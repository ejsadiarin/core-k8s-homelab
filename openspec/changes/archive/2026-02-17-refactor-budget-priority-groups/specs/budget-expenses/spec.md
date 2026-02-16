## MODIFIED Requirements

### Requirement: Expense ownership
Each expense SHALL be associated with a user via user_id foreign key and MAY be associated with a priority group via priority_group_id foreign key.

#### Scenario: Create expense
- **WHEN** authenticated user creates expense
- **THEN** system sets user_id to current user's ID

#### Scenario: Create expense with priority group
- **WHEN** authenticated user creates expense with priority_group_id
- **THEN** system validates priority_group_id exists in budget_priority_groups
- **THEN** system stores priority_group_id on the expense

#### Scenario: Create expense without priority group
- **WHEN** authenticated user creates expense without priority_group_id
- **THEN** system creates expense with null priority_group_id

#### Scenario: Update expense priority group
- **WHEN** authenticated user updates expense with new priority_group_id
- **THEN** system validates priority_group_id exists in budget_priority_groups
- **THEN** system updates priority_group_id on the expense

#### Scenario: Clear expense priority group
- **WHEN** authenticated user updates expense with null priority_group_id
- **THEN** system sets priority_group_id to null on the expense

## ADDED Requirements

### Requirement: Expense priority group in responses
Expense API responses SHALL include priority group information when assigned.

#### Scenario: List expenses with priority groups
- **WHEN** user requests expenses
- **THEN** each expense in the response includes priority_group object (id, name, slug) or null

#### Scenario: Get single expense with priority group
- **WHEN** user requests expense by ID
- **THEN** response includes priority_group object or null
