# Data Model: Publish Extension to Community Catalog

**Feature Branch**: `002-publish-extension`
**Date**: 2026-03-03

## Entities

### Extension Manifest (`extension.yml`)

The authoritative metadata file in the extension repository root.

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `schema_version` | string | yes | Must be `"1.0"` |
| `extension.id` | string | yes | Lowercase letters and hyphens only; unique across catalog |
| `extension.name` | string | yes | Human-readable display name |
| `extension.version` | string | yes | Semantic version `X.Y.Z` |
| `extension.description` | string | yes | Under 100 characters |
| `extension.author` | string | yes | Author name or organization |
| `extension.repository` | string | yes | Valid public GitHub URL |
| `extension.license` | string | yes | SPDX license identifier (e.g., `"MIT"`) |
| `extension.homepage` | string | yes | Valid public URL |
| `requires.speckit_version` | string | yes | Semver range (e.g., `">=0.1.0"`) |
| `provides.commands` | list | yes | Each entry: `name`, `file`, `description` |
| `tags` | list | yes | 2-5 lowercase strings |

**State**: Static after release. Updated only on new version releases.

### Catalog Entry (JSON in `catalog.community.json`)

A JSON object keyed by extension ID within the `extensions` map.

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `name` | string | yes | Matches manifest `extension.name` |
| `id` | string | yes | Matches manifest `extension.id`; unique key |
| `description` | string | yes | Matches manifest `extension.description` |
| `author` | string | yes | Matches manifest `extension.author` |
| `version` | string | yes | Matches manifest `extension.version` |
| `download_url` | string | yes | GitHub archive URL for the tagged release |
| `repository` | string | yes | Matches manifest `extension.repository` |
| `homepage` | string | yes | Matches manifest `extension.homepage` |
| `documentation` | string | yes | URL to README.md on GitHub |
| `changelog` | string | yes | URL to CHANGELOG.md on GitHub |
| `license` | string | yes | Matches manifest `extension.license` |
| `requires.speckit_version` | string | yes | Matches manifest `requires.speckit_version` |
| `provides.commands` | integer | yes | Count of commands provided |
| `provides.hooks` | integer | yes | Count of hooks provided (0 for owl) |
| `tags` | list[string] | yes | Matches manifest `tags` |
| `verified` | boolean | yes | Always `false` for new submissions |
| `downloads` | integer | yes | Always `0` for new submissions |
| `stars` | integer | yes | Always `0` for new submissions |
| `created_at` | string | yes | ISO 8601 timestamp |
| `updated_at` | string | yes | ISO 8601 timestamp |

**State**: Created on first submission. Updated on version bumps via PR.

### GitHub Release

A tagged release on GitHub providing the download archive.

| Field | Type | Constraints |
|-------|------|-------------|
| Tag name | string | `v` prefix + semantic version (e.g., `v1.0.0`) |
| Title | string | Same as tag name or descriptive (e.g., `v1.0.0 - Initial Release`) |
| Release notes | string | Derived from CHANGELOG.md |
| Archive URL | string | Auto-generated: `https://github.com/{owner}/{repo}/archive/refs/tags/{tag}.zip` |

**State**: Immutable once created. New versions create new releases.

## Relationships

```
Extension Manifest (extension.yml)
  └─ describes → GitHub Release (tagged version)
       └─ referenced by → Catalog Entry (download_url)
```

- The manifest is the source of truth for all metadata fields.
- The catalog entry mirrors manifest fields plus adds catalog-specific metadata (downloads, stars, verified, timestamps).
- The GitHub release provides the downloadable archive URL that the catalog entry points to.
