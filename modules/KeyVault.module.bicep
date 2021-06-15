//By Default SoftDeletion is on.
//if you delete the keyvault then it stays for some days as soft deleted
// run az keyvault list-deleted to find it
//and then az keyvault purge --name xxxxx to purge it
param name string
param region string
param tags object

@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

@description('Array of access policy configurations, schema ref: https://docs.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults/accesspolicies?tabs=json#microsoftkeyvaultvaultsaccesspolicies-object')
param accessPolicies array = []

@description('Secrets array with name/value pairs')
param secrets array = []

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: length(name) > 24 ? substring(name, 0, 24) : name
  location: region
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: skuName
    }
    accessPolicies: accessPolicies
  }
  tags: tags
}

module secretsDeployment 'KeyVault.secrets.module.bicep' = if (!empty(secrets)) {
  name: 'keyvault-secrets'
  params: {
    keyVaultName: keyVault.name
    secrets: secrets
  }
}

output id string = keyVault.id
output name string = keyVault.name
output secrets array = secretsDeployment.outputs.secrets
