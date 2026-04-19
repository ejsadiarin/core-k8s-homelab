## ADDED Requirements

### Requirement: Mobile bottom navigation displays all key pages
The mobile bottom navigation bar SHALL display icons and labels for all primary navigation destinations: Dashboard, Budget, Health, Expenses, Incomes, Recurring, and Services. Each navigation item SHALL have a corresponding lucide-react icon.

#### Scenario: Mobile user views bottom navigation
- **WHEN** a user views the dashboard on a mobile viewport (< 768px)
- **THEN** the bottom navigation bar SHALL display icons for Dashboard, Budget, Health, Expenses, Incomes, Recurring, and Services
- **AND** each icon SHALL have an accessible label

#### Scenario: Mobile navigation active state
- **WHEN** the user is on the Health page
- **THEN** the Health icon in the bottom navigation SHALL be visually highlighted
- **WHEN** the user is on the Recurring page
- **THEN** the Recurring icon in the bottom navigation SHALL be visually highlighted
