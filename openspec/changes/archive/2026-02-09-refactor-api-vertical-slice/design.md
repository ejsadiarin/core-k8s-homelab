## Context

The api-gateway is a Go backend serving a homelab dashboard with service monitoring and budget tracking features. Current structure uses horizontal layering:

```
api-gateway/
├── main.go           # 354 lines - routes, middleware, bootstrap, legacy endpoints
├── handlers/         # HTTP handlers grouped by type
├── models/           # Request/response DTOs
├── auth/             # Authentication logic
├── health/           # Health check scheduler
├── internal/
│   ├── sqlc/         # Generated SQL code
│   ├── middleware/   # Zerolog middleware
│   └── validator/    # Request validation
├── migrations/       # Goose migrations
└── sql/queries/      # sqlc query definitions
```

**Constraints:**
- Must maintain all existing API routes and behavior
- Must work with existing frontend at `apps/core/`
- Must continue using sqlc, goose, zerolog, echo
- Go module name is `core-gateway`

## Goals / Non-Goals

**Goals:**
- Reorganize to vertical slice architecture (feature/domain-based packages)
- Follow Go standard project layout (`cmd/`, `internal/`)
- Reduce `main.go` to minimal bootstrap (~50 lines)
- Enable co-located tests per domain
- Improve code discoverability (find all budget code in one place)
- Maintain existing DI pattern (constructor injection)

**Non-Goals:**
- Changing API routes or response formats
- Migrating to different libraries (stay with echo, sqlc, etc.)
- Implementing new features
- Moving migrations (keep at project root for goose compatibility)
- Splitting sqlc generated code by domain (keep centralized)

## Decisions

### 1. Directory Structure

**Decision:** Use Go standard layout with domain packages under `internal/domain/`

```
api-gateway/
├── cmd/
│   └── server/
│       └── main.go              # ~50 lines, minimal bootstrap
├── internal/
│   ├── app/
│   │   ├── app.go               # Application struct, DI wiring
│   │   ├── routes.go            # All route registration
│   │   └── middleware.go        # Middleware setup
│   ├── domain/
│   │   ├── auth/
│   │   │   ├── handler.go       # Auth HTTP handlers
│   │   │   ├── middleware.go    # Auth/RBAC middleware
│   │   │   ├── password.go      # Argon2id hashing
│   │   │   ├── seed.go          # Initial user seeding
│   │   │   └── session.go       # Session management
│   │   ├── budget/
│   │   │   ├── handler.go       # Budget HTTP handlers (categories, tags, expenses, incomes, stats)
│   │   │   ├── models.go        # Budget-specific DTOs
│   │   │   └── helpers.go       # Numeric conversion helpers
│   │   ├── services/
│   │   │   ├── handler.go       # Service monitoring handlers
│   │   │   ├── health_checker.go # Background health check scheduler
│   │   │   └── models.go        # Service-specific DTOs
│   │   └── user/
│   │       └── handler.go       # User management handlers
│   ├── platform/                # Cross-cutting concerns
│   │   ├── config/
│   │   │   └── config.go        # Environment config loading
│   │   ├── database/
│   │   │   └── postgres.go      # DB connection pool setup
│   │   └── logging/
│   │       └── zerolog.go       # Logger initialization
│   ├── repository/
│   │   └── sqlc/                # Generated SQL code (unchanged)
│   └── shared/
│       ├── middleware/
│       │   └── logger.go        # Request logging middleware
│       ├── validator/
│       │   └── validator.go     # Custom validator
│       └── models/
│           ├── pagination.go    # Shared pagination types
│           └── errors.go        # ErrorResponse type
├── migrations/                  # Keep at root for goose
├── sql/
│   └── queries/                 # Keep sqlc queries here
├── docs/                        # Generated swagger docs
├── sqlc.yaml                    # Updated output path
├── Dockerfile                   # Updated build path
└── Makefile                     # Updated commands
```

