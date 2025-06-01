#!/bin/bash

# === CONFIGURATION ===
RESOURCE_GROUP="functions-new-kz-rg"                   # Change as needed
FUNCTION_APP_NAME="my-function-kz-api-app"            # Change as needed
FUNCTION_NAMES=("function_echo" "function_cards_api")  # List of function folders/names

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
