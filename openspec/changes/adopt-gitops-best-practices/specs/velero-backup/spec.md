## ADDED Requirements

### Requirement: Velero SHALL be deployed with Restic integration
The system SHALL deploy Velero with Restic for file-level backup of PVCs.

#### Scenario: Velero is deployed with Restic
- **WHEN** the infrastructure components are synced
- **THEN** Velero SHALL be running with:
  - Restic integration enabled (`--use-restic` flag)
  - Backup storage location configured for Backblaze B2
  - Volume snapshot location configured

#### Scenario: Velero uses B2 as backup target
- **WHEN** Velero is deployed
- **THEN** the BackupStorageLocation SHALL be configured with:
  - Provider: aws (S3-compatible)
  - Bucket: B2 bucket name
  - Endpoint: Backblaze B2 S3 endpoint
  - Credentials from sealed secret

### Requirement: Velero credentials SHALL be stored as SealedSecret
B2 credentials for Velero SHALL be stored as a SealedSecret for git-safe storage.

#### Scenario: B2 credentials are sealed
- **WHEN** Velero is configured
- **THEN** a SealedSecret named `velero-b2-credentials` SHALL exist with:
  - `AWS_ACCESS_KEY_ID`: B2 key ID
  - `AWS_SECRET_ACCESS_KEY`: B2 application key

### Requirement: Velero SHALL have scheduled backups for namespaces with PVCs
The system SHALL define Schedule resources for automated PVC backups.

#### Scenario: Daily backup schedule exists
- **WHEN** Velero is deployed
- **THEN** a Schedule named `daily-pvc-backup` SHALL exist with:
  - schedule: "0 3 * * *" (daily at 3 AM)
  - includeNamespaces: all namespaces with PVCs
  - ttl: 720h (30 days retention)

#### Scenario: Weekly backup schedule exists
- **WHEN** Velero is deployed
- **THEN** a Schedule named `weekly-pvc-backup` SHALL exist with:
  - schedule: "0 2 * * 0" (weekly Sunday 2 AM)
  - includeNamespaces: all namespaces with PVCs
  - ttl: 2160h (90 days retention)

### Requirement: Velero SHALL support PVC restore to different storage class
Velero restore SHALL support migrating PVCs between storage classes.

#### Scenario: Restore to Longhorn storage class
- **WHEN** a backup is restored with modified PVC config
- **THEN** the PVC SHALL be created with the new storage class
- **AND** data SHALL be restored from Restic backup

### Requirement: Velero backups SHALL be verifiable
Velero backups SHALL be verifiable without full restore.

#### Scenario: Backup can be described
- **WHEN** a Velero backup completes
- **THEN** `velero backup describe <name>` SHALL show:
  - Phase: Completed
  - Items backed up count
  - Restic volumes backed up count

### Requirement: Velero shall be included in infrastructure ApplicationSet
The Velero application SHALL be auto-discovered by the infrastructure ApplicationSet.

#### Scenario: Velero is auto-deployed
- **WHEN** the infrastructure ApplicationSet scans directories
- **THEN** Velero at `cluster/infrastructure/backup/velero/` SHALL be deployed
