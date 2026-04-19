## Context

The budget tracking web app has accumulated several mobile responsiveness issues as features were added. The main pain points are:

1. **Spending by Day chart** (`weekday-spending-chart.tsx`): Uses `flex-1` for bar widths, causing bars to compress when many days are displayed. Price labels above bars collide and overflow vertically. Current fix (`overflow-y-hidden`) prevents vertical scroll but doesn't address horizontal overflow.

2. **Mobile navigation** (`dashboard-sidebar.tsx`): The bottom mobile nav shows limited icons, missing Health and Recurring pages which are key user destinations.

3. **Health page date picker**: Uses an "Apply" button pattern that adds friction; users expect instant feedback when selecting dates.

4. **General mobile layouts**: Several components use fixed-width or desktop-first layouts that don't adapt well to mobile viewports.

## Goals / Non-Goals

**Goals:**
- Make "Spending by Day" chart horizontally scrollable with consistent bar widths
- Ensure price labels remain readable regardless of date range size
- Add missing navigation icons (Health, Recurring) to mobile bottom nav
- Auto-fetch data when date is selected (remove Apply button)
- Ensure Health page components render properly on mobile

**Non-Goals:**
- No backend API changes required
- Not redesigning the entire UI - only fixing responsive issues
- Not adding new features beyond navigation icons already present elsewhere

## Decisions

### Decision 1: Horizontal scroll for Spending by Day chart

**Approach:** Replace `flex-1` with fixed minimum bar widths (`min-w-[40px]`) inside an `overflow-x-auto` container.

**Rationale:** 
- Alternative A (keep flex-1): Bars become unreadable with 30+ days
- Alternative B (virtualization): Overkill for this use case, adds complexity
- Fixed widths + horizontal scroll is simple, predictable, and preserves chart readability

### Decision 2: Price label handling

**Approach:** Use `overflow-hidden` on labels with `text-ellipsis` for long amounts. On mobile, show abbreviated format (e.g., "₱1.2k" instead of "₱1,234").

**Rationale:**
- Prevents label collision
- Abbreviated format keeps labels compact while remaining informative

### Decision 3: Mobile navigation icons

**Approach:** Add Health and Recurring icons to the existing mobile bottom nav array. Match the icon pattern used for other navigation items.

**Rationale:**
- Consistent with existing navigation structure
- No new patterns needed

### Decision 4: Auto-fetch on date selection

**Approach:** Remove Apply button; trigger API fetch via `onChange` handler on date inputs using URL search params.

**Rationale:**
- Matches user mental model (date picker = instant filter)
- Reduces click friction
- URL params already handle the state sync

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Horizontal scroll may not be discoverable | Add subtle scroll hint or fade gradient on edges |
| Auto-fetch could cause excessive API calls | Debounce or use React Query's built-in deduplication |
| Abbreviated amounts may lose precision | Show full amount in tooltip on hover/tap |
