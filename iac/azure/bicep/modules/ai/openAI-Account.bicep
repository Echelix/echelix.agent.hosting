param tags object
param location string = resourceGroup().location

//default values if nothing passed in 
param openAiSettings object = {
  name: 'openai'
  sku: 'S0'
  models: [
    {
      name: 'chatmodel'
      sku: {
        name: 'Standard'
        capacity: 20
      }
      model: {
        format: 'OpenAI'
        name: 'gpt-40-mini'
        version: '2024-07-18'
      }
    }
  ]
  publicNetworkAccess: 'Disabled'
}

param createRandomeName bool = true

var myGuid = toLower(replace(guid(resourceGroup().id), '-', ''))

var randomOpenAiAccountName = '${tags.environment}-${tags.product}-${openAiSettings.name}-${myGuid}'

var finalRandomOpenAiAccountName = length(randomOpenAiAccountName) > 24
  ? substring(randomOpenAiAccountName, 0, 24)
  : randomOpenAiAccountName

var openAiAccountName = createRandomeName ? finalRandomOpenAiAccountName : openAiSettings.name

resource openAiAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: openAiAccountName
  location: location
  tags: tags
  sku: {
    name: openAiSettings.sku
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: openAiAccountName
    publicNetworkAccess: openAiSettings.publicNetworkAccess
  }
}

@batchSize(1)
module openAiDeployments './openAI-Deployment.bicep' = [
  for (model, i) in openAiSettings.models: {
    name: model.name
    dependsOn: [
      openAiAccount
    ]
    params: {
      openAIAccountName: openAiAccountName
      openAIDeploymentModel: model
    }
  }
]
