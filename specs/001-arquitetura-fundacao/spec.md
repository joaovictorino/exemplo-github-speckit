# Feature Specification: Foundation Architecture Structure

**Feature Branch**: `001-arquitetura-fundacao`

**Created**: 2026-08-11

**Status**: Draft

**Input**: User description: "crie a estrutura de fundação de arquitetura deste projeto"

## Overview

Establish the foundational technical architecture for a citizen request tracking application. This specification creates an executable, testable, and scalable baseline upon which subsequent features will be built incrementally. The foundation includes backend API, frontend interface, database layer, testing infrastructure, and complete Docker-based deployment.

## User Scenarios & Testing

### User Story 1 - Backend Development Environment Setup (Priority: P1)

A developer needs to set up a fully functional ASP.NET Core backend development environment with database connectivity, migrations, and API endpoints ready for integration testing.

**Why this priority**: This is the foundation layer that enables all subsequent features. Without a working backend with proper database connectivity and API structure, no other user-facing features can be developed or tested.

**Independent Test**: Backend can be started independently, API responds to health check endpoint, migrations execute successfully against MySQL, and developer can run integration tests without additional setup.

**Acceptance Scenarios**:

1. **Given** a developer clones the repository with no prior dependencies installed, **When** they navigate to the backend directory and review the Dockerfile and project structure, **Then** they understand how the ASP.NET Core API is organized (Api/Application/Domain/Infrastructure layers).

2. **Given** the backend is configured, **When** a developer attempts to connect to MySQL using Entity Framework Core, **Then** the connection succeeds and database operations work correctly.

3. **Given** a clean database, **When** migrations are executed via the migration container, **Then** all required tables and schema are created automatically.

4. **Given** the backend is running, **When** a developer sends a GET request to `/api/health`, **Then** the API responds with HTTP 200 OK.

---

### User Story 2 - Data Persistence Foundation (Priority: P1)

A developer needs a working data model and persistence layer that supports the `Solicitacao` (Request) entity with proper Entity Framework Core mapping and MySQL storage.

**Why this priority**: Data persistence is essential infrastructure that blocks development of any feature requiring data storage. This must be established early.

**Independent Test**: The `Solicitacao` entity can be created, retrieved, updated in the database; initial seed data loads correctly; isolation between users' data is enforced.

**Acceptance Scenarios**:

1. **Given** the application is deployed, **When** a database query retrieves all requests, **Then** the system returns only requests belonging to the current authenticated user.

2. **Given** initial seed data exists, **When** the application starts, **Then** two requests exist for `cidadao-001` (status: EmAnalise, Aprovada) and one request exists for `cidadao-002` (status: Recebida).

3. **Given** a request exists in the database, **When** the application retrieves it via repository, **Then** all properties (Id, Numero, CidadaoId, Status, DataCriacao, DataUltimaAtualizacao) are correctly populated.

---

### User Story 3 - API Contract & Error Handling (Priority: P1)

A frontend developer needs clear, documented API contracts and standardized error responses to build the frontend application confidently.

**Why this priority**: Frontend development depends entirely on the API contract. Clear documentation and consistent error handling reduce integration friction significantly.

**Independent Test**: OpenAPI documentation is generated and accessible; error responses follow a consistent format; invalid requests return appropriate HTTP status codes with clear messages.

**Acceptance Scenarios**:

1. **Given** the backend API is running, **When** a developer accesses the OpenAPI documentation endpoint, **Then** complete API specifications are available in Swagger format.

2. **Given** an invalid request is sent to the API, **When** the request fails validation, **Then** a standardized error response with `type`, `title`, and `status` fields is returned (never raw exception details).

3. **Given** an unexpected server error occurs, **When** the API handles it, **Then** a generic error response is returned without exposing internal system details.

---

### User Story 4 - Testing Infrastructure (Priority: P1)

A developer needs comprehensive testing infrastructure (unit, integration, and HTTP testing) that can execute without manual environment setup.

