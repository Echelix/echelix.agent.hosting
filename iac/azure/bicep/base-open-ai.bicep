targetScope = 'resourceGroup'

param location string = resourceGroup().location

/*
default resource group tagging for all resources created in this module
*/
param resourceTagging object

param aiResourceGroupName string

/* 
default openAI account settings if not passed in from parameters files
This is a list of openAI accounts to be created, each with its own settings.
You can add more accounts by appending to this array.
You can also modify the settings for each account as needed.
You can also remove accounts if you don't need them.
You can also change the model name, version, and SKU as needed.
You can also change the public network access setting if needed.
You can also change the name of the account if needed.
*/
param openAiAccounts array = [
  {
    name: 'openAiAccount'
    sku: 'F0'
    models: [
      {
        name: 'chatmodel'
        sku: {
          name: 'Standard'
          capacity: 240
        }
        model: {
          format: 'OpenAI'
          name: 'gpt-4o-mini'
          version: '2024-07-18'
        }
      }
    ]
    publicNetworkAccess: 'Disabled'
  }
]

/*
default settings if not passed in from paramaters files 
*/
param aiSearchServiceSettings object = {
  aiSearchServiceName: ''
  sku: 'standard'
  replicaCount: 1
  partitionCount: 1
  hostingMode: 'Default'
}

param formRecognizerSettings object = {
  formRecognizerName: ''
  sku: 'F0'
  publicNetworkAccess: 'Enabled'
} 



/* setup the azure openAI perovisioning and AI Foundry Endpoint deployments */
module oaiAccts 'modules/ai/openAI-Account.bicep' = [
  for (oIaAcct, i) in openAiAccounts: {
    scope: resourceGroup('${resourceTagging.environment}-${resourceTagging.product}-${aiResourceGroupName}')
    name: '${resourceTagging.environment}-${resourceTagging.product}-openAIAccount-${i}'
    params: {
      tags: resourceTagging
      location: location
      openAiSettings: oIaAcct
    }
  }
]

/*deploy Azure AI Search respsource created with zero configuration or indexes created */ 
module aiSearchService 'modules/ai/openAI-Search.bicep' = {
  scope: resourceGroup('${resourceTagging.environment}-${resourceTagging.product}-${aiResourceGroupName}')
  name: aiSearchServiceSettings.aiSearchServiceName
  params: {
    location: location
    aiSearchServiceName: '${resourceTagging.environment}-${resourceTagging.product}-${aiSearchServiceSettings.aiSearchServiceName}'
    sku: aiSearchServiceSettings.sku
    replicaCount: aiSearchServiceSettings.replicaCount
    partitionCount: aiSearchServiceSettings.partitionCount
    hostingMode: aiSearchServiceSettings.hostingMode
    tags: resourceTagging
  }
}
 

/* set up forms recognizer for document ingestion, cracking, chunking  */
module formRecognizer 'modules/ai/forms-recognizer.bicep' = {
  scope: resourceGroup('${resourceTagging.environment}-${resourceTagging.product}-${aiResourceGroupName}')
  name: '${resourceTagging.environment}-${resourceTagging.product}-${formRecognizerSettings.formRecognizerName}'
  params: {
    location: location
    form_Recognizer_Account_Name: '${resourceTagging.environment}-${resourceTagging.product}-${formRecognizerSettings.formRecognizerName}'
    sku: formRecognizerSettings.sku
    publicNetworkAccess: formRecognizerSettings.publicNetworkAccess
    tags: resourceTagging
  }
}
 
 