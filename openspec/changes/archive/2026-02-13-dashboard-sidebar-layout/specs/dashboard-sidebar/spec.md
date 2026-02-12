## ADDED Requirements

### Requirement: Sidebar displays navigation items grouped by section
The sidebar SHALL display navigation items organized into logical sections: Overview (Dashboard), Finance (Budget, Expenses, Incomes, Budget Settings), System (Services), and Admin (Users). Each section SHALL have a section label header.

#### Scenario: User views sidebar sections
- **WHEN** a user views the dashboard sidebar
- **THEN** the sidebar SHALL display navigation items grouped under section headers: "Overview", "Finance", "System", and "Admin"
- **AND** each section header SHALL be rendered as an uppercase, muted-foreground label

#### Scenario: Admin section visibility
- **WHEN** a non-admin user views the sidebar
- **THEN** the "Admin" section SHALL NOT be displayed
- **AND** the "Users" navigation item SHALL NOT be visible

#### Scenario: Admin user views sidebar
- **WHEN** an admin user views the sidebar
- **THEN** the "Admin" section SHALL be displayed with the "Users" navigation item

### Requirement: Each navigation item has an icon and label
Each sidebar navigation item SHALL display a lucide-react icon alongside a text label. Items SHALL be: Dashboard (LayoutDashboard), Budget (Wallet), Expenses (Receipt), Incomes (TrendingUp), Budget Settings (SlidersHorizontal), Services (Server), Users (Users).

#### Scenario: Navigation item rendering
- **WHEN** the sidebar renders a navigation item
- **THEN** it SHALL display the item's icon on the left and the text label on the right
- **AND** the icon SHALL be sized consistently (w-5 h-5)

### Requirement: Active route highlighting
The sidebar SHALL visually highlight the navigation item that corresponds to the current route. The active item SHALL have a distinct background color (`primary/10`) and text color (`primary`).

#### Scenario: User navigates to Budget page
- **WHEN** the current pathname is `/dashboard/budget`
- **THEN** the "Budget" navigation item SHALL have active styling with primary text color and primary/10 background
- **AND** all other navigation items SHALL have default muted-foreground styling

#### Scenario: Nested route active state
- **WHEN** the current pathname is `/dashboard/budget/expenses`
- **THEN** the "Expenses" navigation item SHALL have active styling
- **AND** the "Budget" navigation item SHALL NOT have active styling (exact match only)

### Requirement: Sidebar collapse/expand toggle
The sidebar SHALL support collapsed (icon-only, ~60px wide) and expanded (~240px wide) states. A toggle button SHALL allow users to switch between states.

#### Scenario: User collapses sidebar
- **WHEN** the user clicks the collapse toggle button
- **THEN** the sidebar SHALL animate to collapsed state showing only icons
- **AND** the text labels and section headers SHALL be hidden
- **AND** the main content area SHALL expand to fill the available space

#### Scenario: User expands sidebar
- **WHEN** the user clicks the expand toggle button from collapsed state
- **THEN** the sidebar SHALL animate to expanded state showing icons and labels
- **AND** section headers SHALL become visible

#### Scenario: Collapsed sidebar tooltip
- **WHEN** the sidebar is in collapsed state and the user hovers over a navigation item
- **THEN** a tooltip SHALL appear showing the navigation item's label

### Requirement: Sidebar persists collapse state
The sidebar SHALL persist its collapsed/expanded state across page navigations within the same session.

#### Scenario: User navigates while sidebar is collapsed
- **WHEN** the sidebar is collapsed and the user navigates to another dashboard page
- **THEN** the sidebar SHALL remain in collapsed state

### Requirement: Sidebar footer with user info
The sidebar SHALL display a footer section containing the current user's email, role badge, and a logout action.

#### Scenario: User views sidebar footer
- **WHEN** a user views the sidebar footer
- **THEN** it SHALL display the user's email address (truncated if necessary)
- **AND** it SHALL display the user's role as a colored badge
- **AND** it SHALL provide a logout button or action

#### Scenario: Collapsed sidebar footer
- **WHEN** the sidebar is collapsed
- **THEN** the footer SHALL display only the user avatar/icon
- **AND** a dropdown or tooltip SHALL provide access to user info and logout on interaction

### Requirement: Mobile sidebar as drawer overlay
On mobile viewports (< 768px), the sidebar SHALL be hidden by default and accessible via a hamburger menu button. The sidebar SHALL appear as a slide-out drawer overlay.

#### Scenario: Mobile user opens sidebar
- **WHEN** a mobile user taps the hamburger menu button
- **THEN** the sidebar SHALL slide in from the left as an overlay
- **AND** a backdrop SHALL appear behind the sidebar

#### Scenario: Mobile user selects navigation item
- **WHEN** a mobile user taps a navigation item in the sidebar drawer
- **THEN** the application SHALL navigate to the selected route
- **AND** the sidebar drawer SHALL automatically close

#### Scenario: Mobile user closes sidebar
- **WHEN** a mobile user taps the backdrop or a close button
- **THEN** the sidebar drawer SHALL slide out and close
