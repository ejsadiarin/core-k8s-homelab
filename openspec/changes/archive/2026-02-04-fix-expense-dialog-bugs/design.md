## Context

The expense detail dialog in the budget dashboard has several bugs and UI issues discovered during testing. The delete button shows guest warnings incorrectly, the edit flow doesn't complete properly, and the UI layout doesn't match the intended design.

## Goals / Non-Goals

**Goals:**
- Fix delete button to check actual auth state from context
- Fix edit workflow to properly update data after save
- Move category badge beside price
- Add proper ellipsis truncation with tooltips
- Clean up overflow styling

**Non-Goals:**
- Not changing the overall dialog structure or adding new features
- Not modifying the edit form itself, just the edit flow

## Decisions

### Decision 1: Pass isGuest to ExpenseDetailDialog
**Rationale:** The dialog should receive the actual guest state, not rely on checking if showToast callback exists.

**Implementation:**
```tsx
<ExpenseDetailDialog
  expense={viewingExpense}
  open={!!viewingExpense}
  onOpenChange={(open) => !open && setViewingExpense(null)}
  onEdit={handleEdit}     // NEW
  onDelete={handleDelete}  // NEW
  showToast={showToast}
  isGuest={isGuest}       // NEW
/>
```

### Decision 2: Use AlertDialog for delete confirmation
**Rationale:** The delete confirmation should use the same AlertDialog pattern as ExpenseCard for consistency.

**Implementation:**
- Import AlertDialog components in expense-detail-dialog.tsx
- Create delete confirmation state
- Show AlertDialog on delete click

### Decision 3: Redesign header layout
**Rationale:** Category should be beside price, not above description.

**Current Layout:**
```
[Description]
[Price]
[Category]
```

**New Layout:**
```
[Description] [Category]     [Price]
```

**Implementation:**
```tsx
<div className="flex items-start justify-between gap-4">
  <div className="min-w-0">
    <h3 className="text-lg font-semibold truncate" title={expense.description}>
      {expense.description}
    </h3>
    {expense.category && (
      <Badge className="mt-1 truncate max-w-[150px]" title={expense.category.name}>
        {expense.category.icon} {expense.category.name}
      </Badge>
    )}
  </div>
  <p className="text-2xl font-bold text-primary shrink-0">
    {expense.currency} {expense.amount.toFixed(2)}
  </p>
</div>
```

### Decision 4: Fix edit callback to pass updated data
**Rationale:** The onEdit callback should pass the updated expense, and parent should invalidate queries.

**Implementation in EditExpenseDialog:**
```tsx
<EditExpenseDialog
  expense={expense}
  open={editDialogOpen}
  onOpenChange={setEditDialogOpen}
  onSubmit={async (data) => {
    await onEdit?.(expense); // This triggers parent's edit
    onOpenChange(false);
  }}
  isLoading={updateExpense.isPending}
/>
```

Actually, the parent needs to handle the edit properly and invalidate queries. The issue is that after save, the detail dialog should refetch or update its local expense data.

**Better approach:** After edit completes, close both dialogs and the data will be refreshed via React Query cache invalidation.

### Decision 5: Improve text truncation
**Rationale:** Use title attribute for tooltip on truncated text.

**Implementation:**
- Add `title={expense.description}` to description
- Add `title={expense.category.name}` to category badge
- Keep `truncate` class for CSS ellipsis

## Risks / Trade-offs

**[Risk]** Changing layout might affect mobile view  
**→ Mitigation:** Test on mobile, use flex-wrap if needed

**[Risk]** Edit flow changes might break existing behavior  
**→ Mitigation:** Follow the same pattern as expenses page

## Migration Plan

1. Update `expense-detail-dialog.tsx`:
   - Import AlertDialog components
   - Add `isGuest` prop
   - Add delete confirmation state
   - Redesign header layout
   - Fix onSubmit callback

2. Update `budget/page.tsx`:
   - Add `handleEdit` function
   - Add `handleDelete` function
   - Pass callbacks to dialog

3. Test:
   - Verify delete works for authenticated users
   - Verify edit updates data properly
   - Verify UI layout on desktop and mobile

## Open Questions

- Should the edit dialog auto-close after save, or stay open to show success?
- Should we add a success toast after edit/delete?
