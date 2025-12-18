# Governance Module

This module implements Azure Policy-based governance for the Demo Platform, enforcing consistent tagging and compliance standards across all platform resources.

## 🏛️ Components

### Tagging Policy (`tagging-policy.bicep`)

**Purpose**: Enforces required tags on all AI platform resources for governance, cost tracking, and compliance.

**Required Tags**:

- `environment` - Environment classification (dev, test, prod)
- `businessUnit` - Business unit responsible for the resource
- `costCenter` - Cost center for billing allocation
- `owner` - Resource owner/contact
- `product` - Product/project name

**Covered Resource Types**:

- Microsoft.CognitiveServices/accounts (AI services)
- Microsoft.ContainerService/managedClusters (AKS)
- Microsoft.Storage/storageAccounts (Storage)
- Microsoft.ServiceBus/namespaces (Service Bus)
- Microsoft.SignalRService/webPubSub (Web PubSub)
- Microsoft.Network/publicIPAddresses (Public IPs)
- Microsoft.ApiManagement/service (APIM)
- Microsoft.KeyVault/vaults (Key Vault)
- Microsoft.ContainerRegistry/registries (ACR)
- Microsoft.OperationalInsights/workspaces (Log Analytics)
- Microsoft.Insights/components (Application Insights)

## 📋 Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `policyName` | string | `demo-required-tags` | Name of the policy definition |
| `policyDisplayName` | string | `Require Demo Platform Tags` | Display name for the policy |
| `policyDescription` | string | Description text | Policy description |
| `resourceTagging` | object | Required | Platform tagging standards object |
| `policyEffect` | string | `Audit` | Policy effect: Audit, Deny, or Disabled |
| `excludedResourceTypes` | array | `[]` | Resource types to exclude from policy |

## 🚀 Deployment

### Option 1: Using the deployment script (Recommended)

```bash
# Make script executable
chmod +x deploy-governance.sh

# Deploy governance policies
./deploy-governance.sh
```

### Option 2: Manual deployment

```bash
# Deploy at subscription scope
az deployment sub create \
    --name "DemoGovernance-$(date +%Y%m%d-%H%M%S)" \
    --location "eastus2" \
    --template-file "base-governance.bicep" \
    --parameters @base-governance.parameters.json
```

### Option 3: PowerShell

```powershell
New-AzSubscriptionDeployment `
    -Name "DemoGovernance-$(Get-Date -Format 'yyyyMMdd-HHmmss')" `
    -Location "eastus2" `
    -TemplateFile "base-governance.bicep" `
    -TemplateParameterFile "base-governance.parameters.json"
```

## 🔍 Testing the Policy

1. **Start with Audit mode** (default):
   - Policy will flag non-compliant resources but won't block deployment
   - Review compliance in Azure Portal → Policy

2. **Test compliance**:

   ```bash
   # This should pass (has required tags)
   az storage account create --name teststorage123 --resource-group test-rg \
       --tags environment=dev businessUnit=eng costCenter=0002 owner=test@demo.com product=test
   
   # This should be flagged (missing tags)
   az storage account create --name teststorage456 --resource-group test-rg
   ```

3. **Switch to Deny mode** when ready:
   - Update `tagPolicyEffect` to `"Deny"` in parameters file
   - Redeploy the governance template

## 📊 Monitoring and Compliance

### View Policy Compliance

1. Go to [Azure Portal → Policy](https://portal.azure.com/#view/Microsoft_Azure_Policy/PolicyMenuBlade/~/Compliance)
2. Find "Demo Platform Required Tags" policy
3. Review compliance status and non-compliant resources

### Policy Assignment Details

- **Scope**: Subscription level
- **Assignment Name**: `demo-required-tags-assignment`
- **Effect**: Configurable (Audit/Deny/Disabled)

## 🔧 Customization

### Adding New Resource Types

Edit the `requiredResourceTypes` array in `base-governance.bicep`:

```bicep
requiredResourceTypes: [
    'Microsoft.CognitiveServices/accounts'
    'Microsoft.Sql/servers'  // Add new resource type
    // ... other types
]
```

### Adding New Required Tags

Edit the `requiredTags` array and update the policy rule:

```bicep
requiredTags: [
    'environment'
    'businessUnit'
    'dataClassification'  // Add new required tag
    // ... other tags
]
```

### Excluding Resource Groups or Resources

Use `notScopes` in the policy assignment:

```bicep
notScopes: [
    '/subscriptions/{subscription-id}/resourceGroups/excluded-rg'
    '/subscriptions/{subscription-id}/resourceGroups/another-rg/providers/Microsoft.Storage/storageAccounts/excluded-storage'
]
```

## 🚨 Troubleshooting

### Common Issues

**Policy not enforcing**:

- Check policy assignment scope and effect
- Verify policy definition exists
- Allow up to 30 minutes for policy to take effect

**Resources still being created without tags**:

- Policy might be in Audit mode instead of Deny
- Check if resource type is covered by the policy
- Verify policy assignment is active

**Deployment failures**:

- Ensure you're deploying at subscription scope
- Check that user has Policy Contributor permissions
- Verify parameter file syntax

### Policy Evaluation Order

1. Policy definitions are created first
2. Policy assignments link definitions to scopes
3. Resources are evaluated against policies during deployment
4. Non-compliant resources are audited or denied based on effect

## 🔗 Related Documentation

- [Azure Policy Overview](https://docs.microsoft.com/en-us/azure/governance/policy/overview)
- [Azure Resource Tagging Best Practices](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources)
- [Policy Effects](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects)

## 📝 Integration with Platform

This governance module integrates with the existing Demo platform tagging structure defined in `config.parameters.json`. All platform resources already include the required tags through the `resourceTagging` parameter, ensuring immediate compliance.

The policy serves as a safety net to prevent manual deployments or third-party tools from creating non-compliant resources.

## Support

- **Maintained by:** Echelix Engineering Team  
- **Last Updated:** December 2025
- **Version:** 0.1.0 - Enhanced for Learning Engineers
