#!/bin/bash


set -e

environment="dev"
APP_FOLDER_PATH="../src/ui/"

cd "$APP_FOLDER_PATH"

echo "Creating .env file..."
{
    echo "BROWSER=none"
    echo "DANGEROUSLY_DISABLE_HOST_CHECK=true"
    echo "HTTPS=true"
    echo "REACT_APP_ENVIRONMENT=$environment"
    echo "REACT_APP_USE_LOCALDEVAUTH=false"
    echo "REACT_APP_LOGGING_LEVEL=Trace"
} > .env
