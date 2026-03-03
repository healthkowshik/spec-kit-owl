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
