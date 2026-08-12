---

# Tasks: Foundation Architecture Structure

**Feature**: Foundation Architecture Structure
**Spec**: specs/001-arquitetura-fundacao/spec.md
**Plan**: specs/001-arquitetura-fundacao/plan.md

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create repository directories: backend/, frontend/, specs/ (paths: backend/, frontend/, specs/)
- [ ] T002 Create backend .NET solution and initial project at backend/src/Api (path: backend/src/Api/)
- [ ] T003 Create frontend React + TypeScript app scaffolded with Vite (path: frontend/src/)
- [ ] T004 Add docker-compose.yml at repository root with services: mysql, migration (runs the backend image with `--migrate`, see T019), backend, frontend; every environment variable is given a working default (`${VAR:-default}`) so `docker compose up` needs no manual `.env` setup (path: docker-compose.yml)
- [ ] T005 Add .env.example at repository root documenting overridable variables — this file is documentation only; docker-compose.yml's built-in defaults (T004) already make the stack runnable without it (path: .env.example)
- [ ] T006 Add CI workflow skeleton for build/tests at .github/workflows/ci.yml (path: .github/workflows/ci.yml)
- [ ] T007 [P] Add project README and quickstart referencing specs/001-arquitetura-fundacao/quickstart.md (path: README.md)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [ ] T008 Setup EF Core persistence project at backend/src/Infrastructure/Persistence (path: backend/src/Infrastructure/Persistence/)
- [ ] T009 Create Solicitacao entity model with a status transition guard implementing the closed transition set from data-model.md (Recebida→EmAnalise; EmAnalise→Aprovada; EmAnalise→Rejeitada; Aprovada/Rejeitada are terminal; any other transition throws) per FR-021, in backend/src/Domain/Entities/Solicitacao.cs (path: backend/src/Domain/Entities/Solicitacao.cs)
- [ ] T010 Create Domain/Exceptions/ custom exception types (`SolicitacaoNaoEncontradaException`, `InvalidStatusTransitionException`) at backend/src/Domain/Exceptions/ (path: backend/src/Domain/Exceptions/)
- [ ] T011 Add EF Core Fluent API mapping configuration for Solicitacao, declaring a unique index on Numero and a non-unique index on CidadaoId, in backend/src/Infrastructure/Persistence/EntityConfigurations/SolicitacaoConfiguration.cs (path: backend/src/Infrastructure/Persistence/EntityConfigurations/SolicitacaoConfiguration.cs)
- [ ] T012 Create DbContext registering the SolicitacaoConfiguration (T011) at backend/src/Infrastructure/Persistence/DbContext.cs (path: backend/src/Infrastructure/Persistence/DbContext.cs)
- [ ] T013 Generate and review the initial EF Core migration, built from T011's mapping so the Numero unique index and CidadaoId index are present from the first migration, at backend/src/Infrastructure/Persistence/Migrations/ (path: backend/src/Infrastructure/Persistence/Migrations/)
- [ ] T014 Create application service folder structure at backend/src/Application/Interfaces/, backend/src/Application/Services/, and backend/src/Application/DTOs/ (path: backend/src/Application/)
- [ ] T015 Implement ICurrentUser abstraction interface (canonical definition; not recreated elsewhere) at backend/src/Domain/Interfaces/ICurrentUser.cs (path: backend/src/Domain/Interfaces/ICurrentUser.cs)
- [ ] T016 Implement development CurrentUser provider (canonical implementation; not recreated elsewhere) at backend/src/Infrastructure/Authentication/DevelopmentCurrentUser.cs (path: backend/src/Infrastructure/Authentication/DevelopmentCurrentUser.cs)
- [ ] T017 Implement centralized error handling middleware mapping the Domain/Exceptions types (T010) to standardized HTTP responses at backend/src/Api/Middleware/ErrorHandlingMiddleware.cs (path: backend/src/Api/Middleware/ErrorHandlingMiddleware.cs)
- [ ] T018 Implement health endpoint at backend/src/Api/Controllers/HealthController.cs (path: backend/src/Api/Controllers/HealthController.cs)
- [ ] T019 [P] Configure the backend Dockerfile with a dual-mode entrypoint: no arguments starts the API (`dotnet Api.dll`); a `--migrate` argument runs `dotnet ef database update` and exits. One image serves both the `backend` and `migration` compose services — no separate migration image (paths: backend/Dockerfile, backend/entrypoint.sh)
- [ ] T020 [P] Configure the frontend Dockerfile (nginx) and add frontend/nginx.conf proxying `/api` to the backend service, so the deployed stack is reachable from a single origin (paths: frontend/Dockerfile, frontend/nginx.conf)
- [ ] T021 Implement the seed data loader as the single canonical mechanism for FR-019 at backend/src/Infrastructure/Persistence/Seeds/SeedData.cs, invoked automatically when the backend image runs in `--migrate` mode (T019), after migrations are applied (path: backend/src/Infrastructure/Persistence/Seeds/SeedData.cs)
- [ ] T022 Configure logging and configuration management in backend/src/Api/Program.cs (kept inline rather than a dedicated Infrastructure/Logging/ folder — see plan.md Complexity Tracking) (path: backend/src/Api/Program.cs)
- [ ] T023 Add OpenAPI/Swagger middleware wiring and global configuration (generator setup only; per-endpoint annotations added in T036) in backend/src/Api/Program.cs — same file as T022, not parallelizable (path: backend/src/Api/Program.cs)

