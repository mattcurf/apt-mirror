# apt-mirror

Local mirror for Debian and Ubuntu repositories, serving amd64, arm64, and source packages via Docker.

## Prerequisites

- Docker and Docker Compose
- Sufficient disk space (~1 TB+ for all mirrored distributions)

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

| Distribution          | Components                                      | Architectures      |
|-----------------------|-------------------------------------------------|---------------------|
| Debian Trixie         | `main contrib non-free non-free-firmware`        | amd64, arm64, src  |
| Debian Bookworm       | `main contrib non-free non-free-firmware`        | amd64, arm64, src  |
| Ubuntu 24.04 (Noble)  | `main restricted universe multiverse`            | amd64, arm64, src  |

Each distribution includes base, security, and update repos. Ubuntu also includes backports.

## Client Configuration

On machines in your local subnet, replace `<MIRROR>` below with the IP or hostname of the machine running this stack. Use port `8020` if port 80 is unavailable (e.g., `http://<MIRROR>:8020/...`).

### Debian Trixie

```bash
sudo tee /etc/apt/sources.list <<EOF
deb http://<MIRROR>/deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://<MIRROR>/deb.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb http://<MIRROR>/deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
EOF
sudo apt update
```

### Debian Bookworm

```bash
sudo tee /etc/apt/sources.list <<EOF
deb http://<MIRROR>/deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://<MIRROR>/deb.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb http://<MIRROR>/deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
EOF
sudo apt update
```

### Ubuntu 24.04 (Noble) — amd64

```bash
sudo tee /etc/apt/sources.list <<EOF
deb http://<MIRROR>/archive.ubuntu.com/ubuntu noble main restricted universe multiverse
deb http://<MIRROR>/archive.ubuntu.com/ubuntu noble-updates main restricted universe multiverse
deb http://<MIRROR>/archive.ubuntu.com/ubuntu noble-security main restricted universe multiverse
deb http://<MIRROR>/archive.ubuntu.com/ubuntu noble-backports main restricted universe multiverse
EOF
sudo apt update
```

### Ubuntu 24.04 (Noble) — arm64

```bash
sudo tee /etc/apt/sources.list <<EOF
deb http://<MIRROR>/ports.ubuntu.com/ubuntu-ports noble main restricted universe multiverse
deb http://<MIRROR>/ports.ubuntu.com/ubuntu-ports noble-updates main restricted universe multiverse
deb http://<MIRROR>/ports.ubuntu.com/ubuntu-ports noble-security main restricted universe multiverse
deb http://<MIRROR>/ports.ubuntu.com/ubuntu-ports noble-backports main restricted universe multiverse
EOF
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
