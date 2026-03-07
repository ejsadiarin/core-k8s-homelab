## 1. Backend - API Changes

- [x] 1.1 Add start_date and end_date query parameters to GET /api/budget/analytics/savings-rate endpoint
- [x] 1.2 Add start_date and end_date query parameters to GET /api/budget/analytics/spending-velocity endpoint
- [x] 1.3 Add start_date and end_date query parameters to GET /api/budget/analytics/spending-by-day endpoint
- [x] 1.4 Add start_date and end_date query parameters to GET /api/budget/analytics/total-money endpoint
- [x] 1.5 Add date validation logic for invalid format and reversed date ranges

## 2. Backend - Query Logic

- [x] 2.1 Create date range utility function to parse and validate start_date/end_date parameters
- [x] 2.2 Update savings rate query to conditionally use custom date range or tracking_start_date
- [x] 2.3 Update spending velocity query to conditionally use custom date range
- [x] 2.4 Update spending by day query to use custom date range
- [x] 2.5 Update total money query to use custom date range

## 3. Backend - Response Metadata

- [x] 3.1 Add date range metadata to analytics responses indicating source (custom vs tracking_start_date)
- [x] 3.2 Include actual date range used in calculation in response metadata

## 4. Frontend - Date Picker Integration

- [x] 4.1 Add date range picker component to analytics dashboard
- [x] 4.2 Connect date picker to analytics API calls
- [x] 4.3 Display current date range in analytics UI

## 5. Testing

- [x] 5.1 Write unit tests for date range validation
- [x] 5.2 Write integration tests for each analytics endpoint with custom date range
- [x] 5.3 Test edge cases: partial date range, invalid dates, reversed dates
