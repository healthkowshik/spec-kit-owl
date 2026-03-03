# Output Format Contract: speckit.owl.metrics

**Branch**: `001-owl-metrics` | **Date**: 2026-03-03

## Default Output (summary mode)

The command prints a human-readable summary to stdout:

```text
Spec vs Code Metrics
====================

  Spec lines:      1,234
  Spec chars:     45,678
  Non-spec lines:  3,456
  Non-spec chars: 123,456

  Total lines:     4,690
  Total chars:   169,134

  Spec %:  Lines: 26%  |  Chars: 27%
```

### Format rules

- Numbers MUST use comma-separated thousands (e.g., `1,234`).
- Percentages MUST be whole numbers followed by `%`.
- Labels MUST be right-aligned within their column.
- When total lines is 0, `Spec %` line displays: `Lines: N/A  |  Chars: N/A`
- When total chars is 0 but total lines > 0, only chars shows N/A.
- Output MUST end with a trailing newline.

## Breakdown Output

When breakdown mode is requested, an additional section appears
after the summary:

```text
Breakdown by Directory
======================

  Directory       Category    Lines    Chars
  ---------       --------    -----    -----
  specs/          spec          890   32,100
  .specify/       spec          344   13,578
  src/            non-spec    2,100   78,900
  tests/          non-spec    1,200   40,200
  .               non-spec      156    4,356
```

### Format rules

- Columns MUST be left-aligned except numeric columns (right-aligned).
- `"."` represents files in the repository root with no directory
  prefix.
- Directories MUST be sorted: spec directories first (alphabetical),
  then non-spec directories (alphabetical).
- Only directories containing at least one counted file appear.

## Exit Codes

| Code | Meaning                                    |
|------|--------------------------------------------|
| 0    | Success                                    |
| 1    | Error (e.g., cannot read files, git error) |

## stderr

Error messages MUST go to stderr, not stdout. Format:
`Error: <description>`
