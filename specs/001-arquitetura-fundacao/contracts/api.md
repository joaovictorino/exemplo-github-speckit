# API Contracts: Foundation Architecture

**Spec**: specs/001-arquitetura-fundacao/spec.md
**Date**: 2026-08-12

## Overview
This document captures the minimal HTTP contracts required by the foundation: health check and basic request retrieval endpoints. These contracts are technology-agnostic and intended for frontend integration and contract testing.

## Endpoints

### GET /api/health
Returns API health status.

Response 200 OK
Content-Type: application/json
Body:
```
{
  "status": "ok"
}
```

### GET /api/solicitacoes
List all solicitacoes belonging to the current user (no pagination in this baseline; full list only — pagination is out of scope for SPEC-001 and may be added in a future spec).

Response 200 OK
Body (array of Solicitacao DTO):
```
[
  {
    "id": "<guid>",
    "numero": "2026-000001",
    "status": "EmAnalise",
    "dataCriacao": "2026-01-01T12:00:00Z",
    "dataUltimaAtualizacao": "2026-01-02T12:00:00Z"
  }
]
```

Note: `cidadaoId` is intentionally omitted from the response DTO — every response is already scoped to the current user (resolved via the CurrentUser abstraction), so echoing the id back is redundant (Constitution Principle V: DTOs designed for client needs, not direct entity serialization).

### GET /api/solicitacoes/{id}
Retrieve a single solicitacao by Id (must belong to current user).

Response 200 OK (Solicitacao DTO) or 404 Not Found

### Error Response (standardized)
All error responses follow this shape:
```
{
  "type": "validation_error|not_found|server_error",
  "title": "Human readable message",
  "status": 400|404|500,
  "details": { /* optional */ }
}
```

## Notes
- All endpoints require the CurrentUser abstraction; behavior is defined such that only solicitacoes belonging to the current user are returned.
- OpenAPI/Swagger must expose these contracts for frontend consumption.
