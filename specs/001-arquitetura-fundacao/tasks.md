---

# Tasks: Foundation Architecture Structure

**Feature**: Foundation Architecture Structure
**Spec**: specs/001-arquitetura-fundacao/spec.md
**Plan**: specs/001-arquitetura-fundacao/plan.md

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create repository directories: backend/, frontend/, specs/ (paths: backend/, frontend/, specs/)
- [ ] T002 Create backend .NET solution and initial project at backend/src/Api (path: backend/src/Api/)
- [ ] T003 Create frontend React + TypeScript app at frontend/src/ (path: frontend/src/)
- [ ] T004 Add docker-compose.yml at repository root with services: mysql, migration, backend, frontend (path: docker-compose.yml)
- [ ] T005 Add .env template at repository root with placeholders for DB connection and ports (path: .env.example)
- [ ] T006 Add CI workflow skeleton for build/tests at .github/workflows/ci.yml (path: .github/workflows/ci.yml)
- [ ] T007 [P] Add project README and quickstart referencing specs/001-arquitetura-fundacao/quickstart.md (path: README.md)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [ ] T008 Setup EF Core persistence project at backend/src/Infrastructure/Persistence (path: backend/src/Infrastructure/Persistence/)
- [ ] T009 Create Solicitacao entity model with status transition guard (Recebida→EmAnalise→Aprovada/Rejeitada, invalid transitions throw a domain exception) in backend/src/Domain/Entities/Solicitacao.cs (path: backend/src/Domain/Entities/Solicitacao.cs)
- [ ] T010 Create DbContext and initial migration setup at backend/src/Infrastructure/Persistence/DbContext.cs (path: backend/src/Infrastructure/Persistence/DbContext.cs)
- [ ] T011 Add migrations folder and initial migration file at backend/src/Infrastructure/Persistence/Migrations/ (path: backend/src/Infrastructure/Persistence/Migrations/)
- [ ] T012 Create application service interfaces and folder structure at backend/src/Application/Interfaces/ and backend/src/Application/Services/ (path: backend/src/Application/)
- [ ] T013 Implement ICurrentUser abstraction interface (canonical definition; not recreated elsewhere) at backend/src/Domain/Interfaces/ICurrentUser.cs (path: backend/src/Domain/Interfaces/ICurrentUser.cs)
- [ ] T014 Implement development CurrentUser provider (canonical implementation; not recreated elsewhere) at backend/src/Infrastructure/Authentication/DevelopmentCurrentUser.cs (path: backend/src/Infrastructure/Authentication/DevelopmentCurrentUser.cs)
- [ ] T015 Implement centralized error handling middleware at backend/src/Api/Middleware/ErrorHandlingMiddleware.cs (path: backend/src/Api/Middleware/ErrorHandlingMiddleware.cs)
- [ ] T016 Implement health endpoint at backend/src/Api/Controllers/HealthController.cs (path: backend/src/Api/Controllers/HealthController.cs)
- [ ] T017 [P] Configure Dockerfiles for backend and frontend (paths: backend/Dockerfile, frontend/Dockerfile)
- [ ] T018 Seed initial data script and containerized migration job at backend/src/Infrastructure/Persistence/Seeds/seed.sql and migration container config (path: backend/src/Infrastructure/Persistence/Seeds/seed.sql)
- [ ] T019 Configure logging and configuration management (path: backend/src/Api/Program.cs)
- [ ] T020 [P] Add OpenAPI/Swagger middleware wiring and global configuration (generator setup only; per-endpoint annotations are added in T034) in backend/src/Api/Program.cs (path: backend/src/Api/Program.cs)

**Checkpoint**: Foundation ready - user stories can begin

---

## Phase 3: User Story 1 - Backend Development Environment Setup (Priority: P1)

**Goal**: Provide a runnable backend with migrations, health endpoint, and integration test harness

**Independent Test**: `docker compose up` starts migration and backend; `curl http://localhost/api/health` returns 200; integration tests can run against provisioned MySQL

- [ ] T021 [US1] Create backend project README with run & test instructions (path: backend/README.md)
- [ ] T022 [US1] Implement integration test harness in backend/tests/IntegrationTests/ (path: backend/tests/IntegrationTests/)
- [ ] T023 [US1] Add sample integration test that verifies migrations run and DB connection (path: backend/tests/IntegrationTests/MigrationsTests.cs)
- [ ] T024 [US1] Wire migration container command to execute EF Core migrations (`dotnet ef database update`) on startup in docker-compose.yml (path: docker-compose.yml)
- [ ] T025 [US1] Ensure backend Dockerfile exposes correct ports and health checks (path: backend/Dockerfile)

