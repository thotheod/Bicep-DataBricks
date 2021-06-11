param name string
param region string
param tags object
param managedResourceGroupId string
param privateSubnetName string 
param publicSubnetName string 
param vnetID string

@allowed([
  'standard'
  'premium'
])
param dBricksSKU string = 'premium'

resource ws 'Microsoft.Databricks/workspaces@2018-04-01' = {
  name: name
  location: region
  sku: {
    name: dBricksSKU
  }
  tags: tags
  properties: {
    managedResourceGroupId: managedResourceGroupId
    parameters: {
      customVirtualNetworkId: {
        value: vnetID
      }
      customPublicSubnetName: {
        value: publicSubnetName
      }
      customPrivateSubnetName: {
        value: privateSubnetName
      }
    }
  }
}
