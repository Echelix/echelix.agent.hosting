#!/bin/zsh

  export platform_rg=$(az group list --query "[?contains(name, 'platform-rg')].{Name:name}" -o tsv)
  echo $platform_rg    
  export registry_name=$(az acr list --resource-group $platform_rg --query "[].{Name:name}" -o tsv)  
  echo $current_rg 
  echo $registry_name
  
# Get ACR credentials
echo "🔐 ${C_DIM}Getting ACR credentials...${C_RESET}"
export acrPassword=$(az acr credential show -n $registry_name --query "passwords[0].value" -o tsv)
export loginService=$(az acr show -n $registry_name --query loginServer --output tsv)

echo $loginService 
echo $acrPassword
 
 # cassi clio 

# az ad sp list --display-name devagentexchelixreg --query "[].appId" --output tsv)
