param name string
param region string
param tags object
var eventHubName = 'hub1'
var consumerGroupName = 'cg-hub1'

var defaultNsSASKeyName = 'RootManageSharedAccessKey'
var authRuleNsResourceId = resourceId('Microsoft.EventHub/namespaces/authorizationRules', name, defaultNsSASKeyName)


@allowed([
  'Basic'
  'Standard'
])
param eventHubSku string = 'Standard'

@allowed([
  1
  2
  4
])
param skuCapacity int = 1


resource namespace 'Microsoft.EventHub/namespaces@2017-04-01' = {
  name: length(name) > 50 ? substring(name, 0, 50) : name
  location: region
  tags: tags
  sku: {
    name: eventHubSku
    tier: eventHubSku
    capacity: skuCapacity
  }
  properties: {}
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2017-04-01' = {
  name: '${namespace.name}/${eventHubName}'
  properties: {}
}

resource consumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2017-04-01' = {
  name: '${eventHub.name}/${consumerGroupName}'
  properties: {}
}

resource eventHubNameSendSASKey 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2017-04-01' = {
  name: 'eventHubNameSendSASKey'
  parent: eventHub
  properties: {
    rights: [
      'Send'
    ]
  }
}

resource eventHubNameListenSASKey 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2017-04-01' = {
  name: 'eventHubNameListenSASKey'
  parent: eventHub
  properties: {
    rights: [
      'Listen'
    ]
  }
}

output EHNamespaceConnectionString string = listkeys(authRuleNsResourceId, eventHub.apiVersion).primaryConnectionString
output EHSendSasKey string = listkeys(eventHubNameSendSASKey.id, eventHubNameSendSASKey.apiVersion).primaryKey
output EHSendSasKeyCS string = listkeys(eventHubNameSendSASKey.id, eventHubNameSendSASKey.apiVersion).primaryConnectionString
output EHListenSasKey string = listkeys(eventHubNameListenSASKey.id, eventHubNameListenSASKey.apiVersion).primaryKey
output EHListenSasKeyCS string = listkeys(eventHubNameListenSASKey.id, eventHubNameListenSASKey.apiVersion).primaryConnectionString

// output namespaceName string = namespaceName_var
// output NamespaceConnectionString string = listkeys(authRuleResourceId, apiVersion).primaryConnectionString
// output NamespaceSharedAccessPolicyPrimaryKey string = listkeys(authRuleResourceId, apiVersion).primaryKey
// output EventHubSendOnlyConnectionString string = listkeys(sendAuthRuleResourceId, apiVersion).primaryConnectionString
// output EventHubSendOnlyPolicyPrimaryKey string = listkeys(sendAuthRuleResourceId, apiVersion).primaryKey
// output EventHubListenOnlyConnectionString string = listkeys(listenAuthRuleResourceId, apiVersion).primaryConnectionString
// output EventHubListenOnlyPolicyPrimaryKey string = listkeys(listenAuthRuleResourceId, apiVersion).primaryKey
