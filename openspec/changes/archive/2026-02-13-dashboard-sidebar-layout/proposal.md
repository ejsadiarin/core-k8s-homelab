## Why

The dashboard currently uses a horizontal top navigation header, which limits scalability as features grow (Analytics, Logs, and other planned sections have dead links). A sidebar-based layout — the standard for dashboards like the reference "Command Center" UI — provides better navigation hierarchy, more room for feature links, and a professional cyberpunk aesthetic that matches the existing color scheme. This also eliminates the dead nav links problem by organizing features into clear sidebar sections.

## What Changes

- Replace the horizontal `NavigationHeader` + `MainLayout` pattern with a sidebar-based dashboard layout
- Create a collapsible sidebar component with icon + label navigation items, grouped by section (Overview, Budget, System, Admin)
- Add a compact top header bar within the main content area for user profile, notifications, and system status
- Restructure the dashboard layout to use sidebar (left) + content (right) pattern
- Remove or repurpose the current `NavigationHeader` (keep for non-dashboard pages like login/register if needed)
- Wire all existing routes into the sidebar navigation (Dashboard, Budget, Budget sub-pages, Services, Users)
- Add placeholder sidebar entries for upcoming features (Analytics, Logs) with proper disabled/coming-soon state
- Support sidebar collapsed (icon-only) and expanded states with smooth transitions
- Mobile: sidebar becomes a slide-out drawer overlay

## Capabilities

### New Capabilities
- `dashboard-sidebar`: Collapsible sidebar navigation component with icon + label items, section grouping, active state highlighting, and collapsed/expanded modes
- `dashboard-layout`: New sidebar-based layout shell that replaces header-only layout for all `/dashboard/**` routes, with sidebar + compact header + main content area

### Modified Capabilities
- `demo-user-experience`: Guest mode badge and read-only indicators move from header into sidebar footer and compact header

## Impact

- **Frontend components**: `main-layout.tsx` and `navigation-header.tsx` will be replaced/heavily modified for dashboard routes
- **Dashboard layout**: `app/dashboard/layout.tsx` will use the new sidebar layout instead of `MainLayout`
- **All dashboard pages**: Container padding/width may need adjustment since content area is narrower with sidebar
- **CSS variables**: Existing `--sidebar-*` CSS variables in `globals.css` are already defined and will be used
- **Dependencies**: May add shadcn/ui `sidebar`, `tooltip`, `separator`, `sheet` components if not already installed
- **No backend changes**: This is purely a frontend layout restructuring
- **No routing changes**: All existing routes remain the same, just navigated differently