**Checkpoint**: Foundation ready - user stories can begin

---

## Phase 3: User Story 1 - Backend Development Environment Setup (Priority: P1)

**Goal**: Provide a runnable backend with migrations, health endpoint, and integration test harness

**Independent Test**: `docker compose up` starts migration and backend; `curl http://localhost/api/health` returns 200; integration tests can run against provisioned MySQL

- [ ] T024 [US1] Create backend project README with run & test instructions, including how migrations are applied via `backend --migrate` (path: backend/README.md)
- [ ] T025 [US1] Implement integration test harness in backend/tests/IntegrationTests/ (path: backend/tests/IntegrationTests/)
- [ ] T026 [US1] Add sample integration test that verifies migrations run and DB connection succeeds (path: backend/tests/IntegrationTests/MigrationsTests.cs)
- [ ] T027 [US1] Wire the `migration` service in docker-compose.yml to run the backend image (T019) with `--migrate`, ordered before `backend` and `frontend` start (path: docker-compose.yml)
- [ ] T028 [US1] Ensure the backend Dockerfile exposes correct ports and health checks for its default (API) mode (path: backend/Dockerfile)

---

## Phase 4: User Story 2 - Data Persistence Foundation (Priority: P1)

**Goal**: Implement Solicitacao persistence, repository, and seed data

**Independent Test**: Repository tests can create/read/update Solicitacao against MySQL and only return the current user's data

- [ ] T029 [US2] Implement SolicitacaoRepository in backend/src/Infrastructure/Persistence/Repositories/SolicitacaoRepository.cs (path: backend/src/Infrastructure/Persistence/Repositories/SolicitacaoRepository.cs)
- [ ] T030 [US2] Create repository integration tests in backend/tests/IntegrationTests/Persistence/SolicitacaoRepositoryTests.cs, including a test asserting the unique constraint on Numero (T011) rejects duplicates (path: backend/tests/IntegrationTests/Persistence/SolicitacaoRepositoryTests.cs)
- [ ] T031 [US2] Add repository/service logic to filter requests by current user in backend/src/Infrastructure/Persistence/Repositories/SolicitacaoRepository.cs and backend/src/Application/Services/ (path: backend/src/Infrastructure/Persistence/Repositories/SolicitacaoRepository.cs)
- [ ] T032 [US2] Create the Solicitacao response DTO per contracts/api.md — excluding `cidadaoId`, since responses are already scoped to the current user — at backend/src/Application/DTOs/SolicitacaoDto.cs (path: backend/src/Application/DTOs/SolicitacaoDto.cs)
- [ ] T033 [US2] Validate the seed data loader (T021) produces the exact seed counts (2 for cidadao-001, 1 for cidadao-002) in backend/tests/IntegrationTests/Persistence/SeedDataTests.cs (path: backend/tests/IntegrationTests/Persistence/SeedDataTests.cs)

---

## Phase 5: User Story 3 - API Contract & Error Handling (Priority: P1)

**Goal**: Provide OpenAPI docs and standardized error responses for frontend integration

**Independent Test**: Swagger UI available; invalid requests return standardized error body; generic 500s do not leak internal details

