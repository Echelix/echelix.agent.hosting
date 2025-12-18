#!/bin/bash

# Script to delete Azure resource groups
# This script will delete all specified resource groups without waiting for completion


# ------------------------------------------------------------------------
# ❌ Resource group names are aggrigates of environment-product-xxxxx-rg ❌ 
# if you have changed these from the defaults this script for resoruce group
# names must be updated prior to running 
# ------------------------------------------------------------------------
export prefix='poc-demo'

echo "Starting deletion of Azure resource groups..."

# Array of resource groups to delete
resource_groups=(
    "$prefix-database-rg"
    "$prefix-platform-rg"
    "$prefix-ui-rg"
    "$prefix-api-rg"
    "$prefix-network-rg"
    "$prefix-monitoring-rg"
    "$prefix-ai-rg"
    "NetworkWatcherRG"
)

# Loop through each resource group and delete it
for rg in "${resource_groups[@]}"; do
    echo "Deleting resource group: $rg"
    az group delete -n "$rg" --no-wait --yes
    if [ $? -eq 0 ]; then
        echo "✓ Successfully initiated deletion of: $rg"
    else
        echo "✗ Failed to initiate deletion of: $rg"
    fi
    echo "---"
done

echo "All deletion commands have been initiated."
echo "Note: Deletions are running in the background (--no-wait flag used)."
echo "You can check the status with: az group list --query '[].{Name:name, ProvisioningState:properties.provisioningState}' -o table"