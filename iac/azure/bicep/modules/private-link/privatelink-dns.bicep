
param registryName string
param location string = resourceGroup().location

param resourceTagging object

@allowed(['Basic', 'Standard', 'Premium'])
param acrSku string
param vNetName string
param vNetId string
param vNetRgName string
param networkEndpointSubnetName string = 'az-endpoints-subnet'
var ImagePullRoleId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource acr 'Microsoft.ContainerRegistry/registries@2025-04-01' = {
  name: '${resourceTagging.environment}${resourceTagging.product}${registryName}'
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: true
  }
  tags: resourceTagging
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-07-01' = if (acrSku == 'Premium') {
  name: '${resourceTagging.environment}-${resourceTagging.product}${registryName}-pep'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${resourceTagging.environment}${resourceTagging.product}${registryName}-pep'
        properties: {
          privateLinkServiceId: acr.id
          groupIds: [
            'registry'
          ]
        }
      }
    ]
    subnet: {
      //id: vNet::epSubnet.id
      id: resourceId(
        vNetRgName,
        'Microsoft.Network/virtualNetworks/subnets',
        vNetName,
        '${resourceTagging.environment}-${resourceTagging.product}-${networkEndpointSubnetName}'
      )
    }
  }
}

resource privDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: '${resourceTagging.product}.azurecr.io'
  location: 'global'
  tags: resourceTagging
}

resource privDnsNetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: privDnsZone
  name: '${resourceTagging.environment}.${resourceTagging.product}.privateLink.azurecr.io'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vNetId
    }
    registrationEnabled: false
  }
  tags: resourceTagging
}

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-07-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-azurecr-io'
        properties: {
          privateDnsZoneId: privDnsZone.id
        }
      }
    ]
  }
}

resource mgdId 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  location: location
  name: '${resourceTagging.environment}-${resourceTagging.product}${registryName}-AcrPull'
}

resource acrImagePull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(ImagePullRoleId, acr.id, mgdId.id)
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', ImagePullRoleId)
    principalId: mgdId.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output imagePullPrincipalId string = mgdId.properties.principalId
output imagePullId string = mgdId.id
