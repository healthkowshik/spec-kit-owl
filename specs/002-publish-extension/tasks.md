# Tasks: Publish Extension to Community Catalog

**Input**: Design documents from `/specs/002-publish-extension/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Not requested — this is a publishing/configuration workflow with manual validation checkpoints.

**Organization**: Tasks are grouped by user story. US1 → US2 → US3 are strictly sequential (each depends on the previous story completing).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Ensure working environment is ready for publishing workflow

- [ ] T001 Verify `gh` CLI is installed and authenticated (`gh auth status`)
- [ ] T002 Checkout `main` branch and pull latest (`git checkout main && git pull origin main`)

**Checkpoint**: On `main` branch, up to date, `gh` CLI functional

---

## Phase 2: User Story 1 - Prepare Extension for Publication (Priority: P1) 🎯 MVP

**Goal**: Fix all manifest gaps and create CHANGELOG so the extension meets every publishing guide requirement

**Independent Test**: Validate `extension.yml` has all required fields (description under 100 chars, homepage present, 2-5 tags present) and `CHANGELOG.md` exists at repo root

### Implementation for User Story 1

- [ ] T003 [P] [US1] Update extension manifest: shorten description to under 100 characters, add `homepage` field, add `tags` list per research.md R1 in `extension.yml`
- [ ] T004 [P] [US1] Create changelog with v1.0.0 release notes using Keep a Changelog format in `CHANGELOG.md`
- [ ] T005 [US1] Validate manifest against publishing guide checklist — confirm: all required fields present, description is 69 characters, ID is lowercase-only, version is semver, tags are 2-5 lowercase strings, all command files referenced exist at their paths
- [ ] T006 [US1] Stage `extension.yml` and `CHANGELOG.md`, commit with message "Prepare extension for community catalog publication", push to `main`

**Checkpoint**: `extension.yml` passes all validation checks, `CHANGELOG.md` exists, both pushed to `main`

---

## Phase 3: User Story 2 - Create GitHub Release (Priority: P2)

**Goal**: Tag v1.0.0 and create a GitHub release so the catalog has a stable download archive URL

**Independent Test**: Verify `gh release view v1.0.0` shows the release and `curl -sI <archive-url>` returns HTTP 302

### Implementation for User Story 2

- [ ] T007 [US2] Create `v1.0.0` git tag on `main` and push to origin (`git tag v1.0.0 && git push origin v1.0.0`)
- [ ] T008 [US2] Create GitHub release titled "v1.0.0 - Initial Release" with CHANGELOG.md as release notes (`gh release create v1.0.0 --title "v1.0.0 - Initial Release" --notes-file CHANGELOG.md`)
- [ ] T009 [US2] Verify release archive URL is accessible: `curl -sI https://github.com/healthkowshik/spec-kit-owl/archive/refs/tags/v1.0.0.zip` returns HTTP 302

**Checkpoint**: GitHub release exists, archive URL is downloadable

---

## Phase 4: User Story 3 - Submit to Community Catalog (Priority: P3)

**Goal**: Add the owl extension to the spec-kit community catalog and submit a PR for review

**Independent Test**: PR is created on `github/spec-kit` with valid catalog entry and README update, passes automated checks

### Implementation for User Story 3

- [ ] T010 [US3] Fork `github/spec-kit` repository (`gh repo fork github/spec-kit --clone`) and create branch `add-owl-extension`
- [ ] T011 [P] [US3] Add `"owl"` entry to `extensions/catalog.community.json` between "cleanup" and "retrospective" with all required fields per `contracts/catalog-entry.md`, update top-level `updated_at` timestamp
- [ ] T012 [P] [US3] Add Spec Kit Owl row to `extensions/README.md` Available Extensions table in alphabetical order per `contracts/catalog-entry.md`
- [ ] T013 [US3] Commit catalog and README changes, push to fork, submit PR to `github/spec-kit` with extension details and confirmation checklist in description

**Checkpoint**: PR submitted to `github/spec-kit`, all automated checks pass

---

## Phase 5: Polish & Verification

**Purpose**: End-to-end verification that the extension is installable

- [ ] T014 Verify extension installs from archive URL (`specify extension add --from https://github.com/healthkowshik/spec-kit-owl/archive/refs/tags/v1.0.0.zip`)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **US1 (Phase 2)**: Depends on Setup — BLOCKS US2
- **US2 (Phase 3)**: Depends on US1 completion — BLOCKS US3
- **US3 (Phase 4)**: Depends on US2 completion (needs archive URL)
- **Polish (Phase 5)**: Depends on US2 completion (needs release archive)

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Setup — strictly sequential prerequisite for US2
- **User Story 2 (P2)**: Can start after US1 pushed to main — strictly sequential prerequisite for US3
- **User Story 3 (P3)**: Can start after US2 release created — final delivery step

### Parallel Opportunities

- **Phase 2 (US1)**: T003 and T004 can run in parallel (different files: `extension.yml` vs `CHANGELOG.md`)
- **Phase 4 (US3)**: T011 and T012 can run in parallel (different files: `catalog.community.json` vs `README.md`)
- **Cross-story parallelism**: Not possible — stories are strictly sequential

---

## Parallel Example: User Story 1

```bash
# Launch both file edits in parallel:
Task: "Update extension manifest in extension.yml"
Task: "Create changelog in CHANGELOG.md"

# Then sequentially:
Task: "Validate manifest against checklist"
Task: "Commit and push to main"
```

## Parallel Example: User Story 3

```bash
# After forking and creating branch, launch both edits in parallel:
Task: "Add owl entry to extensions/catalog.community.json"
Task: "Add owl row to extensions/README.md"

# Then sequentially:
Task: "Commit, push, and submit PR"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: User Story 1
3. **STOP and VALIDATE**: Manifest passes all checks, CHANGELOG exists
4. Extension is "publication-ready" even without release/catalog submission

### Incremental Delivery

1. Complete Setup → Environment ready
2. Complete US1 → Extension meets all publishing requirements (MVP!)
3. Complete US2 → Release exists with stable archive URL
4. Complete US3 → PR submitted for catalog inclusion
5. Complete Polish → Installation verified end-to-end

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- This is a strictly sequential workflow: US1 → US2 → US3 (no cross-story parallelism)
- Parallelism exists only within US1 (2 file edits) and within US3 (2 file edits)
- All exact file contents are specified in `contracts/catalog-entry.md` — copy directly
- Commit after each phase checkpoint