- [ ] T034 [US3] Add Solicitacoes controller GET /api/solicitacoes list endpoint, returning SolicitacaoDto (T032), using Application services at backend/src/Api/Controllers/SolicitacoesController.cs (path: backend/src/Api/Controllers/SolicitacoesController.cs)
- [ ] T035 [US3] Add Solicitacoes controller GET /api/solicitacoes/{id} get-by-id endpoint, throwing SolicitacaoNaoEncontradaException (T010) if not found or not owned by current user, at backend/src/Api/Controllers/SolicitacoesController.cs (path: backend/src/Api/Controllers/SolicitacoesController.cs)
- [ ] T036 [US3] Document HealthController and SolicitacoesController endpoints with response types and Swagger attributes; verify Swagger UI lists both controllers (SC-008) at backend/src/Api/Controllers/HealthController.cs and backend/src/Api/Controllers/SolicitacoesController.cs (path: backend/src/Api/Controllers/)
- [ ] T037 [US3] Implement standardized error response DTOs at backend/src/Application/DTOs/ErrorResponse.cs (path: backend/src/Application/DTOs/ErrorResponse.cs)
- [ ] T038 [US3] Add tests validating error response shapes and generic 500 handling in backend/tests/IntegrationTests/Api/ErrorResponseTests.cs (path: backend/tests/IntegrationTests/Api/ErrorResponseTests.cs)

---

## Phase 6: User Story 4 - Testing Infrastructure (Priority: P1)

**Goal**: Ensure unit, integration, and HTTP tests execute automatically and reliably

**Independent Test**: Unit tests run locally; integration tests provision MySQL; HTTP tests exercise endpoints

- [ ] T039 [US4] Create backend/tests/UnitTests project with xUnit and an enforced minimum 80% line-coverage threshold (coverlet), per constitution Test Strategy (path: backend/tests/UnitTests/)
- [ ] T040 [US4] Configure Testcontainers.MySql helper for integration tests in backend/tests/IntegrationTests/ (path: backend/tests/IntegrationTests/)
- [ ] T041 [US4] Add unit test examples for domain logic, including explicit tests for Solicitacao status transition rules (valid transitions succeed; invalid and terminal-state transitions throw) in backend/tests/UnitTests/ (path: backend/tests/UnitTests/)
- [ ] T042 [US4] Add HTTP integration test examples using TestServer/WebApplicationFactory in backend/tests/IntegrationTests/Api/ (path: backend/tests/IntegrationTests/Api/)
- [ ] T043 [US4] Ensure the CI workflow runs unit and integration tests and publishes the coverage report, failing the build if coverage drops below the 80% threshold (path: .github/workflows/ci.yml)

---

## Phase 7: User Story 5 - Frontend Development Environment (Priority: P1)

**Goal**: Create frontend skeleton, connect to API, and add component testing setup

**Independent Test**: Frontend starts and fetches /api/health; component tests run

- [ ] T044 [US5] Create React app skeleton at frontend/src/ with pages/, components/, services/, and types/ directories, an initial landing page, and Vitest + React Testing Library configuration (path: frontend/src/App.tsx)
- [ ] T045 [US5] Add frontend/src/types/api.ts with TypeScript types aligned to contracts/api.md (path: frontend/src/types/api.ts)
- [ ] T046 [US5] Add API service module (using the browser `fetch` API) to call backend GET /api/health and GET /api/solicitacoes (and /api/solicitacoes/{id}) endpoints per contracts/api.md at frontend/src/services/api.ts (path: frontend/src/services/api.ts)
- [ ] T047 [US5] Add component test example in frontend/tests/components/App.test.tsx (path: frontend/tests/components/App.test.tsx)
- [ ] T048 [US5] Configure the frontend Dockerfile to serve built assets with nginx (pin base image to nginx:1.27-alpine), reusing the nginx.conf `/api` proxy from T020 (path: frontend/Dockerfile)

---

## Phase 8: User Story 6 - Full-Stack Deployment (Priority: P1)

**Goal**: Ensure docker compose orchestration runs everything end-to-end

**Independent Test**: `docker compose up` starts services and health check returns 200

- [ ] T049 [US6] Validate service dependencies and health checks in docker-compose.yml (path: docker-compose.yml)
- [ ] T050 [US6] Ensure full-stack startup order: `migration` completes before `backend` starts; `frontend` starts only once `backend`'s health check passes (path: docker-compose.yml)
- [ ] T051 [US6] Add an end-to-end smoke test as a shell/CI script that runs `docker compose up`, curls `http://localhost/api/health`, and checks the frontend responds at `http://localhost` (a jsdom component test cannot exercise real Compose orchestration) (path: .github/workflows/ci.yml, scripts/smoke-test.sh)
- [ ] T052 [US6] Add docs to quickstart.md with verification steps (path: specs/001-arquitetura-fundacao/quickstart.md)

---

## Phase 9: User Story 7 - Current User Context (Priority: P2)

**Goal**: Implement ICurrentUser abstraction and development provider

**Independent Test**: Application services can read current user id in dev environment

