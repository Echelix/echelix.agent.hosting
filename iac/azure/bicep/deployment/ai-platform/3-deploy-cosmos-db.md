# Cosmos DB Deployment

## Configuration Options

The Cosmos DB deployment supports both serverless and provisioned throughput modes:

### Serverless Mode (Default)

- Set `enableServerless: true` in parameters
- Throughput values are ignored
- Cost-effective for development and variable workloads
- Pay per operation

### Provisioned Throughput Mode

- Set `enableServerless: false` in parameters  
- Throughput values are applied to containers
- Predictable performance and costs
- Requires minimum RU/s allocation

### Free Tier Option

- Set `enableFreeTier: true` and `enableServerless: false` in parameters
- Provides 400 RU/s and 5 GB storage free per month
- Only available for one Cosmos DB account per Azure subscription
- **Cannot be used with serverless mode**
- Good for development with consistent low usage

## Networking Options

### VNet Integration Only (Default for Development)

- Set `privateEndpointEnabled: false` in parameters
- Uses service endpoints for subnet-level access control
- Simpler setup, lower cost
- Traffic goes over Microsoft backbone
- Recommended for development environments

### Private Endpoints (Production Ready)

- Set `privateEndpointEnabled: true` in parameters
- Creates dedicated private IP within your VNet
- Traffic stays completely within your network
- Higher security, additional cost
- Recommended for production environments

### Network Security

Both options provide:

- `publicNetworkAccess: 'Disabled'` - No internet access
- VNet rules for AKS and database subnets
- Network Security Group (NSG) rules deployed in network resource group

## Validation

Deletes existing deployment if failed

```bash
az cosmosdb delete --name agent-system-dev --resource-group dev-agent-database-rg --yes

az cosmosdb list --query "[].name" -o table 

agent-system-dev

```
