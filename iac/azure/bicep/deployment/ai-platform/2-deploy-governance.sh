#!/bin/bash

# Deploy Governance Policies for Demo Platform
# This script deploys Azure Policies to enforce tagging and governance standards

set -e

echo "🏛️ Deploying Demo Platform Governance Policies..."

# Get current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if user is logged in to Azure
if ! az account show &> /dev/null; then
    echo "❌ Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Get current subscription
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)

echo "📋 Current subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"
echo

# Confirm deployment
read -p "🔍 Deploy governance policies to this subscription? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled."
    exit 0
fi

# Deploy governance policies
echo "🚀 Deploying governance policies..."
az deployment sub create \
    --name "DemoGovernance-$(date +%Y%m%d-%H%M%S)" \
    --location "eastus2" \
    --template-file "../../base-governance.bicep" \
    --parameters @../../base-governance.parameters.json \
    --verbose

if [ $? -eq 0 ]; then
    echo "✅ Governance policies deployed successfully!"
    echo
    echo "📊 Next steps:"
    echo "1. Review policy assignments in Azure Portal → Policy"
    echo "2. Test with a resource deployment to verify policy enforcement"
    echo "3. Change tagPolicyEffect from 'Audit' to 'Deny' when ready to enforce"
    echo
    echo "🔗 Azure Portal Policy URL:"
    echo "https://portal.azure.com/#view/Microsoft_Azure_Policy/PolicyMenuBlade/~/Definitions"
else
    echo "❌ Governance deployment failed!"
    exit 1
fi
