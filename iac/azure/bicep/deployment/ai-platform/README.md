# AI Platform Deployment Guide 📚

> **Learning Engineers**: This is a comprehensive guide to understanding and deploying the Echelix Agent Hosting AI Platform infrastructure on Azure.

## 🎯 What You'll Learn

- How Infrastructure as Code (IaC) works with Azure Bicep
- Azure resource deployment patterns and best practices
- Governance and security in cloud deployments
- Troubleshooting common deployment issues

## 📋 Overview

This directory contains Infrastructure as Code (IaC) scripts that deploy a complete AI platform on Microsoft Azure. The deployment is broken into logical phases to make it easier to understand, debug, and maintain.

### 🗂️ Deployment Scripts

| Script | Phase | Purpose | What It Does |
|--------|-------|---------|--------------|
| `1-deploy-ai.sh` | Core Services | Deploys AI infrastructure | Creates Azure OpenAI, Form Recognizer, Resource Groups, Monitoring |
| `2-deploy-governance.sh` | Governance | Applies policies | Enforces tagging standards and compliance rules |
| `3-deploy-cosmos-db.sh` | Database | Deploys database | Creates Cosmos DB for data storage |
| `_ai_creds.sh` | Utilities | Extracts credentials | Gets API keys and endpoints for configuration |
| `_get-acr-creds.sh` | Utilities | Gets container registry access | Retrieves Azure Container Registry credentials |

### 🏗️ What Gets Deployed

When you run these scripts, you'll create:

- **Resource Groups**: Organized containers for your Azure resources
- **Azure OpenAI**: GPT models for AI processing
- **Form Recognizer**: Document processing AI service
- **Cosmos DB**: NoSQL database for application data
- **Monitoring**: Log Analytics and Application Insights for observability
- **Governance Policies**: Rules that enforce tagging and compliance

## 🛠️ Prerequisites

Before you start, make sure you have:

### Required Tools

```bash
# Install Azure CLI (if not already installed)
# macOS
brew install azure-cli

# Check your installation
az --version
az bicep version
```

### Required Access

- An Azure subscription with **Contributor** or **Owner** permissions
- Ability to create resource groups and deploy resources
- Sufficient quota for the services you'll deploy

### Authentication

```bash
# Login to Azure
az login

# Check which subscription you're using
az account show

# Switch subscription if needed
az account set --subscription "your-subscription-id"
```

## 🚀 Step-by-Step Deployment

### Step 1: Deploy Core AI Services

```bash
./1-deploy-ai.sh
```

**What this does:**

1. **Loads configuration** from `config.sh` (sets environment variables)
2. **Creates resource groups** using `init.bicep`
3. **Deploys AI services** (OpenAI, Form Recognizer)
4. **Sets up monitoring** (Log Analytics workspace)
5. **Extracts service keys** and endpoints

**Watch for:**

- Prompts asking if you want to continue each step
- Resource group names being displayed
- Any error messages about quotas or permissions

### Step 2: Apply Governance Policies

```bash
./2-deploy-governance.sh
```

**What this does:**

1. **Checks Azure login** status
2. **Shows current subscription** for confirmation
3. **Deploys Azure Policies** that enforce tagging requirements
4. **Creates policy assignments** at subscription level

**Important for Junior Engineers:**

- **Start with "Audit" mode**: Policies are set to `Audit` first, which means they'll report violations but won't block deployments
- **Graduate to "Deny" mode**: Once you verify everything works, change to `Deny` mode to enforce policies
- **Policies apply subscription-wide**: These rules will affect all resources in your subscription

### Step 3: Deploy Database Services

```bash
./3-deploy-cosmos-db.sh
```

**What this does:**

1. **Creates Cosmos DB account** for application data storage
2. **Sets up database containers** with proper indexing
3. **Configures access policies** and connection strings

## 🔧 Configuration Files

Understanding the parameter files is crucial for customizing your deployment:

### Core Configuration Files

Located in `../../` (two directories up):

| File | Purpose | Key Settings |
|------|---------|--------------|
| `init.parameters.json` | Resource group setup | Names, locations, tagging standards |
| `base-open-ai.parameters.json` | AI services config | Model deployments, capacity settings |
| `base-monitoring.parameters.json` | Observability setup | Log retention, alert rules |
| `base-governance.parameters.json` | Policy configuration | Required tags, policy effects |

### Understanding Parameter Files

**Example: `base-governance.parameters.json`**

```json
{
  "parameters": {
    "tagPolicyEffect": {
      "value": "Audit"  // Start with Audit, change to Deny later
    },
    "resourceTagging": {
      "value": {
        "environment": "poc",
        "businessUnit": "eng",
        "costCenter": "0001",
        "owner": "your.email@company.com"
      }
    }
  }
}
```

## 🔍 Understanding the Output

### When Scripts Run Successfully

You'll see output like:

