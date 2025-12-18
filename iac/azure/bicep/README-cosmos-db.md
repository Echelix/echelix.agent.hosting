# CosmosDB Deployment

This directory contains the Bicep templates and deployment scripts for provisioning Azure CosmosDB with best practices for the Demoi AI platform.

## Files

- `base-cosmos-db.bicep` - Main deployment template that orchestrates the CosmosDB deployment
- `base-cosmos-db.parameters.json` - Parameters file containing configuration values
- `modules/database/cosmosdb.bicep` - Core CosmosDB module implementation
- `modules/database/cosmosdb-containers.bicep` - Container creation module
- `deployment/ai-platform/3-deploy-cosmos-db.sh` - Deployment script

## Architecture

The CosmosDB implementation follows these best practices:

### Security

- **Private Endpoints**: CosmosDB is deployed with private endpoints for secure network access
- **Network Security Groups**: Custom NSG rules to control access from AKS and platform subnets
- **Public Access Disabled**: All public network access is disabled
- **TLS 1.2**: Enforced minimum TLS version
- **VNet Integration**: Virtual network rules restrict access to specific subnets

### Performance & Scalability

- **Serverless Mode**: Configured for serverless billing model for cost optimization
- **Session Consistency**: Default consistency level set to Session for balanced performance
- **Partition Strategy**: Optimized partition keys for each container type:
  - `/agentId` for agents data
  - `/conversationId` for conversation data
  - `/documentId` for document storage
  - `/userId` for user data
  - `/configType` for platform configurations

### Database Structure

#### agentData Database

- **agents** container: Stores AI agent definitions and configurations
- **conversations** container: Stores conversation history and context
- **documents** container: Stores document metadata and references

#### platformData Database

- **users** container: Stores user profiles and preferences
- **configurations** container: Stores platform-wide configuration settings

### Backup & Recovery

- **Periodic Backup**: Configured with 4-hour backup intervals
- **8-hour Retention**: Backup retention set to 8 hours
- **Local Redundancy**: Backup storage redundancy set to Local for cost optimization

## Deployment

### Prerequisites

1. Ensure you have Azure CLI installed and authenticated
2. Have the required resource groups created (platform-rg, network-rg)
3. Virtual network and subnets must exist as defined in networkDefinition

### Deploy CosmosDB

```bash
cd iac/azure/bicep/deployment/ai-platform
./3-deploy-cosmos-db.sh
```

### Manual Deployment

```bash
# Set environment variables
../../config.sh ../..

# Get platform resource group
export platform_rg=$(az group list --query "[?contains(name, 'platform-rg')].{Name:name}" -o tsv)

# Deploy CosmosDB
az deployment group create \
  --resource-group $platform_rg \
  --template-file ../../base-cosmos-db.bicep \
  --parameters @../../base-cosmos-db.parameters.json
```

## Configuration

### Customizing Database Structure

To modify the database and container structure, edit the `databaseConfig` parameter in `base-cosmos-db.parameters.json`:

```json
{
  "databaseConfig": {
    "value": {
      "databases": [
        {
          "name": "your-database-name",
          "containers": [
            {
              "name": "your-container-name",
              "partitionKey": "/your-partition-key",
              "throughput": 400
            }
          ]
        }
      ]
    }
  }
}
```

### Partition Key Best Practices

Choose partition keys that:

- Distribute data evenly across partitions
- Enable efficient query patterns
- Avoid hot partitions
- Support your application's access patterns

Examples:

- `/userId` - Good for user-specific data
- `/tenantId` - Good for multi-tenant scenarios  
- `/category` - Good when you have evenly distributed categories
- `/date` - Good for time-series data (use with caution)

## Monitoring

After deployment, monitor:

- Request units (RU) consumption
- Partition key distribution
- Query performance
- Storage utilization

## Security Notes

- CosmosDB connection strings and keys are considered secrets
- Use Azure Key Vault to store connection strings in production
- Implement proper RBAC for CosmosDB access
- Consider using managed identity for application authentication

## Troubleshooting

### Common Issues

1. **Deployment Failures**: Check that all required resource groups and VNets exist
2. **Network Access**: Verify subnet configurations and NSG rules
3. **Naming Conflicts**: CosmosDB account names must be globally unique
4. **Partition Hot Spots**: Monitor partition key distribution and adjust if needed

### Useful Commands

```bash
# List CosmosDB accounts
az cosmosdb list --query "[].name" -o table

# Get CosmosDB details
az cosmosdb show --name <account-name> --resource-group <rg-name>

# List databases
az cosmosdb sql database list --account-name <account-name> --resource-group <rg-name>

# List containers
az cosmosdb sql container list --account-name <account-name> --database-name <db-name> --resource-group <rg-name>
```

## Support

- **Maintained by:** Echelix Engineering Team  
- **Last Updated:** December 2025
- **Version:** 0.1.0 - Enhanced for Learning Engineers
