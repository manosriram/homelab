#!/bin/bash

# Check if tag argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <tag>"
    echo "Example: $0 daily"
    exit 1
fi

TIMESTAMP=$(date +%Y-%m-%d_%H_%M_%S)

TAG="$1"
if [ "$TAG" = "monthly" ]; then
    BACKUP_DIR="/fs/backups/cold/containerdb/monthly"
else
    BACKUP_DIR="/fs/backups/cold/containerdb/daily"
fi

mkdir -p "$BACKUP_DIR"

# PostgreSQL containers to backup
PSQL_CONTAINERS=(
    "immich-postgres"
		"miniflux-postgres"
)
PSQL_BACKUP_NAMES=(
    "immich-psql"
		"miniflux"
)

# SQLite database files to backup
SQLITE_DATABASES=(
    "/fs/containers/linkding/data/db.sqlite3"
    "/fs/containers/npm/data/database.sqlite"
    "/fs/containers/vaultwarden/data/db.sqlite3"
)
SQLITE_BACKUP_NAMES=(
    "linkding-sqlite"
    "nginx-proxy-manager-sqlite"
    "vaultwarden-sqlite"
)

DAILY_HEALTHCHECKS_URL="https://hc-ping.com/d7d85e6e-1bfc-47de-abb9-e779de6155c0"
MONTHLY_HEALTHCHECKS_URL="https://hc-ping.com/a6a7e144-043d-45cd-9766-e8116233e9f5"

echo "Starting database backups at $(date)"

echo "Backing up PostgreSQL databases..."
for i in "${!PSQL_CONTAINERS[@]}"; do
    container="${PSQL_CONTAINERS[$i]}"
    backup_name="${PSQL_BACKUP_NAMES[$i]}"
    echo "Backing up PostgreSQL container: $container (as $backup_name)"
    docker exec -t "$container" pg_dumpall -c -U manosriram > "$BACKUP_DIR/dump_${backup_name}_${TIMESTAMP}.sql"
    if [ $? -eq 0 ]; then
        echo "✓ Successfully backed up $container as $backup_name"
    else
        echo "✗ Failed to backup $container"
    fi
done

# Backup SQLite databases
echo "Backing up SQLite databases..."
for i in "${!SQLITE_DATABASES[@]}"; do
    db_path="${SQLITE_DATABASES[$i]}"
    backup_name="${SQLITE_BACKUP_NAMES[$i]}"
    if [ -f "$db_path" ]; then
        echo "Backing up SQLite database: $db_path (as $backup_name)"
        sqlite3 "$db_path" ".backup $BACKUP_DIR/${backup_name}_${TIMESTAMP}.bak"
        if [ $? -eq 0 ]; then
            echo "✓ Successfully backed up $db_path as $backup_name"
        else
            echo "✗ Failed to backup $db_path"
        fi
    else
        echo "⚠ SQLite database not found: $db_path"
    fi
done

echo "Database backups completed at $(date)"

# Remove old PostgreSQL dumps (keep latest 30 per container)
for i in "${!PSQL_CONTAINERS[@]}"; do
    backup_name="${PSQL_BACKUP_NAMES[$i]}"
    ls -t "$BACKUP_DIR"/dump_${backup_name}_*.sql 2>/dev/null | tail -n +31 | xargs rm -f 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ Cleaned up old backups for: $backup_name"
    fi
done

# Remove old SQLite backups (keep latest 30 per database)
for i in "${!SQLITE_DATABASES[@]}"; do
    backup_name="${SQLITE_BACKUP_NAMES[$i]}"
    ls -t "$BACKUP_DIR"/${backup_name}_*.bak 2>/dev/null | tail -n +31 | xargs rm -f 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ Cleaned up old backups for: $backup_name"
    fi
done

# Finally, ping healthcheck to notify backup is complete
if [[ "$TAG" == "daily" ]]; then
  curl -s -X POST -H 'Content-Type: application/json' -d '{"text":"Daily db backup completed!"}' $DAILY_HEALTHCHECKS_URL;
elif [[ "$TAG" == "monthly" ]]; then
  curl -s -X POST -H 'Content-Type: application/json' -d '{"text":"Monthly db backup completed!"}' $MONTHLY_HEALTHCHECKS_URL;
fi

echo "✓ Cleanup completed"
