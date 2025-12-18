#!/bin/zsh

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