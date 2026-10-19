# Contabo Server Configuration

NixOS-managed containerized application stack running on a Contabo VPS at `62.84.178.194`.

## Architecture Overview

```
Internet (HTTPS on port 443)
         ↓
    Traefik (Reverse Proxy)
    apps-traefik-1
         ↓
    Vikunja (Todo App)
    apps-vikunja-1
         ↓
    PostgreSQL (Database)
    apps-postgres-1
    (port 5432, internal only)
```

### Service Interaction Flow

1. **Traefik** (`apps-traefik-1`)
   - Reverse proxy and ingress controller
   - Listens on ports 80 (HTTP) and 443 (HTTPS)
   - Automatically handles Let's Encrypt certificate renewal
   - Routes incoming traffic to backend services based on hostname
   - Connects to both `web` (public) and `backend` (internal) networks
   - Discovers services via Docker provider on the `backend` network
   - Forwards requests to Vikunja at internal hostname `vikunja` (via `backend` network)
   - Certificate stored in `/var/lib/apps/letsencrypt/acme.json`

2. **Vikunja** (`apps-vikunja-1`)
   - Todo/task management application
   - **Only on `backend` network** (not exposed to public `web` network)
   - Receives requests **only from Traefik** (cannot be accessed directly)
   - Connects to PostgreSQL at internal hostname `postgres` (port 5432)
   - Stores uploaded files in `/var/lib/apps/vikunja/files/`
   - Database credentials passed via environment variables from agenix

3. **PostgreSQL** (`apps-postgres-1`)
   - Relational database backend
   - Only on `backend` network (marked `internal: true`, completely isolated)
   - Listens on port 5432 (internal Docker network only, not exposed to internet)
   - Data persisted in `/var/lib/apps/postgres/data/`
   - Health checks verify database connectivity
   - Credentials managed via agenix secrets

## Deployment & Reproducibility

### NixOS Configuration Files

- **`default.nix`** - Main system configuration
  - Boot loader and disk setup (via `disko.nix`)
  - Hardware configuration (via `hardware-configuration.nix`)
  - Networking (static IPv4, DNS, firewall)
  - SSH key management (root login via key only)
  - Docker and Docker Compose installation
  - systemd service for application stack
  - Directory creation and permissions
  - Secrets management via agenix

- **`disko.nix`** - Storage layout (GPT, BIOS boot partition, root filesystem)

- **`hardware-configuration.nix`** - Auto-generated hardware details

- **`home.nix`** - User configuration for root account

- **`server/docker-compose.yaml`** - Container definitions
  - Uses generic service names (`apps-traefik-1`, `apps-postgres-1`, `apps-vikunja-1`)
  - Enables easy addition of future services
  - Networks:
    - `web` - Public-facing (Traefik only)
    - `apps` - Internal service-to-service communication
    - No direct internet access for database or app

### Secrets Management

Environment variables are encrypted using **agenix** (age encryption) with:
- Server SSH host key
- User SSH key

**Encrypted file**: `secrets/contabo-server/apps.env.age`

**Decryption flow**:
1. During `nixos-rebuild switch`, agenix decrypts the encrypted file
2. Secret is written to `/var/lib/apps/.env` with restricted permissions (0600)
3. systemd service `apps-compose` waits for agenix secrets before starting
4. Docker Compose loads environment variables from decrypted file

**Contains**:
- `POSTGRES_PASSWORD` - Database password
- `POSTGRES_DB` - Database name
- `POSTGRES_USER` - Database user
- `TRAEFIK_*` - Traefik configuration
- `VIKUNJA_*` - Vikunja application settings

## Deployment Steps

### Initial Setup
```bash
# On the server after OS installation (as the tobias user — root SSH login is disabled):
cd ~/.dotfiles
git pull

# Deploy the system configuration
sudo nixos-rebuild switch --flake .#contabo-server
```

### Updates & Changes

```bash
# Pull latest changes
cd ~/.dotfiles
git pull

# Rebuild and activate new configuration
sudo nixos-rebuild switch --flake .#contabo-server

# Check service status
sudo systemctl status apps-compose

# View container logs
docker ps
docker logs apps-vikunja-1
docker logs apps-postgres-1
docker logs apps-traefik-1
```

### Editing Secrets

```bash
# Add server SSH key to agenix keying
agenix -e secrets/contabo-server/apps.env.age

# Commit encrypted changes
git add secrets/contabo-server/apps.env.age
git commit -m "chore: update server secrets"
git push

# Deploy on server
cd ~/.dotfiles && git pull && sudo nixos-rebuild switch --flake .#contabo-server
```

## Directory Structure

```
/var/lib/apps/
├── .env                      (agenix-managed, symlink to /run/agenix/apps.env)
├── vikunja/
│   └── files/               (uploaded files, 0777 permissions for container)
├── postgres/
│   └── data/                (database files, 0777 permissions for container)
└── letsencrypt/
    └── acme.json            (Let's Encrypt certificates, 0600 permissions)

/etc/apps/
└── docker-compose.yaml      (deployed from ./server/docker-compose.yaml)
```

## Networking

### Firewall Rules
- **Port 80** (HTTP) - allowed, redirects to HTTPS via Traefik
- **Port 443** (HTTPS) - allowed, Traefik serves certificates
- **Port 5432** (PostgreSQL) - **NOT exposed** to internet (internal only)

