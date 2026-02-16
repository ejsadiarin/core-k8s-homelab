## ADDED Requirements

### Requirement: Priority group reference table
The system SHALL maintain a `budget_priority_groups` table with system-defined priority groups seeded via migration.

#### Scenario: Default priority groups exist
- **WHEN** system is initialized
- **THEN** three priority groups exist: "Need" (slug: need), "Want" (slug: want), "Savings" (slug: savings)

### Requirement: Priority group schema
Each priority group SHALL have: id (UUID), name (VARCHAR 50), slug (VARCHAR 20, unique), display_order (INT), created_at (TIMESTAMP).

#### Scenario: Priority group record structure
- **WHEN** querying a priority group
- **THEN** record contains id, name, slug, display_order, and created_at fields

### Requirement: List priority groups endpoint
The system SHALL provide `GET /api/budget/priority-groups` to list all priority groups ordered by display_order.

#### Scenario: List priority groups
- **WHEN** authenticated user requests GET /api/budget/priority-groups
- **THEN** system returns all priority groups ordered by display_order ascending

#### Scenario: Guest lists priority groups
- **WHEN** unauthenticated user requests GET /api/budget/priority-groups
- **THEN** system returns all priority groups (read-only, no user scoping needed)

### Requirement: No user CRUD for priority groups
Priority groups SHALL be system-defined only. No create/update/delete endpoints for users.

#### Scenario: Attempt to create priority group
- **WHEN** user attempts to create a new priority group via API
- **THEN** system returns 404 (endpoint does not exist)
