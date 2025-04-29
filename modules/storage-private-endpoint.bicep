// EXAM NOTE: Deploys Storage Account with Private Endpoint (Blob)
param storageAccountName string
param vnetName string
param subnetName string
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: [ '10.0.0.0/16' ] }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: vnet
  name: subnetName
  properties: {
    addressPrefix: '10.0.1.0/24'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
  }
}

resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.core.windows.net'
  location: 'global'
}

resource dnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: dnsZone
  name: '${vnetName}-link'
  properties: {
    registrationEnabled: false
    virtualNetwork: { id: vnet.id }
  }
}

resource pe 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${storageAccountName}-pe'
  location: location
  properties: {
    subnet: { id: subnet.id }
    privateLinkServiceConnections: [
      {
        name: '${storageAccountName}-conn'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [ 'blob' ]
        }
      }
    ]
  }
}

resource zoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  parent: pe
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${storageAccountName}-zone'
        properties: {
          privateDnsZoneId: dnsZone.id
        }
      }
    ]
  }
}

output privateEndpointId string = pe.id
