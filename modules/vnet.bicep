param name string
param addressPrefix string = '10.0.0.0/16'
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
  }
}

output id string = vnet.id
