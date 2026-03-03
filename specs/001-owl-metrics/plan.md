# Implementation Plan: Owl Metrics Extension

**Branch**: `001-owl-metrics` | **Date**: 2026-03-03 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-owl-metrics/spec.md`

## Summary

Build a spec-kit extension (`owl`) that provides a `speckit.owl.metrics`
command. When invoked, it counts lines and characters in spec files
(under `specs/` and `.specify/`) versus non-spec files, respects
`.gitignore` exclusions, and displays results as percentages. A
breakdown mode shows per-directory counts. Cross-platform via paired
Bash and PowerShell scripts.

## Technical Context

**Language/Version**: Bash 4+ / PowerShell 5.1+
**Primary Dependencies**: git (for `git ls-files` and `.gitignore`
handling), standard Unix utilities (`wc`, `file`, `find`), PowerShell
built-ins (`Get-ChildItem`, `Get-Content`, `Measure-Object`)
**Storage**: N/A
**Testing**: Bash test scripts with fixture repos; manual validation
**Target Platform**: Windows, macOS, Linux
**Project Type**: spec-kit extension (CLI command)
**Performance Goals**: <5 seconds for repositories with up to 100,000
total lines
**Constraints**: No external dependencies beyond git and shell
built-ins; cross-platform parity between Bash and PowerShell output
**Scale/Scope**: Single extension, single command, one optional flag
(breakdown mode)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1
design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Spec-Driven | PASS | Spec written and clarified before planning |
| II. Test-First | PASS | Test fixtures and test scripts planned before implementation |
| III. Simplicity | PASS | Single extension, single script per platform, no external dependencies, no abstractions beyond what spec requires |

No violations. Gate passed.

## Project Structure

### Documentation (this feature)

```text
specs/001-owl-metrics/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── output-format.md
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
extension.yml                    # Extension manifest
commands/
└── metrics.md                   # Command file (AI agent instructions)
scripts/
├── bash/
│   └── metrics.sh               # Bash implementation
└── powershell/
    └── metrics.ps1              # PowerShell implementation
tests/
├── test_metrics.sh              # Bash test runner
└── fixtures/
    ├── basic-repo/              # Spec + non-spec files
    ├── empty-repo/              # No files
    ├── spec-only-repo/          # Only spec dirs
    ├── no-spec-repo/            # No spec dirs
    └── gitignore-repo/          # Files with .gitignore exclusions
```

**Structure Decision**: Single project at repository root. This IS the
extension — `extension.yml` lives at the repo root. No `src/` wrapper
needed; the extension consists of a manifest, a command file, and
platform-specific scripts.

## Complexity Tracking

No constitution violations to justify.
