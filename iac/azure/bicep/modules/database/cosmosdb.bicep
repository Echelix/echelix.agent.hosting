@description('Name of the Cosmos DB account (must be globally unique)')
param cosmosDbAccountName string

@description('Location for the Cosmos DB account')
param location string

@description('Resource tags')
param resourceTagging object  

@description('Subnet Id for private endpoint (database subnet)')
param databaseSubnetId string

@description('AKS subnet Id (for API access)')
param aksSubnetId string

@description('AKS subnet CIDR (for NSG rules)')
param aksSubnetCidr string

@description('Whether to enable serverless mode for Cosmos DB')
param enableServerless bool = true

@description('Whether to enable free tier (cannot be used with serverless)')
param enableFreeTier bool = false

@description('Whether to create a private endpoint for Cosmos DB')
param privateEndpointEnabled bool = false

@description('Network resource group name')
param networkResourceGroupName string

@description('Database configuration including databases and containers')
param databaseConfig object

// Ensure Cosmos DB account name is 3-44 chars, all lowercase, and contains only letters, numbers, and hyphens
var baseName = '${resourceTagging.product}-${cosmosDbAccountName}-${resourceTagging.environment}'
// Remove all invalid characters and ensure valid format
var cleanedName = toLower(replace(replace(replace(replace(baseName, '_', '-'), '.', '-'), ' ', '-'), '//', '-'))
// Ensure we always have a valid Cosmos DB account name
var completeCosmosDbAccountName = length(cleanedName) > 44 ? substring(cleanedName, 0, 44) : cleanedName

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: completeCosmosDbAccountName
  location: location
  tags: resourceTagging
  kind: 'GlobalDocumentDB'
  properties: {
    enableFreeTier: enableFreeTier && !enableServerless
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 300
      maxStalenessPrefix: 100000
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    capabilities: enableServerless ? [
      {
        name: 'EnableServerless'
      }
    ] : []
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Local'
      }
    }
    networkAclBypass: 'AzureServices'
    publicNetworkAccess: 'Disabled'
    enableAnalyticalStorage: false
    enableMultipleWriteLocations: false
    isVirtualNetworkFilterEnabled: true
    virtualNetworkRules: [
      {
        id: databaseSubnetId
        ignoreMissingVNetServiceEndpoint: false
      }
      {
        id: aksSubnetId
        ignoreMissingVNetServiceEndpoint: false
      }
    ]
    ipRules: []
    disableKeyBasedMetadataWriteAccess: false
    enablePartitionMerge: false
    minimalTlsVersion: 'Tls12'
  }
}

// Create databases and containers
resource databases 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = [for db in databaseConfig.databases: {
  parent: cosmosDbAccount
  name: db.name
  properties: {
    resource: {
      id: db.name
    }
  }
}]

// Create containers for each database
module containers 'cosmosdb-containers.bicep' = [for (db, dbIndex) in databaseConfig.databases: {
  name: 'containers-${db.name}'
  params: {
    cosmosDbAccountName: cosmosDbAccount.name
    databaseName: db.name
    containers: db.containers
    enableServerless: enableServerless
  }
  dependsOn: [
    databases[dbIndex]
  ]
}]

// Private endpoint for Cosmos DB
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = if (privateEndpointEnabled) {
  name: '${completeCosmosDbAccountName}-pe'
  location: location
  tags: resourceTagging
  properties: {
    subnet: {
      id: databaseSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${completeCosmosDbAccountName}-pe-connection'
        properties: {
          privateLinkServiceId: cosmosDbAccount.id
          groupIds: [
            'Sql'
          ]
        }
      }
    ]
  }
}

// Deploy NSG in network resource group
module cosmosDbNsg '../network/cosmosdb-nsg.bicep' = {
  name: 'cosmosdb-nsg-deployment'
  scope: resourceGroup('${resourceTagging.environment}-${resourceTagging.product}-${networkResourceGroupName}')
  params: {
    nsgName: '${completeCosmosDbAccountName}-nsg'
    location: location
    resourceTagging: resourceTagging
    aksSubnetCidr: aksSubnetCidr
  }
}

output cosmosDbAccountId string = cosmosDbAccount.id
output cosmosDbEndpoint string = cosmosDbAccount.properties.documentEndpoint
output cosmosDbAccountName string = cosmosDbAccount.name
output databaseNames array = [for db in databaseConfig.databases: db.name]
output privateEndpointId string = privateEndpointEnabled ? privateEndpoint.id : ''
output nsgId string = cosmosDbNsg.outputs.nsgId
