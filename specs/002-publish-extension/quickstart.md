# Quickstart: Publish Spec Kit Owl to Community Catalog

**Feature Branch**: `002-publish-extension`
**Date**: 2026-03-03

## Prerequisites

- Git and `gh` CLI installed and authenticated
- Repository `healthkowshik/spec-kit-owl` is public on GitHub
- All extension code is merged to `main` (confirmed: PR #1 merged `001-owl-metrics`)

## Step 1: Update Extension Manifest

Edit `extension.yml` in the owl repository to fix the description length, add `homepage`, and add `tags`:

```yaml
schema_version: "1.0"

extension:
  id: "owl"
  name: "Spec Kit Owl"
  version: "1.0.0"
  description: "Spec-to-code metrics: line counts, character counts, and percentages"
  author: "Health Kowshik"
  repository: "https://github.com/healthkowshik/spec-kit-owl"
  license: "MIT"
  homepage: "https://github.com/healthkowshik/spec-kit-owl"

requires:
  speckit_version: ">=0.1.0"

provides:
  commands:
    - name: "speckit.owl.metrics"
      file: "commands/metrics.md"
      description: "Display spec vs non-spec line counts, character counts, and percentages"

tags:
  - "metrics"
  - "spec-code"
  - "analysis"
  - "lines-of-code"
```

## Step 2: Create CHANGELOG.md

Create `CHANGELOG.md` in the repository root:

```markdown
# Changelog

All notable changes to the Spec Kit Owl extension will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-03-03

### Added

- `speckit.owl.metrics` command for spec-to-code metrics
- Summary mode: line counts, character counts, and spec percentages
- Breakdown mode (`--breakdown`): per-directory analysis table
- Bash 4+ implementation (`scripts/bash/metrics.sh`)
- PowerShell 5.1+ implementation (`scripts/powershell/metrics.ps1`)
- Binary file detection and symlink filtering
- `.gitignore`-aware file enumeration via `git ls-files`
- Cross-platform line ending normalization
- 9 automated tests across 5 fixture repositories
```

## Step 3: Commit and Push to Main

```bash
git checkout main
git add extension.yml CHANGELOG.md
git commit -m "Prepare extension for community catalog publication"
git push origin main
```

## Step 4: Create GitHub Release

```bash
git tag v1.0.0
git push origin v1.0.0
gh release create v1.0.0 --title "v1.0.0 - Initial Release" --notes-file CHANGELOG.md
```

## Step 5: Verify Release Archive

```bash
# Confirm the archive URL is accessible
curl -sI https://github.com/healthkowshik/spec-kit-owl/archive/refs/tags/v1.0.0.zip | head -1
# Expected: HTTP/2 302 (redirects to download)
```

## Step 6: Fork and Update spec-kit Catalog

```bash
# Fork spec-kit (if not already forked)
gh repo fork github/spec-kit --clone

# Create submission branch
cd spec-kit
git checkout -b add-owl-extension

# Edit extensions/catalog.community.json — add "owl" entry
# Edit extensions/README.md — add table row
# (See contracts/catalog-entry.md for exact content)

git add extensions/catalog.community.json extensions/README.md
git commit -m "Add spec-kit-owl to community catalog"
git push origin add-owl-extension
```

## Step 7: Submit Pull Request

```bash
gh pr create \
  --title "Add spec-kit-owl to community catalog" \
  --body "## Extension Details
- **Name**: Spec Kit Owl
- **ID**: owl
- **Version**: 1.0.0
- **Author**: Health Kowshik
- **Repository**: https://github.com/healthkowshik/spec-kit-owl
- **Description**: Spec-to-code metrics: line counts, character counts, and percentages

## Checklist
- [x] extension.yml manifest is valid
- [x] README.md with installation and usage instructions
- [x] LICENSE file present (MIT)
- [x] CHANGELOG.md with version history
- [x] GitHub release created with download archive
- [x] Tested on macOS (Bash 4+)
- [x] All 9 automated tests passing"
```

## Verification

After PR is merged, confirm discoverability:

```bash
specify extension search owl
# Should show: Spec Kit Owl — Spec-to-code metrics
```
