## MODIFIED Requirements

### Requirement: Dialog handles long text content
The expense detail dialog SHALL properly handle long text content without overflow.

#### Scenario: Long expense description
- **WHEN** expense has a description longer than 50 characters
- **THEN** system displays full text with proper word wrapping within dialog bounds

#### Scenario: Long expense title
- **WHEN** expense has a title longer than 30 characters
- **THEN** system wraps text or truncates with ellipsis while remaining readable

#### Scenario: Long notes field
- **WHEN** expense has notes longer than 100 characters
- **THEN** system displays notes in a scrollable container or with word wrapping

### Requirement: Dialog size is appropriate
The expense detail dialog SHALL be large enough to display content comfortably on various screen sizes.

#### Scenario: Desktop display
- **WHEN** user opens expense detail dialog on desktop (>768px width)
- **THEN** dialog displays at minimum 550px width with proper spacing

#### Scenario: Mobile display
- **WHEN** user opens expense detail dialog on mobile (<768px width)
- **THEN** dialog adapts to screen width with proper padding

### Requirement: Tag display with overflow handling
The expense detail dialog SHALL display tags with proper overflow handling for many tags.

#### Scenario: Few tags displayed
- **WHEN** expense has 3 or fewer tags
- **THEN** system displays all tags inline with wrapping enabled

#### Scenario: Many tags with overflow
- **WHEN** expense has more than 3 tags
- **THEN** system displays first 3 tags and shows "+N more" badge

#### Scenario: Expand hidden tags
- **WHEN** user clicks on "+N more" badge
- **THEN** system displays all tags with proper wrapping

### Requirement: Category badge is responsive
The expense category badge SHALL remain readable and properly sized on all screen sizes.

#### Scenario: Long category name
- **WHEN** category has a name longer than 20 characters
- **THEN** badge wraps text or truncates with ellipsis while maintaining icon visibility
