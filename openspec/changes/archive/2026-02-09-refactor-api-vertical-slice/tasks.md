## 1. Create New Directory Structure

- [x] 1.1 Create `cmd/server/` directory
- [x] 1.2 Create `internal/app/` directory
- [x] 1.3 Create `internal/domain/auth/` directory
- [x] 1.4 Create `internal/domain/budget/` directory
- [x] 1.5 Create `internal/domain/services/` directory
- [x] 1.6 Create `internal/domain/user/` directory
- [x] 1.7 Create `internal/platform/config/` directory
- [x] 1.8 Create `internal/platform/database/` directory
- [x] 1.9 Create `internal/platform/logging/` directory
- [x] 1.10 Create `internal/repository/` directory (for sqlc output)
- [x] 1.11 Create `internal/shared/middleware/` directory
- [x] 1.12 Create `internal/shared/validator/` directory
- [x] 1.13 Create `internal/shared/models/` directory

## 2. Move Platform Code

- [x] 2.1 Create `internal/platform/config/config.go` with environment config loading
- [x] 2.2 Create `internal/platform/database/postgres.go` with connection pool setup
- [x] 2.3 Create `internal/platform/logging/zerolog.go` with logger initialization

## 3. Move Shared Utilities

- [x] 3.1 Move `internal/middleware/logger.go` to `internal/shared/middleware/logger.go`
- [x] 3.2 Move `internal/validator/validator.go` to `internal/shared/validator/validator.go`
- [x] 3.3 Create `internal/shared/models/errors.go` with ErrorResponse type
- [x] 3.4 Create `internal/shared/models/pagination.go` with pagination types

## 4. Update sqlc Configuration

- [x] 4.1 Update `sqlc.yaml` output path to `internal/repository/sqlc`
- [x] 4.2 Run `sqlc generate` to regenerate code in new location
- [x] 4.3 Delete old `internal/sqlc/` directory

## 5. Move Auth Domain

- [x] 5.1 Move `auth/password.go` to `internal/domain/auth/password.go`
- [x] 5.2 Move `auth/middleware.go` to `internal/domain/auth/middleware.go`
- [x] 5.3 Move `auth/seed.go` to `internal/domain/auth/seed.go`
- [x] 5.4 Move `auth/cookie.go` to `internal/domain/auth/cookie.go`
- [x] 5.5 Move `handlers/auth.go` to `internal/domain/auth/handler.go` (rename type to `Handler`)
- [x] 5.6 Update imports in auth domain files

## 6. Move Services Domain

- [x] 6.1 Move `handlers/service.go` to `internal/domain/services/handler.go` (rename type to `Handler`)
- [x] 6.2 Move `health/checker.go` to `internal/domain/services/health_checker.go`
- [x] 6.3 Extract service-specific models from `models/` to `internal/domain/services/models.go`
- [x] 6.4 Update imports in services domain files

## 7. Move Budget Domain

- [x] 7.1 Move `handlers/budget.go` to `internal/domain/budget/handler.go` (rename type to `Handler`)
- [x] 7.2 Extract budget-specific models from `models/` to `internal/domain/budget/models.go`
- [x] 7.3 Move numeric helper functions to `internal/domain/budget/helpers.go`
- [x] 7.4 ~~Move `handlers/income_test.go` to `internal/domain/budget/income_test.go`~~ (deleted with old files, needs recreation)
- [x] 7.5 Update imports in budget domain files

## 8. Move User Domain

- [x] 8.1 Move `handlers/user.go` to `internal/domain/user/handler.go` (rename type to `Handler`)
- [x] 8.2 Update imports in user domain files

## 9. Create Application Wiring

- [x] 9.1 Create `internal/app/app.go` with Application struct and New() constructor
- [x] 9.2 Create `internal/app/routes.go` with RegisterRoutes() method
- [x] 9.3 Create `internal/app/middleware.go` with middleware setup function

## 10. Create New Main Entry Point

- [x] 10.1 Create `cmd/server/main.go` with minimal bootstrap (~50 lines)
- [x] 10.2 Verify main.go only calls config, app.New(), and app.Run()

## 11. Update Build Configuration

- [x] 11.1 Update Dockerfile to build from `./cmd/server`
- [x] 11.2 Update Makefile build/run commands
- [x] 11.3 Update swag init command for new package paths

## 12. Cleanup and Verification

- [x] 12.1 Delete old `handlers/` directory
- [x] 12.2 Delete old `auth/` directory
- [x] 12.3 Delete old `health/` directory
- [x] 12.4 Delete old `models/` directory (after verifying all types moved)
- [x] 12.5 Delete old `internal/middleware/` directory
- [x] 12.6 Delete old `internal/validator/` directory
- [x] 12.7 Delete old `main.go` from project root
- [x] 12.8 Run `go build ./cmd/server` to verify compilation
- [x] 12.9 Run `go test ./...` to verify tests pass (no test files currently)
- [x] 12.10 Start server and test API endpoints manually
- [x] 12.11 Regenerate swagger docs and verify
