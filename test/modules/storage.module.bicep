
param name string

resource storage 'Microsoft.Storage/storageAccounts@2019-04-01' = {
  name: name
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {}
}
