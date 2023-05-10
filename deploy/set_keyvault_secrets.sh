#!/bin/bash

set -e

usage() {
    echo "Usage: $0 <-g <resource group name>> <-b <call management bot's resource group name>> <-t <tenant id>> <-k <key vault name>> <-s <service principal id>> <-p <service principal password>>" 1>&2
    exit 1
}

while getopts ":g:b:t:k:s:p:" o; do
    case "${o}" in
    g)
        RESOURCE_GROUP_NAME=${OPTARG}
        ;;
    b)
        BOT_RESOURCE_GROUP_NAME=${OPTARG}
        ;;
    t)
        TENANT_ID=${OPTARG}
        ;;
    k)
        KEY_VAULT_NAME=${OPTARG}
        ;;
    s)
        SERVICE_PRINCIPAL_ID=${OPTARG}
        ;;
    p)
        SERVICE_PRINCIPAL_PWD=${OPTARG}
        ;;
    *)
        usage
        ;;
    esac
done

shift $((OPTIND - 1))

if [ -z "$SERVICE_PRINCIPAL_ID" ] || [ -z "$RESOURCE_GROUP_NAME" ] || [ -z "$TENANT_ID" ] || [ -z "$SERVICE_PRINCIPAL_PWD" ] || [ -z "$KEY_VAULT_NAME" ]; then
    usage
fi

# Login to Azure
az login --service-principal --username "$SERVICE_PRINCIPAL_ID" --tenant "$TENANT_ID" --password "$SERVICE_PRINCIPAL_PWD"

COSMOS_DB_NAME=$(az resource list -g "$RESOURCE_GROUP_NAME" --query "[?type=='Microsoft.DocumentDB/databaseAccounts'].name" --output tsv)
EVENT_GRID_NAME=$(az resource list -g "$RESOURCE_GROUP_NAME" --query "[?type=='Microsoft.EventGrid/topics'].name" --output tsv)

COSMOS_DB_KEY=$(az cosmosdb keys list -g "$RESOURCE_GROUP_NAME" --name "$COSMOS_DB_NAME" --query primaryMasterKey --output tsv)
EVENT_GRID_KEY=$(az eventgrid topic key list -g "$RESOURCE_GROUP_NAME" -n "$EVENT_GRID_NAME" --query key1 --output tsv)
EVENT_GRID_CLIENT_SECRET=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 30)

CALL_MANAGEMENT_FUNCTION_NAME=$(az functionapp list -g "$BOT_RESOURCE_GROUP_NAME" --query "[?ends_with(name, 'callbot')].name" --output tsv)

FUNCTION_KEY=$(az functionapp function keys list -g "$BOT_RESOURCE_GROUP_NAME" -n "$CALL_MANAGEMENT_FUNCTION_NAME" --function-name 'moderator-actions-handler' --query default --output tsv)

echo "COSMOS_DB_NAME = $COSMOS_DB_NAME"
echo "EVENT_GRID_NAME = $EVENT_GRID_NAME"
echo "KEY_VAULT_NAME = $KEY_VAULT_NAME"
echo "COSMOS_DB_KEY = $COSMOS_DB_KEY"
echo "EVENT_GRID_KEY = $EVENT_GRID_KEY"
echo "EVENT_GRID_CLIENT_SECRET = $EVENT_GRID_CLIENT_SECRET"
echo "CALL_MANAGEMENT_FUNCTION_NAME = $CALL_MANAGEMENT_FUNCTION_NAME"
echo "FUNCTION_KEY = $FUNCTION_KEY"

echo ""
echo ""
echo "PLease validate that all values have been fully initialized/assigned, and then hit Enter to contiue. Otherwise, terminate this script run, fix the missing values and try again."
echo ""
read -r

az keyvault secret set --vault-name "$KEY_VAULT_NAME" -n CosmosDBKey --value "$COSMOS_DB_KEY" --query id --output tsv
az keyvault secret set --vault-name "$KEY_VAULT_NAME" -n EventGridKey --value "$EVENT_GRID_KEY" --query id --output tsv
az keyvault secret set --vault-name "$KEY_VAULT_NAME" -n BotAPIKey --value "$FUNCTION_KEY" --query id --output tsv
az keyvault secret set --vault-name "$KEY_VAULT_NAME" -n EventGridClientSecret --value "$EVENT_GRID_CLIENT_SECRET" --query id --output tsv

# Prompt for the required App Registraton Secrets
echo ""
echo ""
echo "PLease provide the Application Registration Secrets for the following applications."
echo ""
echo -n "Enter the AD Application Client Secret for Courtroom Management API:"
read -r API_SECRET
echo -n "Enter the AD Application Client Secret for Teams Application UI:"
read -r UI_SECRET
echo -n "Enter the AD Application Client Secret for Calling Management Bot:"
read -r CALLBOT_SECRET
echo -n "Enter the password of the Service Account User that was created during the initial setup in the Teams tenant Active Directory:"
read -r SERVICE_ACCOUNT_USER_PWD
echo ""
echo ""

az keyvault secret set --vault-name "$KEY_VAULT_NAME" -n CourtroomManagementApiAzureAdApplicationClientSecret --value "$API_SECRET" --query id --output tsv
az keyvault secret set --vault-name "$KEY_VAULT_NAME" -n TeamsAppAzureAdApplicationClientSecret --value "$UI_SECRET" --query id --output tsv
az keyvault secret set --vault-name "$KEY_VAULT_NAME" -n AzureAdBotClientSecret --value "$CALLBOT_SECRET" --query id --output tsv
az keyvault secret set --vault-name "$KEY_VAULT_NAME" -n AzureAdBotServiceAccountPassword --value "$SERVICE_ACCOUNT_USER_PWD" --query id --output tsv
