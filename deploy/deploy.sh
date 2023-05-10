#!/bin/bash


set -e

GREEN='\033[0;32m'  # Green
RED='\033[0;31m'    # Red
NC='\033[0m'        # No Color

console.log() {
    echo -e "$1$NC"
}

console.error() {
    echo -e "${RED} $1$NC"
}

declare -a ALLOWED_SERVICES=("init" "shared" "teamsapp" "callbot" "notify" "api" "roles" "api-subscriptions" "bot-subscriptions" "notify-subscriptions" "all")

usage() {
    console.log "${NC}Usage: ${GREEN} $0${NC} <${GREEN}-c${NC} <command>> <${GREEN}-s${NC} <SERVICE name>> <${GREEN}-e${NC} <environment settings file path>> <${GREEN}-p${NC} <project settings file path>> [${GREEN}-b${NC} <build application>] [<${GREEN}-y${NC} <already logged in?>>]" 1>&2
    console.log "${NC}-c: '${GREEN}resources${NC}', '${GREEN}app${NC}'" 1>&2
    console.log "${NC}-s: The following services are allowed:" 1>&2
    for item in "${ALLOWED_SERVICES[@]}"
    do
        console.log "\t${GREEN} ${item}${NC}" 1>&2
    done
    exit 1
}

getWebAppConfigValue() {
    # $1 = resource group name
    # $2 = web app name
    # $3 = setting name
    # $4 = output format
    # $5 = is coma required
    if [ "$4" = "json" ]
    then
        echo "\"$3\": \"$(az webapp config appsettings list --resource-group "$1" --name "$2" --query "[?name=='$3'].value" -o tsv)\"$5"
    else
        echo "$3=$(az webapp config appsettings list --resource-group "$1" --name "$2" --query "[?name=='$3'].value" -o tsv)"
    fi
}

getFuncAppConfigValue() {
    # $1 = resource group name
    # $2 = function app name
    # $3 = setting name
    # $4 = output format
    # $5 = is coma required
    if [ "$4" = "json" ]
    then
        echo "\"$3\": \"$(az functionapp config appsettings list --resource-group "$1" --name "$2" --query "[?name=='$3'].value" -o tsv)\"$5"
    else
        echo "$3=$(az functionapp config appsettings list --resource-group "$1" --name "$2" --query "[?name=='$3'].value" -o tsv)"
    fi
}

getKeyVaultSecret() {
    # $1 = key vault name
    # $2 = output property
    # $3 = secret name
    # $4 = output format
    # $5 = is coma required
    # example: getKeyVaultSecret "$keyVaultName" "AZURE_AD_REST_API_CLIENT_SECRET" "CourtroomManagementApiAzureAdApplicationClientSecret" "json" ","
    
    if [ "$4" = "json" ]
    then
        echo "\"$2\": \"$(az keyvault secret show --vault-name "$1" --name "$3" --query value -o tsv)\"$5"
    else
        echo "$2=$(az keyvault secret show --vault-name "$1" --name "$3" --query value -o tsv)"
    fi
}


while getopts ":c:s:e:p:" opt; do
    case "$opt" in
        c) COMMAND=${OPTARG}
        ;;
        s) SERVICE="$OPTARG"
        ;;
        e) ENVIRONMENT_PATH="$OPTARG"
        ;;
        p) PROJECT_SETTINGS_PATH="$OPTARG"
        ;;
        /?)
            usage
        ;;
    esac
done

isServiceAllowed=false
for item in "${ALLOWED_SERVICES[@]}"
do
    if [ "$SERVICE" = "$item" ]
    then
        isServiceAllowed=true
        break
    fi
done

if [ "$isServiceAllowed" = false ]
then
    console.error "Invalid service!"
    usage
fi

for var in "$@"
do
    if [ "$var" = "-y" ]
    then
        isLoggedIn=true
    else
        isLoggedIn=false
    fi
    if [ "$var" = "-b" ]
    then
        isBuildApp=true
    else
        isBuildApp=false
    fi
