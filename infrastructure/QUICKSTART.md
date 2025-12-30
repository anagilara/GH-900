# Quick Start Guide - Infrastructure Deployment

This guide will help you quickly deploy the Shopping Cart application infrastructure.

## Prerequisites Checklist

- [ ] Terraform installed (>= 1.0)
- [ ] Azure CLI installed and configured
- [ ] Docker installed (for local testing)
- [ ] Active Azure subscription
- [ ] Logged in to Azure (`az login`)

## Quick Deployment Steps

### Option 1: Local Testing with Docker (Recommended for Development)

```bash
# 1. Clone the repository
git clone <repository-url>
cd GH-900

# 2. Build and run the application
docker-compose up --build

# 3. Access the application
# Open your browser to: http://localhost:8080
```

### Option 2: Deploy to Azure (Development Environment)

```bash
# 1. Navigate to Terraform directory
cd infrastructure/terraform

# 2. Initialize Terraform
terraform init

# 3. Plan the deployment
terraform plan -var-file="environments/development.tfvars"

# 4. Deploy to Azure
terraform apply -var-file="environments/development.tfvars"

# 5. Get the application URL
terraform output app_service_url
```

### Option 3: Deploy to Azure (Production Environment)

```bash
# 1. Navigate to Terraform directory
cd infrastructure/terraform

# 2. Initialize Terraform (if not already done)
terraform init

# 3. Configure production secrets (create local tfvars file)
cp environments/production.tfvars environments/production.local.tfvars
# Edit production.local.tfvars with your sensitive values

# 4. Plan the deployment
terraform plan -var-file="environments/production.local.tfvars"

# 5. Deploy to Azure
terraform apply -var-file="environments/production.local.tfvars"

# 6. Get the application URL
terraform output app_service_url
```

## Verify Deployment

### Local Docker Deployment

```bash
# Check running containers
docker-compose ps

# View logs
docker-compose logs -f web

# Test the application
curl http://localhost:8080
```

### Azure Deployment

```bash
# Get the App Service URL
terraform output app_service_url

# Check application health
curl -I https://<your-app-service-name>.azurewebsites.net

# View application logs
az webapp log tail \
  --resource-group shopping-cart-development-rg \
  --name shopping-cart-development-app
```

## Common Commands

### Terraform

```bash
# View current state
terraform show

# List all resources
terraform state list

# Get specific output
terraform output <output-name>

# Destroy infrastructure
terraform destroy -var-file="environments/development.tfvars"
```

### Docker

```bash
# Build without cache
docker-compose build --no-cache

# Run in detached mode
docker-compose up -d

# Stop containers
docker-compose down

# View logs for specific service
docker-compose logs -f web
```

### Azure CLI

```bash
# List resource groups
az group list --output table

# List app services
az webapp list --output table

# Restart app service
az webapp restart \
  --resource-group shopping-cart-development-rg \
  --name shopping-cart-development-app
```

## Troubleshooting

### Issue: Terraform initialization fails

```bash
# Clear Terraform cache
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### Issue: Docker build fails

```bash
# Clear Docker cache
docker system prune -a
docker-compose build --no-cache
```

### Issue: Azure authentication fails

```bash
# Re-authenticate
az logout
az login
az account set --subscription <subscription-id>
```

## Next Steps

1. Review the full documentation: `infrastructure/README.md`
2. Configure monitoring and alerts
3. Set up CI/CD pipeline
4. Configure custom domain and SSL
5. Enable backup and disaster recovery

## Support

For detailed information, see:
- Full documentation: `/infrastructure/README.md`
- Terraform files: `/infrastructure/terraform/`
- Docker configuration: `/Dockerfile` and `/docker-compose.yml`
