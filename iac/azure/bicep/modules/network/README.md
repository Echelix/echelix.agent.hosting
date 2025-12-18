# Network Bicep Module

This Bicep module provisions the core Azure networking resources for the AI platform, including the Virtual Network (VNet), subnets, and associated Network Security Groups (NSGs) for different workloads.

## Resources Deployed

- **Virtual Network (VNet)**
  - Address space and subnets are parameterized.
  - Subnets for AKS, APIM, databases, ACI, endpoints, platform, and load balancer.

- **Network Security Groups (NSGs)**
  - `EventingNSG`: Allows ingress on port 443.
  - `ContainerNSG`: Allows ingress on ports 80, 443, 3500, 5000, 8082.
  - `GatewaySubnetNSG`: Allows gateway management ports and denies all other inbound traffic.
  - `FunctionsNSG`: Allows ingress on port 443.
  - `DatabaseNSG`: Allows ingress on ports 443 and 5432.
  - `ApimNSG`: Allows ingress on ports 80, 443, and 3443 (APIM management).

- **Subnet-to-NSG Associations**
  - Each subnet is associated with the appropriate NSG for its workload.

## Parameters

- `location`: Azure region for resource deployment.
- `networkAddresses`: Array of objects defining subnet names, IDs, and CIDRs.
- `resourceTagging`: Object containing tags for all resources.

## Outputs

- `vnetId`: Resource ID of the created VNet.
- `vnetName`: Name of the VNet.
- `vnetRgName`: Name of the resource group containing the VNet.
- `privatelinkSubnetName`: Name of the subnet for Private Link endpoints.

## Usage

Use this module to deploy a secure, segmented network foundation for your AI platform. Reference the outputs to connect other modules (AKS, APIM, ACR, etc.) to the correct subnets and NSGs.

---

**Example:**

```bicep
module network 'modules/network/network.bicep' = {
  name: 'Network-Deploy'
  params: {
    location: location
    resourceTagging: resourceTagging
    networkAddresses: networkDefinition
  }
}
```

## Support

- **Maintained by:** Echelix Engineering Team  
- **Last Updated:** December 2025
- **Version:** 0.1.0 - Enhanced for Learning Engineers
