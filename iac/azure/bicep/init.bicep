targetScope = 'subscription'

param StartDate string = utcNow('yyyyMMdd-HHmmss')

param acrSku string
param location string
param registryName string

// api Resouce Group Name 
param apiResourceGroupName string

// web application resource group name 
param webResourceGroupName string 

// database RG
param databaseResourceGroupName string

//platform azure RG 
param platformResourceGroupName string

// network RG 
param networkResourceGroupName string

// AI Resource Group 
param aiResourceGroupName string

// Monitoring resource group 
param monitoringResourceGroupName string 

param currentYear string = utcNow('yyyy')
/*
*********************
networking parameters 
*********************
*/
 
@description('Network definition for the deployment, including subnets and their configurations.')
param networkDefinition array
 
var networks = [for item in networkDefinition: {
  name: item.name
  id: item.id
  cidr: item.cidr
}]
  
/*
  parameter driven resource tagging 
*/
param resourceTagging object

resource apimRG 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-${apiResourceGroupName}'
  location: location
  tags: resourceTagging
}

resource netRG 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-${networkResourceGroupName}'
  location: location
  tags: resourceTagging
}

resource webRG 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-${webResourceGroupName}'
  location: location
  tags: resourceTagging
}
 
resource dataRG 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-${databaseResourceGroupName}'
  location: location
  tags: resourceTagging
}

resource platformRG 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-${platformResourceGroupName}'
  location: location
  tags: resourceTagging
}

resource aiRG 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-${aiResourceGroupName}'
  location: location
  tags: resourceTagging
}

resource monitorRG 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-${monitoringResourceGroupName}'
  location: location
  tags: resourceTagging
}

module vNet 'modules/network/network.bicep' = {
  scope: netRG
  name: 'Network-Deploy-${StartDate}'
  params: {
    location: location  
    resourceTagging: resourceTagging
    networkAddresses: networks 
  }
}

module keyVault 'modules/platform/keyvault.bicep' = {
  scope: platformRG
  name: 'KeyVault-Deploy-${resourceTagging.product}'
  params: {
    location: location
    resourceTagging: resourceTagging
    networkDefinition: networkDefinition
    vnetworkRg: netRG.name
    keyVaultName: '${resourceTagging.environment}-${resourceTagging.businessUnit}-${currentYear}kv'
  }
  dependsOn: [
    vNet
  ]
}

module acr 'modules/private-link/privatelink-dns.bicep' = {
  scope: platformRG
  name: 'Privatelink-Deploy-${resourceTagging.product}${registryName}'
  params: {
    acrSku: acrSku
    location: location
    registryName: registryName
    vNetName: vNet.outputs.vnetName
    vNetId: vNet.outputs.vnetId
    vNetRgName: vNet.outputs.vnetRgName 
    networkEndpointSubnetName: vNet.outputs.privatelinkSubnetName
    resourceTagging: resourceTagging
  }
}



