# Research: Publish Extension to Community Catalog

**Feature Branch**: `002-publish-extension`
**Date**: 2026-03-03

## R1: Extension Manifest Gaps

**Decision**: Fix three issues in `extension.yml` — shorten description, add `homepage`, add `tags`.

**Rationale**:
- Current description is 112 characters; limit is 100. Shortened to: `"Spec-to-code metrics: line counts, character counts, and percentages"` (69 characters).
- Homepage: Use the repository URL (`https://github.com/healthkowshik/spec-kit-owl`) — consistent with all three existing catalog extensions (cleanup, retrospective, v-model all use repo URL as homepage).
- Tags: `["metrics", "spec-code", "analysis", "lines-of-code"]` — 4 tags, descriptive and lowercase, matching catalog conventions.

**Alternatives considered**:
- Description: `"Watches your Specs vs Code and prints spec-to-code metrics"` (60 chars) — rejected for being less informative than including "line counts, character counts."
- Homepage: A dedicated GitHub Pages site — rejected as unnecessary overhead for v1.0.0.
- Tags: Including `"spec-kit"` as a tag — rejected because it's redundant (all catalog extensions are for spec-kit).

## R2: Branch and Release Strategy

**Decision**: Tag `v1.0.0` from `main` branch. The `001-owl-metrics` branch is already merged to main via PR #1.

**Rationale**: Git log on `main` confirms the merge commit exists:
```
3ed9042 Merge pull request #1 from healthkowshik/001-owl-metrics
```
All extension code (scripts, commands, tests, README, extension.yml, LICENSE) is already on `main`. No additional merging is required before creating the release.

**Alternatives considered**:
- Tagging from a feature branch — rejected; releases should always be from the default branch for stability.
- Creating a release branch — rejected; unnecessary for a single-version first release (Simplicity principle).

## R3: CHANGELOG.md Format

**Decision**: Use [Keep a Changelog](https://keepachangelog.com/) format with semantic versioning.

**Rationale**: Industry standard format recognized by the spec-kit community. The existing catalog extensions (cleanup, retrospective, v-model) all link to a `CHANGELOG.md` in their repos.

**Alternatives considered**:
- Git log dump — rejected; not user-friendly and doesn't follow conventions.
- GitHub release notes only — rejected; the publishing guide lists `CHANGELOG.md` as a recommended file.

## R4: Catalog Entry Format

**Decision**: Follow the exact JSON schema used by existing entries in `catalog.community.json`.

**Rationale**: Three reference entries (cleanup, retrospective, v-model) demonstrate the required fields and format. Key values for owl:

| Field | Value |
|-------|-------|
| `name` | `"Spec Kit Owl"` |
| `id` | `"owl"` |
| `description` | Same shortened description from extension.yml |
| `author` | `"Health Kowshik"` |
| `version` | `"1.0.0"` |
| `download_url` | `"https://github.com/healthkowshik/spec-kit-owl/archive/refs/tags/v1.0.0.zip"` |
| `repository` | `"https://github.com/healthkowshik/spec-kit-owl"` |
| `homepage` | `"https://github.com/healthkowshik/spec-kit-owl"` |
| `documentation` | `"https://github.com/healthkowshik/spec-kit-owl/blob/main/README.md"` |
| `changelog` | `"https://github.com/healthkowshik/spec-kit-owl/blob/main/CHANGELOG.md"` |
| `license` | `"MIT"` |
| `provides.commands` | `1` |
| `provides.hooks` | `0` |
| `tags` | `["metrics", "spec-code", "analysis", "lines-of-code"]` |
| `verified` | `false` |
| `downloads` | `0` |
| `stars` | `0` |

**Alternatives considered**: None — the schema is fixed by the spec-kit catalog.

## R5: Catalog Submission Process

**Decision**: Fork `github/spec-kit`, add entry to `catalog.community.json`, update `extensions/README.md`, submit PR.

**Rationale**: This is the only submission path defined in the Extension Publishing Guide. The owl entry goes alphabetically between "cleanup" and "retrospective" in the JSON (keys are sorted alphabetically). In the README table, "Spec Kit Owl" goes alphabetically after "Cleanup Extension" and before "V-Model Extension Pack".

**Alternatives considered**: None — single defined process.

## R6: Extension ID Availability

**Decision**: The ID `"owl"` is available. Current catalog entries are: `cleanup`, `retrospective`, `v-model`.

**Rationale**: Confirmed by inspecting `catalog.community.json` — no `"owl"` key exists.

**Alternatives considered**: N/A.
