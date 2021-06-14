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
