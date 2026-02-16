## ADDED Requirements

### Requirement: System identifies top merchants
The system SHALL aggregate spending by merchant/description patterns to identify top spending locations.

#### Scenario: Top merchants by amount
- **WHEN** user views merchant analysis
- **THEN** system shows top 10 merchants by total spending amount

#### Scenario: Merchant transaction count
- **WHEN** user views merchant details
- **THEN** system shows number of transactions per merchant

#### Scenario: Merchant average transaction
- **WHEN** user views merchant breakdown
- **THEN** system shows average transaction amount per merchant

### Requirement: System detects subscription patterns
The system SHALL identify potential subscriptions based on recurring merchant patterns.

#### Scenario: Detect monthly subscriptions
- **GIVEN** user has expenses at "Netflix" every month for 3+ months
- **WHEN** system runs subscription detection
- **THEN** "Netflix" is flagged as potential subscription

#### Scenario: Detect weekly subscriptions
- **GIVEN** user has expenses at "Gym" every 7 days
- **WHEN** system runs subscription detection
- **THEN** "Gym" is flagged as potential subscription

#### Scenario: Subscription total calculation
- **GIVEN** user has 5 detected subscriptions
- **WHEN** user views subscription summary
- **THEN** system shows monthly total for all subscriptions

### Requirement: User can mark expense as subscription
The system SHALL allow users to manually mark/unmark expenses as subscriptions.

#### Scenario: Mark as subscription
- **WHEN** user marks an expense as subscription
- **THEN** system stores flag and includes in subscription tracking

#### Scenario: Unmark subscription
- **GIVEN** expense is marked as subscription
- **WHEN** user removes subscription flag
- **THEN** system updates and excludes from subscription totals

### Requirement: System provides subscription management dashboard
The system SHALL provide a dedicated view for managing subscriptions.

#### Scenario: View all subscriptions
- **WHEN** user navigates to subscriptions page
- **THEN** system shows list of all subscriptions with monthly costs

#### Scenario: Upcoming subscription payments
- **WHEN** user views subscription dashboard
- **THEN** system shows next expected payment date for each subscription

#### Scenario: Cancelled subscription tracking
- **GIVEN** user marks subscription as cancelled
- **WHEN** viewing subscription history
- **THEN** system shows cancelled date and excludes from future totals
