## Why

The api-gateway codebase uses horizontal layering (handlers/, models/, auth/) which makes it difficult to understand, modify, and test individual features. A 354-line `main.go` contains all route setup, middleware configuration, and startup logic. Refactoring to vertical slice architecture (domain-driven) will improve code organization, enable easier testing per feature, and follow Go community best practices (`cmd/`, `internal/`, feature-based packages).

## What Changes

- Reorganize directory structure to follow Go standard layout (`cmd/`, `internal/`)
- Split monolithic `main.go` into minimal bootstrap (`cmd/server/main.go`) and application wiring (`internal/app/`)
- Group code by domain/feature rather than technical layer:
  - `internal/domain/auth/` - authentication, sessions, password hashing
  - `internal/domain/budget/` - categories, tags, expenses, incomes, stats
  - `internal/domain/services/` - service monitoring, health checks
  - `internal/domain/user/` - user management
- Move shared utilities to `internal/pkg/` (config, database, middleware, validator)
- Keep sqlc generated code centralized in `internal/repository/sqlc/`
- Keep migrations at project root (works with goose)
- Enable co-located tests within each domain package

## Capabilities

### New Capabilities

- `api-structure`: Documents the standard Go project layout and vertical slice architecture pattern for the api-gateway, including package organization, dependency injection approach, and testing conventions.

### Modified Capabilities

(None - this is a pure refactoring that does not change external behavior or API contracts. Existing capabilities remain unchanged.)

## Impact

- **Code**: All files in `web/apps/api-gateway/` will be reorganized
- **Imports**: All internal import paths change from `core-gateway/handlers` to `core-gateway/internal/domain/...`
- **Build**: Dockerfile needs update to build from `cmd/server/`
- **sqlc**: Config path updates (`out: internal/repository/sqlc`)
- **Swagger**: May need path updates in swag init command
- **No API changes**: All routes, request/response formats unchanged
- **No database changes**: Migrations and schema remain identical
