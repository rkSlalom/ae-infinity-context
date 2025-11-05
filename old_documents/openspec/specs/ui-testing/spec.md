# ui-testing Specification

## Purpose
TBD - created by archiving change add-ui-testing-suite. Update Purpose after archive.
## Requirements
### Requirement: Test Framework Configuration

The UI SHALL provide a comprehensive testing framework using Vitest, React Testing Library, and happy-dom for fast, reliable unit, component, and integration testing.

#### Scenario: Running all tests
- **WHEN** developer runs `npm test`
- **THEN** all test files matching `*.test.ts` and `*.test.tsx` patterns are executed
- **AND** results are displayed with pass/fail status for each test suite

#### Scenario: Watch mode for TDD
- **WHEN** developer runs `npm run test:watch`
- **THEN** Vitest starts in watch mode monitoring file changes
- **AND** re-runs affected tests automatically when source or test files change

#### Scenario: Coverage reporting
- **WHEN** developer runs `npm run test:coverage`
- **THEN** test coverage metrics are generated for all source files
- **AND** coverage report shows line, branch, function, and statement coverage percentages
- **AND** HTML coverage report is generated in `coverage/` directory

### Requirement: Unit Testing for Utilities

The test suite SHALL include unit tests for all utility functions with at least 90% code coverage.

#### Scenario: Testing date formatters
- **GIVEN** a utility function that formats dates
- **WHEN** unit tests are executed
- **THEN** tests verify correct formatting for valid dates
- **AND** tests verify error handling for invalid dates
- **AND** tests cover edge cases (null, undefined, malformed dates)

#### Scenario: Testing permission helpers
- **GIVEN** utility functions that check user permissions based on roles
- **WHEN** unit tests are executed
- **THEN** tests verify correct permission checks for each role (Owner, Editor, Editor-Limited, Viewer)
- **AND** tests verify permission denial for insufficient roles

#### Scenario: Testing API client wrapper
- **GIVEN** an API client utility for HTTP requests
- **WHEN** unit tests are executed with mocked fetch
- **THEN** tests verify correct request formation (URL, headers, body)
- **AND** tests verify error handling for network failures
- **AND** tests verify response parsing and transformation

### Requirement: Unit Testing for Custom Hooks

The test suite SHALL include unit tests for all custom React hooks with at least 80% code coverage.

#### Scenario: Testing navigation hook
- **GIVEN** a custom hook that provides navigation helpers
- **WHEN** hook tests are executed using renderHook
- **THEN** tests verify navigation function returns correct paths
- **AND** tests verify state updates on navigation

#### Scenario: Testing list items hook
- **GIVEN** a custom hook managing list item state
- **WHEN** hook tests are executed
- **THEN** tests verify add, update, delete operations modify state correctly
- **AND** tests verify optimistic updates before server confirmation

### Requirement: Component Testing

The test suite SHALL include component tests for UI components using React Testing Library with at least 60% code coverage.

#### Scenario: Testing loading spinner
- **GIVEN** a LoadingSpinner component
- **WHEN** component test renders the spinner
- **THEN** test verifies spinner element is in the document
- **AND** test verifies accessibility attributes are present

#### Scenario: Testing header component
- **GIVEN** a Header component displaying user info and navigation
- **WHEN** component test renders with authenticated user
- **THEN** test verifies user display name appears
- **AND** test verifies navigation links are rendered
- **AND** test verifies logout button click triggers callback

#### Scenario: Testing login form
- **GIVEN** a Login form component
- **WHEN** component test renders the form
- **THEN** test verifies email and password fields are present
- **AND** test verifies form validation (required fields)
- **AND** test verifies form submission with valid credentials calls auth service
- **AND** test verifies error message displays on login failure

### Requirement: Integration Testing

The test suite SHALL include integration tests for critical user flows testing multiple components together.

#### Scenario: Complete login flow
- **GIVEN** a user on the login page
- **WHEN** integration test simulates user typing credentials and submitting form
- **THEN** test verifies authService.login is called with correct parameters
- **AND** test verifies AuthContext state updates with user data
- **AND** test verifies navigation to dashboard occurs on success

