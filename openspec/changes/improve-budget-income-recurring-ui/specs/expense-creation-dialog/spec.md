## ADDED Requirements

### Requirement: Expense creation via dialog
Users SHALL create new expenses through a dialog component instead of a dedicated page.

#### Scenario: Open expense dialog from budget dashboard
- **WHEN** user clicks "Add Expense" button on budget dashboard
- **THEN** system opens expense creation dialog overlay

#### Scenario: Dialog shows expense form
- **WHEN** expense creation dialog opens
- **THEN** dialog displays expense form with all required fields
- **THEN** dialog shows "Add Expense" title

#### Scenario: Close dialog without saving
- **WHEN** user clicks outside dialog or presses Escape key
- **THEN** system closes dialog without creating expense
- **THEN** form data is discarded

#### Scenario: Create expense and auto-close
- **WHEN** user submits valid expense form in dialog
- **THEN** system creates expense via API
- **THEN** system automatically closes dialog on success
- **THEN** system shows success toast notification

### Requirement: Expense dialog proper UX
The expense dialog SHALL follow best practices for modal UX patterns.

#### Scenario: Dialog traps focus
- **WHEN** expense dialog is open
- **THEN** keyboard focus stays within dialog
- **THEN** Tab key cycles through form fields within dialog

#### Scenario: Escape key closes dialog
- **WHEN** expense dialog is open
- **WHEN** user presses Escape key
- **THEN** system closes dialog without saving

#### Scenario: Click outside closes dialog
- **WHEN** expense dialog is open
- **WHEN** user clicks on backdrop overlay
- **THEN** system closes dialog without saving

#### Scenario: Form validation before close
- **WHEN** user has entered partial data in expense form
- **WHEN** user attempts to close dialog
- **THEN** system allows closing without confirmation (data is not saved)

### Requirement: Expense dialog accessibility
The expense dialog SHALL meet WCAG accessibility standards.

#### Scenario: Screen reader announces dialog
- **WHEN** expense dialog opens
- **THEN** screen reader announces dialog title and role
- **THEN** focus moves to first form field

#### Scenario: Keyboard navigation works
- **WHEN** expense dialog is open
- **THEN** user can navigate all form fields with keyboard only
- **THEN** Enter key submits form when in text fields
- **THEN** Space key activates buttons when focused

#### Scenario: Close button is keyboard accessible
- **WHEN** expense dialog is open
- **THEN** user can Tab to close button
- **THEN** user can activate close button with Enter or Space key

### Requirement: Deep linking to expense dialog
Users SHALL be able to navigate directly to expense creation via URL.

#### Scenario: Direct URL navigation opens dialog
- **WHEN** user navigates to /dashboard/budget/expenses/new
- **THEN** system renders budget dashboard with expense dialog open

#### Scenario: Page refresh maintains dialog state
- **WHEN** user opens expense dialog via button click
- **WHEN** user refreshes page
- **THEN** dialog closes and shows normal budget dashboard

#### Scenario: Browser back button closes dialog
- **WHEN** user opens expense dialog (URL updates to /expenses/new)
- **WHEN** user clicks browser back button
- **THEN** dialog closes and URL returns to /dashboard/budget

### Requirement: Expense dialog loading states
The expense dialog SHALL provide clear feedback during async operations.

#### Scenario: Submit button disabled during creation
- **WHEN** user submits expense form
- **THEN** submit button becomes disabled
- **THEN** button text changes to "Creating..." or shows spinner

#### Scenario: Error handling in dialog
- **WHEN** expense creation API call fails
- **THEN** system keeps dialog open
- **THEN** system displays error message in dialog
- **THEN** user can retry submission or close dialog

#### Scenario: Success feedback
- **WHEN** expense is created successfully
- **THEN** system shows success toast notification
- **THEN** system closes dialog automatically
- **THEN** system refreshes expense list in background

### Requirement: Consistent dialog pattern with income
The expense creation dialog SHALL follow the same UX patterns as the existing income dialog.

#### Scenario: Dialog layout matches income dialog
- **WHEN** expense dialog opens
- **THEN** dialog size, padding, and layout match income dialog
- **THEN** form field styles are consistent with income form

#### Scenario: Action buttons positioned consistently
- **WHEN** expense dialog displays form
- **THEN** Cancel and Submit buttons are in same position as income dialog
- **THEN** Button labels follow same naming convention

#### Scenario: Dialog animation matches income dialog
- **WHEN** expense dialog opens or closes
- **THEN** animation timing and easing match income dialog behavior
