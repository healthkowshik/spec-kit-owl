# Tasks: Owl Metrics Extension

**Input**: Design documents from `/specs/001-owl-metrics/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/output-format.md

**Tests**: Included per constitution principle II (Test-First). Tests MUST be written and FAIL before implementation begins.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create project directory structure and extension manifest

- [x] T001 Create directory structure: `commands/`, `scripts/bash/`, `scripts/powershell/`, `tests/fixtures/`
- [x] T002 [P] Create extension manifest at `extension.yml` with schema_version 1.0, extension id `owl`, and command `speckit.owl.metrics` pointing to `commands/metrics.md`
- [x] T003 [P] Create command file at `commands/metrics.md` with YAML frontmatter referencing `scripts/bash/metrics.sh` (sh) and `scripts/powershell/metrics.ps1` (ps), and markdown body instructing the agent to run `{SCRIPT}` with `$ARGUMENTS` and display stdout

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Test fixtures that ALL user stories depend on

**CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 Create test fixture directories as git repos in `tests/fixtures/`: `basic-repo/` (with `specs/`, `.specify/`, and `src/` containing text files), `empty-repo/` (initialized git repo with no files), `spec-only-repo/` (only `specs/` and `.specify/` dirs), `no-spec-repo/` (only `src/` dir), `gitignore-repo/` (with `.gitignore` excluding `build/` and a `build/` dir with files that should be skipped)
- [x] T005 Create test runner skeleton at `tests/test_metrics.sh` with helper functions: `setup()` to set working directory to a fixture, `assert_output_contains()` to check stdout for expected strings, `assert_exit_code()` to check return code, and a `run_tests()` entrypoint that reports pass/fail counts

**Checkpoint**: Fixtures and test harness ready — user story test-first work can begin

---

## Phase 3: User Story 1 - View Spec-to-Code Ratio (Priority: P1) MVP

**Goal**: User invokes `speckit.owl.metrics` and sees spec lines, spec chars, non-spec lines, non-spec chars, and spec percentages (by lines and chars)

**Independent Test**: Run `bash scripts/bash/metrics.sh` in `tests/fixtures/basic-repo/` and verify output matches the summary format from `contracts/output-format.md`

### Tests for User Story 1

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T006 [US1] Write tests for summary mode in `tests/test_metrics.sh`: test_basic_repo (verifies spec lines, non-spec lines, chars, and percentages appear correctly), test_empty_repo (verifies "N/A" for percentages), test_spec_only_repo (verifies 100% spec percentage), test_no_spec_repo (verifies 0% spec percentage), test_gitignore_repo (verifies excluded files are not counted)

### Implementation for User Story 1

- [x] T007 [US1] Implement `scripts/bash/metrics.sh`: argument parsing (`--breakdown` flag), file enumeration via `git ls-files --cached --others --exclude-standard` with `find . -type f -not -path './.git/*'` fallback for non-git repos, symlink filtering (`-L` test), binary detection (check first 8KB for null bytes via `head -c 8192 | tr -cd '\0' | wc -c`), file categorization (paths starting with `specs/` or `.specify/` are spec, rest are non-spec), line counting per file, character counting with `tr -d '\r'` normalization, percentage calculation with N/A for zero denominators, and summary output formatted per `contracts/output-format.md` (comma-separated thousands, right-aligned labels)
- [x] T008 [P] [US1] Implement `scripts/powershell/metrics.ps1`: mirror metrics.sh logic using `git ls-files` for enumeration, `[System.IO.File]::ReadAllBytes()` for binary detection (check first 8KB for 0x00), `Get-Item` for symlink check, `Get-Content -Raw` with `-replace '\r',''` for normalized char counting, `Measure-Object -Line` for line counting, and matching summary output format
- [x] T009 [US1] Run summary mode tests via `bash tests/test_metrics.sh` and verify all 5 test cases pass

**Checkpoint**: User Story 1 fully functional — `bash scripts/bash/metrics.sh` produces correct summary in any test fixture repo

---

## Phase 4: User Story 2 - Understand File Categorization (Priority: P2)

**Goal**: User invokes the command with `--breakdown` and sees per-directory line counts, character counts, and spec/non-spec categorization

**Independent Test**: Run `bash scripts/bash/metrics.sh --breakdown` in `tests/fixtures/basic-repo/` and verify the breakdown table appears after the summary with correct per-directory grouping

### Tests for User Story 2

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T010 [US2] Write tests for breakdown mode in `tests/test_metrics.sh`: test_breakdown_basic (verifies per-directory table appears with correct columns and categories), test_breakdown_root_files (verifies files in repo root grouped under "."), test_breakdown_gitignore (verifies excluded dirs do not appear), test_breakdown_sorting (verifies spec dirs listed first alphabetically, then non-spec dirs alphabetically)

### Implementation for User Story 2

- [x] T011 [US2] Add breakdown mode to `scripts/bash/metrics.sh`: when `--breakdown` flag is set, after summary output print "Breakdown by Directory" section, group files by first path component (root files under "."), aggregate lines and chars per directory, label each as spec or non-spec, sort spec dirs first (alphabetical) then non-spec dirs (alphabetical), format columns per `contracts/output-format.md` breakdown rules
- [x] T012 [P] [US2] Add `-Breakdown` parameter to `scripts/powershell/metrics.ps1`: mirror the breakdown logic from metrics.sh with matching output format
- [x] T013 [US2] Run breakdown mode tests via `bash tests/test_metrics.sh` and verify all 4 breakdown test cases pass (plus all 5 summary tests still pass)

**Checkpoint**: Both user stories fully functional and independently testable

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: End-to-end validation and cleanup

- [x] T014 [P] Validate quickstart.md instructions: follow `specs/001-owl-metrics/quickstart.md` step-by-step in this repo, verify command output matches expected format
- [x] T015 Run full test suite (`bash tests/test_metrics.sh`) across all fixtures and verify 9 total tests pass with exit code 0

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 completion (needs directory structure) — BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Phase 2 completion (needs fixtures and test harness)
- **User Story 2 (Phase 4)**: Depends on Phase 3 completion (breakdown extends the summary script)
- **Polish (Phase 5)**: Depends on Phase 4 completion

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) — no dependencies on other stories
- **User Story 2 (P2)**: Depends on US1 completion — breakdown mode extends the existing metrics.sh script by adding the `--breakdown` code path after the summary output

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Bash script before PowerShell (Bash is primary, PowerShell mirrors)
- Verify tests pass after implementation

### Parallel Opportunities

- T002 and T003 can run in parallel (different files)
- T008 and T007 can overlap: T008 (PowerShell) can start once T007's file enumeration and counting logic is settled, since it mirrors the same approach
- T012 can run in parallel with T011 (different files)
- T014 can run in parallel with T015

---

## Parallel Example: User Story 1

```bash
# After T006 tests are written and failing:

# Primary implementation (must complete first):
Task: "Implement metrics.sh in scripts/bash/metrics.sh"

# Can start in parallel once metrics.sh approach is clear:
Task: "Implement metrics.ps1 in scripts/powershell/metrics.ps1"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T003)
2. Complete Phase 2: Foundational (T004-T005)
3. Complete Phase 3: User Story 1 (T006-T009)
4. **STOP and VALIDATE**: Run `bash scripts/bash/metrics.sh` in this repo — verify output is correct
5. MVP ready for demo

### Incremental Delivery

1. Setup + Foundational → directory structure, manifest, fixtures ready
2. User Story 1 → summary mode works → Demo (MVP!)
3. User Story 2 → breakdown mode works → Demo
4. Polish → quickstart validated, full test suite green

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story is independently testable after completion
- Tests must fail before implementation begins (Constitution: Test-First)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
