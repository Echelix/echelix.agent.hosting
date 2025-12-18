param location string = resourceGroup().location  

param networkAddresses array = [
  {
    name: 'ai-network'
    id: 'ai-network'
    cidr: 'x.x.x.x/16' // Replace with actual CIDR
  }
]

param resourceTagging object 


resource EventingNSG 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-Eventing-Azure-Resources-NSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowPort443'
        properties: {
          description: 'allows ingress  port 443'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['443']
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
    ]
  }
  tags: resourceTagging
}

resource WebSiteNSG 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-CASSI-HTTPS-Only-NSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowPort443Only'
        properties: {
          description: 'allows ingress of data over port 443'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['443']
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
    ]
  }
  tags: resourceTagging
}

resource ContainerNSG 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-HTTP-HTTPS-Only-NSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowPort80And443'
        properties: {
          description: 'allows ingress of data over port 80, 5000, 8082 and or port 443'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['80', '443', '3500', '5000', '8082']
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
    ]
  }
  tags: resourceTagging
}

resource GatewaySubnetNSG 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-Gateway-Subnet-NSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowGatewayManagement'
        properties: {
          description: 'Allow Azure Gateway management traffic (IKE, IPsec, BGP, and GatewayHealth)'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: ['80', '443', '500', '4500', '1701', '1194', '8080']
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
      // {
      //   name: 'DenyAllInbound'
      //   properties: {
      //     description: 'Deny all other inbound traffic'
      //     protocol: '*'
      //     sourcePortRange: '*'
      //     destinationPortRange: '*'
      //     sourceAddressPrefix: '*'
      //     destinationAddressPrefix: '*'
      //     access: 'Deny'
      //     priority: 4096
      //     direction: 'Inbound'
      //   }
      // }
    ]
  }
  tags: resourceTagging
}

resource FunctionsNSG 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-Functions-HTTPS-NSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowFunctionPort443'
        properties: {
          description: 'port 443'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['443']
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
    ]
  }
  tags: resourceTagging
}

resource DatabaseNSG 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-Database-NSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowPortDb443'
        properties: {
          description: 'allows connections on port 443'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['443', '5432']
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
    ]
  }
  tags: resourceTagging
}

resource ApimNSG 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-APIM-NSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowWebIngress443'
        properties: {
          description: 'allows for port 443 for APIM ingress network security'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['443']
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAPIMManagement'
        properties: {
          description: 'allows correct ports for apim management access'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1500
          direction: 'Inbound'
        }
      }
    ]
  }
  tags: resourceTagging
}

resource vNet 'Microsoft.Network/virtualNetworks@2024-05-01' = { 
name: '${resourceTagging.environment}-${resourceTagging.product}-${filter(networkAddresses, n => n.name == 'ai-network')[0].id}' 
 
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
       filter(networkAddresses, n => n.name == 'ai-network')[0].cidr   
      ]
    } 
    subnets: [
      {
        name: '${resourceTagging.environment}-${resourceTagging.product}-${filter(networkAddresses, n => n.name == 'ai-apim-subnet')[0].id}'
        properties: {
          addressPrefix: filter(networkAddresses, n => n.name == 'ai-apim-subnet')[0].cidr
          networkSecurityGroup: {
            id: ApimNSG.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.KeyVault'
            }
          ]
        }
      }  
      {
        name: '${resourceTagging.environment}-${resourceTagging.product}-${filter(networkAddresses, n => n.name == 'platform-subnet')[0].id}'
        properties: {
          addressPrefix: filter(networkAddresses, n => n.name == 'platform-subnet')[0].cidr
          networkSecurityGroup: {
            id: EventingNSG.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.KeyVault'
            }
             {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
      {
        name: '${resourceTagging.environment}-${resourceTagging.product}-${filter(networkAddresses, n => n.name == 'ai-database-subnet')[0].id}'
        properties: {
          addressPrefix: filter(networkAddresses, n => n.name == 'ai-database-subnet')[0].cidr
          serviceEndpoints: [
            {
              service: 'Microsoft.Sql'
            }
            {
              service: 'Microsoft.AzureCosmosDB'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          networkSecurityGroup: {
            id: DatabaseNSG.id
          }
        }
      }
      {
        name: '${resourceTagging.environment}-${resourceTagging.product}-${filter(networkAddresses, n => n.name == 'ai-aci-subnet')[0].id}'
        properties: {
          addressPrefix: filter(networkAddresses, n => n.name == 'ai-aci-subnet')[0].cidr
          networkSecurityGroup: {
            id: ContainerNSG.id
          }
          delegations: [
            {
              name: 'DelegationService'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
          serviceEndpoints: [
            {
              service: 'Microsoft.KeyVault'
            }
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
      {
        name: '${resourceTagging.environment}-${resourceTagging.product}-${filter(networkAddresses, n => n.name == 'ai-endpoints-subnet')[0].id}'
        properties: {
          addressPrefix: filter(networkAddresses, n => n.name == 'ai-endpoints-subnet')[0].cidr
        }
      }
      {
        name: '${resourceTagging.environment}-${resourceTagging.product}-${filter(networkAddresses, n => n.name == 'ai-aks-subnet')[0].id}'
        properties: {
          addressPrefix: filter(networkAddresses, n => n.name == 'ai-aks-subnet')[0].cidr
          networkSecurityGroup: {
            id: ContainerNSG.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.KeyVault'
            }
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.AzureCosmosDB'
            }
          ]
        }
      }
      {
        name: '${resourceTagging.environment}-${resourceTagging.product}-${filter(networkAddresses, n => n.name == 'ai-web-subnet')[0].id}'
        properties: {
          addressPrefix: filter(networkAddresses, n => n.name == 'ai-web-subnet')[0].cidr
          networkSecurityGroup: {
            id: WebSiteNSG.id
          }
          delegations: [
            {
              name: 'DelegationService'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
          serviceEndpoints: [
            {
              service: 'Microsoft.KeyVault'
            }
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
    {
        name: '${resourceTagging.environment}-${resourceTagging.product}-${filter(networkAddresses, n => n.name == 'ai-aks-lb-subnet')[0].id}'
        properties: {
          addressPrefix: filter(networkAddresses, n => n.name == 'ai-aks-lb-subnet')[0].cidr
          networkSecurityGroup: {
            id: GatewaySubnetNSG.id
          }
        }
      }
    ]
 
  
  }
  tags: resourceTagging
}

output vnetId string = vNet.id
output vnetName string = vNet.name
output vnetRgName string = resourceGroup().name
output privatelinkSubnetName string = filter(networkAddresses, n => n.name == 'ai-endpoints-subnet')[0].id
