param name string
param databaseName string
param containerName string = ''
param region string
param tags object
param publicNetworkAccess string = 'Enabled'

@minValue(4000)
@description('Max throughput in RU/s in an Autoscale configuration - minimum RUs 1/10 of this number')
param maxThroughput int = 4000

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

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-04-15' = {
  name: '${databaseAccount.name}/${databaseName}'
  properties: {
    resource: {
      id: databaseName
    }
    options: {
      autoscaleSettings: {
        maxThroughput: maxThroughput
      }
    }
  }
}

// Sample container definition - tweak of properties will be required on actual deployment (partitioning, indexing etc)
resource cosmosDbCollection 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-04-15' = if (!empty(containerName)) {
  name: '${database.name}/${containerName}'
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
      }
    }
  }
}

output dbAccountID string = databaseAccount.id
output dbAccountName string = databaseAccount.name
//output connectionString string = 'AccountEndpoint=https://${databaseAccount.name}.documents.azure.com:443/;AccountKey=${listKeys(databaseAccount.id, databaseAccount.apiVersion).primaryMasterKey};'
output PrimaryConnectionString string = listConnectionStrings(databaseAccount.id, databaseAccount.apiVersion).connectionStrings[0].connectionString
output PrimaryReadOnlyConnectionString string = listConnectionStrings(databaseAccount.id, databaseAccount.apiVersion).connectionStrings[3].connectionString
