# Research: Owl Metrics Extension

**Branch**: `001-owl-metrics` | **Date**: 2026-03-03

## R1: Listing files while respecting .gitignore

**Decision**: Use `git ls-files` to enumerate files.

**Rationale**: `git ls-files --cached --others --exclude-standard`
lists all tracked and untracked-but-not-ignored files in a single
call. It handles nested `.gitignore` files, global gitignore, and
`.git/info/exclude` automatically. This is the canonical way to
respect `.gitignore` rules without reimplementing them.

**Alternatives considered**:
- `find` + manual `.gitignore` parsing: Complex, error-prone, would
  need to handle nested `.gitignore`, negation patterns, and
  directory-only patterns. Violates Simplicity principle.
- Third-party tools (e.g., `ripgrep --files`): Adds external
  dependency. `rg` respects `.gitignore` but is not universally
  installed.

**Fallback for non-git repos**: Use `find . -type f` excluding
`.git/` directory. No `.gitignore` parsing in this case (per spec
edge case: "Without a `.gitignore`, no additional exclusions apply").

## R2: Binary file detection

**Decision**: Use `git ls-files` with `-z` and check file content for
null bytes as a fast heuristic.

**Rationale**: Git itself uses null-byte detection to classify files
as binary. Checking the first 8KB of each file for `\0` bytes is the
standard heuristic used by `git diff`, `grep`, and most text editors.
Fast and has no dependencies.

**Alternatives considered**:
- `file --mime-type`: Reliable but slower (spawns a process per file)
  and not available on all Windows setups without extra tooling.
- File extension allowlist: Brittle, requires maintenance, misses
  unknown extensions.

**Platform note (PowerShell)**: Use `[System.IO.File]::ReadAllBytes()`
on first 8KB and check for `0x00`. Equivalent to the Bash approach.

## R3: Line counting with cross-platform consistency

**Decision**: Count newline characters (`\n`) in file content. A file
with no trailing newline still counts its last line (i.e., if content
is non-empty and doesn't end with `\n`, add 1).

**Rationale**: Matches `wc -l` behavior with the last-line adjustment
specified in the spec. Consistent across platforms when we normalize
line endings first.

**Alternatives considered**:
- Raw `wc -l`: Does not count the last line if no trailing newline.
  Requires post-processing.
- `grep -c ''`: Counts lines including last without trailing newline,
  but slower for large files.

## R4: Character counting with line-ending normalization

**Decision**: Strip `\r` characters before counting bytes.

**Rationale**: Per clarification, characters are counted after
normalizing `\r\n` → `\n`. Stripping `\r` is a simple `tr -d '\r'`
in Bash and `$content -replace '\r', ''` in PowerShell. Ensures
identical counts regardless of platform checkout settings.

**Alternatives considered**:
- Count bytes as-is: Simpler but produces different counts on Windows
  vs Unix for the same file content. Rejected per clarification.
- Count Unicode codepoints: Over-engineered for this use case; byte
  count after normalization is sufficient.

## R5: PowerShell approach for Windows parity

**Decision**: Mirror the Bash script logic in PowerShell using native
cmdlets.

**Rationale**: PowerShell is available on all supported platforms
(ships with Windows, installable on macOS/Linux). Using native
cmdlets (`Get-ChildItem`, `Get-Content`, `Measure-Object`) avoids
requiring Unix utilities on Windows.

**Key mappings**:
- `git ls-files` → same (git is a requirement on all platforms)
- `wc -l` / `wc -c` → `Measure-Object -Line -Character`
- `tr -d '\r'` → `-replace '\r', ''`
- `file` / null-byte check → `[System.IO.File]::ReadAllBytes()`
- `find` fallback → `Get-ChildItem -Recurse -File`

**Alternatives considered**:
- Bash-only with Git Bash on Windows: Would work but forces Git Bash
  dependency and may behave differently than native Windows tools.
- Node.js/Python script: Adds runtime dependency, violates
  Simplicity and no-external-dependencies constraint.

## R6: spec-kit extension manifest and command structure

**Decision**: Follow the spec-kit extension guide conventions exactly.

**Rationale**: The extension guide prescribes `extension.yml` at the
repo root, commands in `commands/`, scripts in `scripts/`. The
command file references scripts via `scripts:` frontmatter with
`{SCRIPT}` placeholder for path rewriting during installation.

**Key details**:
- Extension ID: `owl`
- Command name: `speckit.owl.metrics`
- Command file: `commands/metrics.md`
- Scripts: `scripts/bash/metrics.sh` and
  `scripts/powershell/metrics.ps1`
- Schema version: `1.0`
