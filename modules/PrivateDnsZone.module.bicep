//  See https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns for privateDNS zones names
param privateDNSZoneName string
param vnetID string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDNSZoneName
  location: 'global'
  properties: {}
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: '${privateDnsZone.name}/${privateDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetID
    }
  }
}

output privateDnsZoneId string = privateDnsZone.id
output privateDnsZoneLink string = privateDnsZoneLink.id
