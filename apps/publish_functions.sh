#!/bin/bash

# === CONFIGURATION ===
RESOURCE_GROUP="functions-new-bz-rg"       
FUNCTION_APP_NAME="my-function-bz-api-app" 
FUNCTION_NAMES=("function_event_logs_consumer" "function_cards_api" "function_event_consumer") 

EVENT_HUB_NAME="my-eventhub-bz-kafka-hub"      
EVENT_HUB_LOGS_NAME="my-eventhub-bz-kafka-logs"

POSTGRES_HOST="pg-azure-db-bz-db.postgres.database.azure.com"
POSTGRES_USER="pgadminuser"
POSTGRES_PASSWORD="password1234"

# === EVENT HUB SETTINGS ===
EVENT_HUB_CONN_STR=$(az eventhubs eventhub authorization-rule keys list \
  --resource-group "$RESOURCE_GROUP" \
  --namespace-name "my-eventhub-bz-kafka" \
  --eventhub-name "$EVENT_HUB_NAME" \
  --name "universal" \
  --query "primaryConnectionString" -o tsv)

EVENT_HUB_CONN_LOGS_STR=$(az eventhubs eventhub authorization-rule keys list \
  --resource-group "$RESOURCE_GROUP" \
  --namespace-name "my-eventhub-bz-kafka" \
  --eventhub-name "$EVENT_HUB_LOGS_NAME" \
  --name "universal" \
  --query "primaryConnectionString" -o tsv)

echo "🔗 Event Hub Connection String: $EVENT_HUB_CONN_STR"
echo "🔧 Setting Azure Function App settings for Event Hub..."
az functionapp config appsettings set \
  --name "$FUNCTION_APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --settings EVENT_HUB_CONN_STR="$EVENT_HUB_CONN_STR" EVENT_HUB_NAME="$EVENT_HUB_NAME" \
  EVENT_HUB_CONN_LOGS_STR="$EVENT_HUB_CONN_LOGS_STR" EVENT_HUB_LOGS_NAME="$EVENT_HUB_LOGS_NAME" \
  POSTGRES_HOST="$POSTGRES_HOST" POSTGRES_USER="$POSTGRES_USER" POSTGRES_PASSWORD="$POSTGRES_PASSWORD"

# === PUBLISH FUNCTION ===
echo "📤 Publishing Azure Function App: $FUNCTION_APP_NAME..."
func azure functionapp publish "$FUNCTION_APP_NAME" --python

# === CHECK FOR ERRORS ===
if [ $? -ne 0 ]; then
  echo "❌ Publish failed. Exiting."
  exit 1
fi

# === GET FUNCTION KEYS FOR EACH FUNCTION ===
for FUNCTION_NAME in "${FUNCTION_NAMES[@]}"; do
  echo "🔑 Fetching function keys for '$FUNCTION_NAME'..."
  az functionapp function keys list \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --function-name "$FUNCTION_NAME" \
    --query "{default: default, function: function}" \
    --output table
  echo ""
done

echo "✅ All function keys retrieved."
