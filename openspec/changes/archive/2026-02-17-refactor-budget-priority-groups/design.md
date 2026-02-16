## Context

The budget tracker classifies expenses as Need/Want/Savings for 50/30/20 analysis. Currently `category_type` lives on `budget_categories`, but categories like "Food" span both Need (groceries) and Want (dining out). This makes the 50/30/20 analysis inaccurate and forces users to create duplicate categories.

The refactor introduces a `budget_priority_groups` reference table and moves classification to the expense level via a nullable `priority_group_id` FK on `budget_expenses`.

## Goals / Non-Goals

**Goals:**
- Move Need/Want/Savings classification from category-level to expense-level
- Maintain accurate 50/30/20 budget analysis
- Provide a seeded reference table with default priority groups
- Allow users to assign priority when creating/editing expenses
- Migrate existing category-level classifications to expense-level where possible
- Clean up dead code (duplicate API functions, unused types)

**Non-Goals:**
- Custom user-defined priority groups (only system defaults: Need, Want, Savings)
- Bulk reassignment UI for existing expenses
- Changes to budget remaining calculation (unrelated to priority)
- Changes to recurring expense logic

## Decisions

### D1: System-level reference table vs user-level

**Decision**: `budget_priority_groups` is a system-level table (no `user_id`). Rows are seeded via migration.

**Rationale**: Need/Want/Savings are universal concepts. Users don't need custom groups — the 50/30/20 framework is standardized. This avoids duplicate data per user and simplifies queries.

**Alternatives considered**:
- Per-user priority groups: unnecessary complexity, users won't customize these
- Enum column on expenses: less flexible, can't add metadata to groups later

### D2: Data migration strategy

**Decision**: Two-phase migration in a single migration file:
1. Create `budget_priority_groups` table with 3 seeded rows
2. Add `priority_group_id` to `budget_expenses`
3. Backfill: for expenses whose category has `category_type` set, copy the mapping to `priority_group_id`
4. Drop `category_type` column and related index from `budget_categories`

**Rationale**: Single migration keeps the change atomic. Backfill preserves existing classifications. Dropping `category_type` avoids confusion about which field is authoritative.

### D3: Priority assignment in expense forms

**Decision**: Add an optional priority group dropdown to the expense create/edit forms. Default is null (unclassified).

**Rationale**: Making it optional avoids forcing users to classify every expense. The 50/30/20 analysis only considers classified expenses, with a note showing how many are unclassified.

### D4: API endpoint changes

**Decision**:
- Remove `PUT /api/budget/categories/:id/type`
- Add `GET /api/budget/priority-groups` (list all groups)
- Modify expense create/update to accept `priority_group_id`
- Modify 50/30/20 endpoint to query by `budget_expenses.priority_group_id`

**Rationale**: Clean break from category-level classification. The priority groups endpoint is read-only (no CRUD needed since they're system-defined).

## Risks / Trade-offs

- **[Data loss]** Expenses without a category_type set on their category will remain unclassified → Acceptable, user can classify them manually going forward
- **[Breaking API]** `PUT /categories/:id/type` removal breaks any client using it → Low risk, only used by our frontend which we control
- **[Unclassified expenses]** 50/30/20 chart accuracy depends on users classifying expenses → Show "X expenses unclassified" message to encourage classification
- **[Migration ordering]** Migration must run before new code deploys → User runs `make migrate-up` before testing new code
