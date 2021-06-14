param name string
param region string
param tags object

@allowed([
  'BlobStorage'
  'Storage'
  'StorageV2'
  'FileStorage'
  'BlockBlobStorage'
])
param kind string = 'StorageV2'

@allowed([
  {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  {
    name: 'Standard_GRS'
    tier: 'Standard'
  }
  {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
  {
    name: 'Standard_ZRS'
    tier: 'Standard'
  }
  {
    name: 'Premium_LRS'
    tier: 'Premium'
  }
  {
    name: 'Premium_GRS'
    tier: 'Premium'
  }
  {
    name: 'Premium_RAGRS'
    tier: 'Premium'
  }
  {
    name: 'Premium_ZRS'
    tier: 'Premium'
  }
])
param sku object = {
  name: 'Standard_LRS'
  tier: 'Standard'
}

@allowed([
  'Hot'
  'Cool'
])
param accessTier string = 'Hot'

param onlyHttps bool = true
param isDataLake bool = true
param allowBlobPublicAccess bool = false

resource storage 'Microsoft.Storage/storageAccounts@2019-06-01' = {  
  name: length(name) > 24 ? toLower(substring(replace(name, '-', ''), 0, 24)) : toLower(replace(name, '-', ''))
  location: region  
  kind: kind
  sku: sku
  tags: tags
  properties: {
    accessTier: accessTier
    supportsHttpsTrafficOnly: onlyHttps
    isHnsEnabled: isDataLake
    allowBlobPublicAccess: allowBlobPublicAccess
  }  
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices@2019-06-01' = {
  name: '${storage.name}/default'
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

output id string = storage.id
output name string = storage.name
output primaryKey string = listKeys(storage.id, storage.apiVersion).keys[0].value
output connectionString string = 'DefaultEndpointsProtocol=https;AccountName=${name};AccountKey=${listKeys(storage.id, storage.apiVersion).keys[0].value}'
