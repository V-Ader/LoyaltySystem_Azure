#!/bin/bash

# === CONFIGURATION ===
POSTGRESQL_HOST="pg-azure-db-bz-db.postgres.database.azure.com" 
POSTGRESQL_PORT="5432" 
POSTGRESQL_USER="pgadminuser" 
POSTGRESQL_PASSWORD="password1234" 
DATABASE_NAME="mydatabase" 
TABLE_NAME="cards"
DB_CONNECTION_STRING="postgresql://$POSTGRESQL_USER:$POSTGRESQL_PASSWORD@$POSTGRESQL_HOST:$POSTGRESQL_PORT"

# === CREATE DATABASE ===
echo "⚡ Creating PostgreSQL Database: $DATABASE_NAME..."

PG_CONN_STR_NO_DB="postgresql://$POSTGRESQL_USER:$POSTGRESQL_PASSWORD@$POSTGRESQL_HOST:$POSTGRESQL_PORT/postgres"
psql "$PG_CONN_STR_NO_DB" -c "CREATE DATABASE $DATABASE_NAME;"

# === CREATE TABLE ===
echo "📝 Creating table '$TABLE_NAME' in the database..."

PG_CONN_STR_WITH_DB="postgresql://$POSTGRESQL_USER:$POSTGRESQL_PASSWORD@$POSTGRESQL_HOST:$POSTGRESQL_PORT/$DATABASE_NAME"
psql "$PG_CONN_STR_WITH_DB" -c "CREATE TABLE $TABLE_NAME (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  tokens INTEGER NOT NULL
);"

psql "$PG_CONN_STR_WITH_DB" -c "CREATE TABLE logs (
  id SERIAL PRIMARY KEY,
  action VARCHAR(32) NOT NULL,
  card_id INTEGER,
  user_name VARCHAR(255),
  log_message TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);"

# === OUTPUT CONNECTION STRING ===
echo "🔗 Database and table created successfully!"
echo "Connection string for the database:"
echo "$PG_CONN_STR_WITH_DB"

# === DONE ===
echo "✅ Database and table setup complete!"
