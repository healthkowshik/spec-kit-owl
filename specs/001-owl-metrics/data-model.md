# Data Model: Owl Metrics Extension

**Branch**: `001-owl-metrics` | **Date**: 2026-03-03

This extension does not persist data. The data model describes the
in-memory structures used during a single command invocation.

## Entities

### FileEntry

Represents a single file discovered during repository traversal.

| Field    | Type    | Description                                    |
|----------|---------|------------------------------------------------|
| path     | string  | Relative path from repository root             |
| category | enum    | `spec` or `non-spec`                           |
| lines    | integer | Number of newline-delimited lines (≥ 0)        |
| chars    | integer | Number of bytes after `\r` removal (≥ 0)       |

**Categorization rule**: A file is `spec` if its path starts with
`specs/` or `.specify/`. All other files are `non-spec`.

**Exclusion rules** (file is not created as a FileEntry):
- Path is under `.git/`
- Path matches a `.gitignore` pattern
- File is binary (contains null byte in first 8KB)
- File is a symbolic link

### MetricsSummary

Aggregated output of the command.

| Field          | Type    | Description                                |
|----------------|---------|--------------------------------------------|
| spec_lines     | integer | Sum of lines across all `spec` files       |
| spec_chars     | integer | Sum of chars across all `spec` files       |
| non_spec_lines | integer | Sum of lines across all `non-spec` files   |
| non_spec_chars | integer | Sum of chars across all `non-spec` files   |
| total_lines    | integer | spec_lines + non_spec_lines                |
| total_chars    | integer | spec_chars + non_spec_chars                |
| line_pct       | integer | Round((spec_lines / total_lines) * 100)    |
| char_pct       | integer | Round((spec_chars / total_chars) * 100)    |

**Edge cases**:
- `total_lines == 0` → `line_pct` displays as "N/A"
- `total_chars == 0` → `char_pct` displays as "N/A"

### DirectoryBreakdown

Per-directory aggregation for breakdown mode.

| Field     | Type    | Description                                  |
|-----------|---------|----------------------------------------------|
| directory | string  | Top-level directory name (or "." for root)   |
| category  | enum    | `spec` or `non-spec`                         |
| lines     | integer | Sum of lines for files in this directory     |
| chars     | integer | Sum of chars for files in this directory     |

**Grouping rule**: Files are grouped by their first path component.
Files in the repository root (no directory prefix) are grouped under
`"."`.

## Relationships

```text
FileEntry ──aggregates──▶ MetricsSummary  (many-to-one)
FileEntry ──groups-into──▶ DirectoryBreakdown  (many-to-one, by directory)
```

## State Transitions

N/A — all data is computed once per invocation and discarded. No
persistence, no lifecycle.
