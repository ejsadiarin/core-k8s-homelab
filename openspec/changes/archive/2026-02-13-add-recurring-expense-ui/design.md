## Context

The backend API has been updated to support recurring expenses with the same pattern as recurring incomes. The frontend currently has:
- `income-form.tsx` - Form with recurring type selector (one-time, daily, weekly, monthly)
- `income-card.tsx` - Card displaying recurring badge and date range
- `expense-form.tsx` - Basic form without recurring support
- `expense-card.tsx` - Basic card without recurring display

The expense components need to mirror the income recurring pattern while accounting for expenses having categories and tags.

## Goals / Non-Goals

**Goals:**
- Add recurring expense type selection to expense form (one-time, daily, weekly, monthly, yearly)
- Display recurring badge and date range on expense cards
- Support "no end date" option for ongoing recurring expenses
- Maintain consistency with income recurring UI patterns
- Update TypeScript types to match backend API

**Non-Goals:**
- Budget calculation changes (backend handles this)
- Complex recurrence patterns (e.g., "every 2 weeks")
- Changes to category/tag functionality
- Mobile-specific UI adaptations

## Decisions

**Decision: Mirror income-form.tsx pattern exactly**
- Rationale: Consistent UX across incomes and expenses reduces user confusion
- Implementation: Use same Select component for recurring type, same checkbox for "no end date"

**Decision: Add 'yearly' type for expenses (not in income)**
- Rationale: Expenses commonly have yearly cycles (insurance, subscriptions) that incomes rarely have
- Note: Income only supports daily, weekly, monthly

**Decision: Display recurring info after category/tags in expense card**
- Rationale: Expenses have more metadata (category, tags) than incomes, so recurring info comes after
- Layout: Description → Category/Tags → Recurring Badge + Dates → Amount

**Decision: Use red color scheme for expense recurring badge**
- Rationale: Expenses use red (negative), incomes use green (positive)
- Implementation: Same Badge component, different styling context

## Risks / Trade-offs

**[Risk] Form becomes lengthy with recurring fields**
- **Mitigation**: Fields only appear when recurring type is selected, keeping one-time expense creation simple

**[Risk] Date validation complexity (end_date < start_date)**
- **Mitigation**: HTML5 date input min attribute prevents invalid dates, backend validates as well

## Migration Plan

1. Update TypeScript types in `types/api.ts`
2. Update `expense-form.tsx` with recurring fields
3. Update `expense-card.tsx` with recurring display
4. Update `expense-edit-dialog.tsx` to pass recurring data
5. Update `expense-detail-dialog.tsx` with recurring info
6. Test form validation and date handling
