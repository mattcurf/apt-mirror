#!/bin/bash
set -e

CRON_SCHEDULE="${CRON_SCHEDULE:-0 2 * * *}"

mkdir -p /var/spool/apt-mirror/var
touch /var/spool/apt-mirror/var/postmirror.sh
chmod +x /var/spool/apt-mirror/var/postmirror.sh

echo "Running initial apt-mirror sync..."
apt-mirror

echo "Setting up cron schedule: ${CRON_SCHEDULE}"
echo "${CRON_SCHEDULE} /usr/bin/apt-mirror >> /var/log/apt-mirror.log 2>&1" > /etc/cron.d/apt-mirror
chmod 0644 /etc/cron.d/apt-mirror
crontab /etc/cron.d/apt-mirror

echo "Starting cron daemon..."
exec cron -f
