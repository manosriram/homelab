#!/bin/bash

source ~/.bashrc;

# Exit if no tag argument is provided
[ -z "$1" ] && { echo "Usage: $0 <tag>"; exit 1; }
TAG="$1" # Assign the provided tag

# Define log directory and create it if it doesn't exist
LOG_DIR="/var/log/restic_backups"
mkdir -p "$LOG_DIR"

# Create a timestamped log file
LOG_FILE="$LOG_DIR/$(date +%d-%m-%Y-%H%M%S).log"

# Paths to backup (customize this list)
BACKUP_PATHS="/fs/containers/immich/ /fs/containers/seafile/ /fs/containers/tubearchivist/ /fs/containers/vaultwarden/ /fs/containers/scripts/ /fs/containers/jellyfin/media/backedup_media /fs/containers/syncthing/data"

HEALTHCHECKS_URL="https://hc-ping.com/5d70a7da-b8ca-4571-a059-839cff1fb6d0"

# Perform backup and log status
restic backup --tag "$TAG" $BACKUP_PATHS &>> "$LOG_FILE" \
  && echo "Backup with tag '$TAG' completed." | tee -a "$LOG_FILE" \
  || { echo "Backup with tag '$TAG' FAILED! Check $LOG_FILE." | tee -a "$LOG_FILE"; exit 1; }

# Conditional curl notification based on tag
if [[ "$TAG" == "daily" ]]; then
  curl -s -X POST -H 'Content-Type: application/json' -d '{"text":"Daily backup completed!"}' $HEALTHCHECKS_URL &>> "$LOG_FILE" \
    && echo "Daily curl notification sent." | tee -a "$LOG_FILE"
elif [[ "$TAG" == "monthly" ]]; then
  curl -s -X POST -H 'Content-Type: application/json' -d '{"text":"Monthly backup completed!"}' $HEALTHCHECKS_URL &>> "$LOG_FILE" \
    && echo "Monthly curl notification sent." | tee -a "$LOG_FILE"
fi

# Apply retention for daily backups
restic forget --tag daily --prune --keep-last 30 &>> "$LOG_FILE" \
  && echo "Daily retention applied." | tee -a "$LOG_FILE" \
  || echo "Daily retention FAILED! Check $LOG_FILE." | tee -a "$LOG_FILE"

# Apply retention for monthly backups
restic forget --tag monthly --prune --keep-last 12 &>> "$LOG_FILE" \
  && echo "Monthly retention applied." | tee -a "$LOG_FILE" \
  || echo "Monthly retention FAILED! Check $LOG_FILE." | tee -a "$LOG_FILE"
