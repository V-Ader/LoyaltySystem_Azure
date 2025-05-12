#!/bin/bash

# === CONFIGURATION ===
POSTGRESQL_HOST="pg-azure-db-kz-db.postgres.database.azure.com"  # Replace with your PostgreSQL host (IP or FQDN)
POSTGRESQL_PORT="5432"                  # Default PostgreSQL port (change if necessary)
POSTGRESQL_USER="pgadminuser"           # PostgreSQL admin user
POSTGRESQL_PASSWORD="password1234"  # Replace with your PostgreSQL password
DATABASE_NAME="mydatabase"             # Name of the database to create
TABLE_NAME="my_table"                  # Table to create
DB_CONNECTION_STRING="postgresql://$POSTGRESQL_USER:$POSTGRESQL_PASSWORD@$POSTGRESQL_HOST:$POSTGRESQL_PORT"

# === CREATE DATABASE ===
echo "⚡ Creating PostgreSQL Database: $DATABASE_NAME..."

PG_CONN_STR_NO_DB="postgresql://$POSTGRESQL_USER:$POSTGRESQL_PASSWORD@$POSTGRESQL_HOST:$POSTGRESQL_PORT/postgres"
psql "$PG_CONN_STR_NO_DB" -c "CREATE DATABASE $DATABASE_NAME;"

# === CREATE TABLE ===
echo "📝 Creating table '$TABLE_NAME' in the database..."

PG_CONN_STR_WITH_DB="postgresql://$POSTGRESQL_USER:$POSTGRESQL_PASSWORD@$POSTGRESQL_HOST:$POSTGRESQL_PORT/$DATABASE_NAME"
psql "$PG_CONN_STR_WITH_DB" -c "CREATE TABLE $TABLE_NAME (id SERIAL PRIMARY KEY, name VARCHAR(255) NOT NULL, value VARCHAR(255) NOT NULL);"

# === OUTPUT CONNECTION STRING ===
echo "🔗 Database and table created successfully!"
echo "Connection string for the database:"
echo "$PG_CONN_STR_WITH_DB"

# === DONE ===
echo "✅ Database and table setup complete!"
