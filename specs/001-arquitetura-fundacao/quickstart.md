# Quickstart: Run Foundation Locally

**Spec**: specs/001-arquitetura-fundacao/spec.md
**Date**: 2026-08-12

## Requirements
- Docker and Docker Compose installed on host

## Start

1. From repository root, run:

```bash
docker compose up --build
```

2. Verify services started:

```bash
curl -fsS http://localhost/api/health
# expected: {"status":"ok"}
```

3. Verify frontend:
- Open http://localhost in a browser; initial page should load.

## Test
- Run backend unit tests (inside container or via CLI if SDK installed):

```bash
# inside backend container or local dev
dotnet test --project backend/tests/UnitTests
```

- Run integration tests (will provision isolated MySQL instance):

```bash
dotnet test --project backend/tests/IntegrationTests
```

## Migrations
- Migrations are executed automatically by the migration container during `docker compose up`.
- To run migrations manually (from backend container):

```bash
dotnet ef database update --project backend/src/Infrastructure/Persistence
```

## Notes
- Environment variables are loaded from `.env` (template available at repo root).
- Seed data is loaded automatically for development environment.
