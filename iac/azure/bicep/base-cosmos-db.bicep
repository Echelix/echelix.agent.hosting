targetScope = 'resourceGroup'

param cosmosDbAccountName string
param location string
param resourceTagging object 
param networkResourceGroupName string 
param databaseResourceGroupName string

@description('Whether to enable serverless mode for Cosmos DB')
param enableServerless bool = true

@description('Whether to enable free tier (cannot be used with serverless)')
param enableFreeTier bool = false

@description('Whether to create a private endpoint for Cosmos DB')
param privateEndpointEnabled bool = false

@description('Network definition for the deployment, including subnets and their configurations.')
param networkDefinition array

@description('Database configuration including databases and containers')
param databaseConfig object = {
  databases: [
    {
      name: 'agentData'
      containers: [
        {
          name: 'agents'
          partitionKey: '/agentId'
          throughput: 400
        }
        {
          name: 'conversations'
          partitionKey: '/conversationId'
          throughput: 400
        }
        {
          name: 'documents'
          partitionKey: '/documentId'
          throughput: 400
        }
      ]
    }
    {
      name: 'platformData'
      containers: [
        {
          name: 'users'
          partitionKey: '/userId'
          throughput: 400
        }
        {
          name: 'configurations'
          partitionKey: '/configType'
          throughput: 400
        }
      ]
    }
  ]
}

var networkAddresses = [for item in networkDefinition: {
  name: item.name
  id: item.id
  cidr: item.cidr
}]

resource vNet 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-${filter(networkAddresses, n => n.name == 'ai-network')[0].id}'
  scope: resourceGroup('${resourceTagging.environment}-${resourceTagging.product}-${networkResourceGroupName}')
  resource aksSubnet 'subnets' existing = {
    name: '${resourceTagging.environment}-${resourceTagging.product}-${filter(networkAddresses, n => n.name == 'ai-aks-subnet')[0].id}'
  }
  resource databaseSubnet 'subnets' existing = {
    name: '${resourceTagging.environment}-${resourceTagging.product}-${filter(networkAddresses, n => n.name == 'ai-database-subnet')[0].id}'
  }
}

module cosmosDb 'modules/database/cosmosdb.bicep' = {
  name: 'CosmosDbProvision'
  scope: resourceGroup('${resourceTagging.environment}-${resourceTagging.product}-${databaseResourceGroupName}')
  params: {
    cosmosDbAccountName: cosmosDbAccountName
    location: location
    resourceTagging: resourceTagging 
    databaseSubnetId: vNet::databaseSubnet.id
    aksSubnetId: vNet::aksSubnet.id
    aksSubnetCidr: filter(networkAddresses, n => n.name == 'ai-aks-subnet')[0].cidr
    databaseConfig: databaseConfig
    enableServerless: enableServerless
    enableFreeTier: enableFreeTier
    privateEndpointEnabled: privateEndpointEnabled
    networkResourceGroupName: networkResourceGroupName
  }
}

output cosmosDbAccountId string = cosmosDb.outputs.cosmosDbAccountId
output cosmosDbEndpoint string = cosmosDb.outputs.cosmosDbEndpoint
output databaseNames array = cosmosDb.outputs.databaseNames
