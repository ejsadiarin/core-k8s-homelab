## ADDED Requirements

### Requirement: Secrets SHALL be stored as SealedSecrets in git
All secrets SHALL be converted to SealedSecret resources for safe git storage.

#### Scenario: Cloudflare tunnel credentials are sealed
- **WHEN** the cluster is configured
- **THEN** a SealedSecret for cloudflared credentials SHALL exist with:
  - name: `cloudflared-credentials` (or equivalent)
  - cluster-wide scope annotation
  - Encrypted credentials.json content

#### Scenario: Backup credentials are sealed
- **WHEN** Velero is configured
- **THEN** a SealedSecret for B2 credentials SHALL exist with:
  - name: `velero-b2-credentials`
  - cluster-wide scope annotation
  - Encrypted AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY

### Requirement: SealedSecrets SHALL use cluster-wide scope
All SealedSecrets SHALL use cluster-wide scope for flexibility.

#### Scenario: Cluster-wide annotation is present
- **WHEN** a SealedSecret is created
- **THEN** it SHALL have annotation:
  - `sealedsecrets.bitnami.com/cluster-wide: "true"`

### Requirement: Sealed secrets key rotation script SHALL exist
The system SHALL provide a script for rotating sealed secrets keys.

#### Scenario: Rotation script exists
- **WHEN** key rotation is needed
- **THEN** a script at `cluster/scripts/rotate-seal-key.sh` SHALL:
  - Extract current key from cluster
  - Generate new key pair
  - Resseal all SealedSecrets with new key
  - Update bootstrap secret file

### Requirement: Sealed secrets key SHALL be backed up
The sealed-secrets private key SHALL be backed up for disaster recovery.

#### Scenario: Key is backed up
- **WHEN** the sealed-secrets controller is deployed
- **THEN** the key secret `sealed-secrets-key` SHALL be backed up to:
  - External storage (B2 via Velero)
  - Offline storage (documented location)

### Requirement: SealedSecret creation workflow SHALL be documented
The process for creating new SealedSecrets SHALL be documented.

#### Scenario: Creating a new SealedSecret
- **WHEN** a developer needs to add a new secret
- **THEN** the workflow SHALL be:
  1. Create plain Secret YAML (do not commit)
  2. Run `kubeseal --format=yaml --scope=cluster-wide < secret.yaml > secret-sealed.yaml`
  3. Commit only the SealedSecret YAML
  4. Delete the plain Secret YAML
