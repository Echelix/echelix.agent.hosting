 
param location string = resourceGroup().location
@allowed(['PerGB2018'])
param sku string
param resourceTagging object
param retentionInDays int = 30 // Retention period in days, adjust or remove based on tier

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: '${resourceTagging.environment}-${resourceTagging.product}-loganalytics-workspace'
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
  }
  tags: resourceTagging
}

output workspaceId string = logAnalyticsWorkspace.id
output workspaceName string = logAnalyticsWorkspace.name
