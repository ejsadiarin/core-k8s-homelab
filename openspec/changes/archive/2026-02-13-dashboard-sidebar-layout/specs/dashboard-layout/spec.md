## ADDED Requirements

### Requirement: Dashboard uses sidebar-based layout
All routes under `/dashboard/**` SHALL use a sidebar-based layout consisting of a left sidebar and a main content area to the right. The layout SHALL replace the current header-only `MainLayout` for dashboard routes.

#### Scenario: User visits any dashboard page
- **WHEN** a user navigates to any `/dashboard/**` route
- **THEN** the page SHALL render with a sidebar on the left and main content on the right
- **AND** the `NavigationHeader` horizontal navigation bar SHALL NOT be displayed

### Requirement: Compact top header bar in content area
The main content area SHALL include a compact top header bar displaying the current page title, a breadcrumb trail, and right-aligned quick actions (notifications bell, user avatar as secondary access).

#### Scenario: User views content header
- **WHEN** a user views any dashboard page
- **THEN** a compact header bar SHALL appear at the top of the content area
- **AND** it SHALL display the current page title derived from the active route
- **AND** it SHALL show a breadcrumb trail (e.g., "Dashboard > Budget > Expenses")

#### Scenario: Mobile content header includes menu trigger
- **WHEN** a mobile user views the content header
- **THEN** a hamburger menu button SHALL appear on the left side of the header
- **AND** tapping it SHALL open the sidebar drawer

### Requirement: Content area fills remaining space
The main content area SHALL fill all horizontal space not occupied by the sidebar. When the sidebar collapses, the content area SHALL expand accordingly with a smooth transition.

#### Scenario: Sidebar collapse expands content
- **WHEN** the sidebar transitions from expanded to collapsed state
- **THEN** the main content area SHALL smoothly expand to fill the freed horizontal space
- **AND** page content SHALL reflow naturally without layout jumps

### Requirement: Non-dashboard routes keep existing layout
Routes outside `/dashboard/**` (login, register, landing page) SHALL continue to use their existing layouts unchanged. The sidebar layout SHALL only apply within the dashboard.

#### Scenario: User visits login page
- **WHEN** a user navigates to `/login`
- **THEN** the page SHALL render with its existing layout (no sidebar)

### Requirement: Animated page transitions
Page content within the dashboard layout SHALL animate on route changes using a subtle fade-in transition, maintaining the existing framer-motion animation pattern.

#### Scenario: User navigates between dashboard pages
- **WHEN** a user clicks a sidebar navigation item to change pages
- **THEN** the new page content SHALL fade in smoothly
- **AND** the sidebar SHALL remain stationary during the transition
