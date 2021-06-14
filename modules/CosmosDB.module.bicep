param name string
param region string
param tags object
param publicNetworkAccess string = 'Enabled'

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2020-06-01-preview' = {
  name: length(name) > 44 ? toLower(substring(name, 0, 44)) : toLower(name)
  location: region
  tags: tags
  kind: 'GlobalDocumentDB'
  properties: {
    createMode: 'Default'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: region
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    publicNetworkAccess: publicNetworkAccess
  }
}

output dbAccountID string = databaseAccount.id
output dbAccountName string = databaseAccount.name
//output connectionString string = 'AccountEndpoint=https://${databaseAccount.name}.documents.azure.com:443/;AccountKey=${listKeys(databaseAccount.id, databaseAccount.apiVersion).primaryMasterKey};'
output PrimaryConnectionString string = listConnectionStrings(databaseAccount.id, databaseAccount.apiVersion).connectionStrings[0].connectionString
output PrimaryReadOnlyConnectionString string = listConnectionStrings(databaseAccount.id, databaseAccount.apiVersion).connectionStrings[3].connectionString
