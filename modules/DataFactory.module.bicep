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
