#!/bin/bash

LOG_DIR="/var/log/myapp"
BACKUP_DIR="/backup/logs"
DAYS_TO_KEEP=7

# Create backup dir if missing
mkdir -p "$BACKUP_DIR"

# Archive logs older than 7 days
find "$LOG_DIR" -name "*.log" -mtime +$DAYS_TO_KEEP -exec gzip {} \;

# Move compressed logs to backup
mv "$LOG_DIR"/*.gz "$BACKUP_DIR/" 2>/dev/null

# Report result
echo "[$(date)] Cleanup complete. Logs older than ${DAYS_TO_KEEP}d archived."


# cleanup.sh — Daily maintenance script
# Run via cron: 0 2 * * * /opt/scripts/cleanup.sh
