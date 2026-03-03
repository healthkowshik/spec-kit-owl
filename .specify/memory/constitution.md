<!--
Sync Impact Report
==================
Version change: N/A → 1.0.0 (initial ratification)

Modified principles: N/A (initial)

Added sections:
- Core Principles (3 principles: Spec-Driven, Test-First, Simplicity)
- Governance

Removed sections:
- [SECTION_2_NAME] placeholder (not needed per user decision)
- [SECTION_3_NAME] placeholder (not needed per user decision)

Templates requiring updates:
- .specify/templates/plan-template.md — ✅ no changes needed
  (Constitution Check section is generic; gates derived at runtime)
- .specify/templates/spec-template.md — ✅ no changes needed
  (user-story structure is compatible with all three principles)
- .specify/templates/tasks-template.md — ✅ no changes needed
  (task phases and parallel markers align with principles)

Follow-up TODOs: None
-->

# spec-kit-owl Constitution

## Core Principles

### I. Spec-Driven Development

Every feature MUST begin with a specification before any code is
written. The specification is the source of truth:

- A feature without a spec MUST NOT be implemented.
- Code MUST demonstrably satisfy every requirement in its spec.
- When code and spec diverge, the spec MUST be updated first,
  then code follows — never the reverse.
- Spec changes MUST be reviewed with the same rigor as code
  changes.

**Rationale**: spec-kit-owl exists to enforce spec-code alignment.
The project itself MUST embody the discipline it promotes.

### II. Test-First

Tests MUST be written before the implementation they verify:

- Write failing tests that encode spec requirements.
- Implement only enough code to make the tests pass.
- Refactor only while tests remain green.
- Every user-facing behavior MUST have at least one automated
  test that can run without manual intervention.

**Rationale**: A tool that watches code correctness MUST itself be
provably correct. Test-first ensures regressions are caught early
and requirements are unambiguous.

### III. Simplicity

Prefer the simplest solution that satisfies the spec:

- Do not introduce abstractions, indirection, or configurability
  beyond what the current spec requires (YAGNI).
- Three similar lines of code are better than a premature
  abstraction.
- Every added dependency or layer of complexity MUST be justified
  by a concrete, current requirement — not a hypothetical future
  one.
- When in doubt, leave it out.

**Rationale**: Complexity is the primary enemy of maintainability
and correctness. Keeping the codebase small and focused makes it
easier to reason about and to extend when a real need arises.

## Governance

This constitution supersedes all other development practices for
the spec-kit-owl project. Compliance is mandatory:

- All pull requests and code reviews MUST verify adherence to the
  three core principles.
- Amendments to this constitution require:
  1. A written proposal describing the change and its rationale.
  2. An update to this file with a version bump following semantic
     versioning (MAJOR for principle removals or redefinitions,
     MINOR for additions or material expansions, PATCH for
     clarifications and wording fixes).
  3. A consistency review of all dependent templates under
     `.specify/templates/` to ensure alignment.
- The Sync Impact Report (HTML comment at the top of this file)
  MUST be updated with every amendment.

**Version**: 1.0.0 | **Ratified**: 2026-03-03 | **Last Amended**: 2026-03-03
