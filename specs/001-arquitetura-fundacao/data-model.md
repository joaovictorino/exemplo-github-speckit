# Data Model: Foundation Architecture

**Feature**: Foundation Architecture Structure
**Spec**: specs/001-arquitetura-fundacao/spec.md
**Date**: 2026-08-12

## Entities

### Solicitacao (Request)
Represents a citizen request handled by the organization.

Fields:
- Id: GUID (primary key)
- Numero: string (human-friendly sequential number, e.g., "2026-000001")
- CidadaoId: string (reference to the citizen identifier)
- Status: enum {Recebida, EmAnalise, Aprovada, Rejeitada}
- DataCriacao: timestamp (creation time)
- DataUltimaAtualizacao: timestamp (last update time)

Validation rules:
- Numero must be unique per request
- CidadaoId must be present
- Status must be one of the defined enum values
- DataCriacao <= DataUltimaAtualizacao

State transitions (initial):
- Initial state: Recebida
- Recebida -> EmAnalise
- EmAnalise -> Aprovada
- EmAnalise -> Rejeitada

### CurrentUser (abstraction)
- Id: string (e.g., "cidadao-001")
- Purpose: Provide the current authenticated user's identifier to application services without coupling to authentication details.

## Relationships
- Solicitacao.CidadaoId references CurrentUser.Id (logical relationship; no FK to user table for initial baseline unless user table is introduced)

## Persistence considerations
- Use EF Core Fluent API to map entities to `Solicitacoes` table
- Index on `CidadaoId` and `Numero` for query performance
- Migrations stored under backend/src/Infrastructure/Persistence/Migrations

## Seed Data
- cidadao-001
  - Solicitacao 2026-000001 (Status: EmAnalise)
  - Solicitacao 2026-000002 (Status: Aprovada)
- cidadao-002
  - Solicitacao 2026-000003 (Status: Recebida)