---

## Phase 4: User Story 2 - Data Persistence Foundation (Priority: P1)

**Goal**: Implement Solicitacao persistence, repository, and seed data

**Independent Test**: Repository tests can create/read/update Solicitacao against MySQL and only return the current user's data

- [ ] T026 [US2] Implement SolicitacaoRepository in backend/src/Infrastructure/Persistence/Repositories/SolicitacaoRepository.cs (path: backend/src/Infrastructure/Persistence/Repositories/SolicitacaoRepository.cs)
- [ ] T027 [US2] Create repository unit/integration tests in backend/tests/IntegrationTests/Persistence/SolicitacaoRepositoryTests.cs (path: backend/tests/IntegrationTests/Persistence/SolicitacaoRepositoryTests.cs)
- [ ] T028 [US2] Add repository/service logic to filter requests by current user in backend/src/Infrastructure/Persistence/Repositories/SolicitacaoRepository.cs and backend/src/Application/Services/ (path: backend/src/Infrastructure/Persistence/Repositories/SolicitacaoRepository.cs)
- [ ] T029 [US2] Add EF Core Fluent API mapping configuration for Solicitacao, declaring indexes on CidadaoId and Numero, in backend/src/Infrastructure/Persistence/EntityConfigurations/SolicitacaoConfiguration.cs (path: backend/src/Infrastructure/Persistence/EntityConfigurations/SolicitacaoConfiguration.cs)
- [ ] T030 [US2] Add seed data loader to apply initial seeds and validate exact seed counts in backend/src/Infrastructure/Persistence/Seeds/SeedData.cs and backend/tests/IntegrationTests/Persistence/SeedDataTests.cs (path: backend/src/Infrastructure/Persistence/Seeds/SeedData.cs)
- [ ] T031 [US2] Generate and review the EF Core migration produced by T029's mapping configuration (verifies CidadaoId/Numero indexes exist in schema) (path: backend/src/Infrastructure/Persistence/Migrations/)

---

## Phase 5: User Story 3 - API Contract & Error Handling (Priority: P1)

**Goal**: Provide OpenAPI docs and standardized error responses for frontend integration

**Independent Test**: Swagger UI available; invalid requests return standardized error body; generic 500s do not leak internal details

- [ ] T032 [US3] Add Solicitacoes controller GET /api/solicitacoes list endpoint using Application services at backend/src/Api/Controllers/SolicitacoesController.cs (path: backend/src/Api/Controllers/SolicitacoesController.cs)
- [ ] T033 [US3] Add Solicitacoes controller GET /api/solicitacoes/{id} get-by-id endpoint (404 if not found or not owned by current user) at backend/src/Api/Controllers/SolicitacoesController.cs (path: backend/src/Api/Controllers/SolicitacoesController.cs)
- [ ] T034 [US3] Document HealthController and SolicitacoesController endpoints with response types and Swagger attributes; verify Swagger UI lists both controllers (SC-008) at backend/src/Api/Controllers/HealthController.cs and backend/src/Api/Controllers/SolicitacoesController.cs (path: backend/src/Api/Controllers/)
- [ ] T035 [US3] Implement standardized error response DTOs at backend/src/Api/DTOs/ErrorResponse.cs (path: backend/src/Api/DTOs/ErrorResponse.cs)
- [ ] T036 [US3] Add contract tests validating error response shapes and generic 500 handling in backend/tests/Contract/ErrorResponseTests.cs (path: backend/tests/Contract/ErrorResponseTests.cs)

---

## Phase 6: User Story 4 - Testing Infrastructure (Priority: P1)

**Goal**: Ensure unit, integration, and HTTP tests execute automatically and reliably

**Independent Test**: Unit tests run locally; integration tests provision MySQL; HTTP tests exercise endpoints

- [ ] T037 [US4] Create backend/tests/UnitTests project with xUnit and coverage config (path: backend/tests/UnitTests/)
- [ ] T038 [US4] Configure Testcontainers.MySql helper for integration tests (path: backend/tests/TestHelpers/)
- [ ] T039 [US4] Add unit test examples for domain logic, including explicit tests for Solicitacao status transition rules (valid transitions succeed, invalid transitions throw) in backend/tests/UnitTests/ (path: backend/tests/UnitTests/)
- [ ] T040 [US4] Add HTTP integration test examples using TestServer/WebApplicationFactory (path: backend/tests/IntegrationTests/Api/)
- [ ] T041 [US4] Ensure CI workflow runs unit and integration tests (path: .github/workflows/ci.yml)

