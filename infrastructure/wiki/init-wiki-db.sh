#!/usr/bin/env bash
set -euo pipefail

# Init Wiki.js database and user in existing PostgreSQL
# Run this on the host where PostgreSQL is accessible

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${POSTGRES_USER:-arborisis}"
DB_PASS="${POSTGRES_PASSWORD:-change-me}"
DB_NAME="${POSTGRES_DB:-arborisis}"

WIKI_DB_NAME="${WIKI_DB_NAME:-wikijs}"
WIKI_DB_USER="${WIKI_DB_USER:-wikijs}"
WIKI_DB_PASSWORD="${WIKI_DB_PASSWORD:-change-me-wiki}"

echo "Creating Wiki.js database and user..."

PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" <<EOF
-- Create user if not exists
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${WIKI_DB_USER}') THEN
      CREATE USER ${WIKI_DB_USER} WITH PASSWORD '${WIKI_DB_PASSWORD}';
   END IF;
END
\$\$;

-- Create database if not exists
SELECT 'CREATE DATABASE ${WIKI_DB_NAME}'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${WIKI_DB_NAME}')\gexec

-- Grant privileges
ALTER DATABASE ${WIKI_DB_NAME} OWNER TO ${WIKI_DB_USER};
GRANT ALL PRIVILEGES ON DATABASE ${WIKI_DB_NAME} TO ${WIKI_DB_USER};

-- Connect to wikijs db and create schema
\c ${WIKI_DB_NAME};
CREATE SCHEMA IF NOT EXISTS wikijs AUTHORIZATION ${WIKI_DB_USER};
ALTER USER ${WIKI_DB_USER} SET search_path TO wikijs,public;
EOF

echo "Wiki.js database '${WIKI_DB_NAME}' and user '${WIKI_DB_USER}' ready."
