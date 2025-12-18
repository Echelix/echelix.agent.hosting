/*
  Azure Policy for demo Platform Required Tags
  Enforces consistent tagging across all AI platform resources
  Based on existing resourceTagging structure from config.parameters.json
  
  NOTE: This template must be deployed at subscription scope
*/

targetScope = 'subscription'

param policyName string = 'demo-required-tags'
param policyDisplayName string = 'Require Demo Platform Tags'
param policyDescription string = 'Ensures all AI platform resources have required tags for governance, cost tracking, and compliance'
param createdDate string = utcNow('yyyy-MM-dd')

@description('Resource tags object containing the platform tagging standards')
param resourceTagging object

@description('Effect for the policy')
@allowed(['Audit', 'Deny', 'Disabled'])
param policyEffect string = 'Audit'

@description('Resource types to exclude from the policy')
param excludedResourceTypes array = []

@description('Array of resource types that must have required tags')
param requiredResourceTypes array = [
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

@description('Array of tag names that are required on all resources')
param requiredTags array = [
  'environment'
  'businessUnit'
  'costCenter'
  'owner'
  'product'
]

// Create the policy definition
resource demoTaggingPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      category: 'Tags'
      version: '1.0.0'
      source: 'DEMO Platform IaC'
      createdBy: resourceTagging.owner
      createdDate: createdDate
    }
    parameters: {
      effect: {
        type: 'String'
        defaultValue: 'Deny'
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        metadata: {
          displayName: 'Effect'
          description: 'Enable or disable the execution of the policy'
        }
      }
      excludedResourceTypes: {
        type: 'Array'
        defaultValue: []
        metadata: {
          displayName: 'Excluded Resource Types'
          description: 'List of resource types to exclude from this policy'
        }
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            in: requiredResourceTypes
          }
          {
            field: 'type'
            notIn: '[parameters(\'excludedResourceTypes\')]'
          }
          {
            anyOf: [
              {
                not: {
                  field: 'tags[\'environment\']'
                  exists: 'true'
                }
              }
              {
                not: {
                  field: 'tags[\'businessUnit\']'
                  exists: 'true'
                }
              }
              {
                not: {
                  field: 'tags[\'costCenter\']'
                  exists: 'true'
                }
              }
              {
                not: {
                  field: 'tags[\'owner\']'
                  exists: 'true'
                }
              }
              {
                not: {
                  field: 'tags[\'product\']'
                  exists: 'true'
                }
              }
            ]
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
  }
}

// Create policy assignment at subscription level
resource demoTaggingPolicyAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: '${policyName}-assignment'
  properties: {
    displayName: '${policyDisplayName} - Assignment'
    description: 'Assignment of demo platform tagging policy to enforce governance standards'
    policyDefinitionId: demoTaggingPolicy.id
    notScopes: []
    parameters: {
      effect: {
        value: policyEffect
      }
      excludedResourceTypes: {
        value: excludedResourceTypes
      }
    }
    metadata: {
      assignedBy: resourceTagging.owner
      assignmentDate: createdDate
      environment: resourceTagging.environment
    }
  }
}

// Output policy information
output policyDefinitionId string = demoTaggingPolicy.id
output policyAssignmentId string = demoTaggingPolicyAssignment.id
output policyName string = demoTaggingPolicy.name
output requiredTags array = requiredTags
output coveredResourceTypes array = requiredResourceTypes
