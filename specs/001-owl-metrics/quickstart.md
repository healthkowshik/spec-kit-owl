# Quickstart: Owl Metrics Extension

**Branch**: `001-owl-metrics` | **Date**: 2026-03-03

## Prerequisites

- Git installed and available in PATH
- A spec-kit project (has `.specify/` directory)
- Bash 4+ (macOS/Linux) or PowerShell 5.1+ (Windows)

## Install the extension

From your project root:

```bash
specify extension add --dev /path/to/spec-kit-owl
```

Verify installation:

```bash
specify extension list
```

You should see `owl` listed with the `speckit.owl.metrics` command.

## Usage

### View spec-to-code metrics

Invoke the command through your AI agent (e.g., Claude Code):

```
/speckit.owl.metrics
```

Expected output:

```text
Spec vs Code Metrics
====================

  Spec lines:        234
  Spec chars:      8,901
  Non-spec lines:  1,456
  Non-spec chars: 52,340

  Total lines:     1,690
  Total chars:    61,241

  Spec %:  Lines: 14%  |  Chars: 15%
```

### View per-directory breakdown

```
/speckit.owl.metrics --breakdown
```

This adds a table showing each directory's line count, character
count, and whether it is categorized as spec or non-spec.

## Running the script directly

You can also run the underlying script directly:

**Bash (macOS/Linux)**:

```bash
bash scripts/bash/metrics.sh
bash scripts/bash/metrics.sh --breakdown
```

**PowerShell (Windows)**:

```powershell
powershell -File scripts/powershell/metrics.ps1
powershell -File scripts/powershell/metrics.ps1 -Breakdown
```

## Verify correctness

To manually verify the counts match:

```bash
# Count spec lines (Unix)
find specs/ .specify/ -type f ! -name '*.png' -exec cat {} + | wc -l

# Count all non-ignored text files
git ls-files --cached --others --exclude-standard | \
  grep -v '^specs/' | grep -v '^\.specify/' | \
  xargs wc -l
```

The numbers should match the extension's output.
