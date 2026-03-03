# spec-kit-owl

A [spec-kit](https://github.com/github/spec-kit) extension that watches your Specs vs Code — so you don't have to.

Prints spec lines, non-spec lines, character counts, and spec percentages for any repository that uses spec-kit conventions (`specs/` and `.specify/` directories).

## Prerequisites

- Git
- Bash 4+ (macOS/Linux) or PowerShell 5.1+ (Windows)
- A spec-kit project (optional — works in any git repo)

## Install

```bash
specify extension add --dev /path/to/spec-kit-owl
```

Verify:

```bash
specify extension list
# Should show: owl — speckit.owl.metrics
```

## Usage

### Via AI agent (e.g. Claude Code)

```
/speckit.owl.metrics
```

### Via command line

**macOS / Linux:**

```bash
bash scripts/bash/metrics.sh
```

**Windows:**

```powershell
powershell -File scripts/powershell/metrics.ps1
```

### Example output

```
Spec vs Code Metrics
====================

  Spec lines:         3,014
  Spec chars:       106,314
  Non-spec lines:     2,101
  Non-spec chars:    91,122

  Total lines:        5,115
  Total chars:      197,436

  Spec %:  Lines: 59%  |  Chars: 54%
```

### Breakdown mode

Add `--breakdown` (Bash) or `-Breakdown` (PowerShell) to see per-directory counts:

```bash
bash scripts/bash/metrics.sh --breakdown
```

```
Breakdown by Directory
======================

  Directory            Category        Lines      Chars
  ---------            --------        -----      -----
  .specify/            spec            2,193     73,114
  specs/               spec              821     33,200
  .                    non-spec           78      2,343
  commands/            non-spec           21        576
  scripts/             non-spec          417     11,513
  tests/               non-spec          192      4,656
```

## How it works

1. Lists files via `git ls-files` (respects `.gitignore`). Falls back to `find` in non-git repos.
2. Skips binary files (null-byte detection) and symbolic links.
3. Categorizes files: anything under `specs/` or `.specify/` is **spec**, everything else is **non-spec**.
4. Counts lines and characters (with `\r\n` → `\n` normalization for cross-platform consistency).
5. Displays totals and spec percentage.

## Running tests

```bash
bash tests/test_metrics.sh
```

Runs 9 tests across 5 fixture repos covering summary mode, breakdown mode, edge cases (empty repo, spec-only, no-spec, `.gitignore` exclusions).

## License

MIT
