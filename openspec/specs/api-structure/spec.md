## ADDED Requirements

### Requirement: Standard Go project layout

The api-gateway SHALL follow the Go community standard project layout with `cmd/` for application entry points and `internal/` for private packages.

#### Scenario: Entry point location
- **WHEN** building the application
- **THEN** the main package SHALL be located at `cmd/server/main.go`

#### Scenario: Internal package protection
- **WHEN** external packages attempt to import from `internal/`
- **THEN** Go compiler SHALL reject the import

### Requirement: Vertical slice architecture

The api-gateway SHALL organize code by domain/feature rather than technical layer, with each domain containing its handlers, models, and related logic.

#### Scenario: Domain package structure
- **WHEN** looking for budget-related code
- **THEN** all budget handlers, models, and helpers SHALL be in `internal/domain/budget/`

#### Scenario: Domain isolation
- **WHEN** modifying auth functionality
- **THEN** changes SHALL be contained within `internal/domain/auth/` without affecting other domains

#### Scenario: Feature co-location
- **WHEN** adding tests for a domain
- **THEN** tests SHALL be placed alongside the code in the same domain package (e.g., `internal/domain/budget/handler_test.go`)

### Requirement: Minimal bootstrap main.go

The `cmd/server/main.go` SHALL contain only application bootstrap logic (config loading, app initialization, server start) with no business logic.

#### Scenario: Bootstrap file size
- **WHEN** reviewing `cmd/server/main.go`
- **THEN** the file SHALL be under 60 lines of code

#### Scenario: No business logic in main
- **WHEN** reviewing `cmd/server/main.go`
- **THEN** the file SHALL NOT contain HTTP handlers, route definitions, or domain-specific logic

### Requirement: Centralized route registration

All HTTP routes SHALL be registered in a single location (`internal/app/routes.go`) to provide a complete API overview.

#### Scenario: Route discovery
- **WHEN** looking for all API endpoints
- **THEN** all routes SHALL be visible in `internal/app/routes.go`

#### Scenario: Route-handler mapping
- **WHEN** reviewing `internal/app/routes.go`
- **THEN** each route SHALL clearly map to its handler in the corresponding domain package

### Requirement: Application dependency injection

The api-gateway SHALL use an `Application` struct in `internal/app/app.go` to wire all dependencies together.

#### Scenario: Dependency wiring
- **WHEN** initializing the application
- **THEN** all dependencies (database, logger, handlers) SHALL be created through the `Application` struct

#### Scenario: Testability
- **WHEN** testing a domain handler
- **THEN** dependencies SHALL be injectable through constructor parameters

### Requirement: Platform separation

Infrastructure concerns (config, database, logging) SHALL be separated from domain logic in `internal/platform/`.

#### Scenario: Config loading
- **WHEN** loading application configuration
- **THEN** config logic SHALL be in `internal/platform/config/`

#### Scenario: Database setup
- **WHEN** establishing database connections
- **THEN** connection pool setup SHALL be in `internal/platform/database/`

### Requirement: Shared utilities location

Cross-cutting utilities (middleware, validator, common models) SHALL be placed in `internal/shared/`.

#### Scenario: Request logging middleware
- **WHEN** adding request logging
- **THEN** logging middleware SHALL be in `internal/shared/middleware/`

#### Scenario: Common models
- **WHEN** using ErrorResponse or PaginationParams
- **THEN** these types SHALL be in `internal/shared/models/`

### Requirement: sqlc generated code location

Generated sqlc code SHALL be placed in `internal/repository/sqlc/` with centralized query definitions.

#### Scenario: sqlc output path
- **WHEN** running `sqlc generate`
- **THEN** generated code SHALL be output to `internal/repository/sqlc/`

#### Scenario: Query file location
- **WHEN** adding new SQL queries
- **THEN** queries SHALL be added to `sql/queries/` directory