---

## Phase 7: User Story 5 - Frontend Development Environment (Priority: P1)

**Goal**: Create frontend skeleton, connect to API, and add component testing setup

**Independent Test**: Frontend starts and fetches /api/health; component tests run

- [ ] T042 [US5] Create React app skeleton at frontend/src/ with initial landing page and Jest + React Testing Library configuration scaffolding (path: frontend/src/App.tsx)
- [ ] T043 [US5] Add API service module to call backend GET /api/health and GET /api/solicitacoes (and /api/solicitacoes/{id}) endpoints per contracts/api.md at frontend/src/services/api.ts (path: frontend/src/services/api.ts)
- [ ] T044 [US5] Add component test example in frontend/tests/components/App.test.tsx (path: frontend/tests/components/App.test.tsx)
- [ ] T045 [US5] Configure frontend Dockerfile to serve built assets with nginx (pin base image to nginx:1.27-alpine) (path: frontend/Dockerfile)

---

## Phase 8: User Story 6 - Full-Stack Deployment (Priority: P1)

**Goal**: Ensure docker compose orchestration runs everything end-to-end

**Independent Test**: `docker compose up` starts services and health check returns 200

- [ ] T046 [US6] Validate service dependencies and health checks in docker-compose.yml (path: docker-compose.yml)
- [ ] T047 [US6] Add migration job container config and ensure order (path: docker-compose.yml)
- [ ] T048 [US6] Add end-to-end smoke test for frontend-to-backend health check in frontend/tests/integration/healthcheck.test.tsx (path: frontend/tests/integration/healthcheck.test.tsx)
- [ ] T049 [US6] Add docs to quickstart.md with verification steps (path: specs/001-arquitetura-fundacao/quickstart.md)

---

## Phase 9: User Story 7 - Current User Context (Priority: P2)

**Goal**: Implement ICurrentUser abstraction and development provider

**Independent Test**: Application services can read current user id in dev environment

- [ ] T050 [US7] Register ICurrentUser/DevelopmentCurrentUser (created in T013/T014) for dependency injection and wire consumption in Application services (no new interface/implementation files created here) at backend/src/Api/Program.cs (path: backend/src/Api/Program.cs)
- [ ] T051 [US7] Add unit test verifying services receive current user id (path: backend/tests/UnitTests/Authentication/CurrentUserTests.cs)

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Documentation, CI, security hardening, cleanup

- [ ] T052 Documentation: Update root README.md and architecture notes with cross-links only (do not duplicate content already covered by T007 root README and T021 backend README) (path: README.md, specs/)
- [ ] T053 [P] CI/CD: finalize workflows, add caching/workflow optimizations (path: .github/workflows/ci.yml)
- [ ] T054 Code cleanup: linting, formatting, and basic refactors (paths: backend/, frontend/)
- [ ] T055 Security: basic security headers, vulnerability scan integration (path: .github/workflows/security.yml)
- [ ] T056 [P] Add performance verification: automated or documented checks confirming SC-001 (health <100ms), SC-002 (unit tests <10s), SC-003 (integration tests <30s), SC-004 (compose startup <60s), SC-005 (frontend render <2s), and SC-006 (migrations <5s), recording results in specs/001-arquitetura-fundacao/quickstart.md (path: specs/001-arquitetura-fundacao/quickstart.md)

---

## Dependencies & Execution Order

- Setup (Phase 1) -> Foundational (Phase 2) -> User Stories (Phase 3+)
- All User Stories depend on Foundational phase completion
- Within each story: Models -> Repositories/Services -> Controllers/Endpoints -> Tests

## Summary Report

- Total tasks: 56
- Tasks per story:
  - Setup/Foundation: 20
  - US1: 5
  - US2: 6
  - US3: 5
  - US4: 5
  - US5: 4
  - US6: 4
  - US7: 2
  - Polish: 5

- Parallel opportunities identified: T007, T017, T020, T038, T053, T056 (and many setup/foundation tasks marked [P])
- Suggested MVP scope: Complete Phase 1 + Phase 2 + Phase 3 (Backend environment + health endpoint + migrations)
- Format validation: All tasks follow the checklist format `- [ ] T### [P?] [US?] Description (path)`
- Commit conventions: Enforced manually per constitution guidance (Section: Commit Conventions); no automated commit-message linting tool is included in this baseline (CN2 — accepted as out-of-scope for SPEC-001)

