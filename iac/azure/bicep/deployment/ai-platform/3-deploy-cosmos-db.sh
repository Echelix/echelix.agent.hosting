#!/bin/zsh

echo "starting the deployment of the CosmosDB resources"
 
echo "setting the environment variables for deployment"

../../config.sh ../..

read "answer?Do you want to deploy CosmosDB for the AI platform (y/n): "   
answer_lower=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [[ "$answer_lower" == "y" || "$answer_lower" == "yes" ]]; then 

  echo "deploying CosmosDB for the AI platform"
  echo "get the platform resource group for deploying CosmosDB"    
  export database_rg=$(az group list --query "[?contains(name, 'database-rg')].{Name:name}" -o tsv)
  echo $database_rg
  az deployment group create --resource-group $database_rg --template-file  ../../base-cosmos-db.bicep --parameters @../../base-cosmos-db.parameters.json
  # az deployment group create --resource-group $database_rg --template-file  base-cosmos-db.bicep --parameters @base-cosmos-db.parameters.json --what-if

  echo "listing CosmosDB accounts"
  az cosmosdb list --query "[].name" -o table 

fi

echo -e "\nObtain CosmosDB connection details \n"
echo "Get the names of CosmosDB accounts to find the one you created "
echo " az cosmosdb list --query "[].name" -o table "

echo -e " az cosmosdb show \\
    --name <your-cosmosdb-account-name> \\
    --resource-group <your-resource-group-name> \\
    --output table"

echo -e "\nTo get the connection string (use with caution):"
echo " az cosmosdb keys list \\
    --name <your-cosmosdb-account-name> \\
    --resource-group <your-resource-group-name> \\
    --type connection-strings \\
    --output table"

echo -e "\nTo get the primary key (use with caution):"
echo " az cosmosdb keys list \\
    --name <your-cosmosdb-account-name> \\
    --resource-group <your-resource-group-name> \\
    --type keys \\
    --query 'primaryMasterKey' \\
    --output tsv"