# Echelix Agent Hosting Platform Starter

This repository `echelix.agent.hosting` defines base architecture to deliver an Agentic AI platform that enables rapid deployment of AI Agents and services. This platform is a base building block that we utilize to build out eco-systems

## Core Infrastructure Components

| Component | Purpose | Technology |
|-----------|---------|------------|
| **Networking** | Private VNet with subnets | Azure VNet, NSGs, Private Endpoints |
| **AI Services** | Machine learning & AI processing | Azure OpenAI, Cognitive Services |
| **Security** | Secrets & identity management | Azure Key Vault, Managed Identity |
| **Monitoring** | Observability & diagnostics | Application Insights, Log Analytics |
| **DNS** | Internal name resolution | Azure Private DNS Zones |

extenensive monorepo for the Demo AI platform, providing foundational infrastructure-as-code (IaC) for Azure and deployment automation. It is designed to support agentic workflows, scalable AI services, secure API management, and enterprise-grade infrastructure deployment.

---

## Repository Structure

```text
echelix.platform/
├── README.md                                 # Top-level overview (this file)
└── iac/                                      # Infrastructure-as-Code
    └── azure/                                # Azure Bicep templates
        └── bicep/                            # Bicep modules and templates
            ├── README.md                     # Azure IaC overview
            ├── deployment/                   # Organized deployment scripts
            │   ├── README.md                 # Deployment orchestration guide
            │   ├── ai-platform/              # AI and messaging service deployment
            │   │   └── README.md             # AI platform deployment guide 
            │   └── dns/                      # Internal DNS configuration
            │       └── README.md             # DNS setup guide
            └── modules/                      # Reusable Bicep modules
                ├── network/                  # VNet, subnets, NSGs
                │   └── README.md             # Network module documentation 
                ├── ai/                       # AI services (OpenAI, etc.)   
                ├── monitoring/               # Observability & logging
                ├── platform/                 # Key Vault, shared resources
                └── private-link/             # Private endpoints & DNS
```

---

## Quick Navigation

### 📁 Main Components

- [**Infrastructure (IaC)**](iac/azure/bicep/README.md) - Azure Bicep templates and deployment automation

### 🚀 Deployment Guides Networking

- [Infrastructure Deployment](iac/azure/bicep/README.md#setup-instructions) - Azure resource provisioning

### 🔧 Development Resources

- [Network Architecture](iac/azure/bicep/modules/network/README.md) - VNet and subnet design
- [Deployment Orchestration](iac/azure/bicep/deployment/README.md) - Script organization and execution order

---

## Platform Overview

The Echelix Platform is designed as a cloud-native, enterprise-grade infrastructure platform with the following key characteristics:

- **🏗️ Infrastructure-First Design**: Complete Azure infrastructure defined as code using Bicep
- **🤖 AI-Ready Foundation**: Infrastructure optimized for Azure OpenAI and AI services integration
- **🔐 Security by Design**: Azure Key Vault integration, managed identities, and private networking
- **📈 Enterprise Scale**: AKS-based deployment with auto-scaling and observability
- **🔌 Extensible Architecture**: Modular design supporting additional services and integrations
- **📚 Production-Ready Templates**: Battle-tested Bicep modules for enterprise deployment

---

## Core Components

### [Infrastructure-as-Code: Azure Bicep](iac/azure/bicep/README.md)

Modern, modular Bicep templates for deploying enterprise-grade Azure infrastructure:

- **Networking**: Virtual networks, subnets, NSGs, and private endpoints
- **Compute**: Azure Kubernetes Service (AKS) with managed identity integration
- **Security**: Azure Key Vault, managed identities, and secure secret management
- **Observability**: Application Insights, Log Analytics, and monitoring dashboards

**Key Resources:**

- [Main IaC Documentation](iac/azure/bicep/README.md)
- [Network Architecture Guide](iac/azure/bicep/modules/network/README.md)
- [Deployment Scripts Organization](iac/azure/bicep/deployment/README.md)

---

## Getting Started

### Prerequisites

- Azure CLI (authenticated)
- Docker Desktop (optional, for containerized deployments)
- kubectl (configured for AKS)
- Helm 3.x

### 🌍 Recommended Azure Regions for AI Platform

**⚠️ Important**: Azure AI services availability varies significantly by region. Choose your deployment region carefully:

#### **Primary Recommended Regions** (Full AI service availability)

- **East US 2** (`eastus2`) - ✅ Recommended default
- **West Europe** (`westeurope`)
- **South Central US** (`southcentralus`)

#### **Secondary Options** (Good AI coverage)

- **West US 2** (`westus2`)
- **North Central US** (`northcentralus`)
- **UK South** (`uksouth`)

#### **What to Check Before Deployment**

```bash
# Verify Azure OpenAI availability in your chosen region
az cognitiveservices model list --location eastus2 --query "[?name=='gpt-4']"

# Check Form Recognizer availability
az provider show --namespace Microsoft.CognitiveServices --query "resourceTypes[?resourceType=='accounts'].locations" --location eastus2
```

**Notes:**

- GPT-4 and advanced models have limited regional availability
- Form Recognizer capabilities vary by region
- Always verify current service availability as Azure expands AI service regions regularly
- Consider data residency requirements for your organization

### 🔧 Azure Subscription Setup

- **IF NEW AZURE SUBSCRIPTION RUN THE FOLLOWING**

```bash
   az provider register --namespace Microsoft.Insights
   az provider register --namespace Microsoft.OperationalInsights
   az provider register --namespace Microsoft.AlertsManagement
   az provider register --namespace Microsoft.CognitiveServices
   az provider register --namespace Microsoft.DocumentDB

   az provider show --namespace Microsoft.OperationalInsights --query "registrationState"    
   # look for "Registered"
```

### Quick Start Guide

1. **🏗️ Deploy Infrastructure:**

   ```bash
   cd iac/azure/bicep
   # Follow the setup instructions in README.md
   ./deploy-ai.sh
   ```

   See: [Infrastructure Deployment Guide](iac/azure/bicep/README.md#setup-instructions)
   See: [Deployment Orchestration Guide](iac/azure/bicep/deployment/README.md)

### Development Workflow

1. **Infrastructure Setup**: Deploy the foundational Azure infrastructure using Bicep templates
2. **Network Configuration**: Configure networking, ingress, and DNS for your applications
3. **Monitor & Debug**: Use the built-in observability tools for monitoring and troubleshooting

---

## Architecture Highlights

- **🌐 Private Networking**: Complete private network setup with internal DNS
- **🔐 Zero-Trust Security**: Managed identities, Key Vault integration, private endpoints
- **📊 Observability**: Application Insights, structured logging, health checks
- **🔄 GitOps Ready**: Infrastructure and application deployment automation
- **🎯 Production Ready**: High availability, auto-scaling, disaster recovery considerations

---

## Documentation Links

### 📚 Core Documentation

- [Infrastructure README](iac/azure/bicep/README.md)

### 🚀 Deployment Guides

- [Infrastructure Deployment](iac/azure/bicep/README.md)
- [AI Platform Services](iac/azure/bicep/deployment/ai-platform/README.md)

### 🔧 Technical References

- [Network Architecture](iac/azure/bicep/modules/network/README.md)
- [Deployment Scripts](iac/azure/bicep/deployment/README.md)

---

**Maintained by:** Echelix Engineering Team  
**Last Updated:** August 2025  
**Platform Version:** 0.1.0
