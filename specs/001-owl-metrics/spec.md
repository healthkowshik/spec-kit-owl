# Feature Specification: Owl Metrics Extension

**Feature Branch**: `001-owl-metrics`
**Created**: 2026-03-03
**Status**: Draft
**Input**: User description: "Create an extension /specify.owl.metrics to print out number of lines of specs, number of lines of non-specs skipping the .gitignore folder and their ratio clearly when invoked."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Spec-to-Code Ratio (Priority: P1)

A developer working on a spec-kit project wants to understand how
much of their project is specification versus implementation code.
They invoke the `speckit.owl.metrics` command and immediately see
a clear summary: total spec lines, total non-spec lines, and their
ratio. This gives them a quick health check on whether their
project is adequately specified.

**Why this priority**: This is the entire core value proposition of
the extension. Without this, the extension has no purpose.

**Independent Test**: Can be fully tested by running the command in
any repository that contains a `specs/` or `.specify/` directory
and at least one non-spec file. The output displays three numbers
(spec lines, non-spec lines, ratio) and delivers immediate insight.

**Acceptance Scenarios**:

1. **Given** a repository with spec files under `specs/` and
   `.specify/` and source files elsewhere, **When** the user
   invokes `speckit.owl.metrics`, **Then** the output displays
   the total number of spec lines, total number of non-spec lines,
   and the ratio of spec lines to non-spec lines.

2. **Given** a repository with files and directories that match
   patterns in `.gitignore`, **When** the user invokes the command,
   **Then** those ignored files and the `.git/` directory are
   excluded from both spec and non-spec line counts.

3. **Given** a repository with no spec files (no `specs/` or
   `.specify/` directory), **When** the user invokes the command,
   **Then** the output shows 0 spec lines, the non-spec line
   count, and a ratio of 0.

4. **Given** a repository with no non-spec files (only spec
   directories exist), **When** the user invokes the command,
   **Then** the output shows the spec line count, 0 non-spec lines,
   and indicates the ratio as "N/A" (division by zero).

---

### User Story 2 - Understand File Categorization (Priority: P2)

A developer is surprised by the metrics and wants to understand
which files are counted as "spec" versus "non-spec." They invoke
the command with a breakdown flag and see a per-directory summary
so they can verify the counts make sense.

**Why this priority**: Transparency builds trust in the metrics.
Without understanding the categorization, users may distrust or
misinterpret the numbers.

**Independent Test**: Can be tested by running the command with a
breakdown option in a repository with mixed file types and verifying
that each listed directory maps to the correct category.

**Acceptance Scenarios**:

1. **Given** a repository with spec and non-spec files, **When**
   the user invokes the command requesting a breakdown, **Then**
   the output lists each top-level directory with its line count
   and whether it is categorized as spec or non-spec.

2. **Given** a repository where some files are excluded by
   `.gitignore`, **When** the user views the breakdown, **Then**
   excluded files do not appear in the listing.

---

### Edge Cases

- What happens when `.gitignore` does not exist? The command MUST
  still work, excluding only the `.git/` directory.
- What happens with binary files (images, compiled assets)? Binary
  files MUST be skipped — only text files are counted.
- What happens with empty files? They MUST be included in the
  count with 0 lines.
- What happens with symbolic links? They MUST be skipped to avoid
  double-counting.
- What happens when run outside a git repository? The command MUST
  still work, counting all files except `.git/` if present. Without
  a `.gitignore`, no additional exclusions apply.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The extension MUST register as a spec-kit extension
  with the command `speckit.owl.metrics` following the extension
  development guide conventions (extension ID: `owl`, command name:
  `metrics`).
- **FR-002**: The command MUST count total lines across all files
  in spec directories (`specs/` and `.specify/`).
- **FR-003**: The command MUST count total lines across all
  remaining files in the repository, excluding `.git/`, files
  matching `.gitignore` patterns, and binary files.
- **FR-004**: The command MUST display the spec-to-non-spec ratio
  as a decimal number rounded to two decimal places (e.g., 0.42).
- **FR-005**: The command MUST exclude binary files from all
  counts.
- **FR-006**: The command MUST exclude symbolic links from all
  counts.
- **FR-007**: The command MUST support a breakdown mode that shows
  per-directory line counts with spec/non-spec categorization.
- **FR-008**: The command MUST produce human-readable output by
  default, clearly labeling each metric.
- **FR-009**: The extension MUST include a valid `extension.yml`
  manifest following the spec-kit extension schema version 1.0.

### Key Entities

- **Spec File**: Any text file located under the `specs/` or
  `.specify/` directories. Counted toward the spec line total.
- **Non-Spec File**: Any text file in the repository that is not a
  spec file and is not excluded by `.gitignore` patterns, `.git/`,
  binary detection, or symlink detection. Counted toward the
  non-spec line total.
- **Metrics Summary**: The output artifact containing spec lines,
  non-spec lines, and the ratio.

### Assumptions

- "Lines" means newline-delimited lines as counted by standard
  line-counting tools (e.g., `wc -l` behavior). A file with no
  trailing newline still counts its last line.
- The `.gitignore` exclusion uses the same rules as git — including
  nested `.gitignore` files and global gitignore if present.
- The ratio is calculated as: spec lines / non-spec lines. When
  non-spec lines is 0, the output displays "N/A" instead of
  dividing by zero.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can invoke the command and see spec lines,
  non-spec lines, and ratio within 5 seconds on a repository with
  up to 100,000 total lines.
- **SC-002**: The line counts produced by the command match the
  result of manually counting lines in the same file categories
  with 100% accuracy.
- **SC-003**: Files matching `.gitignore` patterns and `.git/`
  contents are excluded from counts with 100% accuracy.
- **SC-004**: Users can view a per-directory breakdown to verify
  file categorization in a single command invocation.
