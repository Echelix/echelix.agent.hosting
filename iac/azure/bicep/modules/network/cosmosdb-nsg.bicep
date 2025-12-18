@description('Name for the NSG')
param nsgName string

@description('Location for the NSG')
param location string

@description('Resource tags')
param resourceTagging object

@description('AKS subnet CIDR (for NSG rules)')
param aksSubnetCidr string

// Network Security Group rules for Cosmos DB
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsgName
  location: location
  tags: resourceTagging
  properties: {
    securityRules: [
      {
        name: 'AllowCosmosDbPrivateEndpoint'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          description: 'Allow HTTPS traffic to Cosmos DB private endpoint'
        }
      }
      {
        name: 'AllowAKSToCosmosDb'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: aksSubnetCidr // AKS subnet CIDR
          destinationAddressPrefix: '*'
          description: 'Allow AKS pods to access Cosmos DB'
        }
      }
      // {
      //   name: 'DenyAllOtherInbound'
      //   properties: {
      //     priority: 4000
      //     direction: 'Inbound'
      //     access: 'Deny'
      //     protocol: '*'
      //     sourcePortRange: '*'
      //     destinationPortRange: '*'
      //     sourceAddressPrefix: '*'
      //     destinationAddressPrefix: '*'
      //     description: 'Deny all other inbound traffic'
      //   }
      // }
    ]
  }
}

output nsgId string = nsg.id
output nsgName string = nsg.name
