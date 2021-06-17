#!/bin/bash

# Variables
red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
blue='\e[1;34m%s\e[0m\n'

# Set your Azure Subscription
SUBSCRIPTION=0a52391c-0d81-434e-90b4-d04f5c670e8a

# choice of dev|prod
ENVIRONMENT=dev
RG_NAME="rg-test"
LOCATION=northeurope


# 0. use for dynamic extension loader
az config set extension.use_dynamic_install=yes_without_prompt

# Code - do not change anything here on deployment
# 1. Set the right subscription
printf "$blue" "*** Setting the subsription to $SUBSCRIPTION ***"
az account set --subscription "$SUBSCRIPTION"

# 2. Create main Resource group if not exists
az group create --name $RG_NAME --location $LOCATION
printf "$green" "*** Resource Group $SUBSCRIPTION created (or Existed) ***"
# az group delete --name $RG_NAME --yes




az deployment group create \
    -f ./storageRoleAssignment.bicep \
    -g $RG_NAME \
    -c
