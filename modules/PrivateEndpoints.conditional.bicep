param vnetID string
param cosmosDBName string
param dataLakeName string
param keyVaultName string
param adfName string
param eventHubNamespace string
param tags object
param cosmosDbId string //cosmosDB.outputs.dbAccountID
param dataLakeId string
param keyVaultId string
param adfID string
param subnetPeID string
param eventHubNsId string

var privateLinkConfig = {
  cosmosDBSql: {
    name: 'privatelink.documents.azure.com'
    subResource: 'Sql'
  }
  dataLakeFileSystemGen2: {
    name: 'privatelink.dfs.core.windows.net'
    subResource: 'dfs'
  }
  eventHub: {
    name: 'privatelink.servicebus.windows.net'
    subResource: 'namespace'
  }
  keyVault: {
    name: 'privatelink.vaultcore.azure.net'
    subResource: 'vault'
  }
  dataFactory: {
    name: 'privatelink.datafactory.azure.net'
    subResource: 'dataFactory' //here I think it has one more option for ADF which is portal :S
  }
}

// CosmosDB
//TODO: test connectivity https://docs.microsoft.com/en-us/azure/private-link/tutorial-private-endpoint-cosmosdb-portal?bc=/azure/cosmos-db/breadcrumb/toc.json&toc=/azure/cosmos-db/toc.json#test-connectivity-to-private-endpoint
module cosmosDbDnsZone 'PrivateDnsZone.module.bicep' = {
  name: 'CosmosDBDnsZoneDeployment'
  params: {
    privateDNSZoneName: privateLinkConfig.cosmosDBSql.name
    vnetID: vnetID
  }
}

module cosmosDBPrivateLink 'PE.module.bicep' = {
  name: 'CosmosDBPrivateLinkDeployment'
  params: {
    name: 'pe-${cosmosDBName}'
    region: resourceGroup().location
    tags: tags
    pLinkServiceID: cosmosDbId
    serviceLinkGroupId: privateLinkConfig.cosmosDBSql.subResource
    privateDnsZoneId: cosmosDbDnsZone.outputs.privateDnsZoneId
    snetID: subnetPeID
  }
}

//Azure storage
// reference: https://docs.microsoft.com/en-us/azure/storage/common/storage-private-endpoints
module dataLakeDnsZone 'PrivateDnsZone.module.bicep' = {
  name: 'DataLakeDnsZoneDeployment'
  params: {
    privateDNSZoneName: privateLinkConfig.dataLakeFileSystemGen2.name
    vnetID: vnetID
  }
}

module dataLakePrivateLink 'PE.module.bicep' = {
  name: 'DataLakePrivateLinkDeployment'
  params: {
    name: 'pe-${dataLakeName}'
    region: resourceGroup().location
    tags: tags
    pLinkServiceID: dataLakeId
    privateDnsZoneId: dataLakeDnsZone.outputs.privateDnsZoneId
    serviceLinkGroupId: privateLinkConfig.dataLakeFileSystemGen2.subResource
    snetID: subnetPeID
  }
}

//eventHub
module eventHubDnsZone 'PrivateDnsZone.module.bicep' = {
  name: 'EventHubDnsZoneDeployment'
  params: {
    privateDNSZoneName: privateLinkConfig.eventHub.name
    vnetID: vnetID
  }
}

module eventHubPrivateLink 'PE.module.bicep' = {
  name: 'EventHubPrivateLinkDeployment'
  params: {
    name: 'pe-${eventHubNamespace}'
    region: resourceGroup().location
    tags: tags
    pLinkServiceID: eventHubNsId
    privateDnsZoneId: eventHubDnsZone.outputs.privateDnsZoneId
    serviceLinkGroupId: privateLinkConfig.eventHub.subResource
    snetID: subnetPeID
  }
}

//keyvault
module keyVaultDnsZone 'PrivateDnsZone.module.bicep' = {
  name: 'KeyVaultDnsZoneDeployment'
  params: {
    privateDNSZoneName: privateLinkConfig.keyVault.name
    vnetID: vnetID
  }
}

module keyVaultPrivateLink 'PE.module.bicep' = {
  name: 'KeyVaultPrivateLinkDeployment'
  params: {
    name: 'pe-${keyVaultName}'
    region: resourceGroup().location
    tags: tags
    pLinkServiceID: keyVaultId
    privateDnsZoneId: keyVaultDnsZone.outputs.privateDnsZoneId
    serviceLinkGroupId: privateLinkConfig.keyVault.subResource
    snetID: subnetPeID
  }
}

//DataFactory 
module dataFactoryDnsZone 'PrivateDnsZone.module.bicep' = {
  name: 'DataFactoryDnsZoneDeployment'
  params: {
    privateDNSZoneName: privateLinkConfig.dataFactory.name
    vnetID: vnetID
  }
}

module dataFactoryPrivateLink 'PE.module.bicep' = {
  name: 'DataFactoryPrivateLinkDeployment'
  params: {
    name: 'pe-${adfName}'
    region: resourceGroup().location
    tags: tags
    pLinkServiceID: adfID
    privateDnsZoneId: dataFactoryDnsZone.outputs.privateDnsZoneId
    serviceLinkGroupId: privateLinkConfig.dataFactory.subResource
    snetID: subnetPeID
  }
}
