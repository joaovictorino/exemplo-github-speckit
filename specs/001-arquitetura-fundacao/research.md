# Research: Foundation Architecture Structure

**Related spec**: specs/001-arquitetura-fundacao/spec.md
**Date**: 2026-08-12

## Purpose

Resolve any outstanding technical unknowns required to produce a practical implementation plan for the foundation architecture.

## Findings

- No [NEEDS CLARIFICATION] markers were present in the specification.
- The constitution already prescribes required constraints (separation of concerns, real MySQL for integration tests, Docker composability). These are adopted.
- Chosen stack (ASP.NET Core + EF Core + MySQL, React + TypeScript) is appropriate for the project's goals and aligns with the constitution and spec.

## Decisions

- Use real MySQL 8.x for both development (container) and integration tests (ephemeral containers).
- Use EF Core for persistence mapping; repositories provide the boundary between Application and Infrastructure.
- Use Docker Compose for local orchestration and Testcontainers/Docker for test automation.

## Alternatives considered (rejected)

- SQLite in-memory for integration tests — rejected because it does not exercise MySQL-specific behavior.
- Heavy framework abstractions (generic repository patterns) — rejected per constitution (avoid premature abstraction).

## Rationale

Choices minimize friction for developers, maximize test fidelity, and adhere to non-negotiable project principles.
