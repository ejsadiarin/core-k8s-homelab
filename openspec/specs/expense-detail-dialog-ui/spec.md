## MODIFIED Requirements

### Requirement: Category badge positioned beside price
The category badge SHALL be displayed beside the price, not above it.

#### Scenario: Desktop layout
- **WHEN** expense detail dialog opens on desktop
- **THEN** description and category appear on one line
- **AND** price appears on the right side
- **AND** there is proper gap spacing between elements

### Requirement: Long text shows ellipsis truncation
Long text SHALL display with "..." ellipsis when truncated.

#### Scenario: Long description
- **WHEN** expense description exceeds 50 characters
- **THEN** text is truncated with "..."
- **AND** full text is visible on hover (tooltip)

#### Scenario: Long category name
- **WHEN** category name exceeds available space
- **THEN** name is truncated with "..."
- **AND** icon remains visible

### Requirement: Clean overflow handling
Dialog overflow SHALL be handled gracefully without visual glitches.

#### Scenario: Long content
- **WHEN** expense has many tags or long notes
- **THEN** dialog scrolls vertically within max-height
- **AND** scrollbar is styled consistently
- **AND** no horizontal overflow occurs

### Requirement: Dialog sizing
Dialog SHALL have appropriate sizing for content.

#### Scenario: Dialog dimensions
- **WHEN** dialog opens
- **THEN** width is responsive (max 600px on sm+ screens)
- **AND** height is constrained (max 90vh with internal scroll)
