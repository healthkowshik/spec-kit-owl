# Contract: Catalog Entry for Spec Kit Owl

**Feature Branch**: `002-publish-extension`
**Date**: 2026-03-03

## Catalog Entry JSON

The exact JSON object to be added to `catalog.community.json` under the `extensions` key, alphabetically between `"cleanup"` and `"retrospective"`:

```json
{
  "owl": {
    "name": "Spec Kit Owl",
    "id": "owl",
    "description": "Spec-to-code metrics: line counts, character counts, and percentages",
    "author": "Health Kowshik",
    "version": "1.0.0",
    "download_url": "https://github.com/healthkowshik/spec-kit-owl/archive/refs/tags/v1.0.0.zip",
    "repository": "https://github.com/healthkowshik/spec-kit-owl",
    "homepage": "https://github.com/healthkowshik/spec-kit-owl",
    "documentation": "https://github.com/healthkowshik/spec-kit-owl/blob/main/README.md",
    "changelog": "https://github.com/healthkowshik/spec-kit-owl/blob/main/CHANGELOG.md",
    "license": "MIT",
    "requires": {
      "speckit_version": ">=0.1.0"
    },
    "provides": {
      "commands": 1,
      "hooks": 0
    },
    "tags": ["metrics", "spec-code", "analysis", "lines-of-code"],
    "verified": false,
    "downloads": 0,
    "stars": 0,
    "created_at": "2026-03-03T00:00:00Z",
    "updated_at": "2026-03-03T00:00:00Z"
  }
}
```

## Extensions README Table Row

Row to add in alphabetical order to the "Available Community Extensions" table in `extensions/README.md`:

```markdown
| Spec Kit Owl | Spec-to-code metrics: line counts, character counts, and percentages | [spec-kit-owl](https://github.com/healthkowshik/spec-kit-owl) |
```

## Updated Extension Manifest

The corrected `extension.yml` for the owl repository:

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

## Validation Checklist

- [ ] Extension ID uses only lowercase letters and hyphens: `owl` ✓
- [ ] Version follows semantic versioning: `1.0.0` ✓
- [ ] Description under 100 characters: 69 characters ✓
- [ ] Repository URL is public and accessible
- [ ] All referenced command files exist: `commands/metrics.md` ✓
- [ ] Tags are 2-5 lowercase descriptive strings: 4 tags ✓
- [ ] Download URL points to valid GitHub release archive
- [ ] Catalog entry `id` matches manifest `extension.id`
