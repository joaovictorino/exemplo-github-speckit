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
- The `migration` service in docker-compose.yml runs the same backend image as `backend`, with a `--migrate` argument, before `backend` and `frontend` start.
- To run migrations manually:

```bash
docker compose run --rm backend --migrate
```

## Notes
- All environment variables have working defaults baked into docker-compose.yml; `.env.example` at the repo root is documentation only — no copy-to-`.env` step is required to run `docker compose up`.
- Seed data is loaded automatically (as part of the `--migrate` step) for the development environment.
