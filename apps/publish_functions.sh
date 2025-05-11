#!/bin/bash

# === CONFIGURATION ===
RESOURCE_GROUP="azure-functions-kz-rg"                  # change as needed
FUNCTION_APP_NAME="my-func-app-g3q9im"         # change as needed
FUNCTION_NAME="function_echo"                    # name of your function folder

# === PUBLISH FUNCTION ===
echo "📤 Publishing Azure Function App: $FUNCTION_APP_NAME..."
func azure functionapp publish "$FUNCTION_APP_NAME" --python

# === CHECK FOR ERRORS ===
if [ $? -ne 0 ]; then
  echo "❌ Publish failed. Exiting."
  exit 1
fi

# === GET FUNCTION KEYS ===
echo "🔑 Fetching function keys for '$FUNCTION_NAME'..."
az functionapp function keys list \
  --name "$FUNCTION_APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --function-name "$FUNCTION_NAME" \
  --query "{default: default, function: function}" \
  --output table
