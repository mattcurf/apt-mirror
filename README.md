# apt-mirror

Local Debian Trixie mirror serving amd64, arm64, and source packages via Docker.

## Prerequisites

- Docker and Docker Compose
- Sufficient disk space (~300+ GB for a full mirror)

## Setup

1. **Create the mirror directory** (bind mount for mirrored packages):

   ```bash
   mkdir -p mirror
   ```

2. **Build and start the services:**

   ```bash
   docker compose up -d --build
   ```

3. The `apt-mirror` container will immediately begin syncing on first start. Monitor progress with:

   ```bash
   docker compose logs -f apt-mirror
   ```

The initial sync will take a significant amount of time depending on your connection speed. Subsequent syncs run daily at 2:00 AM via cron (configurable via `CRON_SCHEDULE` in `docker-compose.yml`).

## Services

| Service    | Description                          | Ports       |
|------------|--------------------------------------|-------------|
| nginx      | Serves mirrored packages over HTTP   | 80, 8020    |
| apt-mirror | Mirrors Debian repos, syncs via cron | —           |

## What's Mirrored

Configured in `apt-mirror/mirror.list`:

- **Debian Trixie** — `main contrib non-free non-free-firmware`
- **Trixie Security** — `trixie-security`
- **Trixie Updates** — `trixie-updates`
- **Architectures:** amd64, arm64, source

## Client Configuration

On machines in your local subnet, update `/etc/apt/sources.list` to point to the mirror host:

```
deb http://<mirror-host-ip>/deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://<mirror-host-ip>/deb.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb http://<mirror-host-ip>/deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
```

Replace `<mirror-host-ip>` with the IP address of the machine running this stack. Use port `8020` if port 80 is unavailable (e.g., `http://<mirror-host-ip>:8020/...`).

Then run:

```bash
sudo apt update
```

## Managing the Mirror

```bash
# Rebuild after config changes
docker compose up -d --build apt-mirror

# Trigger a manual sync
docker compose exec apt-mirror apt-mirror

# View sync logs
docker compose logs -f apt-mirror

# Stop everything
docker compose down
```

## Configuration

- **Mirror sources:** `apt-mirror/mirror.list`
- **Sync schedule:** `CRON_SCHEDULE` env var in `docker-compose.yml` (default: `0 2 * * *`)
- **Download threads:** `nthreads` in `apt-mirror/mirror.list` (default: 60)
