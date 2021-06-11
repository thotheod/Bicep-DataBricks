param name string
param region string
param tags object
param nsgName string
param vnetAddressSpace string 
param enableVmProtection bool = false
param enableDdosProtection bool = false
param snetDBricksPublic object
param snetDBricksPrivate object
param snetPE object
param snetAdmin object
param snetBastion object


resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: name
  location: region
  tags: tags
  properties: {
    enableVmProtection: enableVmProtection
    enableDdosProtection: enableDdosProtection
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }  
    subnets: [
      {
        name: snetDBricksPublic.name
        properties: {
          addressPrefix: snetDBricksPublic.subnetPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
          delegations: [
            {
              name: 'databricks-del-public'
              properties: {
                serviceName: 'Microsoft.Databricks/workspaces'
              }
            }
          ]
        }
      } 
      {
        name: snetDBricksPrivate.name
        properties: {
          addressPrefix: snetDBricksPrivate.subnetPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
          delegations: [
            {
              name: 'databricks-del-private'
              properties: {
                serviceName: 'Microsoft.Databricks/workspaces'
              }
            }
          ]
        }
      }
      {
        name: snetPE.name
        properties: {
          addressPrefix: snetPE.subnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'          
        }
      }
      {
        name: snetAdmin.name
        properties: {
          addressPrefix: snetAdmin.subnetPrefix
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
      {
        name: snetBastion.name
        properties: {
          addressPrefix: snetBastion.subnetPrefix
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
    ]
  }  
}


//it 's required for the Databricks subnets
resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: nsgName
  location: region
  tags: tags
}


output vnetID string = vnet.id
output snetDBricksPublicID string = vnet.properties.subnets[0].id
output snetDBricksPrivateID string = vnet.properties.subnets[1].id
output snetPEID string = vnet.properties.subnets[2].id
output snetAdminID string = vnet.properties.subnets[3].id
output snetBastionID string = vnet.properties.subnets[4].id
