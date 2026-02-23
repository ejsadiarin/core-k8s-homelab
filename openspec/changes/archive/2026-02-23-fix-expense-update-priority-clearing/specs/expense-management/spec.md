## MODIFIED Requirements

### Requirement: Expense update preserves unprovided fields
The system SHALL preserve existing field values when they are not explicitly included in the expense update request. Only fields that are explicitly provided SHALL be updated.

#### Scenario: Update description without affecting priority_group_id
- **WHEN** user updates an expense with description only (no priority_group_id in request)
- **THEN** the expense description is updated
- **AND** the existing priority_group_id value is preserved

#### Scenario: Update amount without affecting end_date
- **WHEN** user updates an expense with amount only (no end_date in request)
- **THEN** the expense amount is updated
- **AND** the existing end_date value is preserved

#### Scenario: Explicitly clear optional field with null
- **WHEN** user updates an expense with priority_group_id explicitly set to null
- **THEN** the expense priority_group_id is cleared to null

#### Scenario: Explicitly set new end_date
- **WHEN** user updates an expense with a new end_date value
- **THEN** the expense end_date is updated to the new value