**Why this priority**: Testing infrastructure ensures code quality and prevents regressions. This must be in place from day one to establish testing discipline.

**Independent Test**: Unit tests execute against business logic in isolation; integration tests execute against a real MySQL instance created automatically for tests; HTTP tests exercise the full API request/response cycle.

**Acceptance Scenarios**:

1. **Given** the test suite is executed, **When** unit tests run, **Then** they execute business logic without requiring HTTP or database dependencies.

2. **Given** integration tests are triggered, **When** they start, **Then** an isolated MySQL database is automatically created, initialized with migrations, and cleaned up after tests complete.

3. **Given** API integration tests execute, **When** an HTTP request is sent to a running backend instance, **Then** the request flows through the complete stack (Controller → Service → Repository → Database) and the response is validated.

---

### User Story 5 - Frontend Development Environment (Priority: P1)

A frontend developer needs a React application with TypeScript support, component structure, and initial infrastructure for testing and API integration.

**Why this priority**: Frontend is the user-facing layer that demonstrates the entire system works end-to-end.

**Independent Test**: Frontend can be started independently; initial page renders without errors; component testing infrastructure is in place; API calls can be mocked or real.

**Acceptance Scenarios**:

1. **Given** the frontend is started, **When** the developer navigates to the application, **Then** an initial landing page is displayed successfully.

2. **Given** the frontend application structure is examined, **When** the developer reviews the source code, **Then** components are organized logically (pages/, components/, services/, types/) and testing infrastructure (test files, mocks) is present.

3. **Given** a component test is written, **When** it is executed, **Then** the component renders and user interactions can be validated.

---

### User Story 6 - Full-Stack Deployment (Priority: P1)

A developer or ops engineer needs to deploy the entire application stack (backend, frontend, migration, MySQL) with a single command in any environment.

**Why this priority**: Docker Compose deployment is the mechanism that enables local development, CI/CD integration, and production readiness. Without this, environmental inconsistencies create friction.

**Independent Test**: `docker compose up` command starts all services; all services become healthy and responsive; the complete application is accessible end-to-end.

**Acceptance Scenarios**:

1. **Given** Docker and Docker Compose are installed, **When** `docker compose up` is executed from the repository root, **Then** all containers start without errors in the correct order (database, migration, backend, frontend).

2. **Given** the application stack is deployed via Docker Compose, **When** a curl request is sent to `http://localhost/api/health`, **Then** the backend responds with HTTP 200.

3. **Given** the application is running in Docker Compose, **When** a browser navigates to `http://localhost`, **Then** the frontend loads and displays the initial page.

---

### User Story 7 - Current User Context (Priority: P2)

The application needs a mechanism to identify and propagate the current authenticated user throughout the system without coupling business logic to authentication implementation details.

**Why this priority**: Many features require user context, but the actual authentication mechanism should be pluggable. This abstraction enables future auth implementation without refactoring business logic.

**Independent Test**: A use case can request the current user ID; the user ID is available in any application service; different authentication implementations can be swapped without changing use cases.

**Acceptance Scenarios**:

1. **Given** a use case executes in the development environment, **When** it requests the current user, **Then** it receives a known user ID (e.g., "cidadao-001") from the development implementation.

2. **Given** multiple authentication implementations exist (development, OAuth, SAML), **When** each is deployed, **Then** use cases remain unchanged and work correctly with each implementation.

---

### Edge Cases

- What happens when the MySQL container fails to start? → Docker Compose should fail with a clear error; migration should not begin.
- How does the system handle a database schema mismatch? → Migrations should detect and report schema issues clearly.
- What happens when the API receives a malformed JSON request? → A validation error response should be returned, never a raw exception.
- How are concurrent requests from multiple users handled? → Requests are isolated; each user sees only their own data via repository filtering.

## Requirements

### Functional Requirements

