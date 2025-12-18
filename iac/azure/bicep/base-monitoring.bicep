targetScope = 'resourceGroup' 

param location string = resourceGroup().location

param resourceTagging object
param monitoringResourceGroupName string   
param sku string = 'PerGB2018' // Pricing tier
param retentionInDays int = 30 // Retention period in days, adjust or remove based on tier
param rg string = '${resourceTagging.environment}-${resourceTagging.product}-${monitoringResourceGroupName}'

module createLogWorkspace 'modules/monitoring/logAnalystics.bicep' = {
  scope: resourceGroup(rg) 
  name: 'LogAnalyticsWorkspace-${resourceTagging.environment}-${resourceTagging.product}'
  params: {  
      sku: sku
      resourceTagging: resourceTagging
      retentionInDays: retentionInDays
      location: location
    } 
}
 
 