// that's the default, but put it here for completeness
targetScope = 'resourceGroup'

// PARAMS General
param suffix string = 'DataBricksExplore'
param usePrivateLinks bool = true

// params exported on param file
param resourceTags object
param keyVaultSku string

// PARAMS Vnet
param vnetAddressSpace string = '192.168.0.0/24'
param snetDBricksPublic object = {
  name: 'snet-DBricksPublic'
  subnetPrefix: '192.168.0.0/26'
}
param snetDBricksPrivate object = {
  name: 'snet-DBricksPrivate'
  subnetPrefix: '192.168.0.64/26'
}
param snetPE object = {
  name: 'snet-PE'
  subnetPrefix: '192.168.0.128/26'
}
param snetAdmin object = {
  name: 'snet-Admin'
  subnetPrefix: '192.168.0.192/27'
}
param snetBastion object = {
  name: 'AzureBastionSubnet' //fixed name of subnet de-jure
  subnetPrefix: '192.168.0.224/27'
}
param nsgID string

//params Databircks
param dBricksSKU string = 'premium'

//params VM
param vmJumpBox object

//VARS
// vars  Resource Names
var env = resourceTags.Environment
var vnetName = 'vnet-${env}-${suffix}'
var dataFactoryName = 'adf-${env}-${suffix}'
var dBricksWSName = 'dbw-${env}-${suffix}'
var managedResourceGroupName = 'rg-databricks-${dBricksWSName}-${uniqueString(dBricksWSName, resourceGroup().id)}'
var managedResourceGroupId = '${subscription().id}/resourceGroups/${managedResourceGroupName}'
var dataLakeName = 'st${env}${uniqueString(resourceGroup().id)}${suffix}'
var keyVaultName = 'kv-${env}-${suffix}'
var eventHubName = 'evh-${env}-${suffix}-${uniqueString(resourceGroup().id)}'
var cosmosDBAccountName = 'cosmos-${env}-${suffix}-${uniqueString(resourceGroup().id)}'
var cosmosDBName = 'adventureWorks'
var cosmosContainerName = 'stores'
var bastionName = 'bastionHost${env}'

//vars for keyvault
var secretNames = {
  DataLakeConnectionString: 'DataLakeConnectionString'
  EventHubNsManageConnectionString: 'EventHubNsManageConnectionString'
  EventHubSendConnectionString: 'EventHubSendConnectionString'
  EventHubListenConnectionString: 'EventHubListenConnectionString'
  CosmosDBPrimaryConnectionString: 'CosmosDBPrimaryConnectionString'
  CosmosDBReadOnlyConnectionString: 'CosmosDBReadOnlyConnectionString'
}

//Create Resources

//create the Virtual Network to host all resources and its subnets
module vnet 'modules/VNet.module.bicep' = {
  name: 'vnetDeployment-${vnetName}'
  params: {
    name: vnetName
    region: resourceGroup().location
    snetDBricksPublic: snetDBricksPublic
    snetDBricksPrivate: snetDBricksPrivate
    snetPE: snetPE
    snetAdmin: snetAdmin
    snetBastion: snetBastion
    vnetAddressSpace: vnetAddressSpace
    tags: resourceTags
    nsgID: nsgID
  }
}
module dBricksWS 'modules/DataBricks.module.bicep' = {
  name: 'DataBricksWorkspaceDeplyment'
  params: {
    name: dBricksWSName
    region: resourceGroup().location
    tags: resourceTags
    dBricksSKU: dBricksSKU
    managedResourceGroupId: managedResourceGroupId
    privateSubnetName: snetDBricksPrivate.name
    publicSubnetName: snetDBricksPublic.name
    vnetID: vnet.outputs.vnetID
  }
}

module dataLake 'modules/DataLake.module.bicep' = {
  name: 'DataLakeDeployment'
  params: {
    name: dataLakeName
    region: resourceGroup().location
    tags: resourceTags
  }
}

