#!/bin/zsh

echo "starting the deployment of the AI platform resources"
 
echo   "setting the environment variables for deployment"

../../config.sh ../..

read "answer?Do you want to continue root deployment? (y/n): "   
answer_lower=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [[ "$answer_lower" == "y" || "$answer_lower" == "yes" ]]; then
  # echo "Aborted."
  # exit 1
   # az deployment sub create -f init.bicep --location eastus2 --parameters @init.parameters.json --what-if
  echo "setting the subscription for deployment"
  az deployment sub create -f ../../init.bicep --location eastus2 --parameters @../../init.parameters.json
 
fi

read "answer?Do you want to deploy AI Resources (y/n): "   
answer_lower=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [[ "$answer_lower" == "y" || "$answer_lower" == "yes" ]]; then 
 
  echo "get the AI resource group for deployment assignment"
  export current_rg=$(az group list --query "[?contains(name, 'ai-rg')].{Name:name}" -o tsv)
  echo $current_rg

  echo "provision all AI resources and setup defailt embedding and AI model for the ai platform"
  az deployment group create --resource-group $current_rg --template-file ../../base-open-ai.bicep --parameters @../../base-open-ai.parameters.json

fi 

read "answer?Do you want to deploy monitoring log analytics (y/n): "   
answer_lower=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [[ "$answer_lower" == "y" || "$answer_lower" == "yes" ]]; then 

  echo "provision the monitoring log analytics"
  export monitoring_rg=$(az group list --query "[?contains(name, 'monitoring-rg')].{Name:name}" -o tsv)
  echo $monitoring_rg
  az deployment group create --resource-group $monitoring_rg --template-file ../../base-monitoring.bicep --parameters @../../base-monitoring.parameters.json   
 
fi
 
read "answer?Do you want to obtain all the AI KEYS (y/n): "   
answer_lower=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [[ "$answer_lower" == "y" || "$answer_lower" == "yes" ]]; then 

  echo "get the AI resource group for reading all config parameters needed for APIs"    
  export current_rg=$(az group list --query "[?contains(name, 'ai-rg')].{Name:name}" -o tsv)
  echo $current_rg
  echo "setting the AI resource group for deployment assignment"
  export rg=$current_rg
  echo "getting the AI resource group for deployment assignment"
  export ai_name=$(az cognitiveservices account list -o tsv -g $rg --query "[?kind=='OpenAI'].{name:name}")
  echo $ai_name
  echo "getting the AI key for deployment assignment"
  export ai_key=$(az cognitiveservices account keys list -n $ai_name -g $rg -o tsv --query "key1")
  echo "getting the cognative services endpoint for deployment assignment"
  export forms_name=$(az cognitiveservices account list -o tsv -g $rg --query "[?kind=='FormRecognizer'].{name:name}")
  export forms_key=$(az cognitiveservices account keys list -n $forms_name -g $rg -o tsv --query "key1") 

  export forms_recognizer=$(az cognitiveservices account list --resource-group $rg --query "[?kind=='FormRecognizer'].properties.endpoint" --output tsv)
  export open_ai_endpoint=$(az cognitiveservices account list --resource-group $rg --query "[?kind=='OpenAI'].properties.endpoint" --output tsv)
   
  echo "\n\n\n------------------------------------------------------------\n"
  echo "AI ENDPOINT FOR CONFIG"
  echo $open_ai_endpoint
  echo "AI KEY FOR CONFIG"
  echo $ai_key
  echo "FORMS RECOGNIZER ENDPOINT FOR CONFIG"
  echo $forms_recognizer
  echo "FORMS RECOGNIZER KEY FOR CONFIG"
  echo $forms_key

  echo "\n------------------------------------------------------------\n\n\n\n"

fi



echo "get the platform resource group name for keyvault access"
export platform_rg=$(az group list --query "[?contains(name, 'platform-rg')].{Name:name}" -o tsv)
echo $platform_rg

export keyvault_name=$(az keyvault list --resource-group $platform_rg --query "[].name" -o tsv)
echo $keyvault_name
export keyvault_url=$(az keyvault show --name $keyvault_name --query "properties.vaultUri" -o tsv)
echo $keyvault_url 


echo "done"

 