```bash
✅ Governance policies deployed successfully!
📊 Next steps:
1. Review policy assignments in Azure Portal → Policy
2. Test with a resource deployment to verify policy enforcement
```

### Key Information Extracted

The `_ai_creds.sh` script will display:

```bash
AI ENDPOINT FOR CONFIG: https://your-openai-service.openai.azure.com/
AI KEY FOR CONFIG: [32-character key]
FORMS RECOGNIZER ENDPOINT: https://your-forms.cognitiveservices.azure.com/
```

**⚠️ Security Note**: Never commit these keys to source control!

## 🐛 Common Issues & Solutions

### Issue 1: "Not logged in to Azure"

```bash
❌ Not logged in to Azure. Please run 'az login' first.
```

**Solution:**

```bash
az login
az account show  # Verify you're logged in
```

### Issue 2: "InvalidPolicyRuleEffectDetails"

```bash
The policy effect 'details' property could not be parsed using mode 'Indexed'
```

**Solution:** This was the error you encountered! It means the policy definition had incompatible settings. We fixed it by removing the `details` section from Audit/Deny policies.

### Issue 3: "Insufficient quota"

**Solution:**

- Check your subscription limits in Azure Portal
- Request quota increases if needed
- Try a different region

### Issue 4: Permission denied

**Solution:**

- Ensure you have Contributor or Owner role
- Check resource provider registrations
- Verify subscription access

## 📚 Learning Resources

### Key Concepts to Understand

1. **Infrastructure as Code (IaC)**: Writing infrastructure definitions in code rather than manually clicking through portals
2. **Azure Bicep**: A domain-specific language for deploying Azure resources
3. **Resource Groups**: Logical containers that group related Azure resources
4. **Azure Policies**: Rules that enforce governance and compliance standards

### Next Steps for Learning

1. **Explore the Bicep files**: Look at `../../base-*.bicep` files to understand resource definitions
2. **Study the modules**: Check `../../modules/` to see reusable components
3. **Practice modifications**: Try changing parameters and redeploying
4. **Monitor resources**: Use Azure Portal to see what was created

## 🛡️ Security Best Practices

### What These Scripts Do Right

- ✅ Use managed identities where possible
- ✅ Apply governance policies for compliance
- ✅ Separate credentials extraction into utility scripts
- ✅ Prompt for confirmation before deploying

### Additional Security Considerations

- 🔐 Store secrets in Azure Key Vault (not in scripts)
- 🏷️ Always apply proper resource tagging
- 🔍 Monitor deployments with Application Insights
- 🚫 Never commit credentials to version control

## 🧹 Cleanup

### To Remove Everything

```bash
# List resource groups created
az group list --output table

# Delete specific resource groups (CAREFUL!)
az group delete --name "your-ai-rg-name" --yes --no-wait
az group delete --name "your-monitoring-rg-name" --yes --no-wait

# Remove policy assignments
az policy assignment delete --name "echelix-required-tags-assignment"
```

**⚠️ Warning**: Deletion is permanent and cannot be undone!

## 📖 File Structure Deep Dive

```text
deployment/ai-platform/
├── 1-deploy-ai.sh           # 🚀 Main deployment script
├── 2-deploy-governance.sh   # 🏛️ Policy deployment
├── 3-deploy-cosmos-db.sh    # 🗄️ Database deployment
├── _ai_creds.sh            # 🔑 Credential extraction
├── _get-acr-creds.sh       # 📦 Container registry access
└── README.md               # 📚 This guide

../../                      # Parent directory contains:
├── base-*.bicep           # 📄 Main resource templates
├── base-*.parameters.json # ⚙️ Configuration files
├── modules/               # 🧩 Reusable components
└── config.sh             # 🔧 Environment setup
```

## 🎓 Junior Engineer Checklist

Before running these scripts:

- [ ] I understand what Infrastructure as Code means
- [ ] I have Azure CLI installed and I'm logged in
- [ ] I understand what each script does at a high level
- [ ] I know where to find the configuration files
- [ ] I understand the security implications of extracting credentials
- [ ] I know how to clean up resources when I'm done testing

After running scripts:

- [ ] I can find the created resources in Azure Portal
- [ ] I understand what each resource does in the architecture
- [ ] I've saved the important endpoints and keys securely
- [ ] I can explain why we start with Audit policies instead of Deny

---

## 💡 Pro Tips for Learning Engineers

1. **Always read the output**: The scripts provide valuable information about what's happening
2. **Start small**: Run one script at a time and verify each step
3. **Use Azure Portal**: Check the portal to see what resources were created
4. **Practice in dev environments**: Never test on production subscriptions
5. **Keep learning**: Each deployment teaches you more about Azure architecture

**Remember**: Infrastructure as Code is a superpower - you can recreate entire environments with a few commands! 🚀

## Support

- **Maintained by:** Echelix Engineering Team  
- **Last Updated:** December 2025
- **Version:** 0.1.0 - Enhanced for Learning Engineers
