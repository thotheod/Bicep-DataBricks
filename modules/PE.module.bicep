param name string
param region string
param tags object
param snetID string
param pLinkServiceID string
param privateDnsZoneId string

@allowed([
  'sites'
  'sqlServer'
  'mysqlServer'
  'blob'
  'file'
  'queue'
  'redisCache'
  'namespace'
  'Sql'
  'dfs'
  'vault'
  'dataFactory'
  'portal'
])
param serviceLinkGroupId string


resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: name
  location: region
  tags: tags
  properties: {
    subnet: {
      id: snetID
    }
    privateLinkServiceConnections: [
      {
        name: 'pl-${name}'
        properties: {
          privateLinkServiceId: pLinkServiceID
          groupIds: [
            serviceLinkGroupId
          ]
        }
      }
    ]
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${privateEndpoint.name}/dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}
