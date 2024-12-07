# Homelab Services

- for the complete documentation see [https://github.com/ejsadiarin/wizardry](https://github.com/ejsadiarin/wizardry)

> [!IMPORTANT]
> **make sure that backups include the docker volumes for ALL services**

# Backing Up

NOTE: database backups should be `dump`ed, not copied (e.g. `pg_dump` for postgresql)
- see instructions below for specifics

*  Traefik
- bind: `./data` 
- volume: `traefik-certs` (`/var/lib/docker/volumes/traefik-certs/_data`) 

* Authentik
- bind: `./media`
- bind: `./custom-templates`
- bind: `./certs`
- volume: `database` (`/var/lib/docker/volumes/authentik_database/_data`)
- volume: `redis` (`/var/lib/docker/volumes/authentik_redis/_data`)

* Immich - read [backup and restore docs](https://immich.app/docs/administration/backup-and-restore/#filesystem)
- bind: `./library/library`
- bind: `./library/upload`
- bind: `./library/profile`
- bind: `./library/backups` (for the database) - immich does auto backups for db
- volume: `model-cache` (`/var/lib/docker/volumes/immich_model-cache/_data`)

* Gitea - read [backup and restore docs](https://docs.gitea.com/next/administration/backup-and-restore)
- database:
```bash
su git
./gitea dump -c ~/
```

* Ntfy
- bind: `./cache`
- bind: `./etc`

* Portainer
- 

## Traefik

- make sure to add a certificate file `acme.json` on `services/traefik/data/`

```bash
touch services/traefik/data/acme.json
```
## Authentik

*note that: run `sudo sysctl vm.overcommit_memory=1` for redis*

### middlewares:

- `authentik@file` - services with type: `Proxy Provider`

## Immich

*note that: run `sudo sysctl vm.overcommit_memory=1` for redis*

### backup immich regularly

1. postgres db backup immich
- built-in automatic backups (see docs)

- if need manual:
```bash
docker exec -t immich_postgres pg_dumpall --clean --if-exists --username=postgres | gzip > "/path/to/backup/dump.sql.gz"
```


2. library (media files) backup

only need to backup original content stored in:
- `UPLOAD_LOCATION/library`
- `UPLOAD_LOCATION/upload`
- `UPLOAD_LOCATION/profile`

backup onsite & offsite
```bash
```

### restore from backup
- see [docs](https://immich.app/docs/administration/backup-and-restore#manual-backup-and-restore) for more details

```bash
docker compose down -v  # CAUTION! Deletes all Immich data to start from scratch
## Uncomment the next line and replace DB_DATA_LOCATION with your Postgres path to permanently reset the Postgres database
# rm -rf DB_DATA_LOCATION # CAUTION! Deletes all Immich data to start from scratch
docker compose pull             # Update to latest version of Immich (if desired)
docker compose create           # Create Docker containers for Immich apps without running them
docker start immich_postgres    # Start Postgres server
sleep 10                        # Wait for Postgres server to start up
# Check the database user if you deviated from the default
gunzip < "/path/to/backup/dump.sql.gz" \
| sed "s/SELECT pg_catalog.set_config('search_path', '', false);/SELECT pg_catalog.set_config('search_path', 'public, pg_catalog', true);/g" \
| docker exec -i immich_postgres psql --username=postgres  # Restore Backup
docker compose up -d            # Start remainder of Immich apps
```
