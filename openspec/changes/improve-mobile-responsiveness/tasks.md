## 1. Spending by Day Chart - Horizontal Scroll

- [x] 1.1 Update `weekday-spending-chart.tsx` to use fixed minimum bar widths (`min-w-[32px]`) instead of `flex-1`
- [x] 1.2 Wrap the bar chart container with `overflow-x-auto` for horizontal scrolling
- [x] 1.3 Keep `overflow-y-hidden` to prevent vertical label overflow

## 2. Spending by Day Chart - Price Labels

- [x] 2.1 Add `text-ellipsis` and `overflow-hidden` to price labels for collision prevention
- [x] 2.2 Implement abbreviated format for amounts >= 10,000 (e.g., "₱12.5k")
- [x] 2.3 Add tooltip on hover/tap to show full amount (optional enhancement)

## 3. Mobile Bottom Navigation - Add Missing Icons

- [x] 3.1 Locate the mobile bottom navigation component (likely in `dashboard-sidebar.tsx` or a dedicated mobile nav file)
- [x] 3.2 Add Health page icon (use `Heart` or `Activity` from lucide-react) with label
- [x] 3.3 Add Recurring page icon (use `Repeat` or `RefreshCcw` from lucide-react) with label
- [x] 3.4 Ensure active state highlighting works for new icons

## 4. Health Page - Date Range Auto-fetch

- [x] 4.1 Remove the "Apply" button from the date range selector in `health/page.tsx`
- [x] 4.2 Add `onChange` handlers to date inputs that update URL search params immediately
- [x] 4.3 Verify React Query refetches automatically when URL params change

## 5. Health Page - Mobile Responsiveness

- [x] 5.1 Audit Health page layout on mobile viewport (< 768px)
- [x] 5.2 Update 50/30/20 breakdown card to stack vertically on mobile
- [x] 5.3 Ensure health score card scales appropriately for smaller screens
- [x] 5.4 Verify all charts and metrics are readable without horizontal scroll (aside from intentional chart scrolling)

## 6. Testing and Verification

- [x] 6.1 Test "Spending by Day" chart with 30+ day range - verify horizontal scroll works
- [x] 6.2 Test mobile bottom navigation - verify Health and Recurring icons are visible and functional
- [x] 6.3 Test Health page date picker - verify auto-fetch on date selection
- [x] 6.4 Test Health page on mobile viewport - verify responsive layout
- [x] 6.5 Run `pnpm lint` and fix any issues
- [x] 6.6 Run `pnpm build` to verify production build succeeds
