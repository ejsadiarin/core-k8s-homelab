## Context

The budget tracker frontend currently has several UX issues related to responsiveness and user feedback. Components were built with basic styling but don't handle edge cases like long text content, high tag counts, or provide feedback for async operations. Users experience overflow issues in the expense detail dialog, cannot interact with expense cards in the Recent Expenses section, receive no feedback when performing CRUD operations, and see stale data after navigation due to React Query cache not being properly invalidated.

## Goals / Non-Goals

**Goals:**
- Fix text overflow and responsiveness issues in expense detail dialog
- Make expense cards clickable while maintaining edit/delete button functionality
- Implement toast notifications for all CRUD operations
- Eliminate stale data display through proper cache invalidation
- Maintain existing component architecture and styling patterns

**Non-Goals:**
- Redesigning the overall UI layout or visual design system
- Adding new features beyond the UX improvements listed
- Changing the backend API or data models
- Implementing loading states (already exists)

## Decisions

### Decision 1: Use shadcn/ui Sonner for toast notifications
**Rationale:** The project already uses shadcn/ui components. Sonner is the recommended toast library for shadcn/ui, providing a modern, accessible toast system with TypeScript support. It integrates seamlessly with the existing design system.

**Alternatives Considered:**
- React Hot Toast: Popular but would add an extra dependency outside the shadcn/ui ecosystem
- Custom toast component: More work to build and maintain, would need accessibility considerations

### Decision 2: Increase dialog max-width to 600px
**Rationale:** Current 450px max-width is too narrow for displaying expense details with multiple tags and long descriptions. 600px provides more breathing room while remaining reasonable on tablet/desktop screens. Mobile devices will still use responsive full-width behavior.

**Alternatives Considered:**
- 550px: Still feels cramped with multiple tags
- Full-screen on all devices: Too aggressive, reduces desktop UX

### Decision 3: Implement "+N more" expandable tag display
**Rationale:** Showing all tags inline can cause layout issues with 5+ tags. A "+N more" badge that expands on click provides clean initial display while maintaining full access. This pattern is used in Recent Expenses cards already, so it's consistent.

**Alternatives Considered:**
- Always show all tags wrapped: Can make dialog feel cluttered
- Tooltip on hover: Less discoverable, requires mouse interaction

### Decision 4: Add line-clamp and text truncation utilities
**Rationale:** Tailwind's `line-clamp` utility provides clean CSS-based text truncation. Using `truncate` for single-line content (titles) and `line-clamp-3` for multi-line content (descriptions) gives consistent overflow handling without JavaScript.

**Alternatives Considered:**
- JavaScript-based truncation: More complex, introduces unnecessary logic
- No truncation, only scrolling: Can feel cramped in small spaces

### Decision 5: Use React Query's invalidateQueries for cache management
**Rationale:** React Query's `invalidateQueries` API provides declarative cache invalidation. After successful mutations, invalidating query keys like `["expenses"]`, `["expense-stats"]`, `["summary-stats"]` ensures all related data refetches automatically.

**Alternatives Considered:**
- Manual refetch calls: Error-prone, need to track all dependent queries
- Optimistic updates only: Can lead to stale data if mutations fail

### Decision 6: Add refetchOnMount: true to critical queries
**Rationale:** Setting `refetchOnMount: true` for expense and stats queries ensures data freshness when navigating between pages. This eliminates the 0.5-1 second delay where old data is visible after mutations on other pages.

**Alternatives Considered:**
- Always refetch on window focus: Too aggressive, refetches when switching browser tabs
- Lower staleTime: Doesn't address navigation scenario directly

### Decision 7: Make expense cards clickable at Card level, not CardContent
**Rationale:** Adding `onClick` to the `<Card>` component makes the entire card clickable. Edit/delete buttons use `e.stopPropagation()` to prevent triggering the card click. This is a standard React pattern for nested interactive elements.

**Alternatives Considered:**
- Wrapping card in button element: Semantically incorrect, causes HTML validation issues
- Adding invisible click overlay: Overcomplicates DOM structure

## Risks / Trade-offs

**[Risk]** Text truncation may hide important information from users  
**→ Mitigation:** Use hover tooltips or expandable sections for truncated content. The detail dialog click action makes full content accessible.

**[Risk]** Aggressive cache invalidation may cause unnecessary refetches  
**→ Mitigation:** Only invalidate after successful mutations. Keep staleTime at reasonable values (e.g., 30 seconds) to balance freshness and performance.

**[Risk]** Toast notifications might be intrusive with many rapid operations  
**→ Mitigation:** Use Sonner's built-in queuing and auto-dismiss (5 seconds). Success toasts are brief and non-modal.

**[Risk]** Clickable expense cards may confuse users with existing edit/delete buttons  
**→ Mitigation:** Maintain hover state changes and cursor indicators. Edit/delete button clicks properly stop propagation to prevent card click.

**[Risk]** Larger dialog (600px) may not work well on small tablets (768-800px)  
**→ Mitigation:** Use responsive max-width with Tailwind (sm:max-w-[600px]). Dialog will still adapt to smaller screens.

## Migration Plan

This is a frontend-only change with no breaking changes:

1. **Install Sonner dependency** (`pnpm add sonner`)
2. **Add Toaster component to root layout**
3. **Update expense-detail-dialog.tsx** with responsive styling
4. **Update expense-card.tsx** to be clickable
5. **Update use-budget.ts hooks** with invalidateQueries calls
6. **Update budget dashboard page** to handle expense card clicks
7. **Add toast notifications** to all CRUD operations
8. **Test on mobile, tablet, desktop** viewports

**Rollback:** This change is additive and can be partially rolled back if issues occur. Toast notifications can be disabled without breaking functionality. Cache invalidation changes are safe to revert.

## Open Questions

- Should we add toast notifications to service monitoring CRUD operations as well for consistency?
- Should the "+N more" tag expansion be a modal/popover or inline expansion?
- Do we need different refetch strategies for different pages (e.g., dashboard vs detailed views)?
