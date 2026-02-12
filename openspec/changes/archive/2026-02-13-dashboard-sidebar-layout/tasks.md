## 1. Sidebar Context & Configuration

- [x] 1.1 Create `sidebar-context.tsx` with `SidebarProvider` and `useSidebar` hook exposing `isCollapsed`, `toggle`, `setCollapsed` state
- [x] 1.2 Create navigation items config array in `sidebar-nav-items.ts` with typed `NavItem` interface (`label`, `icon`, `path`, `section`, `adminOnly?`, `disabled?`) and all items: Dashboard, Budget, Expenses, Incomes, Budget Settings, Services, Analytics (disabled), Logs (disabled), Users (adminOnly)

## 2. Sidebar Component (Desktop)

- [x] 2.1 Create `sidebar.tsx` — main sidebar component that renders the sidebar container with expand/collapse width transition (240px expanded, 64px collapsed), background using `--sidebar` CSS variable, left border using `--sidebar-border`
- [x] 2.2 Create `sidebar-nav.tsx` — renders navigation items grouped by section headers (Overview, Finance, System, Admin), with each item showing icon + label (label hidden when collapsed), active route highlighting using `pathname` matching, and tooltips on hover when collapsed
- [x] 2.3 Create `sidebar-footer.tsx` — renders user email (truncated), role badge with color coding, guest mode badge when applicable, and logout button. In collapsed state, show only user icon with dropdown for full info
- [x] 2.4 Add collapse toggle button to sidebar header area (top, next to logo — expand/collapse chevrons)
- [x] 2.5 Wire disabled nav items (Analytics, Logs) to show "Coming Soon" tooltip and prevent navigation

## 3. Content Header

- [x] 3.1 Create `content-header.tsx` — compact top bar inside main content area showing: left-side breadcrumb trail (e.g., "Dashboard > Budget > Expenses"), right-side actions (guest mode badge, notification bell, user avatar dropdown as secondary access)

## 4. Dashboard Shell & Layout Integration

- [x] 4.1 Create `dashboard-shell.tsx` — composes `SidebarProvider` + sidebar + mobile bottom nav + content header + main content area in a flex row layout. Sidebar is fixed/sticky on the left, content scrolls independently
- [x] 4.2 ~~Implement mobile sidebar as radix `Sheet` overlay~~ → Replaced with `MobileBottomNav` floating bottom navbar (5 primary items + overflow "More" menu)
- [x] 4.3 Modify `app/dashboard/layout.tsx` to use `DashboardShell` instead of `MainLayout`
- [x] 4.4 Add framer-motion fade-in transition on content area for route changes

## 5. Page Content Adjustments

- [x] 5.1 Review and adjust container classes on all dashboard pages — remove `container mx-auto` if it constrains content too narrowly within the sidebar layout, replace with appropriate padding
- [x] 5.2 Verify dashboard page (`/dashboard`) renders correctly in new layout
- [x] 5.3 Verify budget pages (`/dashboard/budget`, `/dashboard/budget/expenses`, `/dashboard/budget/incomes`, `/dashboard/budget/settings`) render correctly
- [x] 5.4 Verify services page (`/dashboard/services`) renders correctly
- [x] 5.5 Verify admin users page (`/dashboard/admin/users`) renders correctly
- [x] 5.6 Fix mobile filter layout on expenses/incomes pages (grid-based responsive layout for filters)

## 6. Guest Mode & Polish

- [x] 6.1 Guest mode badge displayed in sidebar footer (dot indicator + GUEST badge) and content header (Guest Mode badge)
- [x] 6.2 `NavigationHeader` and `MainLayout` no longer used by any dashboard route — orphaned dead code, safe to delete
- [x] 6.3 Smooth framer-motion transitions on sidebar collapse/expand (width animation, label fade+slide)
- [x] 6.4 Mobile bottom nav with overflow menu, active route indicators, safe-area-inset support
- [x] 6.5 Verify all existing features still work (expense CRUD, income CRUD, service CRUD, user management, auth flow)
