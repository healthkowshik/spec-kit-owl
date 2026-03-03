# Feature Specification: Publish Extension to Community Catalog

**Feature Branch**: `002-publish-extension`
**Created**: 2026-03-03
**Status**: Draft
**Input**: User description: "Publish the owl extension to the spec-kit community catalog per the Extension Publishing Guide"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Prepare Extension for Publication (Priority: P1)

As an extension author, I want to ensure the owl extension meets all publishing requirements so that it passes the catalog review process on the first submission.

The extension already has `extension.yml`, `README.md`, `LICENSE`, command files, scripts, and tests. However, several gaps must be addressed before submission:

1. The `extension.yml` description exceeds the 100-character limit
2. The manifest is missing `homepage` and `tags` fields
3. No `CHANGELOG.md` exists to document the version history
4. No GitHub release has been created with a version tag

**Why this priority**: Without meeting the required manifest fields and file requirements, the extension cannot be submitted at all. This is the gating prerequisite.

**Independent Test**: Can be fully tested by validating the extension manifest against the publishing guide checklist and confirming all required files exist in the repository root.

**Acceptance Scenarios**:

1. **Given** the extension repository, **When** the manifest is validated, **Then** the `extension.yml` contains all required fields: `schema_version`, `extension.id`, `extension.name`, `extension.version`, `extension.description` (under 100 characters), `extension.author`, `extension.repository`, `extension.license`, `extension.homepage`, `requires.speckit_version`, `provides.commands`, and `tags`
2. **Given** the extension repository, **When** a reviewer checks the root directory, **Then** `extension.yml`, `README.md`, `LICENSE`, and `CHANGELOG.md` all exist
3. **Given** the extension manifest, **When** the ID field is inspected, **Then** it contains only lowercase letters and hyphens
4. **Given** the extension manifest, **When** the version field is inspected, **Then** it follows semantic versioning (X.Y.Z)
5. **Given** the extension manifest, **When** the tags field is inspected, **Then** it contains 2-5 lowercase descriptive tags

---

### User Story 2 - Create GitHub Release (Priority: P2)

As an extension author, I want to tag and create a GitHub release so that users and the catalog can reference a stable download archive URL.

**Why this priority**: The catalog submission requires a valid `download_url` pointing to a GitHub release archive. Without a release, the submission PR cannot be created.

**Independent Test**: Can be tested by verifying the release exists on GitHub and the archive URL returns a downloadable zip file.

**Acceptance Scenarios**:

1. **Given** the repository with all changes committed and pushed, **When** a version tag is created, **Then** the tag follows the `v1.0.0` format
2. **Given** a version tag has been pushed, **When** a GitHub release is created, **Then** it has a title, release notes referencing the changelog, and an accessible archive URL
3. **Given** the GitHub release exists, **When** the archive URL is accessed, **Then** a zip file containing the complete extension is downloaded successfully

---

### User Story 3 - Submit to Community Catalog (Priority: P3)

As an extension author, I want to submit the owl extension to the spec-kit community catalog so that other developers can discover and install it via `specify extension search`.

This involves forking the spec-kit repository, adding the extension to `catalog.community.json`, updating the extensions README, and submitting a pull request.

**Why this priority**: This is the final delivery step that makes the extension publicly discoverable, but it depends on the release being created first.

**Independent Test**: Can be tested by verifying the PR is created with the correct catalog entry, all automated checks pass, and the extension appears in a local catalog search.

**Acceptance Scenarios**:

1. **Given** a fork of the spec-kit repository, **When** the catalog entry is added, **Then** `catalog.community.json` contains a valid entry with all required fields (name, id, description, author, version, download_url, repository, homepage, documentation, changelog, license, requires, provides, tags, verified=false, downloads=0, stars=0, timestamps)
2. **Given** the catalog entry is added, **When** the extensions README is updated, **Then** the owl extension appears in the "Available Extensions" table in alphabetical order
3. **Given** all catalog changes are committed, **When** a PR is submitted to `github/spec-kit`, **Then** the PR description includes the extension name, ID, version, author, repository URL, description, and a confirmation checklist

---

### Edge Cases

- What happens if the extension ID "owl" is already taken in the community catalog? The author must choose a different, unique ID.
- What happens if the GitHub repository is private? The submission will fail validation — the repository must be public for community catalog inclusion.
- What happens if the `download_url` archive becomes unavailable after submission? The extension will fail installation for users until the URL is restored via a new release or catalog update.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The extension manifest MUST have a description under 100 characters
- **FR-002**: The extension manifest MUST include a `homepage` field with a valid public URL
- **FR-003**: The extension manifest MUST include 2-5 lowercase `tags` relevant to the extension's purpose
- **FR-004**: The repository MUST contain a `CHANGELOG.md` documenting at least the v1.0.0 release
- **FR-005**: A GitHub release MUST be created with a `v1.0.0` tag and release notes
- **FR-006**: The extension MUST be installable from its GitHub release archive URL using `specify extension add --from <archive-url>`
- **FR-007**: The catalog entry in `catalog.community.json` MUST contain all required fields per the publishing guide
- **FR-008**: The extensions README in the spec-kit repository MUST be updated with the owl extension entry in alphabetical order
- **FR-009**: A pull request MUST be submitted to `github/spec-kit` with the catalog and README changes
- **FR-010**: All command files referenced in `extension.yml` MUST exist at their specified paths

### Key Entities

- **Extension Manifest** (`extension.yml`): The metadata file that describes the extension's identity, version, dependencies, and provided commands
- **Catalog Entry**: A JSON object in `catalog.community.json` that enables discovery and installation of the extension through the spec-kit ecosystem
- **GitHub Release**: A tagged, versioned archive of the extension source code that provides a stable download URL for the catalog

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The extension manifest passes all validation checks from the publishing guide with zero errors
- **SC-002**: The extension installs successfully from the GitHub release archive URL in under 30 seconds
- **SC-003**: A pull request is submitted to the spec-kit community catalog and passes all automated checks
- **SC-004**: The extension is discoverable via catalog search after the PR is merged

## Assumptions

- The GitHub repository `healthkowshik/spec-kit-owl` is (or will be made) publicly accessible
- The author has a GitHub account with permission to fork `github/spec-kit` and submit pull requests
- The extension ID "owl" is not already claimed in the community catalog
- The current `v1.0.0` version in `extension.yml` is the intended first release version
- The spec-kit community catalog accepts new submissions (the process is not frozen or deprecated)
