## MODIFIED Requirements

### Requirement: Guest mode toast notification
The system SHALL display a toast notification when guest users attempt write operations.

#### Scenario: Toast notification appears for guest
- **WHEN** a guest user performs an action that would modify data
- **THEN** a toast notification SHALL appear
- **AND** the toast SHALL display the message "Guest user is read-only. Create an account to save changes"
- **AND** the toast SHALL auto-dismiss after 3 seconds

### Requirement: Guest mode visual indicator in sidebar
The system SHALL display a guest mode indicator in the sidebar layout instead of the previous header badge. The sidebar footer SHALL show a "Guest Mode" badge alongside the user info when the user is a guest.

#### Scenario: Guest user sees guest indicator in sidebar
- **WHEN** a guest user views the dashboard sidebar footer
- **THEN** a "Guest Mode" badge SHALL be displayed with accent styling (bg-accent/10 text-accent border-accent/30)
- **AND** the badge SHALL be visible in both expanded and collapsed sidebar states

#### Scenario: Guest user sees guest indicator in compact header
- **WHEN** a guest user views the compact top header bar
- **THEN** a "Guest Mode" badge SHALL be displayed near the right-side actions