done

DEPLOY_FOLDER_PATH=${PWD}
cd ..
PROJECT_ROOT_PATH=$(pwd)
cd "$DEPLOY_FOLDER_PATH"

console.log "Command: ${GREEN} $COMMAND ${NC}"
console.log "Service: ${GREEN} $SERVICE ${NC}"
console.log "Environment settings file path: ${GREEN} $ENVIRONMENT_PATH ${NC}"
console.log "Project settings file path: ${GREEN} $PROJECT_SETTINGS_PATH ${NC}"
console.log "Project root path: ${GREEN} $PROJECT_ROOT_PATH ${NC}"
console.log "Already logged in?: ${GREEN} $isLoggedIn ${NC}"
console.log "Build application?: ${GREEN} $isBuildApp ${NC}"


shift $((OPTIND - 1))

if [ "$SERVICE" = "init" ]
then
    console.log "Installing pre-requisites..."
    npm install -g azure-functions-core-tools@4 --unsafe-perm true
fi

if [ -z "$COMMAND" ] || [ "$COMMAND" != "resources" ] && [ "$COMMAND" != "app" ]
then
    console.error "Invalid command! Allowed arguments: resources or app."
    usage
fi

if [ -z "$ENVIRONMENT_PATH" ] || [[ ! -e "$ENVIRONMENT_PATH" ]]; then
    console.error "Environment settings file not found! Please check the path and try again."
    usage
fi

if [ -z "$PROJECT_SETTINGS_PATH" ] || [[ ! -e "$PROJECT_SETTINGS_PATH" ]]; then
    console.error "Project settings file not found! Please check the path and try again."
    usage
fi

# get the project global variables
console.log "Getting the project environment variables..."
applicationName=$(jq '.environments[].applicationName.value' "$ENVIRONMENT_PATH" -r)
environment=$(jq '.environments[].environment.value' "$ENVIRONMENT_PATH" -r)
deploymentId=$(jq '.environments[].deploymentId.value' "$ENVIRONMENT_PATH" -r)
primaryRegion=$(jq '.environments[].primaryRegion.value' "$ENVIRONMENT_PATH" -r)
secondaryRegion=$(jq '.environments[].secondaryRegion.value' "$ENVIRONMENT_PATH" -r)

console.log "Getting the project settings..."
timeZoneOptions=$(jq '.timeZoneOptions.value' "$PROJECT_SETTINGS_PATH" -r)
defaultTimeZone=$(jq '.defaultTimeZone.value' "$PROJECT_SETTINGS_PATH" -r)


console.log "Getting the EventGrid Client secret value from the Key Vault..."
keyVaultName=$(az deployment sub show --name "shared" --query properties.outputs.key_vault.value -o tsv)
eventGridClientSecretId=$(az keyvault secret list --vault-name "$keyVaultName" --query "[?name=='EventGridClientSecret'].id" -o tsv)

if [ "$eventGridClientSecretId" = "" ]
then
    eventGridClientSecret=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 30)
else
    eventGridClientSecret=$(az keyvault secret show --vault-name "$keyVaultName" --name "EventGridClientSecret" --query value -o tsv)
fi


if [ "$COMMAND" = "app" ] && [ -z "$SERVICE" ]
then
    console.error "No application service is specified! Please specify an application service to deploy."
    usage
fi

