# AGENTS.md

## Purpose

This repository uses Spec-Driven Development.

Functional behavior is defined by specifications under `specs/`.

Agents must inspect the applicable specification and the existing
implementation before modifying code.

---

## Reading Order

Before making relevant changes, read:

1. the active specification under `specs/`;
2. `docs/base/architecture.md`;
3. `docs/base/quality.md`;
4. relevant source code;
5. the specification's `plan.md` and `tasks.md`, when available.

---

## Source of Truth

Each area has a distinct responsibility:

```text
specs/
    functional requirements, behavior and acceptance criteria

docs/base/architecture.md
    persistent architectural decisions

docs/base/quality.md
    quality requirements and Definition of Done

prompts/
    reusable execution workflows

scripts/
    deterministic build and validation
```

Do not create another source of truth for functional requirements.

---

## Engineering Principles

- implement only the requested scope;
- prefer simple solutions;
- preserve existing patterns;
- avoid speculative abstractions;
- avoid unrelated refactoring;
- do not introduce dependencies without concrete need;
- do not modify contracts unless required by a specification;
- keep business logic outside controllers;
- keep infrastructure concerns outside domain logic;
- inspect existing code before creating new abstractions.

---

## Workflows

For implementation use:

`prompts/implement.md`

For code review use:

`prompts/review.md`

For bug fixing use:

`prompts/fix.md`

For investigation use:

`prompts/investigate.md`

---

## Validation

Before reporting implementation work as complete run:

```bash
./scripts/validate.sh
```

Do not report successful completion if validation is failing.

Do not modify valid tests merely to hide implementation defects.

---

## Repository Safety

Do not:

- overwrite unrelated user changes;
- delete code merely because it appears unused without confirming;
- commit secrets;
- introduce unrelated refactoring;
- perform destructive Git operations without explicit instruction.

Do not commit, push, merge or rebase unless explicitly requested.