module dataFactory 'modules/DataFactory.module.bicep' = {
  name: 'DataFactoryDeployment'
  params: {
    name: dataFactoryName
    region: resourceGroup().location
    tags: resourceTags
  }
}

module keyVault 'modules/keyvault.module.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    name: keyVaultName
    region: resourceGroup().location
    skuName: keyVaultSku
    tags: resourceTags
    accessPolicies: [
      {
        tenantId: dataFactory.outputs.identity.tenantId
        objectId: dataFactory.outputs.identity.principalId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
    secrets: [
      {
        name: secretNames.DataLakeConnectionString
        value: dataLake.outputs.connectionString
      }
      {
        name: secretNames.EventHubNsManageConnectionString
        value: eventHub.outputs.EHNamespaceConnectionString
      }
      {
        name: secretNames.EventHubListenConnectionString
        value: eventHub.outputs.EHListenSasKeyCS
      }
      {
        name: secretNames.EventHubSendConnectionString
        value: eventHub.outputs.EHSendSasKeyCS
      }
      {
        name: secretNames.CosmosDBPrimaryConnectionString
        value: cosmosDB.outputs.PrimaryConnectionString
      }
      {
        name: secretNames.CosmosDBReadOnlyConnectionString
        value: cosmosDB.outputs.PrimaryReadOnlyConnectionString
      }
    ]
  }
}

module eventHub 'modules/EventHub.module.bicep' = {
  name: 'eventHubDeployment'
  params: {
    name: eventHubName
    region: resourceGroup().location
    tags: resourceTags
  }
}

module cosmosDB 'modules/CosmosDB.module.bicep' = {
  name: 'cosmosDBDeployment'
  params: {
    name: cosmosDBAccountName
    databaseName: cosmosDBName
    containerName: cosmosContainerName
    region: resourceGroup().location
    tags: resourceTags
  }
}

module privateLinks 'modules/PrivateEndpoints.conditional.bicep' = if (usePrivateLinks) {
  name: 'privateLinksDeployment'
  params: {
    tags: resourceTags
    cosmosDbId: cosmosDB.outputs.dbAccountID
    cosmosDBName: cosmosDB.outputs.dbAccountName
    subnetPeID: vnet.outputs.snetPEID
    vnetID: vnet.outputs.vnetID
    dataLakeName: dataLake.outputs.name
    dataLakeId: dataLake.outputs.id
    eventHubNamespace: eventHub.outputs.EventHubNamespace
    eventHubNsId: eventHub.outputs.EventHubNamespaceId
    keyVaultName: keyVault.outputs.name
    keyVaultId: keyVault.outputs.id
    adfID: dataFactory.outputs.id
    adfName: dataFactory.outputs.name
  }
}

module vm 'modules/vmjumpbox.module.bicep' = {
  name: 'vmJumpboxDeployment'
  params: {
    name: vmJumpBox.name
    region: resourceGroup().location
    tags: resourceTags
    adminUserName: vmJumpBox.adminUserName
    adminPassword: vmJumpBox.adminPassword
    dnsLabelPrefix: vmJumpBox.dnsLabelPrefix
    subnetId: vnet.outputs.snetAdminID
    vmSize:  vmJumpBox.vmSize
    windowsOSVersion: vmJumpBox.windowsOSVersion
  }
}

module bastion 'modules/bastion.module.bicep' = {
  name: 'bastionDeployment'
  params: {
    name: bastionName
    region: resourceGroup().location
    tags: resourceTags
    subnetId: vnet.outputs.snetBastionID
  }
}

output dataBricksName string = dBricksWS.outputs.dataBricksName
output dataLakeID string = dataLake.outputs.id
output akvID string = keyVault.outputs.id
output akvURL string = 'https://${toLower(keyVault.outputs.name)}.vault.azure.net/'//https://kv-dev-databricksexplore.vault.azure.net/