if [ "$COMMAND" = "resources" ]
then
    if [ "$SERVICE" = "all" ] || [ -z "$SERVICE" ]
    then
        console.error "Either the no services specified or 'All' argument was passed! Deploying all services..."
    fi
    
    if [ -z "$isLoggedIn" ]
    then
        console.log "Logging in to Azure..."
        az login
    else
        console.log "Already logged in to Azure. Using the signed user credentials..."
    fi
    
    
    # get the object id of the signed in user
    console.log "$NC Getting the object id of the signed in user..."
    signedUserObjectId=$(az ad signed-in-user show --query id)
    signedUserObjectId=$(echo "$signedUserObjectId" | tr -d '"')
    console.log "User Object Id: $signedUserObjectId"
    
    console.log "Deploying $GREEN $SERVICE $NC resources to Azure..."
    
    # deploy the azure resources
    az deployment sub create --template-file ./bicep/main.bicep --location "${primaryRegion}" \
    --parameters "$PROJECT_SETTINGS_PATH" \
    --parameters deploymentType="$SERVICE" \
    --parameters environment="$environment" \
    --parameters applicationName="$applicationName" \
    --parameters deploymentId="$deploymentId" \
    --parameters primaryRegion="$primaryRegion" \
    --parameters secondaryRegion="$secondaryRegion" \
    --parameters signedUserObjectId="$signedUserObjectId" \
    --parameters eventGridClientSecret="$eventGridClientSecret"
    
    # APP_AD_SECRET=$(az ad app credential reset --id ${{AAD_APP_CLIENT_ID}} --append --query "password" -o tsv)
    # az az keyvault secret set --vault-name "${KEY_VAULT_NAME}" -n CourtroomManagementApiAzureAdApplicationClientSecret --value "$APP_AD_SECRET" --query id --output tsv
    
