param appGatewayName string = 'agw-waf'
param location string = resourceGroup().location
param vnetName string
param subnetName string = 'AppGatewaySubnet'

resource vnet 'Microsoft.Network/virtualNetworks@2023-10-01' existing = {
  name: vnetName
}

resource appGw 'Microsoft.Network/applicationGateways@2023-09-01' = {
  name: appGatewayName
  location: location
  sku: {
    name: 'WAF_v2'
    tier: 'WAF_v2'
    capacity: 2
  }
  properties: {
    gatewayIPConfigurations: [
      {
        name: 'gwip'
        properties: {
          subnet: {
            id: vnet::subnets[subnetName].id
          }
        }
      }
    ]
    enableHttp2: true
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
    }
  }
}
