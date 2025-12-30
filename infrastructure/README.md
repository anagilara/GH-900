# Infrastructure as Code (IaC) Documentation

## Overview

This document describes the Infrastructure as Code (IaC) setup for the Shopping Cart application. The infrastructure is defined using Terraform for Azure resources and Docker for containerization.

## Table of Contents

1. [Architecture](#architecture)
2. [Prerequisites](#prerequisites)
3. [Terraform Configuration](#terraform-configuration)
4. [Docker Configuration](#docker-configuration)
5. [Deployment Guide](#deployment-guide)
6. [Environment Management](#environment-management)
7. [Security Considerations](#security-considerations)
8. [Troubleshooting](#troubleshooting)

## Architecture

The infrastructure includes the following Azure resources:

- **Resource Group**: Container for all Azure resources
- **App Service Plan**: Hosting plan for the web application (Linux-based)
- **App Service**: Hosts the ASP.NET Core 9.0 application
- **Application Insights**: Monitoring and diagnostics
- **Storage Account**: For application assets and data
- **Key Vault**: Secure storage for secrets and configuration
- **Managed Identity**: System-assigned identity for secure access to Azure resources

### Optional Resources

- **SQL Server & Database**: Can be enabled for data persistence (commented out in main.tf)

## Prerequisites

### Required Tools

1. **Terraform** (>= 1.0)
   ```bash
   # Install Terraform
   # Visit: https://www.terraform.io/downloads
   ```

2. **Azure CLI**
   ```bash
   # Install Azure CLI
   # Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
   
   # Login to Azure
   az login
   ```

3. **Docker** (for local testing)
   ```bash
   # Install Docker Desktop
   # Visit: https://www.docker.com/products/docker-desktop
   ```

4. **.NET 9.0 SDK** (for local development)
   ```bash
   # Install .NET SDK
   # Visit: https://dotnet.microsoft.com/download
   ```

### Azure Subscription

- An active Azure subscription
- Appropriate permissions to create resources
- Service Principal (for CI/CD pipelines)

## Terraform Configuration

### File Structure

```
infrastructure/
└── terraform/
    ├── main.tf              # Main infrastructure configuration
    ├── variables.tf         # Variable definitions
    ├── outputs.tf           # Output values
    └── environments/
        ├── development.tfvars   # Development environment variables
        ├── staging.tfvars       # Staging environment variables
        └── production.tfvars    # Production environment variables
```

### Configuration Files

- **main.tf**: Defines all Azure resources
- **variables.tf**: Input variables with validation
- **outputs.tf**: Output values (URLs, connection strings, etc.)
- **environments/*.tfvars**: Environment-specific configurations

## Docker Configuration

### Dockerfile

The multi-stage Dockerfile includes:

1. **Build stage**: Restores dependencies and builds the application
2. **Publish stage**: Publishes the application in Release mode
3. **Runtime stage**: Creates a minimal runtime image with the published app

### docker-compose.yml

Defines services for local development:

- **web**: The ASP.NET Core application
- **sqlserver**: SQL Server (optional, commented out)

## Deployment Guide

### Initial Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd GH-900
   ```

2. **Configure Azure credentials**
   ```bash
   az login
   az account set --subscription <subscription-id>
   ```

### Terraform Deployment

#### Development Environment

```bash
# Navigate to Terraform directory
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Review the plan
terraform plan -var-file="environments/development.tfvars"

# Apply the configuration
terraform apply -var-file="environments/development.tfvars"

# Save outputs
terraform output > outputs.txt
```

#### Staging Environment

```bash
terraform plan -var-file="environments/staging.tfvars"
terraform apply -var-file="environments/staging.tfvars"
```

#### Production Environment

```bash
terraform plan -var-file="environments/production.tfvars"
terraform apply -var-file="environments/production.tfvars"
```

### Docker Deployment

#### Local Testing

```bash
# Build and run with Docker Compose
docker-compose up --build

# Access the application
# Open browser: http://localhost:8080
```

#### Build Docker Image

```bash
# Build the image
docker build -t shopping-cart:latest .

# Run the container
docker run -p 8080:8080 shopping-cart:latest

# Stop the container
docker stop <container-id>
```

### Application Deployment to Azure

```bash
# Build and publish the application
dotnet publish -c Release

# Deploy to Azure App Service
az webapp deployment source config-zip \
  --resource-group shopping-cart-<environment>-rg \
  --name shopping-cart-<environment>-app \
  --src ./bin/Release/net9.0/publish.zip
```

## Environment Management

### Environment Variables

Each environment (development, staging, production) has its own configuration file:

- **development.tfvars**: Uses B1 tier (Basic)
- **staging.tfvars**: Uses S1 tier (Standard)
- **production.tfvars**: Uses P1V2 tier (Premium)

### Secrets Management

Sensitive data should be stored in Azure Key Vault:

```bash
# Add a secret to Key Vault
az keyvault secret set \
  --vault-name shopping-cart-<environment>-kv \
  --name "ConnectionString" \
  --value "your-connection-string"
```

### Environment-Specific Settings

Configure environment-specific settings in the App Service:

```bash
# Set app settings
az webapp config appsettings set \
  --resource-group shopping-cart-<environment>-rg \
  --name shopping-cart-<environment>-app \
  --settings ASPNETCORE_ENVIRONMENT=Production
```

## Security Considerations

### Best Practices

1. **Use Managed Identity**: The App Service uses System-Assigned Managed Identity to access Azure resources securely
2. **HTTPS Only**: All App Services are configured with HTTPS-only access
3. **Key Vault**: Store all secrets in Azure Key Vault
4. **Least Privilege**: Grant minimal required permissions
5. **Network Security**: Consider adding Virtual Network integration for production

### Secrets in Terraform

Never commit sensitive data to version control:

```bash
# Create a local variables file (gitignored)
cp environments/development.tfvars environments/development.local.tfvars

# Edit local file with sensitive values
# This file should be in .gitignore
```

### State File Security

For production, use remote state storage:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate"
    container_name       = "tfstate"
    key                  = "shopping-cart.terraform.tfstate"
  }
}
```

## Troubleshooting

### Common Issues

#### Terraform Errors

**Issue**: Provider authentication failed
```bash
# Solution: Re-authenticate with Azure
az login
az account set --subscription <subscription-id>
```

**Issue**: Resource name already exists
```bash
# Solution: Use unique resource names or destroy existing resources
terraform destroy -var-file="environments/development.tfvars"
```

#### Docker Issues

**Issue**: Port already in use
```bash
# Solution: Change port mapping in docker-compose.yml
ports:
  - "8081:8080"  # Use a different host port
```

**Issue**: Build fails
```bash
# Solution: Clear Docker cache
docker system prune -a
docker-compose build --no-cache
```

#### Application Issues

**Issue**: Application won't start in Azure
```bash
# Check logs
az webapp log tail \
  --resource-group shopping-cart-<environment>-rg \
  --name shopping-cart-<environment>-app
```

### Getting Help

- Check Terraform documentation: https://www.terraform.io/docs
- Azure documentation: https://docs.microsoft.com/azure
- Docker documentation: https://docs.docker.com

## Maintenance

### Updates

```bash
# Update Terraform providers
terraform init -upgrade

# Update Docker base images
docker-compose pull
```

### Cleanup

```bash
# Destroy Terraform resources
terraform destroy -var-file="environments/development.tfvars"

# Remove Docker containers and images
docker-compose down -v
docker system prune -a
```

## Next Steps

1. Set up CI/CD pipelines (GitHub Actions, Azure DevOps)
2. Configure monitoring and alerting
3. Implement backup and disaster recovery
4. Add network security (Virtual Network, Application Gateway)
5. Configure auto-scaling policies
6. Implement database migrations
