## Context

The existing budget analytics system calculates financial metrics using the tracking_start_date configuration as a global filter. Users cannot perform ad-hoc analysis over custom time periods without modifying their baseline configuration.

## Goals / Non-Goals

**Goals:**
- Add optional start_date and end_date parameters to all budget analytics API endpoints
- Enable custom date range analysis for Savings Rate, Spending Velocity, Spending by Day, and Total Money
- Maintain backward compatibility with existing tracking_start_date behavior

**Non-Goals:**
- Modifying the tracking_start_date configuration UI or flow
- Adding new analytics features beyond date range support
- Changing data storage or schema

## Decisions

### Decision: Query Parameter Approach
**Chosen:** Add optional `start_date` and `end_date` query parameters to existing analytics endpoints.

**Alternative Considered:** Create new endpoints for date-range-specific analytics.

**Rationale:** Minimizes API surface changes, maintains RESTful conventions, and allows gradual adoption.

### Decision: Date Range Override Behavior
**Chosen:** Custom date range parameters override tracking_start_date filtering when provided.

**Alternative Considered:** Require both tracking_start_date and custom range.

**Rationale:** Provides maximum flexibility - users can analyze any period regardless of their tracking configuration.

### Decision: Backend Query Strategy
**Chosen:** Conditionally apply date filtering in SQL queries - use tracking_start_date by default, use custom range if provided.

**Alternative Considered:** Apply both filters with OR logic.

**Rationale:** Custom date range should give users complete control over the analysis period.

## Risks / Trade-offs

- [Risk] Users may be confused about which date filter takes precedence → **Mitigation**: Document clearly in API response metadata which date range was used
- [Risk] Performance impact for wide date ranges → **Mitigation**: Add database indexes on expense_date and income_date columns
- [Risk] Edge case: custom range completely outside tracking period → **Mitigation**: Allow this - it's valid for historical analysis

## Open Questions

- Should custom date ranges be persisted/saved for future sessions? (Deferred - can be added later)
- Should there be a maximum range limit (e.g., 2 years)? (Deferred - can be added if performance issues arise)
