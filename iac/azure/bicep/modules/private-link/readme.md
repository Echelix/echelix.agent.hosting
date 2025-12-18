# Private Link & DNS Bicep Module

This Bicep module provisions an Azure Container Registry (ACR) with optional Private Endpoint and Private DNS integration, and sets up a managed identity for secure image pulls.

## Resources Deployed

- **Azure Container Registry (ACR)**
  - Creates an ACR instance with the specified SKU (`Basic`, `Standard`, or `Premium`).
  - Enables admin user access.
  - Applies custom tags.

- **Private Endpoint** (only if SKU is `Premium`)
  - Creates a Private Endpoint for the ACR.
  - Connects the Private Endpoint to a specified subnet in a given Virtual Network.

- **Private DNS Zone**
  - Creates a Private DNS Zone for the ACR (`<product>.azurecr.io`).

- **Virtual Network Link**
  - Links the Private DNS Zone to the specified Virtual Network.

- **Private DNS Zone Group**
  - Associates the Private DNS Zone with the Private Endpoint (if created).

- **User-Assigned Managed Identity**
  - Creates a managed identity for ACR image pulls.

- **Role Assignment**
  - Assigns the managed identity the "AcrPull" role on the ACR, allowing it to pull images.

## Outputs

- `imagePullPrincipalId`: The principal ID of the managed identity.
- `imagePullId`: The resource ID of the managed identity.

## Usage

Use this module to automate the secure setup of an Azure Container Registry with private networking and DNS, and configure a managed identity with pull permissions for use by workloads such as Azure Container Instances or Kubernetes.

## Support

- **Maintained by:** Echelix Engineering Team  
- **Last Updated:** December 2025
- **Version:** 0.1.0 - Enhanced for Learning Engineers