**Rationale:** 
- `cmd/server/` is Go convention for application entry points
- `internal/` prevents external imports
- `domain/` groups by feature, making it easy to find all related code
- `platform/` separates infrastructure from business logic
- `shared/` contains reusable utilities that don't belong to any domain

**Alternatives considered:**
- `pkg/` for shared code: Rejected because nothing is exported externally
- Keeping `handlers/` at root: Rejected because it perpetuates horizontal slicing
- Domain-specific sqlc generation: Rejected due to complexity and sqlc limitations

### 2. Application Wiring

**Decision:** Create `internal/app/app.go` with an `Application` struct that holds all dependencies

```go
type Application struct {
    Config     *config.Config
    Logger     *zerolog.Logger
    DB         *pgxpool.Pool
    Queries    *sqlc.Queries
    
    // Domain handlers
    AuthHandler    *auth.Handler
    BudgetHandler  *budget.Handler
    ServiceHandler *services.Handler
    UserHandler    *user.Handler
    
    // Background services
    HealthChecker  *services.HealthChecker
}

func New(cfg *config.Config) (*Application, error) {
    // Wire everything up
}
```

**Rationale:** 
- Single place to understand all dependencies
- Easy to test with mock dependencies
- Clean separation from route registration

### 3. Route Registration

**Decision:** All routes registered in `internal/app/routes.go`

```go
func (app *Application) RegisterRoutes(e *echo.Echo) {
    // Middleware setup
    // Public routes
    // Protected routes by domain
}
```

**Rationale:**
- Single file to see all API routes
- Easy to find route → handler mapping
- Keeps `main.go` minimal

### 4. sqlc Configuration

**Decision:** Update output path only, keep queries centralized

```yaml
version: "2"
sql:
  - engine: "postgresql"
    queries: "sql/queries"
    schema: "migrations"
    gen:
      go:
        package: "sqlc"
        out: "internal/repository/sqlc"  # Changed from internal/sqlc
        # ... rest unchanged
```

**Rationale:**
- sqlc works best with centralized queries
- Splitting by domain adds complexity without benefit
- All domains share the same DB connection anyway

### 5. Shared vs Domain-Specific Models

**Decision:** Split models by ownership

- `internal/shared/models/` - ErrorResponse, PaginationParams (used everywhere)
- `internal/domain/budget/models.go` - Budget-specific DTOs
- `internal/domain/services/models.go` - Service-specific DTOs
- `internal/domain/auth/` - Auth types stay with auth package

**Rationale:**
- Domain models change with domain requirements
- Shared models have stable interfaces
- Reduces cross-domain imports

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Import path changes break builds | Update all imports in single commit, run tests |
| Dockerfile path change | Update build path: `go build -o /server ./cmd/server` |
| Swagger generation path | Update `swag init` command in Makefile |
| IDE autocomplete issues during refactor | Complete refactor in focused session |
| Temporary code duplication | Accept during migration, clean up after |

## Migration Plan

**Approach:** Incremental migration with working state at each step

1. **Create new structure** - Add new directories without moving code
2. **Move platform code** - config, database, logging (low risk)
3. **Move shared utilities** - middleware, validator, models
4. **Update sqlc config** - Regenerate in new location
5. **Move domain code** - One domain at a time (auth → services → budget → user)
6. **Update main.go** - Move to `cmd/server/`, add app wiring
7. **Update Dockerfile and Makefile** - Build/run commands
8. **Clean up** - Remove empty directories, verify all imports
9. **Run full test suite** - Ensure everything works

**Rollback:** Git revert to pre-refactor commit

## Open Questions

1. **Legacy endpoints** - Keep `getSystemStats` and `getLegacyServices` in `internal/domain/legacy/` or in `internal/app/routes.go`? 
   → Recommendation: Keep in routes.go as they're small and deprecated

2. **Swagger annotations** - Do they need updates for new package paths?
   → Need to test: swag should handle package changes automatically
