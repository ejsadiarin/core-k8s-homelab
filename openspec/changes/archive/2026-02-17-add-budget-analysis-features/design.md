## Context

The budget tracker currently provides basic CRUD for expenses, income, categories, and tags. Users can view simple statistics like total spending and category breakdowns. However, the system lacks advanced financial analytics that transform raw data into actionable insights.

This design implements industry-standard budgeting features including savings rate tracking, budget variance monitoring, spending velocity calculations, and the 50/30/20 rule analysis. These features will be implemented across the existing Go backend (Echo framework) and Next.js frontend.

**Current State:**
- Database: PostgreSQL with tables for expenses, income, categories, tags
- Backend: Go with Echo, sqlc for type-safe queries
- Frontend: Next.js with React Query, shadcn/ui, recharts
- Authentication: Session-based with RBAC

**Constraints:**
- Must maintain existing data integrity
- Must work within current auth/tenant isolation model (user_id filtering)
- New features should be additive, not breaking

## Goals / Non-Goals

**Goals:**
- Implement savings rate calculation with health indicators
- Add category budget setting with variance tracking
- Create spending velocity projections with warnings
- Build 50/30/20 rule categorization and visualization
- Provide upcoming bills forecasting
- Add merchant/subscription analysis

**Non-Goals:**
- Bank account integration (Plaid, etc.)
- Multi-currency support (uses existing currency field)
- Investment/portfolio tracking
- Receipt scanning or OCR
- Mobile app (web-only for now)
- Real-time notifications (can be added later)

## Decisions

### 1. Budget Storage: Monthly Category Budgets Table
**Decision:** Create `category_budgets` table with (user_id, category_id, month, budget_amount) rather than storing budget in categories table.

**Rationale:**
- Allows different budgets per month (January vs December holidays)
- Historical tracking of budget changes
- Supports rollovers and adjustments

**Alternative Considered:** Adding `budget_amount` to `budget_categories` - rejected because it doesn't support month-over-month variation.

### 2. Category Type Classification: Need/Want/Savings
**Decision:** Add `category_type` enum to `budget_categories` with values 'need', 'want', 'savings'.

**Rationale:**
- Enables 50/30/20 rule calculation
- Users classify categories once, applies to all expenses
- Can be NULL for users who don't use this feature

### 3. Spending Velocity Calculation
**Decision:** Calculate velocity as `(total_spent / days_elapsed) × days_in_month` vs current month budget.

**Rationale:**
- Simple linear projection
- Easy to understand
- Can be enhanced with ML later

**Trade-off:** Doesn't account for known upcoming large expenses (e.g., rent due on 1st).

### 4. Recurring Detection: Pattern Matching vs Explicit Flag
**Decision:** Use explicit `recurring_type` field (already exists) for forecasting, with future enhancement for merchant pattern detection.

**Rationale:**
- Explicit is more reliable than inference
- User already sets this when creating expenses
- Can add merchant clustering later without breaking changes

### 5. API Design: New Stats Endpoints vs Extending Existing
**Decision:** Create new endpoints under `/api/budget/stats/*` and `/api/budget/analysis/*` rather than extending `/api/budget/stats/summary`.

**Rationale:**
- Better separation of concerns
- Easier to test and document
- Clients can fetch only what they need

### 6. Frontend: Widget-Based Dashboard
**Decision:** Build modular analytics widgets that can be arranged on the budget dashboard.

**Rationale:**
- Reusable components
- Users can focus on metrics they care about
- Easy to add/remove features later

## Risks / Trade-offs

**Risk:** Budget setting adds complexity for new users → **Mitigation:** Make budget fields optional; show 