## ADDED Requirements

### Requirement: Renovate SHALL be configured for automated dependency updates
The system SHALL provide a `.github/renovate.json` configuration for automated dependency management.

#### Scenario: Renovate configuration exists
- **WHEN** the repository is configured
- **THEN** a `.github/renovate.json` file SHALL exist with:
  - schedule: "* 0-4 * * 1" (weekly during off-hours)
  - extends: ["config:recommended"]

### Requirement: Renovate SHALL manage Helm chart versions
Renovate SHALL detect and update Helm chart versions in kustomization.yaml files.

#### Scenario: Helm charts are updated
- **WHEN** a new Helm chart version is released
- **THEN** Renovate SHALL create a PR updating the `version:` field in kustomization.yaml

### Requirement: Renovate SHALL manage Docker image tags
Renovate SHALL detect and update Docker image tags in deployment and statefulset manifests.

#### Scenario: Docker images are updated
- **WHEN** a new Docker image tag is available
- **THEN** Renovate SHALL create a PR updating the `image:` field

### Requirement: Renovate SHALL use regex managers for custom formats
Renovate SHALL use custom regex managers to detect versions in project-specific formats.

#### Scenario: Regex manager detects versions
- **WHEN** Renovate scans deployment.yaml files
- **THEN** the regex pattern `image:\s+(?<depName>[^\s:@]+):(?<currentValue>[^\s@]+)` SHALL detect image versions

### Requirement: Related packages SHALL be grouped
Renovate SHALL group related packages to reduce PR count and ensure compatibility.

#### Scenario: CNPG packages are grouped
- **WHEN** CloudNativePG packages have updates
- **THEN** they SHALL be grouped under "CNPG Stack"

### Requirement: Renovate SHALL respect GitHub App authentication
Renovate configuration SHALL be compatible with GitHub App or GitHub Actions authentication.

#### Scenario: Renovate runs on schedule
- **WHEN** the scheduled time occurs
- **THEN** Renovate SHALL scan the repository and create PRs for available updates