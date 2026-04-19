## ADDED Requirements

### Requirement: Generate occurrences on rule creation
The system SHALL generate all occurrence rows when a recurring income or expense rule is created.

#### Scenario: Create weekly income rule
- **WHEN** user creates a weekly recurring income with start_date = 2026-01-08 and end_date = 2026-04-09
- **THEN** the system generates occurrence rows for every matching weekday from start_date to end_date
- **THEN** each occurrence has the rule's amount, currency, and description

#### Scenario: Create monthly expense rule with no end date
- **WHEN** user creates a monthly recurring expense with start_date = 2026-02-23 and end_date = NULL
- **THEN** the system generates occurrence rows from start_date up to start_date + 1 year (generation horizon)
- **THEN** each occurrence uses the rule's day-of-month, clamped to end-of-month for shorter months

#### Scenario: Create daily income rule
- **WHEN** user creates a daily recurring income with start_date and end_date
- **THEN** the system generates one occurrence row per day from start_date to end_date

### Requirement: Generation horizon for open-ended rules
The system SHALL cap occurrence generation at 1 year from start_date for rules with no end_date.

#### Scenario: Open-ended weekly rule
- **WHEN** a weekly recurring rule has end_date = NULL
- **THEN** the system generates occurrences from start_date to start_date + 365 days

#### Scenario: Rule with end_date within horizon
- **WHEN** a recurring rule has end_date before start_date + 1 year
- **THEN** the system generates occurrences only up to end_date

### Requirement: Regenerate occurrences on rule update
The system SHALL regenerate future occurrences when a recurring rule's date range or frequency changes.

#### Scenario: Extend rule end date
- **WHEN** user updates a recurring rule to extend end_date from 2026-04-09 to 2026-06-30
- **THEN** the system generates new occurrence rows for the extended period (2026-04-10 to 2026-06-30)
- **THEN** existing occurrence rows before 2026-04-10 remain unchanged (preserving any skip state)

#### Scenario: Shorten rule end date
- **WHEN** user updates a recurring rule to shorten end_date from 2026-04-09 to 2026-03-15
- **THEN** the system deletes occurrence rows after 2026-03-15
- **THEN** occurrence rows on or before 2026-03-15 remain unchanged

#### Scenario: Rule amount changes
- **WHEN** user updates a recurring rule's amount
- **THEN** the system updates the amount on all future occurrence rows (occurrence_date > today)
- **THEN** past occurrence rows retain their original amount

### Requirement: Backfill existing rules
The migration SHALL generate occurrence rows for all existing recurring income and expense rules.

#### Scenario: Backfill weekly income rules
- **WHEN** the migration runs
- **THEN** for each existing weekly recurring income rule, the system generates occurrence rows aligned to the rule's start_date weekday, from start_date to min(end_date, current_date + 1 year)

#### Scenario: Backfill monthly expense rules
- **WHEN** the migration runs
- **THEN** for each existing monthly recurring expense rule, the system generates occurrence rows on the rule's day-of-month from start_date to min(end_date, current_date + 1 year)

### Requirement: Migrate existing skip records
The migration SHALL convert existing "Skipped:" negative-amount records into properly skipped occurrence rows.

#### Scenario: Migrate skipped income records
- **WHEN** the migration encounters a negative-amount income record with description starting with "Skipped:"
- **THEN** the system finds the corresponding occurrence row (matching date and source rule by description)
- **THEN** the system sets is_skipped = true on that occurrence row
- **THEN** the system deletes the negative-amount record from budget_incomes

#### Scenario: No matching occurrence for skip record
- **WHEN** a "Skipped:" record cannot be matched to an occurrence row
- **THEN** the migration logs a warning but does not fail
- **THEN** the unmatched record is preserved in budget_incomes

### Requirement: Date alignment for occurrence generation
The system SHALL align occurrence dates to the rule's original start date pattern.

#### Scenario: Weekly alignment to weekday
- **WHEN** a weekly rule has start_date on a Wednesday (2026-01-07)
- **THEN** all generated occurrences fall on Wednesdays

#### Scenario: Monthly alignment to day-of-month
- **WHEN** a monthly rule has start_date on the 23rd
- **THEN** occurrences are generated on the 23rd of each month
- **THEN** for months with fewer days (e.g., February), the occurrence date is clamped to the last day of the month

#### Scenario: Yearly alignment
- **WHEN** a yearly rule has start_date on March 15
- **THEN** occurrences are generated on March 15 of each year
