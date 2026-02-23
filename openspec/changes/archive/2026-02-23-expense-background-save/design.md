## Context

Currently, expense edit/create operations block the UI with a "Saving..." state. The dialog stays open until the API responds. With NeonDB's serverless cold starts, this can take 1-3 seconds, making the app feel sluggish.

Current flow:
1. User clicks Save
2. Dialog shows "Saving..." and disables button
3. API call completes
4. Dialog closes, toast shows success

## Goals / Non-Goals

**Goals:**
- Close dialog immediately on submit (optimistic UI)
- Show toast feedback after background operation completes
- Improve perceived performance without blocking user

**Non-Goals:**
- Optimistic cache updates (let React Query handle via invalidation)
- Income operations (same pattern can be applied later)
- Error retry UI

## Decisions

**Background save with immediate dialog close**: Instead of optimistic updates to React Query cache, close dialog immediately and let React Query's `invalidateQueries` refetch data. This is simpler and ensures data consistency.

**Toast on success/error**: Show toast notification after the mutation completes. Success: green toast. Error: red toast with error message.

**No loading state on button**: Remove `isLoading` prop from submit button since dialog closes immediately.

## Risks / Trade-offs

- **Risk**: User sees stale data briefly until refetch completes → Acceptable, React Query invalidation is fast
- **Risk**: User navigates away before save completes → Mutation still completes, next visit shows updated data
- **Trade-off**: Not doing full optimistic update (updating cache immediately) → Simpler implementation, less risk of cache inconsistency
