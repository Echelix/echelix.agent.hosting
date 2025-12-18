@description('Name of the Cosmos DB account')
param cosmosDbAccountName string

@description('Name of the database')
param databaseName string

@description('Array of containers to create')
param containers array

@description('Whether the Cosmos DB account is serverless')
param enableServerless bool = true

// Reference to the existing Cosmos DB account
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: cosmosDbAccountName
}

// Reference to the existing database
resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' existing = {
  parent: cosmosDbAccount
  name: databaseName
}

// Create containers
resource sqlContainers 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = [for container in containers: {
  parent: database
  name: container.name
  properties: {
    resource: {
      id: container.name
      partitionKey: {
        paths: [
          container.partitionKey
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
      defaultTtl: -1
    }
    options: (!enableServerless && contains(container, 'throughput')) ? {
      throughput: container.throughput
    } : {}
  }
}]

output containerNames array = [for container in containers: container.name]
