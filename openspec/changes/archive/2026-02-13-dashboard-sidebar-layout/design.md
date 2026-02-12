## Context

The dashboard currently uses a horizontal `NavigationHeader` at the top with a `MainLayout` wrapper. All `/dashboard/**` routes render inside this header-only layout. The navigation links (Dashboard, Budget, Services, Analytics, Logs, Users) are displayed horizontally in the header, which doesn't scale well and has dead links (Analytics, Logs have no pages).

The reference UI is a dark cyberpunk "Command Center" dashboard with a left sidebar containing icon-based navigation tabs. The project already defines `--sidebar-*` CSS variables in `globals.css` that are unused.

Key existing components:
- `NavigationHeader` (`components/layout/navigation-header.tsx`): sticky top bar with horizontal nav, user dropdown, notification bell
- `MainLayout` (`components/layout/main-layout.tsx`): wraps header + content + footer
- `dashboard/layout.tsx`: auth protection wrapper using `MainLayout`
- shadcn/ui components already installed: button, badge, dropdown-menu, dialog, tooltip, sheet (radix dependencies present)

## Goals / Non-Goals

**Goals:**
- Replace header-only navigation with a sidebar-based layout for all dashboard routes
- Match the cyberpunk aesthetic of the reference "Command Center" UI using the existing color scheme
- Support collapsed (icon-only) and expanded (icon + label) sidebar states
- Provide mobile support via a slide-out drawer
- Keep all existing routes and features working identically
- Use existing CSS variables (`--sidebar-*`) and shadcn/ui component patterns

**Non-Goals:**
- Building a custom sidebar from scratch — use shadcn/ui's `Sidebar` component pattern (or build a lightweight custom one using existing radix primitives)
- Implementing Analytics or Logs pages — these remain as placeholder/disabled items
- Changing the landing page, login, or register layouts
- Adding new backend functionality
- Redesigning individual page content (only the layout shell changes)
- Dark/light theme toggle — stays dark-only

## Decisions

### 1. Custom sidebar component over shadcn/ui `Sidebar`

**Decision:** Build a lightweight custom sidebar component using existing primitives (radix tooltip, radix sheet for mobile, framer-motion for animations) rather than installing shadcn/ui's opinionated `Sidebar` component.

**Rationale:** The shadcn/ui sidebar component is heavy and introduces its own state management patterns (cookie-based persistence, complex context). A custom component gives us full control over the cyberpunk styling, matches framer-motion animation patterns used elsewhere, and avoids introducing a new state management paradigm. The existing radix `Sheet` primitive already handles the mobile drawer case.

**Alternatives considered:**
- shadcn/ui Sidebar: Too opinionated, brings cookie-based state and complex provider tree. Would require overriding many default styles.

### 2. Layout composition — sidebar replaces MainLayout for dashboard routes

**Decision:** Create a new `DashboardShell` component that composes sidebar + compact header + content. Modify `dashboard/layout.tsx` to use `DashboardShell` instead of `MainLayout`. Keep `MainLayout` for potential non-dashboard pages.

**Rationale:** Clean separation between dashboard and non-dashboard layouts. Existing auth protection logic in `dashboard/layout.tsx` stays the same — only the visual wrapper changes.

### 3. Collapse state stored in React state (not localStorage/cookies)

**Decision:** Store sidebar collapsed/expanded state in React context scoped to the dashboard layout. Don't persist to localStorage initially.

**Rationale:** Simplifies implementation. The sidebar defaults to expanded on desktop. Persistence across hard refreshes can be added later if needed. State persists across in-app navigations via React context.

### 4. Navigation items defined as a static configuration array

**Decision:** Define all navigation items as a typed configuration array with `{ label, icon, path, section, adminOnly?, disabled? }`. The sidebar component maps over this array to render items.

**Rationale:** Easy to add/remove/reorder items. Admin-only filtering is a simple filter. Disabled items (Analytics, Logs) get a `disabled` flag with a "coming soon" tooltip.

### 5. Compact top header bar

**Decision:** Add a thin header bar inside the content area (not the full-width NavigationHeader) that shows: breadcrumb, page title, and right-side actions (notification bell, guest badge, user avatar dropdown). This replaces the current `NavigationHeader` entirely for dashboard routes.

**Rationale:** The sidebar handles primary navigation. The compact header provides context (where am I?) and quick actions without duplicating navigation. The reference UI uses this same pattern — sidebar for nav, minimal header for context.

### 6. File structure

**Decision:**
```
src/components/layout/
├── main-layout.tsx          (keep, used for non-dashboard pages)
├── navigation-header.tsx    (keep for reference, no longer used by dashboard)
├── dashboard-shell.tsx      (NEW: sidebar + header + content wrapper)
├── sidebar.tsx              (NEW: sidebar component)
├── sidebar-nav.tsx          (NEW: navigation item rendering)
├── sidebar-footer.tsx       (NEW: user info footer)
├── content-header.tsx       (NEW: compact top header bar)
└── sidebar-context.tsx      (NEW: collapse state context)
```

**Rationale:** Follows existing project pattern of colocating layout components. Each file has a single responsibility.

## Risks / Trade-offs

- **[Risk] Page content width changes** → All existing dashboard pages use `container mx-auto px-4` which should adapt naturally. May need to remove `container` class or adjust max-width since the content area is already constrained by the sidebar.
  - Mitigation: Test each page after layout change, adjust container classes if needed.

- **[Risk] Mobile experience regression** → Current mobile nav is hidden (`hidden md:flex`). The new sidebar drawer needs to work well.
  - Mitigation: Use battle-tested radix `Sheet` component for mobile drawer. Test on small viewports.

- **[Risk] Animation performance** → Sidebar collapse/expand animation on lower-end devices.
  - Mitigation: Use CSS transitions for width changes (GPU-accelerated `transform` where possible). Keep framer-motion for mount/unmount only.

- **[Trade-off] No persistent collapse state** → Users lose their collapse preference on hard refresh. Acceptable for initial implementation, can add localStorage persistence later.
