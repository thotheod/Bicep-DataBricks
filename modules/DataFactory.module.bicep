param name string
param region string
param tags object

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: name
  location: region
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}


output name string = dataFactory.name
output id string = dataFactory.id
output identity object = {
  tenantId: dataFactory.identity.tenantId
  principalId: dataFactory.identity.principalId
  type: dataFactory.identity.type
}


// gone with Private Link for DataFctory (not portal)
// https://docs.microsoft.com/en-us/azure/data-factory/data-factory-service-identity
// https://docs.microsoft.com/en-us/azure/data-factory/data-factory-private-link
// https://docs.microsoft.com/en-us/azure/data-factory/managed-virtual-network-private-endpoint
