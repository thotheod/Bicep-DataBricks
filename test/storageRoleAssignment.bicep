@description('The principal to assign the role to')
param principalId string = 'xxx'

@description('A new GUID used to identify the role assignment')
param roleNameGuid string = guid(resourceGroup().id)

// var Owner = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
// var Contributor = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
var Reader = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7'
var storageName_var = 'storage${uniqueString(resourceGroup().id)}'


module storagemodule 'modules/storage.module.bicep' = {
  name: 'storageDeployment'
  params: {
    name: storageName_var
  }
}

resource storageRef 'Microsoft.Storage/storageAccounts@2019-04-01' existing = {
  name: storageName_var
}

resource roleNameGuid_resource 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: storageRef
  // scope: 'Microsoft.Storage/storageAccounts/${storageName_var}'
  name: roleNameGuid
  properties: {
    roleDefinitionId: Reader
    principalId: principalId
  }
  dependsOn: [
    storagemodule
  ]
}
