## ADDED Requirements

### Requirement: Skip Recurring Income Occurrence
The system SHALL allow users to skip a single occurrence of a recurring income, creating a negative income record for that specific date.

#### Scenario: User skips weekly recurring income
- **WHEN** user clicks "Skip" on a weekly recurring income (e.g., 500 PHP every Wednesday)
- **THEN** dialog appears showing: Income description, Amount, Date to skip (auto-calculated next Wednesday)
- **AND** user confirms skip
- **THEN** negative income record created with amount -500 PHP on that date

#### Scenario: User skips with custom date
- **WHEN** user clicks "Skip" and selects a different date
- **THEN** negative income created for the selected date instead of auto-calculated date

#### Scenario: Skip creates visible record
- **WHEN** user skips a recurring income
- **THEN** negative income appears in Recent Incomes list with strikethrough or "(Skipped)" label

#### Scenario: Duplicate skip prevented
- **WHEN** user attempts to skip the same date for the same recurring income twice
- **THEN** system shows error "This occurrence has already been skipped"

#### Scenario: Undo skip
- **WHEN** user views a skipped (negative) income
- **THEN** user can delete the negative income to undo the skip
- **AND** recurring income schedule continues unaffected

#### Scenario: Skip does not affect future occurrences
- **WHEN** user skips one occurrence of a recurring income
- **THEN** subsequent occurrences continue as scheduled (skip does not change the recurring rule)

#### Scenario: Skip with reason (optional)
- **WHEN** user skips an occurrence
- **THEN** optional "reason" field available (e.g., "vacation", "sick leave")
- **AND** reason stored in notes field of negative income record
