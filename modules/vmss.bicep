param name string
param subnetId string
param sku string = 'Standard_B2ms'
param instanceCount int = 2
param location string = resourceGroup().location

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2023-03-01' = {
  name: name
  location: location
  sku: {
    name: sku
    capacity: instanceCount
    tier: 'Standard'
  }
  properties: {
    virtualMachineProfile: {
      storageProfile: {
        imageReference: {
          publisher: 'Canonical'
          offer: '0001-com-ubuntu-server-focal'
          sku: '20_04-lts'
          version: 'latest'
        }
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'nic'
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'ipconfig'
                  properties: {
                    subnet: { id: subnetId }
                  }
                }
              ]
            }
          }
        ]
      }
    }
    upgradePolicy: { mode: 'Automatic' }
  }
}

output id string = vmss.id