else
    console.log "Building and deploying the $GREEN $SERVICE $NC service application..."
    
    console.log "Getting the Shared Azure resource output values..."
    keyVaultName=$(az deployment sub show --name "shared" --query properties.outputs.key_vault.value -o tsv)
    
    if [ "$isBuildApp" = true ]
    then
        console.log "Moving to the $RED $PROJECT_ROOT_PATH $GREEN root folder...$NC"
        cd "$PROJECT_ROOT_PATH" # move to the root folder
        console.log "Installing the dependencies..."
        npm install
    fi
    
    case "$SERVICE" in
        teamsapp)
            
            console.log "Getting the Teams App Azure resource output values..."
            
            appFolder="packages/teamsapp"
            deploymentName="teamsapp"
            resourceGroup=$(az deployment sub show --name "$deploymentName" --query properties.outputs.resource_group.value -o tsv)
            appName=$(az deployment sub show --name "$deploymentName" --query properties.outputs.application_name.value -o tsv)
            appHost=$(az deployment sub show --name "$deploymentName" --query properties.outputs.application_host.value -o tsv)
            notifyHubUrl=$(az deployment sub show --name "notificationhub" --query properties.outputs.application_url.value -o tsv)
            
            if [ "$isBuildApp" = true ]
            then
                console.log "Moving to the $RED $appFolder $GREEN application folder..."
                cd "$PROJECT_ROOT_PATH/$appFolder"
                
                console.log "Creating .env file..."
                {
                    echo "BROWSER=none"
                    echo "DANGEROUSLY_DISABLE_HOST_CHECK=true"
                    echo "HTTPS=true"
                    echo "REACT_APP_ENVIRONMENT=$environment"
                    echo "REACT_APP_USE_LOCALDEVAUTH=false"
                    echo "REACT_APP_LOGGING_LEVEL=Trace"
                    echo "REACT_APP_API_URL=https://$appHost"
                    echo "REACT_APP_NOTIFICATION_HUB=https://$notifyHubUrl/api"
                    echo "REACT_APP_TIME_ZONE_OPTIONS=$timeZoneOptions"
                    echo "REACT_APP_DEFAULT_TIME_ZONE=$defaultTimeZone"
                    echo "DEFAULT_TIME_ZONE=$defaultTimeZone"
                    echo "WEBSITES_ENABLE_APP_SERVICE_STORAGE=false"
                    echo "WEBSITE_RUN_FROM_PACKAGE=1"
                    echo "WEBSITE_NODE_DEFAULT_VERSION=~18"
                    echo "WEBSITE_DISABLE_MSI=false"
                    getFuncAppConfigValue "$resourceGroup" "$appName" "APPINSIGHTS_INSTRUMENTATIONKEY"
                } > .env
                
                export echo DEFAULT_TIME_ZONE=$defaultTimeZone
                
                console.log "Building the $RED $SERVICE $GREEN application..."
                npm run build
                
                console.log "Running the tests..."
                npm run test
                
                console.log "Creating the $RED $SERVICE $GREEN zip file in the project root folder..."
                rm -rf "$PROJECT_ROOT_PATH/$SERVICE.zip"
                7z a -y "$PROJECT_ROOT_PATH/$SERVICE.zip" .
                
                console.log "Adding Node modules to the zip file..."
                cd "$PROJECT_ROOT_PATH"
                7z a -r -y "$SERVICE.zip" ./node_modules
            fi
            
            cd "$PROJECT_ROOT_PATH"
            
            console.log "Setting up the $RED $SERVICE $GREEN application for the deployment..."
            
            if [ -z "$isLoggedIn" ]
            then
                console.log "Logging in to Azure..."
                az login
            else
                console.log "Already logged in to Azure. Using the signed user credentials..."
            fi
            
            console.log "Enable running from package..."
            az webapp config appsettings set --resource-group "$resourceGroup" --name "$appName" --settings WEBSITE_RUN_FROM_PACKAGE="1"
            
            console.log "Deploying the $RED $SERVICE $GREEN application to Azure..."
            az webapp deployment source config-zip \
            --resource-group "$resourceGroup" \
            --name "$appName" \
            --src "$SERVICE.zip"
        ;;
        callbot)
            
            console.log "Getting the Call Bot Azure resource output values..."
            
            appFolder="packages/call-management-bot"
            deploymentName="callbot"
            resourceGroup=$(az deployment sub show --name "$deploymentName" --query properties.outputs.resource_group.value -o tsv)
            appName=$(az deployment sub show --name "$deploymentName" --query properties.outputs.application_name.value -o tsv)
            
            console.log "Moving to the $RED $appFolder $GREEN application folder..."
            cd "$PROJECT_ROOT_PATH/$appFolder"
            
            if [ "$isBuildApp" = true ]
            then
                console.log "Creating local.settings.json file..."
                {
                    echo "{"
                    echo '"IsEncrypted": false,'
                    echo '"Values": {'
                    getFuncAppConfigValue "$resourceGroup" "$appName" "WEBSITE_TIME_ZONE" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "DEFAULT_TIME_ZONE" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "TIME_ZONE_OPTIONS" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "HEARING_CONTROL_URL" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "GRAPH_BASE_URL" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "GRAPH_SCOPE" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "GRAPH_PRIVATE_BASE_URL" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "GRAPH_PRIVATE_SCOPE" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "TEAMS_APP_ID" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "AZURE_AD_TENANT_ID" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "AZURE_AD_BOT_CLIENT_ID" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "AZURE_AD_BOT_SERVICE_ACCOUNT_OBJECT_ID" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "AZURE_AD_BOT_SERVICE_ACCOUNT_UPN" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "AZURE_AD_DOMAIN_NAME" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "AZURE_AD_BOT_CLIENT_SECRET" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "AZURE_AD_BOT_SERVICE_ACCOUNT_PASSWORD" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "EventGridTopicKey" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "AzureWebJobsStorage" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "WEBSITE_CONTENTSHARE" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "APPINSIGHTS_INSTRUMENTATIONKEY" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "FUNCTIONS_WORKER_RUNTIME" "json" ","
                    echo "\"FUNCTIONS_WORKER_PROCESS_COUNT\": \"2\","
                    echo "\"FUNCTIONS_EXTENSION_VERSION\": \"~4\","
                    echo "\"WEBSITE_NODE_DEFAULT_VERSION\": \"~18\","
                    echo "\"GRAPH_PUBLIC_ENDPOINT\": true,"
                    echo "\"APPLICATIONINSIGHTS_ROLE_NAME\": \"CallManagementBot\","
                    echo "\"HEARING_ORGANISER_EMAIL_ADDRESS_OVERRIDE\": \"\","
                    echo "\"HEARING_ATTENDEE_EMAIL_ADDRESS_OVERRIDE\": \"\","
                    echo "\"LOGGING_SERVICE\": \"CallManagementBot\","
                    echo "\"LOGGING_LEVEL\": \"debug\","
                    echo "\"LOGGING_APP_INSIGHTS_LEVEL\": \"debug\","
                    echo "\"ONLINE_MEETING_LIFECYCLE_MANAGEMENT_JOIN_BEFORE_START_DATE_MINUTES\": \"10080\","
                    echo "\"ONLINE_MEETING_LIFECYCLE_MANAGEMENT_LEAVE_AFTER_END_DATE_MINUTES\": \"1440\","
                    echo "\"NODE_ENV\": \"development\","
                    echo "\"NOTIFICATIONS_AUTH_ISSUER\": \"https://api.botframework.com\","
                    echo "\"NOTIFICATIONS_AUTH_JWKS_URL\": \"https://api.aps.skype.com/v1/keys\","
                    echo "\"NOTIFICATIONS_AUTH_JWKS_CACHE_MINUTES\": \"60\","
                    echo "\"NOTIFICATIONS_AUTH_DISABLED\": \"false\","
                    echo "\"TEAMS_APP_NAME\": \"Teams for Justice Online Hearing\""
                    echo "},"
                    echo "\"Host\": {"
                    echo "\"LocalHttpPort\": 7071"
                    echo "}"
                    echo "}"
                } > local.settings.json
                
                export echo DEFAULT_TIME_ZONE=$defaultTimeZone
                
                console.log "Building the $RED $SERVICE $GREEN application..."
                npm run build
                
                # console.log "Running the tests..."
                # npm run test
            fi
            
            console.log "Deploying the $RED $SERVICE $GREEN application to Azure..."
            
            if [ -z "$isLoggedIn" ]
            then
                console.log "Logging in to Azure..."
                az login
            else
                console.log "Already logged in to Azure. Using the signed user credentials..."
            fi
            
            RETRIES=0
            until [[ "$RETRIES" -ge 3 ]]; do
                func azure functionapp publish "$appName" --build-native-deps --build remote --typescript \
                --timeout 3600 && break
                RETRIES=$((RETRIES + 1))
                sleep 30
            done
            
            if [[ "$RETRIES" -ge 3 ]]; then
                console.error "Failed to deploy after 3 retries." 1>&2
                exit 1
            fi
            
            console.log "Obtain the function key of the Moderate Action Handler function..."
            moderatorActionsHandlerFuncKey=$(az functionapp function keys list --resource-group "$resourceGroup" --function-name "moderator-actions-handler" --name "$appName" --query "default" -o tsv)
            
            console.log "Add the Function Key to the Key Vault Secret..."
            az keyvault secret set --vault-name "$keyVaultName" -n BotAPIKey --value "$moderatorActionsHandlerFuncKey" --query id --output tsv
            
        ;;
        notify)
            console.log "Getting the Notification Hub Azure resource output values..."
            
            appFolder="packages/notification-hub"
            deploymentName="notificationhub"
            resourceGroup=$(az deployment sub show --name "$deploymentName" --query properties.outputs.resource_group.value -o tsv)
            appName=$(az deployment sub show --name "$deploymentName" --query properties.outputs.application_name.value -o tsv)
            
            console.log "Moving to the $RED $appFolder $GREEN application folder..."
            cd "$PROJECT_ROOT_PATH/$appFolder"
            
            if [ "$isBuildApp" = true ]
            then
                
                console.log "Creating local.settings.json file..."
                {
                    echo "{"
                    echo '"IsEncrypted": false,'
                    echo '"Values": {'
                    getFuncAppConfigValue "$resourceGroup" "$appName" "AzureWebJobsStorage" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "WEBSITE_CONTENTSHARE" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "APPINSIGHTS_INSTRUMENTATIONKEY" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "AZURE_AD_REST_API_CLIENT_ID" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "AZURE_AD_ISSUER_URL" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "AZURE_AD_JWKS_URL" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "EventGridTopicKey" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "EventGridTopicEndpointUri" "json" ","
                    getFuncAppConfigValue "$resourceGroup" "$appName" "AzureSignalRConnectionString" "json" ","
                    echo "\"AzureSignalRServiceTransportType\": \"Transient\","
                    echo "\"AZURE_AD_AUTH_DISABLED\": false,"
                    echo "\"FUNCTIONS_WORKER_PROCESS_COUNT\": \"2\","
                    echo "\"FUNCTIONS_WORKER_RUNTIME\": \"node\","
                    echo "\"FUNCTIONS_EXTENSION_VERSION\": \"~4\","
                    echo "\"WEBSITE_NODE_DEFAULT_VERSION\": \"~18\","
                    echo "\"LOGGING_SERVICE\": \"NotificationHub\","
                    echo "\"APPLICATIONINSIGHTS_ROLE_NAME\": \"NotificationHub\","
                    echo "\"AZURE_AD_JWKS_CACHE_MINUTES\": 15,"
                    echo "\"LOGGING_APP_INSIGHTS_LEVEL\": \"debug\""
                    echo "},"
                    echo "\"Host\": {"
                    echo "\"LocalHttpPort\": 7075,"
                    echo "\"CORS\": \"http://localhost:3000\","
                    echo "\"CORSCredentials\": true"
                    echo "}"
                    echo "}"
                } > local.settings.json
                
                console.log "Building the $RED $SERVICE $GREEN application..."
                npm run build
                
                # console.log "Running the tests..."
                # npm run test
            fi
            
            console.log "Deploying the $RED $SERVICE $GREEN application to Azure..."
            
            if [ -z "$isLoggedIn" ]
            then
                console.log "Logging in to Azure..."
                az login
            else
                console.log "Already logged in to Azure. Using the signed user credentials..."
            fi
            
            RETRIES=0
            until [[ "$RETRIES" -ge 3 ]]; do
                func azure functionapp publish "$appName" --build-native-deps --build remote --typescript \
                --timeout 3600 && break
                RETRIES=$((RETRIES + 1))
                sleep 30
            done
            
            if [[ "$RETRIES" -ge 3 ]]; then
                console.error "Failed to deploy after 3 retries." 1>&2
                exit 1
            fi
        ;;
        api)
            console.log "Getting the API App Azure resource output values..."
            
            appFolder="packages/api"
            deploymentName="api"
            resourceGroup=$(az deployment sub show --name "$deploymentName" --query properties.outputs.resource_group.value -o tsv)
            appName=$(az deployment sub show --name "$deploymentName" --query properties.outputs.application_name.value -o tsv)
            
            if [ "$isBuildApp" = true ]
            then
                console.log "Moving to the $RED $appFolder $GREEN application folder..."
                cd "$PROJECT_ROOT_PATH/$appFolder"
                console.log "Creating .env file..."
                {
                    echo "PROJECT_API_TAG=Teams for Justice APIs"
                    getWebAppConfigValue "$resourceGroup" "$appName" "APPHOST"
                    getWebAppConfigValue "$resourceGroup" "$appName" "APPINSIGHTS_INSTRUMENTATIONKEY"
                    getWebAppConfigValue "$resourceGroup" "$appName" "AZURE_AD_REST_API_CLIENT_ID"
                    getKeyVaultSecret "$keyVaultName" "AZURE_AD_REST_API_CLIENT_SECRET" "CourtroomManagementApiAzureAdApplicationClientSecret"
                    getWebAppConfigValue "$resourceGroup" "$appName" "AZURE_AD_TEAMS_APP_CLIENT_ID"
                    getKeyVaultSecret "$keyVaultName" "AZURE_AD_TEAMS_APP_CLIENT_SECRET" "TeamsAppAzureAdApplicationClientSecret"
                    getWebAppConfigValue "$resourceGroup" "$appName" "AZURE_AD_TENANT_BASEURL"
                    getWebAppConfigValue "$resourceGroup" "$appName" "AZURE_COSMOS_DB_ENDPOINT"
                    getKeyVaultSecret "$keyVaultName" "AZURE_COSMOS_DB_KEY" "CosmosDBKey"
                    getWebAppConfigValue "$resourceGroup" "$appName" "AZURE_COSMOS_DB_NAME"
                    getWebAppConfigValue "$resourceGroup" "$appName" "CORS_ALLOWED_ORIGINS"
                    getWebAppConfigValue "$resourceGroup" "$appName" "CORS_MAX_AGE_SECONDS"
                    getKeyVaultSecret "$keyVaultName" "EVENT_GRID_COURTROOM_EVENTS_TOPIC_API_KEY" "EventGridKey"
                    getWebAppConfigValue "$resourceGroup" "$appName" "EVENT_GRID_COURTROOM_EVENTS_TOPIC_ENDPOINT"
                    getKeyVaultSecret "$keyVaultName" "EVENT_GRID_WEBHOOK_CLIENT_SECRET" "TeamsAppAzureAdApplicationClientSecret"
                    getWebAppConfigValue "$resourceGroup" "$appName" "LOCAL_DEV_AUTH_SECRET"
                    getWebAppConfigValue "$resourceGroup" "$appName" "LOGGING_APP_INSIGHTS_LEVEL"
                    getWebAppConfigValue "$resourceGroup" "$appName" "LOGGING_LEVEL"
                    getWebAppConfigValue "$resourceGroup" "$appName" "LOGGING_SERVICE"
                    getWebAppConfigValue "$resourceGroup" "$appName" "AZURE_BLOB_STORAGE_ENDPOINT"
                    getWebAppConfigValue "$resourceGroup" "$appName" "AZURE_BLOB_STORAGE_EMAILS_CONTAINER"
                    getWebAppConfigValue "$resourceGroup" "$appName" "BOT_API_URL"
                    getKeyVaultSecret "$keyVaultName" "BOT_API_KEY" "BotAPIKey"
                    getWebAppConfigValue "$resourceGroup" "$appName" "TIME_ZONE_OPTIONS"
                    getWebAppConfigValue "$resourceGroup" "$appName" "DEFAULT_TIME_ZONE"
                    getWebAppConfigValue "$resourceGroup" "$appName" "APPINSIGHTS_INSTRUMENTATIONKEY"
                    echo "WEBSITES_ENABLE_APP_SERVICE_STORAGE=false"
                    echo "WEBSITE_RUN_FROM_PACKAGE=1"
                    echo "WEBSITE_NODE_DEFAULT_VERSION=~18"
                    echo "WEBSITE_DISABLE_MSI=false"
                    echo "LOGGING_CONSOLE_LEVEL=debug"
                    echo "LOGGING_FILE_LEVEL=debug"
                    echo "LOGGING_FILE_MAX_FILES=50"
                    echo "LOGGING_FILE_MAX_SIZE=10000"
                    echo "LOGGING_FILE_NAME=api.log"
                    echo "NODE_ENV=development"
                    echo "SCM_DO_BUILD_DURING_DEPLOYMENT=false"
                } > .env
                
                # console.log "Creating Self-signed certificate..."
                # export MSYS_NO_PATHCONV=1
                # cd rootca
                # touch db/index
                # openssl rand -hex 16 > db/serial
                # echo 1001 > db/crlnumber
                # console.log "Generating a private key and the certificate signing request (CSR)..."
                # openssl req -x509 -new -nodes -sha256 -newkey rsa:2048 -days 1024 -out rootca.pem -keyout private/rootca.key -subj '/CN=US/CN=T4J-Root-CA'
                # console.log "Sign the certificate, and commit it to the database..."
                # openssl x509 -outform pem -in rootca.pem -out rootca.crt
                
                
                export echo DEFAULT_TIME_ZONE=$defaultTimeZone
                
                console.log "Building the $RED $SERVICE $GREEN application..."
                npm run build
                
                console.log "Running the tests..."
                npm run test
                
                console.log "Creating the $RED $SERVICE $GREEN zip file in the project root folder..."
                rm -rf "$PROJECT_ROOT_PATH/$SERVICE.zip"
                7z a -y "$PROJECT_ROOT_PATH/$SERVICE.zip" .
                
                console.log "Adding Node modules to the zip file..."
                cd "$PROJECT_ROOT_PATH"
                7z a -r -y "$SERVICE.zip" ./node_modules
            fi
            
            cd "$PROJECT_ROOT_PATH"
            
            console.log "Setting up the $RED $SERVICE $GREEN application for the deployment..."
            
            if [ -z "$isLoggedIn" ]
            then
                console.log "Logging in to Azure..."
                az login
            else
                console.log "Already logged in to Azure. Using the signed user credentials..."
            fi
            
            console.log "Enable running from package..."
            az webapp config appsettings set --resource-group "$resourceGroup" --name "$appName" --settings WEBSITE_RUN_FROM_PACKAGE="1"
            
            console.log "Deploying the $RED $SERVICE $GREEN application to Azure..."
            az webapp deployment source config-zip \
            --resource-group "$resourceGroup" \
            --name "$appName" \
            --src "$SERVICE.zip"
        ;;
        dbconfig)
            console.log "Getting the Cosmos DB Configurator App Azure resource output values..."
            
            appFolder="utilities/cosmosdb-config"
            deploymentName="shared"
            resourceGroup=$(az deployment sub show --name "$deploymentName" --query properties.outputs.resource_group_name.value -o tsv)
            appName=$(az deployment sub show --name "$deploymentName" --query properties.outputs.dbconfig_application_name.value -o tsv)
            
            if [ "$isBuildApp" = true ]
            then
                console.log "Installing the dependencies..."
                console.log "Moving to the $RED $appFolder $GREEN application folder..."
                cd "$PROJECT_ROOT_PATH/$appFolder"
                console.log "Creating .env file..."
                {
                    echo "PROJECT_API_TAG=Teams for Justice Cosmos DB Configurator APIs"
                    echo "NODE_ENV=development"
                    getWebAppConfigValue "$resourceGroup" "$appName" "AZURE_COSMOS_DB_NAME"
                    getWebAppConfigValue "$resourceGroup" "$appName" "AZURE_COSMOS_DB_ENDPOINT"
                    getKeyVaultSecret "$keyVaultName" "AZURE_COSMOS_DB_KEY" "CosmosDBKey"
                    echo "WEBSITES_ENABLE_APP_SERVICE_STORAGE=false"
                    echo "WEBSITE_RUN_FROM_PACKAGE=1"
                    echo "WEBSITE_NODE_DEFAULT_VERSION=~18"
                    echo "WEBSITE_DISABLE_MSI=false"
                    echo "LOGGING_CONSOLE_LEVEL=debug"
                    echo "PORT=3000"
                    echo "SCM_DO_BUILD_DURING_DEPLOYMENT=false"
                } > .env
                
                console.log "Building the $RED $SERVICE $GREEN application..."
                npm run build
                
                console.log "Creating the $RED $SERVICE $GREEN zip file in the project root folder..."
                rm -rf "$PROJECT_ROOT_PATH/$SERVICE.zip"
                7z a -y "$PROJECT_ROOT_PATH/$SERVICE.zip" .
            fi
            
            cd "$PROJECT_ROOT_PATH"
            
            console.log "Setting up the $RED $SERVICE $GREEN application for the deployment..."
            
            if [ -z "$isLoggedIn" ]
            then
                console.log "Logging in to Azure..."
                az login
            else
                console.log "Already logged in to Azure. Using the signed user credentials..."
            fi
            
            console.log "Enable running from package..."
            az webapp config appsettings set --resource-group "$resourceGroup" --name "$appName" --settings WEBSITE_RUN_FROM_PACKAGE="1"
            
            console.log "Deploying the $RED $SERVICE $GREEN application to Azure..."
            az webapp deployment source config-zip \
            --resource-group "$resourceGroup" \
            --name "$appName" \
            --src "$SERVICE.zip"
        ;;
    esac
fi