### DNS
- Domain: `todo.tobiornot2b.com` → `62.84.178.194`
- Nameservers: `195.179.224.53`, `209.126.15.53` (Contabo DNS)

### Internal Docker Networks

The service architecture uses two separate Docker networks for security:

- **`web` (apps-web)** - Public-facing network
  - Only Traefik listens to ports 80 and 443
  - Receives all internet traffic
  - **Isolated from application services**

- **`backend` (apps-backend)** - Internal application network
  - Marked `internal: true` - cannot access internet
  - Traefik, Vikunja, and PostgreSQL communicate here
  - **Security guarantee**: No container on this network can be directly accessed from internet
  - Traefik bridges both networks, routing public traffic to backend services

## Maintenance

### Monitoring

```bash
# SSH into server (root login is disabled — tobias has passwordless sudo)
ssh tobias@62.84.178.194

# Check system resource usage
htop
iotop

# View container status
docker ps -a

# Check service logs
sudo journalctl -u apps-compose -f

# Test connectivity to Vikunja
curl https://todo.tobiornot2b.com
```

### AWS Backup Prerequisites

Backups are stored in the AWS S3 bucket
`tmaede-backup` in `eu-central-1`. Keep S3
Block Public Access enabled. A bucket may contain independent Restic
repositories under separate prefixes, for example `vikunja/` and
`nextcloud/`.

Create a dedicated IAM user such as `tmaede-restic-backup`, with no console
access. Create an access key for it and attach the following inline policy. It
limits the user to this bucket while allowing Restic to upload, restore, use
multipart uploads, and prune expired backup data:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListResticBucket",
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads"
      ],
      "Resource": "arn:aws:s3:::tmaede-backup"
    },
    {
      "Sid": "ManageResticObjects",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:AbortMultipartUpload",
        "s3:ListMultipartUploadParts"
      ],
      "Resource": "arn:aws:s3:::tmaede-backup/*"
    }
  ]
}
```

Do not use an AWS root access key or `AmazonS3FullAccess`. `s3:DeleteObject`
is required because the configured Restic retention task prunes unreferenced
repository data. Store the access-key ID and secret access key only in the
agenix-encrypted Restic secret described below.

### Automated Vikunja Backups

`vikunja-backup.timer` runs nightly at 01:00 (Europe/Berlin). It stops
Vikunja briefly, creates a logical PostgreSQL dump plus a copy of the
attachment directory, and sends the staging directory to the encrypted Restic
repository in S3. PostgreSQL's raw data directory is intentionally not copied.

Before deploying, create the two agenix secrets:

```bash
agenix -e secrets/contabo-server/restic-s3.env.age
agenix -e secrets/contabo-server/restic-password.age
```

`restic-s3.env.age` must use this dotenv format:

```dotenv
RESTIC_REPOSITORY=s3:s3.eu-central-1.amazonaws.com/tmaede-backup/vikunja
AWS_DEFAULT_REGION=eu-central-1
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
```

`restic-password.age` contains only a long, unique repository password. Keep
an offline recovery copy of that password.

Useful commands on the server:

```bash
sudo systemctl start vikunja-backup.service
systemctl list-timers vikunja-backup.timer
sudo journalctl -u vikunja-backup.service -n 100
```

### Certificate Renewal

Traefik automatically renews Let's Encrypt certificates 30 days before expiration. Certificate status is visible in `/var/lib/apps/letsencrypt/acme.json`. No manual intervention needed.

## Scalability

The setup is designed for future expansion:

1. **Add new services**: Extend `server/docker-compose.yaml` with new container definitions
2. **Add new secrets**: Update `secrets/contabo-server/apps.env.age` and reference in compose file
3. **Add new routes**: Configure Traefik labels in compose file for additional hostnames

Example: Adding a second application (e.g., `api.tobiornot2b.com`):
```yaml
# In docker-compose.yaml
  my-api:
    image: my-api:latest
    networks:
      - apps
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api.rule=Host(`api.tobiornot2b.com`)"
      - "traefik.http.services.api.loadbalancer.server.port=8000"
```

## Flake Integration

Configuration is integrated into `flake.nix`:

```nix
contabo-server = lib.nixosSystem rec {
  inherit system;
  modules = [
    disko.nixosModules.disko
    agenix.nixosModules.default           # Enables age.secrets
    ./hosts/contabo-server
    { environment.systemPackages = [ agenix.packages.${system}.default ]; }
    home-manager.nixosModules.home-manager
    { home-manager.users.root = import ./hosts/contabo-server/home.nix; }
  ];
};
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Container won't start after rebuild | Check `sudo systemctl status apps-compose` and `sudo journalctl -u apps-compose -n 50` |
| Database connection refused | Verify PostgreSQL is healthy: `docker ps` (should show `healthy`) and check `.env` credentials |
| HTTPS certificate expired | Traefik handles renewal automatically; check `/var/lib/apps/letsencrypt/acme.json` permissions (should be 0600) |
| Vikunja can't access database | Ensure `postgres` hostname resolves in `apps` network; check container network: `docker inspect apps-vikunja-1` |
| Permission denied on uploaded files | Ensure `/var/lib/apps/vikunja/files` has 0777 permissions: `sudo chmod 777 /var/lib/apps/vikunja/files` |

## Contact & Support

- Git repository: https://github.com/tobiornot2b/dotfiles
- Server admin: Tobias
