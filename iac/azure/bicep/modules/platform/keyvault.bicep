@description('Name of the Key Vault')
param keyVaultName string = 'demo-vault'

@description('Location for resources')
param location string = resourceGroup().location 
 
/*
  parameter driven resource tagging 
*/
param resourceTagging object

param vnetworkRg string

param networkDefinition array 


resource vNet 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-${filter(networkDefinition, n => n.name == 'ai-network')[0].id}'
  scope: resourceGroup(vnetworkRg)
  resource aksSubnet 'subnets' existing = {
    name: '${resourceTagging.environment}-${resourceTagging.product}-${filter(networkDefinition, n => n.name == 'ai-aks-subnet')[0].id}'
  }
  resource apimSubnet 'subnets' existing = {
    name: '${resourceTagging.environment}-${resourceTagging.product}-${filter(networkDefinition, n => n.name == 'ai-apim-subnet')[0].id}'
  }
  resource platformSubnet 'subnets' existing = {
    name: '${resourceTagging.environment}-${resourceTagging.product}-${filter(networkDefinition, n => n.name == 'platform-subnet')[0].id}'
  }
}

// Create Managed Identity
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-kv-demo-identity'
  location: location
}

// Create Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: keyVaultName
  location: location
  tags: resourceTagging
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: managedIdentity.properties.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: [
         {
          id: vNet::aksSubnet.id
         }
         {
          id: vNet::apimSubnet.id
         }
         {
          id: vNet::platformSubnet.id
         }
      ]
      ipRules: []
    }
    enableRbacAuthorization: false
  }
}

output managedIdentityId string = managedIdentity.id
output keyVaultId string = keyVault.id
