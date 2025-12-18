// provided by Lindsay Suarez
@description('The resource ID of the resource receiving the role. This is not the the managed identity princinpal ID.')
param resourceId string
@description('The principal ID of the identity receiving the role.')
param principalId string
@description('The ID of the role to be assigned on the resource group.')
param roleId string
var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)

resource aksRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, resourceId, roleDefinitionResourceId)
  scope: resourceGroup()
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinitionResourceId
    principalType: 'ServicePrincipal'
  }
}
