/*
  Main Governance Deployment Template
  Deploys Azure Policies for the Echelix Platform
  
  This template must be deployed at subscription scope
*/

targetScope = 'subscription'

param StartDate string = utcNow('yyyyMMdd-HHmmss')
param location string
param resourceTagging object

@description('Effect for the tagging policy')
@allowed(['Audit', 'Deny', 'Disabled'])
param tagPolicyEffect string = 'Audit'

@description('Resource types to exclude from tagging policy')
param excludedResourceTypes array = []

// Deploy tagging policy
module taggingPolicy 'modules/governance/tagging-policy.bicep' = {
  name: 'TaggingPolicy-Deploy-${StartDate}'
  params: {
    policyName: 'demo-required-tags'
    policyDisplayName: 'Demo Platform Required Tags'
    policyDescription: 'Enforces required tags on all Demo platform resources for governance and cost tracking'
    createdDate: StartDate
    resourceTagging: resourceTagging
    policyEffect: tagPolicyEffect
    excludedResourceTypes: excludedResourceTypes
    requiredResourceTypes: [
      'Microsoft.CognitiveServices/accounts'
      'Microsoft.ContainerService/managedClusters'
      'Microsoft.Storage/storageAccounts'
      'Microsoft.ServiceBus/namespaces'
      'Microsoft.SignalRService/webPubSub'
      'Microsoft.Network/publicIPAddresses'
      'Microsoft.ApiManagement/service'
      'Microsoft.KeyVault/vaults'
      'Microsoft.ContainerRegistry/registries'
      'Microsoft.OperationalInsights/workspaces'
      'Microsoft.Insights/components'
    ]
    requiredTags: [
      'environment'
      'businessUnit'
      'costCenter'
      'owner'
      'product'
    ]
  }
}

// Outputs
output taggingPolicyDefinitionId string = taggingPolicy.outputs.policyDefinitionId
output taggingPolicyAssignmentId string = taggingPolicy.outputs.policyAssignmentId
output requiredTags array = taggingPolicy.outputs.requiredTags
output coveredResourceTypes array = taggingPolicy.outputs.coveredResourceTypes
