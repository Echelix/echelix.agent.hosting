param openAIAccountName string

//default if nothin passed into the process
param openAIDeploymentModel object = {
  name: 'chatmodel'
  sku: {
    name: 'Standard'
    capacity: 20
  }
  model: {
    format: 'OpenAI'
    name: 'gpt-4o-mini'
    version: '2024-07-18'
  }
}

resource openAiAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  name: openAIAccountName
}

resource openAiModelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: openAiAccount
  name: openAIDeploymentModel.name
  sku: openAIDeploymentModel.sku
  properties: {
    model: openAIDeploymentModel.model
  }
}
