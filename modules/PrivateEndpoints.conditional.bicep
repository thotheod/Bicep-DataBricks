param vnetID string 
param cosmosDBName string
param tags object
param cosmosDbId string //cosmosDB.outputs.dbAccountID
param subnetPeID string


// private endpoints
module dnsZoneForCosmosDB 'PrivateDnsZone.module.bicep' =  {
  name: 'dnsZoneForCosmosDBDeployment'
  params:{
    privateDNSZoneName: 'privatelink.documents.azure.com'
    vnetID: vnetID
  }
}

module cosmosDBPrivateLink 'PE.module.bicep' =  {
  name: 'cosmosDBPrivateLinkDeployment'
  params:{
    name: cosmosDBName
    region: resourceGroup().location
    tags: tags
    pLinkServiceID: cosmosDbId
    serviceLinkGroupId: 'Sql'
    privateDnsZoneId: dnsZoneForCosmosDB.outputs.privateDnsZoneId
    snetID: subnetPeID
  }
}
