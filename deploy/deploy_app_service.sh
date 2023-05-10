#!/bin/bash

set -e

echo "Deploying App Service"

usage() {
    echo "Usage: $0 <-c <command>> <-g <resource group name>> <-e <environment name>> <-d <deployment Id>> <-b <bicep deployment name> <-a <artifact directory>> [-s <app settings folder>]" 1>&2
    exit 1
}

while getopts ":g:e:b:a:c:s:d:" o; do
    case "${o}" in
        a)
            ARTIFACT_PATH=${OPTARG}
        ;;
        c)
            COMMAND=${OPTARG}
        ;;
        b)
            APP_NAME=${OPTARG}
        ;;
        e)
            ENVIRONMENT_NAME=${OPTARG}
        ;;
        g)
            RESOURCE_GROUP_NAME=${OPTARG}
        ;;
        d)
            DEPLOYMENT_ID=${OPTARG}
        ;;
        s)
            APP_SETTINGS_FOLDER=${OPTARG}
        ;;
        *)
            usage
        ;;
    esac
done

shift $((OPTIND - 1))

echo "Executing command: $0 -c $COMMAND -g $RESOURCE_GROUP_NAME -e $ENVIRONMENT_NAME -d $DEPLOYMENT_ID -b $APP_NAME -a $ARTIFACT_PATH -s $APP_SETTINGS_FOLDER"

if [ -z "$APP_NAME" ] || [ -z "$ARTIFACT_PATH" ] || [ -z "$ENVIRONMENT_NAME" ] || [ -z "$RESOURCE_GROUP_NAME" ] || [ -z "$DEPLOYMENT_ID" ]; then
    usage
fi

RESOURCE_GROUP_NAME="$RESOURCE_GROUP_NAME-$ENVIRONMENT_NAME-$APP_NAME-$DEPLOYMENT_ID"

APP_SERVICE_NAME=$(az deployment sub show --name "$APP_NAME" --query properties.outputs.application_name.value -o tsv)
echo "App Name: $APP_SERVICE_NAME"

# SETTINGS=()
# if [[ -e "${APP_SETTINGS_FOLDER}/appsettings.common.json" ]]; then
#     SETTINGS+=("@${APP_SETTINGS_FOLDER}/appsettings.common.json")
# fi

# if [[ -e "${APP_SETTINGS_FOLDER}/appsettings.${ENVIRONMENT_NAME}.json" ]]; then
#     SETTINGS+=("@${APP_SETTINGS_FOLDER}/appsettings.${ENVIRONMENT_NAME}.json")
# fi

# if [[ ${#SETTINGS[@]} -gt 0 ]]; then
#     az "$COMMAND" config appsettings set --resource-group "$RESOURCE_GROUP_NAME" \
#     --name "$APP_SERVICE_NAME" \
#     --slot staging \
#     --settings "${SETTINGS[@]}"
# fi

az "$COMMAND" config appsettings set --resource-group "$RESOURCE_GROUP_NAME" \
--name "$APP_SERVICE_NAME" --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true

RETRIES=0
until [[ "$RETRIES" -ge 3 ]]; do
    az "$COMMAND" deployment source config-zip --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$APP_SERVICE_NAME" \
    --slot staging \
    --src "$ARTIFACT_PATH" \
    --timeout 3600 && break
    RETRIES=$((RETRIES + 1))
    sleep 30
done

# RETRIES=0
# until [[ "$RETRIES" -ge 3 ]]; do
#     az "$COMMAND" deployment source config-zip --resource-group "$RESOURCE_GROUP_NAME" \
#     --name "$APP_SERVICE_NAME" \
#     --slot staging \
#     --src "$ARTIFACT_PATH" \
#     --timeout 3600 && break
#     RETRIES=$((RETRIES + 1))
#     sleep 30
# done

if [[ "$RETRIES" -ge 3 ]]; then
    echo "Failed to deploy after 3 retries." 1>&2
    exit 1
fi

SWAP_MODE=$(az "$COMMAND" show -g "$RESOURCE_GROUP_NAME" -n "$APP_SERVICE_NAME" --slot staging --query "tags.swap_mode" --output tsv)
if [[ "$SWAP_MODE" == "swap_and_stop" ]]; then
    az "$COMMAND" start -g "$RESOURCE_GROUP_NAME" -n "$APP_SERVICE_NAME" --slot staging
    az "$COMMAND" deployment slot swap -g "$RESOURCE_GROUP_NAME" -n "$APP_SERVICE_NAME" --slot staging
    az "$COMMAND" stop -g "$RESOURCE_GROUP_NAME" -n "$APP_SERVICE_NAME" --slot staging
fi