- **FR-001**: Backend MUST be deployable as an ASP.NET Core Web API in a Docker container
- **FR-002**: Backend MUST connect to MySQL via Entity Framework Core with configurable connection strings
- **FR-003**: Backend MUST support database migrations that create required schema automatically
- **FR-004**: Backend MUST expose a `/api/health` endpoint that returns HTTP 200 OK
- **FR-005**: Backend MUST provide OpenAPI documentation for all endpoints via Swagger
- **FR-006**: Backend MUST implement centralized error handling that returns standardized error responses without exposing internal details
- **FR-007**: Backend MUST persist `Solicitacao` entities with properties: Id, Numero, CidadaoId, Status, DataCriacao, DataUltimaAtualizacao
- **FR-008**: Backend MUST enforce data isolation so users can only access their own requests
- **FR-009**: Backend MUST provide an abstraction for current user identification (not coupled to specific auth mechanism)
- **FR-010**: Backend MUST support unit testing of business logic without HTTP or database dependencies
- **FR-011**: Backend MUST support integration testing against a real MySQL database that is automatically provisioned
- **FR-012**: Backend MUST support HTTP API testing that exercises the complete request/response cycle
- **FR-013**: Frontend MUST be a React application with TypeScript support
- **FR-014**: Frontend MUST organize code into logical directories (pages, components, services, types)
- **FR-015**: Frontend MUST provide infrastructure for component testing and user interaction validation
- **FR-016**: Frontend MUST be deployable in an nginx Docker container
- **FR-017**: Frontend MUST be able to make HTTP calls to the backend API
- **FR-018**: Application MUST be fully deployable via `docker compose up` including backend, frontend, migration, and MySQL
- **FR-019**: Application MUST initialize with seed data for testing (2 requests for cidadao-001, 1 request for cidadao-002)
- **FR-020**: Application architecture MUST separate concerns into Application, Domain, and Infrastructure layers to enable testability and evolution

### Key Entities

- **Solicitacao (Request)**: Represents a citizen's request to the organization
  - `Id`: Unique identifier (GUID)
  - `Numero`: Sequential number for display (e.g., "2026-000001")
  - `CidadaoId`: Reference to the citizen who submitted the request
  - `Status`: Current state (Recebida, EmAnalise, Aprovada, Rejeitada)
  - `DataCriacao`: Timestamp when request was created
  - `DataUltimaAtualizacao`: Timestamp of last modification

- **CurrentUser**: Abstraction for the authenticated user
  - `Id`: User identifier (e.g., "cidadao-001")
  - Implementation details (JWT, OAuth, session) are hidden from business logic

## Success Criteria

### Measurable Outcomes

- **SC-001**: Backend API responds to health check within 100ms of startup
- **SC-002**: All backend unit tests execute in under 10 seconds total
- **SC-003**: All backend integration tests execute in under 30 seconds total
- **SC-004**: Complete Docker Compose deployment initializes all services within 60 seconds
- **SC-005**: Frontend application loads and renders initial page within 2 seconds in Docker environment
- **SC-006**: Database migrations execute successfully and complete schema setup within 5 seconds
- **SC-007**: Seed data loads correctly so at least one request is accessible for each test user
- **SC-008**: OpenAPI documentation is generated and includes all implemented endpoints
- **SC-009**: 100% of API error paths return standardized error responses (no raw exceptions)
- **SC-010**: Data isolation is enforced: user querying database can only access their own requests

## Assumptions

- Docker and Docker Compose are available in development and deployment environments
- MySQL 8.0+ is suitable for this application (no exotic database features required)
- Entity Framework Core can be used for data access without custom ORM requirements
- Development authentication can use a hardcoded user ID; OAuth/OIDC will be added in future specs
- Initial user stories do not require user registration; users are known/pre-configured
- Frontend can make unauthenticated calls to backend endpoints for MVP demonstration
- Test databases can be created and destroyed on-demand during test runs
- No data retention, compliance, or regulatory requirements are in scope for this foundation
- Application will evolve incrementally; extensibility is more important than comprehensive feature coverage
- Performance targets are for single-instance deployment; distributed scaling is out of scope for this foundation
