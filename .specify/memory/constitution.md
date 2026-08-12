<!-- 
===== SYNC IMPACT REPORT =====
Version: 1.0.0 (Initial Ratification)
Date: 2026-08-11

This constitution captures the foundational architecture and development principles for the 
Solicitações Application (exemple-github-speckit), derived from /docs/001-arquitetura.md.

Initial Principles Documented: 11 architectural principles covering separation of concerns,
testing strategy, technology stack, project structure, and development discipline.

Sections Added:
- Core Principles (11 principles: business/infrastructure separation, testing, contracts, etc.)
- Technology Stack (Backend: ASP.NET Core, C#, EF Core; Frontend: React, TypeScript; DevOps: Docker)
- Project Structure (Backend: Api/Application/Domain/Infrastructure; Frontend: components/pages/services)
- Code Conventions (Layered architecture, naming, error handling)
- Test Strategy (Unit tests, MySQL integration tests, HTTP API tests, frontend tests)
- Commit Conventions (Semantic versioning, clear messages)

Templates Updated:
✅ plan-template.md - Aligned with layered architecture principles
✅ spec-template.md - User story and requirement clarity
✅ tasks-template.md - Task organization by principle and layer

Status: Ready for compliance verification in all specifications and implementations.
================================ -->

# Solicitações Application — Constitution

A foundational governance document for an ASP.NET Core + React application enabling citizens to track 
service requests. Establishes explicit architectural principles, technology choices, development discipline, 
and project structure to ensure testability, maintainability, and evolutionary capacity.

**Baseline Specification**: `/docs/001-arquitetura.md`

---

## Core Principles

### I. Separation of Business Logic from Infrastructure

**Non-negotiable Rule**: Domain logic MUST NOT depend on infrastructure details (databases, frameworks, HTTP).

**Rationale**: Enables testing of business rules without initializing frameworks or databases. Improves 
code clarity, reduces coupling, and facilitates future infrastructure changes (e.g., database migration).

**Application**:
- Domain entities live in `Domain/` layer with zero infrastructure dependencies
- Business rules enforced via domain services or entity methods
- Controllers and API routes MUST NOT contain decision logic
- Repository interfaces defined in `Domain/`; implementations in `Infrastructure/`

---

### II. No Business Logic in Controllers

**Non-negotiable Rule**: Controllers MUST act as adapters; they accept HTTP requests, delegate to Application 
services, and translate responses to HTTP.

**Rationale**: Controllers are implementation details; moving business rules there couples them to HTTP contracts 
and makes them untestable outside of HTTP context.

**Application**:
- Controllers call Application services (e.g., `ICreateSolicitacaoService`, `IListSolicitacoesService`)
- Controllers format responses and error handling (HTTP status codes, JSON)
- Controllers perform minimal validation (request shape only)
- Application layer handles business validation

---

### III. Testability Without Framework Initialization

**Non-negotiable Rule**: All business rules MUST be testable via unit tests without starting ASP.NET Core, 
initializing EF Core, or spinning up MySQL.

**Rationale**: Unit tests are the first feedback loop; they must run instantly (< 1 second for most tests) 
and provide isolation for root cause analysis.

**Application**:
- Domain entities and services testable with plain C# objects
- Application services testable by mocking Repository interfaces
- No "integration test masquerading as unit test" with in-memory databases
- In-memory mocking acceptable only for Repository contracts, never for EF Core behavior

---

### IV. MySQL Real Integration Tests

**Non-negotiable Rule**: Integration tests exercising persistence MUST use real MySQL instances (not in-memory), 
isolated per test run, with automatic schema setup via migrations.

**Rationale**: In-memory databases (e.g., SQLite) do not exercise MySQL-specific behavior (transactions, 
concurrency, constraints, data types). Real MySQL tests catch bugs that in-memory tests would miss.

**Application**:
- Test infrastructure spins up isolated MySQL container or temporary instance per test session
- Migrations execute automatically before test suite runs
- Test database tables created fresh, populated with seed data per test class
- Repository implementation tested directly against real MySQL (no mock repositories in integration tests)
- Tests must NOT require manual database setup or pre-existing schemas

---

### V. Frontend Decoupled from Backend Implementation

**Non-negotiable Rule**: React frontend MUST depend only on documented HTTP contracts (OpenAPI), never on 
internal backend structure, class names, or implementation details.

**Rationale**: Enables independent frontend and backend evolution; allows backend refactoring without frontend changes.

**Application**:
- OpenAPI/Swagger contract is the contract; frontend generated from it or strictly adheres to documented endpoints
- Backend changes internal architecture (e.g., Domain → Application → Repository) without breaking frontend
- Frontend service layer communicates only via HTTP endpoints; no internal service imports
- DTOs in responses intentionally designed for client needs, not direct entity serialization

---

### VI. Explicit HTTP Contracts (OpenAPI/Swagger)

**Non-negotiable Rule**: Every API endpoint MUST be documented in OpenAPI; documentation generated from code 
annotations, never handwritten separately.

**Rationale**: Self-documenting API reduces integration friction; OpenAPI enables client generation and 
contract testing.

**Application**:
- ASP.NET Core configured with Swagger/OpenAPI middleware
- All endpoints annotated with `[ApiController]`, `[HttpGet]`, `[Produces]`, `[ProducesResponseType]` attributes
- Response types and status codes explicitly declared
- OpenAPI available at `/swagger` (development) and generated in docs
- Clients trust OpenAPI as source of truth

---

### VII. Standardized Error Handling

**Non-negotiable Rule**: All errors (validation, business, infrastructure) MUST be converted to standardized 
HTTP responses; application exceptions MUST NOT leak to client.

**Rationale**: Prevents accidental exposure of internal details (stack traces, database queries); provides 
consistent client experience.

**Application**:
- Centralized exception handler middleware (or controller filter) catches all unhandled exceptions
- Domain and Application layers define custom exception types (e.g., `SolicitacaoNaoEncontradaException`)
- Exception middleware maps each exception type to appropriate HTTP response (4xx vs 5xx)
- Standardized response shape: `{ type: string, title: string, status: int, details: object? }`
- Production: generic error messages; development: additional context via headers or debug endpoints

---

### VIII. Incremental Evolution Without Structural Reorganization

**Non-negotiable Rule**: Architecture MUST permit new features (specs) to be added without dismantling 
existing layers or reshaping the codebase.

**Rationale**: Enables teams to work in parallel; reduces friction as application grows.

**Application**:
- New domain entities added to `Domain/`, new repositories to `Infrastructure/`, new services to `Application/`
- No arbitrary limits on project complexity (e.g., "max 10 entities per project"); layering is structural, not capacity-based
- Layered architecture scales horizontally (add more entities, services, repositories) not vertically (add new layers)
- Refactoring within a layer permitted; cross-layer refactoring requires full specification review

---

### IX. Avoid Premature Abstraction

**Non-negotiable Rule**: Abstractions (interfaces, base classes, patterns) MUST serve a concrete, current 
need; never created "in case we might need it."

**Rationale**: Premature abstraction increases complexity without benefit; often wrong and becomes tech debt.

**Application**:
- Repository pattern introduced because EF Core is the concrete problem (testability, persistence)
- ICurrentUser abstraction introduced because user context is used across multiple layers
- Generic base repositories avoided; concrete repositories for each entity or aggregate
- Dependency injection accepted because multiple layers need to coordinate; ad-hoc service location rejected
- Refactoring to abstraction only when > 2 implementations exist or real feature requires flexibility

---

### X. Simplicity Over Framework Features and Patterns

**Non-negotiable Rule**: Favor boring, explicit code over clever framework features or design patterns; 
when in doubt, choose the solution that requires fewer library dependencies.

**Rationale**: Reduces learning curve, improves debuggability, minimizes magic; new team members understand 
code without studying framework internals.

**Application**:
- Direct repository calls in Application services over generic repositories with LINQ specifications
- Entity Framework Core queries explicit (not auto-generated specs) with comments explaining business intent
- No "too clever" LINQ chains; multi-line queries preferred for clarity
- Custom middleware for cross-cutting concerns over third-party libraries when core needs are simple
- No double-wrapping (e.g., Repository wrapping Repository, Service wrapping Service)
- Async/await used explicitly and documented (not hidden in base classes)

---

### XI. Docker-Composable Local Environment

**Non-negotiable Rule**: Entire application (backend, frontend, database, migrations) MUST be startable 
locally with `docker compose up` from repository root, requiring zero manual configuration or pre-installed tools.

**Rationale**: Ensures consistent development, CI/CD, and onboarding experience; eliminates "works on my machine" 
issues.

**Application**:
- `docker-compose.yml` at repository root orchestrates backend, frontend, migration, and MySQL services
- Each service (backend, frontend, migration) has its own `Dockerfile`
- No host dependencies required (no local .NET SDK, Node.js, MySQL installation needed)
- Environment variables passed via `.env` file (templated or generated)
- All migrations execute automatically on startup (via dedicated migration container)
- Health checks prevent service interdependencies from causing race conditions
- Seed data loaded automatically for development environment

---

## Technology Stack

### Backend

- **Runtime/Language**: ASP.NET Core (C#)
- **API Framework**: ASP.NET Core Web API
- **Data Access**: Entity Framework Core + MySQL
- **Database**: MySQL (relational)
- **API Documentation**: OpenAPI (Swagger)
- **HTTP Server**: Kestrel (embedded in ASP.NET Core)

### Frontend

- **Framework**: React
- **Language**: TypeScript
- **Component Model**: Functional components (React 16.8+)
- **HTTP Client**: Browser fetch API or Axios
- **Styling**: (To be defined per feature spec)
- **Build Tool**: (To be defined per feature spec)
- **HTTP Server**: Nginx (reverse proxy in Docker)

### DevOps & Testing

- **Containerization**: Docker + Docker Compose
- **Databases (Testing)**: MySQL (real instance, isolated per test run)
- **Backend Tests**: 
  - Unit: MSTest, xUnit, or NUnit
  - Integration: Real MySQL with automatic schema setup
  - HTTP: HttpClientFactory for API endpoint testing
- **Frontend Tests**:
  - Component: React Testing Library or Jest
  - Integration: Real API calls where needed
  - User interactions: Simulated via test utilities

---

## Project Structure

### Backend

```
backend/
├── src/
│   ├── Api/                          # HTTP layer (controllers, routing, middleware)
│   │   ├── Controllers/              # ASP.NET Core controllers
│   │   ├── Middleware/               # Custom middleware (error handling, logging)
│   │   └── Program.cs                # Startup, dependency injection, middleware pipeline
│   │
│   ├── Application/                  # Business orchestration (services, use cases)
│   │   ├── Services/                 # Application services (e.g., CreateSolicitacaoService)
│   │   ├── DTOs/                     # Data transfer objects (request/response contracts)
│   │   └── Interfaces/               # Service interfaces
│   │
│   ├── Domain/                       # Business entities and rules (zero framework dependencies)
│   │   ├── Entities/                 # Core entities (Solicitacao, etc.)
│   │   ├── ValueObjects/             # Immutable value objects (if needed)
│   │   ├── Exceptions/               # Domain-specific exceptions
│   │   ├── Interfaces/               # Repository contracts, abstractions defined here
│   │   └── Services/                 # Domain services (business rules)
│   │
│   └── Infrastructure/               # Technical implementation (databases, external services)
│       ├── Persistence/              # Entity Framework Core setup, DbContext, migrations
│       │   ├── Repositories/         # Repository implementations
│       │   └── Migrations/           # EF Core migrations
│       ├── Authentication/           # User context implementation (ICurrentUser)
│       └── Logging/                  # Logging and observability
│
├── tests/
│   ├── UnitTests/                    # Fast, isolated tests of domain logic
│   │   └── Domain/                   # Tests for entities, value objects, services
│   │
│   └── IntegrationTests/             # Tests against real MySQL and HTTP endpoints
│       ├── Persistence/              # Repository tests (real MySQL)
│       └── Api/                      # HTTP endpoint tests (real API)
│
└── Dockerfile
```

### Frontend

```
frontend/
├── src/
│   ├── components/                   # Reusable UI components
│   │   └── [feature]/               # Feature-specific components
│   │
│   ├── pages/                        # Page-level components (React Router routes)
│   │   └── [page]/                  # Page structure and page-specific layout
│   │
│   ├── services/                     # HTTP clients, API communication
│   │   └── api.ts                   # Centralized API service (calls backend)
│   │
│   ├── types/                        # TypeScript type definitions (aligned with OpenAPI)
│   │   └── api.ts                   # Generated or manually maintained OpenAPI types
│   │
│   └── App.tsx                       # Root component, routing
│
├── tests/                            # Component and integration tests
│   ├── components/                   # Component tests
│   └── integration/                  # User workflow tests
│
└── Dockerfile
```

### Shared

```
docker-compose.yml                     # Orchestration: backend, frontend, migration, MySQL
specs/                                 # Feature specifications (SPEC-001, SPEC-002, etc.)
.specify/                              # Specification metadata, templates, workflows
```

---

## Code Conventions

### Naming

- **Classes**: PascalCase (C# convention) — e.g., `CreateSolicitacaoService`, `SolicitacaoRepository`
- **Methods**: PascalCase — e.g., `GetSolicitacaoById()`, `CreateSolicitacao()`
- **Properties**: PascalCase — e.g., `Id`, `StatusSolicitacao`
- **Local Variables & Parameters**: camelCase — e.g., `solicitacaoId`, `isValid`
- **Constants**: UPPER_SNAKE_CASE — e.g., `DEFAULT_TIMEOUT`, `MAX_RETRIES`
- **Database Tables**: Plural, PascalCase — e.g., `Solicitacoes`, `Cidadaos`
- **Database Columns**: PascalCase (match C# properties) — e.g., `Id`, `StatusSolicitacao`, `DataCriacao`
- **API Endpoints**: kebab-case paths — e.g., `/api/solicitacoes`, `/api/cidadaos/{id}`
- **React Components**: PascalCase — e.g., `SolicitacaoList`, `StatusBadge`
- **React Hooks/Utilities**: camelCase starting with `use` — e.g., `useSolicitacoes()`, `useCurrentUser()`

### Async/Await

- All I/O operations (database, HTTP, file) MUST be async
- Use `async Task` or `async Task<T>` for all async methods
- Avoid `Result`, `Wait()` (can deadlock); use `await`
- All HTTP requests use async/await

### Error Handling

- Domain layer defines custom exceptions (e.g., `SolicitacaoNaoEncontradaException`)
- Application layer catches domain exceptions and translates to DTOs/errors
- Controllers rely on centralized exception middleware (no try-catch in controllers unless specific HTTP handling)
- Logging: Log at WARN level for expected business errors; ERROR for infrastructure failures

### Comments

- Document *why*, not *what*; code is self-documenting
- Complex LINQ or algorithm: add comment explaining business intent
- Rationale for non-obvious design decisions: add comment
- Mark temporary workarounds with `TODO:` or `HACK:` (searchable)

---

## Test Strategy

### Unit Tests (Domain & Application)

**Scope**: Business logic, domain services, application services (without HTTP or database)

**Approach**:
- Mock Repository interfaces; test Application services with mocks
- Direct instantiation of Domain entities; test invariants
- Test edge cases: null inputs, boundary values, state transitions
- Assert outcomes, not implementation details

**Tools**: MSTest, xUnit, or NUnit (project choice); Moq or NSubstitute for mocking

**Coverage Target**: Minimum 80% for business-critical logic

**Execution**: `dotnet test --project tests/UnitTests` (runs in milliseconds)

### Integration Tests (MySQL)

**Scope**: Repository implementations against real MySQL; migration execution; persistence invariants

**Approach**:
- Spin up isolated MySQL container per test session (via Docker or in-memory container provider)
- Apply migrations automatically
- Seed test data (fixtures) per test or test class
- Clean up after each test or test class (fresh schema)
- Test pessimistic scenarios: transaction rollback, constraint violations, concurrent access

**Tools**: xUnit, Docker.DotNet or Testcontainers for container orchestration

**Execution**: `dotnet test --project tests/IntegrationTests --filter "Category=Persistence"`

### HTTP API Tests

**Scope**: Full stack: HTTP request → Controller → Application → Repository → MySQL → Response

**Approach**:
- Use `WebApplicationFactory<Program>` or TestServer to host API in-process
- Make real HTTP calls (no direct method calls); test serialization
- Verify response status codes, headers, body schema
- Create fresh test database per test class
- Test error scenarios: 404, 400, 500, validation

**Tools**: xUnit, HttpClientFactory

**Execution**: `dotnet test --project tests/IntegrationTests --filter "Category=Api"`

### Frontend Tests

**Scope**: Component rendering, user interactions, API integration

**Approach**:
- Component tests: Render in isolation, simulate user actions, assert UI updates
- Integration tests: Test feature workflows (multiple components, API calls)
- Mock only external API calls (use interceptors or MSW)
- Test states: loading, error, success, empty

**Tools**: React Testing Library, Jest, React Query testing utilities

**Execution**: `npm test` (from frontend directory)

---

## Commit Conventions

### Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type** (required):
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code restructuring (no functional change)
- `test`: Test additions or modifications
- `docs`: Documentation updates
- `chore`: Build, dependencies, tooling, config
- `perf`: Performance improvements
- `style`: Formatting, missing semicolons (no logic change)

**Scope** (optional): Feature or component affected — e.g., `solicitacao`, `api`, `frontend`, `auth`

**Subject** (required): Imperative mood ("add", "fix", "update", not "added", "fixed", "updates")
- Lowercase first letter
- No period at end
- Max 50 characters

**Body** (optional): Detailed explanation — when to use, edge cases, alternatives considered

**Footer** (optional): References to issues, breaking changes — e.g., `Closes #123`, `BREAKING CHANGE: ...`

### Examples

```
feat(solicitacao): add status filtering for list endpoint

Users can now filter solicitacoes by status (recebida, em_analise, aprovada, rejeitada)
on the GET /api/solicitacoes endpoint. Supports multiple statuses via query params.

Closes #42
```

```
fix(api): handle null user context gracefully

Previously returned 500 if CurrentUser was null. Now returns 401 Unauthorized with
clear error message.
```

```
refactor(domain): rename SolicitacaoService to SolicitacaoDomainService

Clarifies that this service contains only domain logic, not application orchestration.
No functional change.
```

### Branching

- Feature branches: `feat/###-feature-name` (e.g., `feat/001-solicitacao-listing`)
- Bugfix branches: `fix/###-issue-name` (e.g., `fix/045-null-user-handling`)
- Refactor branches: `refactor/###-task-name`
- Branch name lowercase, hyphens, no underscores

---

## Governance

### Constitution Precedence

This constitution defines non-negotiable architectural principles for the Solicitações Application. 
All feature specifications, implementation plans, and code reviews MUST verify compliance with these 
principles before approval.

### Amendment Process

1. **Proposal**: Document the amendment (principle change, new principle, removal) in a GitHub Issue 
   tagged with `constitution-review`
2. **Justification**: Explain why the change is necessary and what problem it solves
3. **Impact Analysis**: Assess which existing features or specifications would be affected
4. **Approval**: Review by technical leads; merge only after consensus
5. **Migration**: If a principle changes retroactively, file follow-up task for existing code to comply
6. **Documentation**: Update this file with new version, amended date, and summary of changes

### Versioning

Constitution follows semantic versioning:
- **MAJOR**: Removal or redefinition of a principle (backward-incompatible governance change)
- **MINOR**: Addition of new principle or significant expansion (clarifies or extends rules)
- **PATCH**: Wording clarifications, examples, typo fixes (no semantic change)

### Compliance Review

- **On Specification**: Each spec's plan must reference which principles it applies; violation must be justified
- **On Code Review**: Reviewers verify layering (Api → Application → Domain → Infrastructure), error handling, 
  async/await patterns, and naming conventions
- **On Test Suite**: Coverage reports and test execution logs attached to PRs
- **On Architecture Decision**: Breaking changes (new layer, removed layer, new abstraction) require 
  constitution review before implementation

### Guidance Files

- **Development Runtime Guidance**: Not yet established (to be added in future specs)
- **Specification Templates**: `.specify/templates/spec-template.md`
- **Planning Templates**: `.specify/templates/plan-template.md`
- **Task Templates**: `.specify/templates/tasks-template.md`

---

**Version**: 1.0.0 | **Ratified**: 2026-08-11 | **Last Amended**: 2026-08-11