#### Scenario: List creation flow
- **GIVEN** an authenticated user on the lists dashboard
- **WHEN** integration test simulates clicking "Create List" button
- **THEN** test verifies navigation to create list page
- **AND** test simulates filling form and submitting
- **AND** test verifies listsService.createList is called
- **AND** test verifies redirect to new list detail page

#### Scenario: Item management flow
- **GIVEN** a user viewing a list detail page
- **WHEN** integration test simulates adding a new item
- **THEN** test verifies item appears in the list immediately (optimistic update)
- **AND** test simulates toggling item purchased status
- **AND** test verifies visual update (strikethrough, checked)
- **AND** test simulates deleting item
- **AND** test verifies item removal from UI

### Requirement: Test Utilities and Helpers

The test suite SHALL provide reusable test utilities to simplify test authoring and reduce boilerplate.

#### Scenario: Render with providers
- **GIVEN** a component that requires AuthContext and Router
- **WHEN** test uses renderWithProviders helper
- **THEN** component renders with all necessary providers wrapped
- **AND** test can specify initial route for MemoryRouter
- **AND** test can provide custom auth state

#### Scenario: Mock factories
- **GIVEN** tests that need mock data (users, lists, items)
- **WHEN** test uses mock factories (mockUser, mockList, mockItem)
- **THEN** factory generates valid mock data with sensible defaults
- **AND** factory accepts overrides for specific properties
- **AND** mock data conforms to TypeScript types

#### Scenario: API client mocking
- **GIVEN** tests that depend on API calls
- **WHEN** test uses mockApiClient
- **THEN** all HTTP methods (get, post, put, delete) are mocked with vi.fn()
- **AND** mocks are automatically cleared between tests
- **AND** test can specify return values or errors per test case

### Requirement: Service Testing

The test suite SHALL include unit tests for all service modules (authService, listsService, itemsService) with at least 80% coverage.

#### Scenario: Testing auth service login
- **GIVEN** authService.login function
- **WHEN** unit test calls login with credentials
- **THEN** test verifies correct API endpoint is called (/api/v1/auth/login)
- **AND** test verifies JWT token is extracted from response
- **AND** test verifies token is stored in localStorage
- **AND** test verifies user object is returned

#### Scenario: Testing lists service CRUD
- **GIVEN** listsService CRUD methods
- **WHEN** unit tests call each method with mocked apiClient
- **THEN** test verifies createList calls POST /api/v1/lists
- **AND** test verifies getList calls GET /api/v1/lists/:id
- **AND** test verifies updateList calls PUT /api/v1/lists/:id
- **AND** test verifies deleteList calls DELETE /api/v1/lists/:id

#### Scenario: Testing error handling in services
- **GIVEN** service methods that make API calls
- **WHEN** API returns error response (4xx or 5xx)
- **THEN** test verifies service throws or returns error object
- **AND** test verifies error message is user-friendly

### Requirement: Context Testing

The test suite SHALL include tests for React Contexts to verify state management logic.

#### Scenario: Testing AuthContext provider
- **GIVEN** AuthContext provider with login/logout methods
- **WHEN** tests render children components consuming the context
- **THEN** test verifies initial state (no user, not authenticated)
- **AND** test verifies login updates state with user data
- **AND** test verifies logout clears user state
- **AND** test verifies token persistence in localStorage

### Requirement: Coverage Thresholds

The test suite SHALL enforce minimum coverage thresholds to prevent regression in test quality.

#### Scenario: Coverage threshold enforcement
- **GIVEN** Vitest coverage configuration with thresholds
- **WHEN** tests run with coverage reporting
- **THEN** build fails if overall coverage drops below 70%
- **AND** build fails if utilities coverage drops below 90%
- **AND** coverage report highlights uncovered lines

### Requirement: Continuous Integration Support

The test suite SHALL support CI/CD pipelines with appropriate reporters and fail-fast behavior.

#### Scenario: CI test execution
- **WHEN** tests run in CI environment with `npm run test:ci`
- **THEN** tests execute without watch mode (run once and exit)
- **AND** JUnit XML report is generated for CI dashboard integration
- **AND** coverage report is generated in machine-readable format
- **AND** process exits with non-zero code if any test fails

