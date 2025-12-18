param form_Recognizer_Account_Name string = 'formrecognizer'
@allowed([
  'F0'
  'S0'
])
param sku string
param location string = resourceGroup().location
param tags object
param publicNetworkAccess string = 'Enabled'

resource form_recognizer 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: form_Recognizer_Account_Name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  kind: 'FormRecognizer'
  properties: {
    customSubDomainName: form_Recognizer_Account_Name
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    publicNetworkAccess: publicNetworkAccess
  }
}
