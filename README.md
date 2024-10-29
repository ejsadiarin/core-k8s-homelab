# Homelab Services

- for the complete documentation see [https://github.com/ejsadiarin/wizardry](https://github.com/ejsadiarin/wizardry)

> [!IMPORTANT]
> **make sure that backups include the docker volumes for ALL services**

## Traefik

- make sure to add a certificate file `acme.json` on `services/traefik/data/`

```bash
touch services/traefik/data/acme.json
```