- [ ] T053 [US7] Register ICurrentUser/DevelopmentCurrentUser (created in T015/T016) for dependency injection and wire consumption in Application services (no new interface/implementation files created here) at backend/src/Api/Program.cs (path: backend/src/Api/Program.cs)
- [ ] T054 [US7] Add unit test verifying services receive current user id (path: backend/tests/UnitTests/Authentication/CurrentUserTests.cs)

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Documentation, CI, security hardening, cleanup

- [ ] T055 Documentation: Update root README.md and architecture notes with cross-links only (do not duplicate content already covered by T007 root README and T024 backend README) (path: README.md, specs/)
- [ ] T056 [P] CI/CD: finalize workflows, add caching/workflow optimizations (path: .github/workflows/ci.yml)
- [ ] T057 Code cleanup: linting, formatting, and basic refactors (paths: backend/, frontend/)
- [ ] T058 Security: basic security headers, vulnerability scan integration (path: .github/workflows/security.yml)
- [ ] T059 [P] Add performance verification: automated or documented checks confirming SC-001 (health p95 <100ms warm), SC-002 (unit tests <10s), SC-003 (integration tests <30s), SC-004 (compose startup <60s), SC-005 (frontend render <2s), and SC-006 (migrations <5s), recording results in specs/001-arquitetura-fundacao/quickstart.md (path: specs/001-arquitetura-fundacao/quickstart.md)

---

## Dependencies & Execution Order

- Setup (Phase 1) -> Foundational (Phase 2) -> User Stories (Phase 3+)
- All User Stories depend on Foundational phase completion
- Within Foundational: entity + exceptions (T009-T010) -> EF mapping (T011) -> DbContext (T012) -> initial migration (T013), so the first migration already contains the Numero/CidadaoId indexes
- Within each story: Models -> Repositories/Services -> Controllers/Endpoints -> Tests
- The `migration` compose service (T027) and the `backend` compose service both run the single backend image built in T019, differing only by the `--migrate` argument

---

## Parallel Example: Foundational Phase

```bash
# Launch the two independent Dockerfile tasks together (different files, no shared state):
Task: "Configure the backend Dockerfile with a dual-mode entrypoint in backend/Dockerfile, backend/entrypoint.sh"
Task: "Configure the frontend Dockerfile (nginx) and frontend/nginx.conf in frontend/Dockerfile, frontend/nginx.conf"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (runnable backend, migrations, health endpoint)
4. **STOP and VALIDATE**: `docker compose up`, `curl http://localhost/api/health` returns 200, integration tests pass against provisioned MySQL
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready (EF Core, DbContext, exceptions, error middleware, health endpoint, dual-mode backend image, seed loader all in place)
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 (persistence + isolation) → Test independently → Deploy/Demo
4. Add User Story 3 (API contract + error handling) → Test independently → Deploy/Demo
5. Add User Story 4 (testing infrastructure, coverage gate) → Test independently
6. Add User Story 5 (frontend) → Test independently → Deploy/Demo
7. Add User Story 6 (full-stack Docker Compose deployment) → Test independently → Deploy/Demo
8. Add User Story 7 (current-user DI wiring, P2) → Test independently
9. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers, after Setup + Foundational are done:
- Developer A: User Story 1 → User Story 2 (both backend-persistence-focused, natural continuation)
- Developer B: User Story 5 (frontend) → User Story 6 (deployment)
- Developer C: User Story 3 → User Story 4 (API contract + testing infrastructure)
- User Story 7 (P2) picked up by whoever finishes first, since it only wires existing T015/T016 artifacts into DI

## Summary Report

- Total tasks: 59
- Tasks per phase:
  - Setup: 7
  - Foundational: 16
  - US1: 5
  - US2: 5
  - US3: 5
  - US4: 5
  - US5: 5
  - US6: 4
  - US7: 2
  - Polish: 5

- Parallel opportunities identified: T007, T019, T020, T056, T059
- Suggested MVP scope: Complete Phase 1 + Phase 2 + Phase 3 (Backend environment + health endpoint + migrations)
- Format validation: All tasks follow the checklist format `- [ ] T### [P?] [US?] Description (path)`
- Commit conventions: Enforced manually per constitution guidance (Section: Commit Conventions); no automated commit-message linting tool is included in this baseline (CN2 — accepted as out-of-scope for SPEC-001)

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Foundational-phase tasks are ordered so the entity, its exceptions, and its EF mapping all exist before the initial migration is generated (T009 → T010 → T011 → T012 → T013) — generating the migration any earlier would miss the Numero/CidadaoId indexes
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- T019 and T022/T023 both touch backend/Dockerfile-adjacent and Program.cs concerns respectively — only T019/T020 are parallel; T022 and T023 intentionally share Program.cs and run sequentially
