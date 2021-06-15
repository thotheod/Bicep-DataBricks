#!/bin/bash

# Variables
red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
blue='\e[1;34m%s\e[0m\n'

# Set your Azure Subscription
SUBSCRIPTION=0a52391c-0d81-434e-90b4-d04f5c670e8a

# choice of dev|prod
ENVIRONMENT=dev
RG_NAME="rg-DataBricks-${ENVIRONMENT}"
LOCATION=northeurope
PARAM_FILE="./deploy.parameters.${ENVIRONMENT}.json"
NSG_NAME="nsg-${ENVIRONMENT}-DataBricks"
NSG_ID=""

# 0. use for dynamic extension loader
az config set extension.use_dynamic_install=yes_without_prompt

# Code - do not change anything here on deployment
# 1. Set the right subscription
printf "$blue" "*** Setting the subsription to $SUBSCRIPTION ***"
az account set --subscription "$SUBSCRIPTION"

# 2. Create main Resource group if not exists
az group create --name $RG_NAME --location $LOCATION
printf "$green" "*** Resource Group $SUBSCRIPTION created (or Existed) ***"

# 3. Create a void NSG that will be used by Databricks. Query first its existance
printf "$blue" "check if nsg ${NSG_NAME} exists"

if [[ $(az network nsg list --query "[?name=='${NSG_NAME}']" | jq 'length') -gt 0 ]]; then
    printf "$green" "NSG ${NSG_NAME} exists, get its ID"
    NSG_ID=$(az network nsg list --query "[?name=='${NSG_NAME}']" | jq -r '.[0].id')
    printf "$green" "NSG ${NSG_NAME} has NSG_ID: ${NSG_ID}"
else
    printf "$blue" "NSG ${NSG_NAME} does not exist, create one and get its ID"
    NEW_NSG=$(az network nsg create --name $NSG_NAME --resource-group $az ad sp show --id your-client-id)
    NSG_ID=$(jq -r '.NewNSG.id' <<<$NEW_NSG)
    printf "$green" "NSG ${NSG_NAME} created with NSG_ID is ${NSG_ID}"
fi

# 4. start the BICEP deployment
printf "$blue" "starting BICEP deployment for ENV: $ENVIRONMENT"
az deployment group create \
    -f ./deploy.bicep \
    -g $RG_NAME \
    -p "{ \"nsgID\": { \"value\": \"${NSG_ID}\" } }" \
    -p $PARAM_FILE

printf "$green" "*** Deployment finished for ENV: $ENVIRONMENT.  ***"
printf "$green" "***************************************************"

# get the outputs of the deployment
outputs=$(az deployment group show --name deploy -g $RG_NAME --query properties.outputs)

# store them in variables
DataBricksName=$(jq -r .dataBricksName.value <<<$outputs)
DataLakeID=$(jq -r .dataLakeID.value <<<$outputs)
AKV_ID=$(jq -r .akvID.value <<<$outputs)
AKV_URL=$(jq -r .akvURL.value <<<$outputs)

printf "$green" "DataBricksName:   $DataBricksName"
printf "$green" "DataLakeID:       $DataLakeID"
printf "$green" "AKV_ID:           $AKV_ID"
printf "$green" "AKV_URL:          $AKV_URL"


