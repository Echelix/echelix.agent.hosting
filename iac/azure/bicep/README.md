
# Demo Platform Azure Infrastructure

Enterprise-grade Azure infrastructure framework supporting AI workflows and cloud-native applications. This provides a foundation to build cloud native AI applications levaraging AI Foundry and other cloud-native resources.

This repository provides comprehensive infrastructure-as-code (IaC) solution for deploying a secure, scalable AI platform on Azure. It leverages [Azure Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview) for infrastructure provisioning and includes comprehensive deployment automation.

---

## 📋 Table of Contents

- [Architecture Overview](#️-architecture-overview)
- [Project Structure](#-project-structure)
- [Core Design](#core-technologies)
- [Deployment Workflow](#-deployment-flow)
- [Key Components](#-key-components--resources)
- [Security Architecture](#secrets-management-with-azure-key-vault)
- [Getting Started](#-getting-started)
- [Deployment Scripts](#-deployment-flow)
- [Monitoring & Observability](#security--governance)
- [References](#-references)

---

## 🏗️ Architecture Overview

The Echelix platform implements a focused Azure AI infrastructure designed for:

- **🤖 AI-First Design**: Native integration with Azure OpenAI and Cognitive Services
- **🔐 Enterprise Security**: Managed identities, Key Vault integration, governance policies
- **📊 Scalable Data**: Cosmos DB for global data distribution and high availability
- **📈 Comprehensive Monitoring**: Application Insights and Log Analytics for observability
- **🏛️ Governance-Ready**: Policy-based compliance and resource management

### Core Infrastructure Components

| Component | Purpose | Technology |
|-----------|---------|------------|
| **AI Services** | Machine learning & AI processing | Azure OpenAI, Form Recognizer |
| **Database** | Globally distributed data storage | Azure Cosmos DB |
| **Storage** | Container registry & blob storage | Azure Container Registry, Storage Accounts |
| **Security** | Secrets & identity management | Azure Key Vault, Managed Identity |
| **Monitoring** | Observability & diagnostics | Application Insights, Log Analytics |
| **Governance** | Policy enforcement & compliance | Azure Policy, Resource Tagging |
| **Networking** | Basic connectivity & private endpoints | Azure VNet, Private Endpoints |

---

---

## 📁 Project Structure

```text
echelix.platform.iac.bicep.azure/
├── README.md                        # This comprehensive guide
├── base-cosmos-db.bicep             # Cosmos DB deployment template
├── base-cosmos-db.parameters.json   # Cosmos DB configuration parameters
├── base-governance.bicep            # Governance policies deployment
├── base-governance.parameters.json  # Policy configuration parameters
├── base-monitoring.bicep            # Monitoring stack deployment
├── base-monitoring.parameters.json  # Monitoring configuration
├── base-open-ai.bicep               # Azure OpenAI resource deployment
├── base-open-ai.parameters.json     # OpenAI service configuration
├── README-cosmos-db.md              # Cosmos DB deployment documentation
├── config.parameters.json           # Global platform configuration
├── config.sh                        # Parameter propagation script
├── deploy-docker-images.sh          # Container image deployment utility
├── init.bicep                       # Main orchestration template
├── init.parameters.json             # Orchestration parameters
├── deployment/                      # Deployment automation
│   ├── README.md                    # Deployment orchestration guide
│   ├── ai-platform/                 # AI platform deployment scripts
│   │   ├── README.md                # AI platform deployment guide
│   │   ├── 1-deploy-ai.sh           # Core AI services deployment
│   │   ├── 2-deploy-governance.sh   # Governance policies deployment
│   │   ├── 3-deploy-cosmos-db.sh    # Cosmos DB deployment
│   │   ├── 3-deploy-cosmos-db.md    # Cosmos DB deployment guide
│   │   ├── _ai_creds.sh             # AI credentials extraction
│   │   └── _get-acr-creds.sh        # ACR credentials utility
│   └── env-death/                   # Environment cleanup utilities
│       └── kill.sh                  # Complete environment teardown
└── modules/                         # Reusable Bicep modules
    ├── ai/                          # AI service modules (OpenAI, Form Recognizer)
    ├── database/                    # Database modules (Cosmos DB)
    ├── governance/                  # Policy and compliance modules
    ├── monitoring/                  # Observability modules
    ├── network/                     # Basic network infrastructure
    ├── platform/                    # Platform-wide resources (Key Vault)
    └── private-link/                # Private connectivity modules
```

**Related Documentation:**

- [Deployment Scripts Organization](./deployment/README.md)
- [Network Module Documentation](./modules/network/README.md)

---

## 🚀 Deployment Flow

### Automated Deployment

Navigate to the deployment directory for guided deployment:

```bash
cd deployment/ai-platform
```

### Manual Step-by-Step Process

1. **Environment Preparation**
   - Configure parameters in `config.parameters.json`
   - Run `config.sh` to propagate settings across templates

2. **Core Infrastructure**
   - Deploy resource groups and networking using `init.bicep`
   - Deploy AI services with `base-open-ai.bicep`
   - Set up monitoring with `base-monitoring.bicep`

3. **Governance & Compliance**
   - Deploy policy framework using `base-governance.bicep`
   - Configure resource tagging and compliance standards

4. **Database Services**
   - Deploy Cosmos DB using `base-cosmos-db.bicep`
   - Configure database containers and access policies

5. **Access & Configuration**
   - Extract service credentials and endpoints
   - Configure application connection strings

**Detailed Instructions**: See [Deployment Guide](./deployment/README.md)

---

## 🔧 Key Components & Resources

### AI Services

- **Azure OpenAI:** GPT models for text generation, analysis, and processing
- **Form Recognizer:** Document analysis and data extraction capabilities
- **Cognitive Services:** Additional AI processing capabilities

### Data Platform

- **Cosmos DB:** Globally distributed, multi-model database for applications
- **Storage Accounts:** Blob storage for documents, images, and application assets
- **Container Registry:** Private Docker image repository

### Security & Governance

- **Key Vault:** Secure storage for secrets, API keys, and certificates
- **Managed Identity:** Azure AD identities for secure service-to-service authentication
- **Azure Policy:** Governance framework for resource compliance and tagging

### Observability

- **Application Insights:** Application performance monitoring and analytics
- **Log Analytics:** Centralized logging and query capabilities
- **Monitoring Rules:** Automated alerting and diagnostic capabilities

### First-Time Setup Requirements

```bash
# Register required Azure resource providers
az provider register --namespace Microsoft.CognitiveServices
az provider register --namespace Microsoft.DocumentDB
az provider register --namespace Microsoft.Insights
az provider register --namespace Microsoft.OperationalInsights
```

See [modules/](./modules) for detailed module documentation.

---

## 🔐 Security Best Practices

### Secrets Management with Azure Key Vault

**Recommended Approach:**

- Store all sensitive information (API keys, connection strings) in Azure Key Vault
- Use Managed Identity for secure, passwordless authentication
- Never commit secrets to source control
- Rotate keys and secrets regularly

### Access Control

- Apply least-privilege access principles
- Use Azure RBAC for fine-grained permissions
- Monitor access with Azure Activity Log
- Implement governance policies for compliance

---

## 📜 Available Scripts

### Core Scripts

- **config.sh:** Updates parameter files across all templates for your environment
- **deploy-docker-images.sh:** Builds and pushes Docker images to Azure Container Registry

### Deployment Scripts (in deployment/ai-platform/)

- **1-deploy-ai.sh:** Deploys core AI services (OpenAI, Form Recognizer, monitoring)
- **2-deploy-governance.sh:** Applies governance policies and compliance standards
- **3-deploy-cosmos-db.sh:** Deploys Cosmos DB database services
- **_ai_creds.sh:** Extracts AI service credentials and endpoints
- **_get-acr-creds.sh:** Retrieves Azure Container Registry access credentials

### Utility Scripts

- **env-death/kill.sh:** Complete environment cleanup (⚠️ destructive operation)

---

## 🚀 Getting Started

### Prerequisites

- Azure CLI installed and authenticated (`az login`)
- Sufficient Azure subscription permissions (Contributor role recommended)
- Bicep CLI installed (`az bicep install`)

### ⚠️ Critical Configuration Requirements

**Before deployment, you MUST update `config.parameters.json`:**

1. **Resource Tagging** - Update all tag values to reflect your organization:

   ```json
   "resourceTagging": {
     "owner": "your.email@company.com",        // ← Change to your email
     "product": "your-product-name",           // ← Change to your product
     "environment": "dev|test|prod",           // ← Change to your environment
     "costCenter": "your-cost-center",         // ← Change to your cost center
     "businessUnit": "your-business-unit"      // ← Change to your business unit
   }
   ```

2. **Registry Name** - **CRITICAL**: Azure Container Registry names must be globally unique:

   ```json
   "registryName": {
     "value": "yourcompanyuniqueregistry2024"  // ← MUST be globally unique!
   }
   ```

3. **Resource Group Prefixes** - Leave these as-is (referenced by deployment scripts):

   ```json
   "aiResourceGroupName": { "value": "ai-rg" },           // ← Keep as-is
   "platformResourceGroupName": { "value": "platform-rg" }, // ← Keep as-is
   "monitoringResourceGroupName": { "value": "monitoring-rg" } // ← Keep as-is
   ```

### Quick Start

1. **Configure Your Environment**

   ```bash
   # REQUIRED: Edit the configuration file with your settings
   nano config.parameters.json
   
   # Apply configuration across all templates
   ./config.sh
   ```

2. **Deploy the AI Platform**

   ```bash
   cd deployment/ai-platform
   
   # Follow the guided deployment process
   ./1-deploy-ai.sh
   ./2-deploy-governance.sh
   ./3-deploy-cosmos-db.sh
   ```

3. **Extract Service Credentials**

   ```bash
   # Get AI service endpoints and keys
   ./_ai_creds.sh
   
   # Get container registry access (if needed)
   ./_get-acr-creds.sh
   ```

### Detailed Instructions

For comprehensive deployment guidance, see [Deployment Guide](./deployment/README.md)

---

## 🧹 Cleanup & Uninstall

### Automated Cleanup

```bash
cd deployment/env-death
./kill.sh
```

### Manual Cleanup

```bash
# Delete resource groups (⚠️ destructive operation)
az group delete --name <ai-rg-name> --yes --no-wait
az group delete --name <platform-rg-name> --yes --no-wait
az group delete --name <monitoring-rg-name> --yes --no-wait

# Remove policy assignments
az policy assignment delete --name "demo-required-tags-assignment"
```

**⚠️ Warning:** These operations are irreversible. Only run in development environments.

---

## 📚 References

### Core Technologies

- [Azure Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure OpenAI Service](https://docs.microsoft.com/en-us/azure/cognitive-services/openai/)
- [Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/)
- [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/)
- [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/)

### Monitoring & Security

- [Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
- [Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/)
- [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/)
- [Azure Managed Identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/)

---

## Support

- **Maintained by:** Echelix Engineering Team  
- **Last Updated:** December 2025
- **Version:** 0.1.0 - Enhanced for Learning Engineers
