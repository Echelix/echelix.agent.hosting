#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Error: No baseFolder parameter provided"
  exit 1
fi

baseFolder="$1"
combinedFile="config.parameters.json"
combinedFileName="$baseFolder/$combinedFile"
bicepPath="$baseFolder/bicep"

if [ ! -f "$combinedFileName" ]; then
  echo "Error: Unable to locate the combined file: $combinedFileName"
  exit 1
fi

echo "$combinedFileName"
echo "$bicepPath"

# Read combined config entries
commonContent=$(cat "$combinedFileName")

# Helper to update a JSON file with jq
update_json() {
  local file="$1"
  local jq_filter="$2"
  local depth="${3:-5}"
  tmpfile=$(mktemp)
  jq "$jq_filter" "$file" > "$tmpfile"
  mv "$tmpfile" "$file"
  echo "Modified config file: $file"
}
 

# init.parameters.json
fpath="$baseFolder/init.parameters.json"
update_json "$fpath" "
  .parameters.acrSku = ($commonContent | .aksParameters.acrSku) |
  .parameters.location = ($commonContent | .commonParameters.location) |
  .parameters.registryName = ($commonContent | .commonParameters.registryName) |
  .parameters.apiResourceGroupName = ($commonContent | .commonParameters.apiResourceGroupName) |
  .parameters.webResourceGroupName = ($commonContent | .commonParameters.webResourceGroupName) |
  .parameters.networkResourceGroupName = ($commonContent | .commonParameters.networkResourceGroupName) |
  .parameters.databaseResourceGroupName = ($commonContent | .commonParameters.databaseResourceGroupName) |
  .parameters.aiResourceGroupName = ($commonContent | .commonParameters.aiResourceGroupName) |
  .parameters.platformResourceGroupName = ($commonContent | .commonParameters.platformResourceGroupName) |
  .parameters.monitoringResourceGroupName = ($commonContent | .commonParameters.monitoringResourceGroupName) |
  .parameters.resourceTagging = ($commonContent | .resourceTagging) |
  .parameters.networkDefinition = {\"value\": ($commonContent | .networkDefinition.value)} 
  "
 
# base-open-ai.parameters.json
fpath="$baseFolder/base-open-ai.parameters.json"
update_json "$fpath" "
  .parameters.location = ($commonContent | .commonParameters.location) |
  .parameters.aiResourceGroupName = ($commonContent | .commonParameters.aiResourceGroupName) |
  .parameters.resourceTagging = ($commonContent | .resourceTagging) |
  .parameters.openAiAccounts = {\"value\": ($commonContent | .openaiParameters.openAiAccounts.value)} |
  .parameters.aiSearchServiceSettings = {\"value\": ($commonContent | .openaiParameters.aiSearchServiceSettings.value)} |
  .parameters.formRecognizerSettings = {\"value\": ($commonContent | .openaiParameters.formRecognizerSettings.value)}
"
  
# base-monitoring.parameters.json
fpath="$baseFolder/base-monitoring.parameters.json"
update_json "$fpath" "
  .parameters.location = ($commonContent | .commonParameters.location) |
  .parameters.monitoringResourceGroupName = ($commonContent | .commonParameters.monitoringResourceGroupName) |
  .parameters.resourceTagging = ($commonContent | .resourceTagging)
" 

# base-governance.parameters.json
fpath="$baseFolder/base-governance.parameters.json"
update_json "$fpath" "
  .parameters.location = ($commonContent | .commonParameters.location) |
  .parameters.resourceTagging = ($commonContent | .resourceTagging) |
  .parameters.tagPolicyEffect = ($commonContent | .governanceParameters.tagPolicyEffect) |
  .parameters.excludedResourceTypes = ($commonContent | .governanceParameters.excludedResourceTypes)
" 

# base-cosmos-db.parameters.json
fpath="$baseFolder/base-cosmos-db.parameters.json"
update_json "$fpath" "
  .parameters.location = ($commonContent | .commonParameters.location) |
  .parameters.cosmosDbAccountName = ($commonContent | .cosmosdbParameters.cosmosDbAccountName) |
  .parameters.privateEndpointEnabled = ($commonContent | .cosmosdbParameters.privateEndpointEnabled) | 
  .parameters.enableServerless = ($commonContent | .cosmosdbParameters.enableServerless) |
  .parameters.databaseResourceGroupName = ($commonContent | .cosmosdbParameters.databaseResourceGroupName) | 
  .parameters.networkResourceGroupName = ($commonContent | .commonParameters.networkResourceGroupName) | 
  .parameters.enableFreeTier = ($commonContent | .cosmosdbParameters.enableFreeTier) | 
  .parameters.databaseConfig = {\"value\": ($commonContent | .cosmosdbParameters.databaseConfig.value)} |  
  .parameters.resourceTagging = ($commonContent | .resourceTagging) |
  .parameters.networkDefinition = {\"value\": ($commonContent | .networkDefinition.value)} 
" 