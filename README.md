# Shopping Cart Application

An ASP.NET Core 9.0 web application for managing a shopping cart, built with Infrastructure as Code (IaC) for automated deployment to Azure.

## 🚀 Quick Start

### Local Development with Docker

```bash
# Build and run the application
docker compose up --build

# Access the application at http://localhost:8080
```

### Deploy to Azure

```bash
# Navigate to infrastructure directory
cd infrastructure/terraform

# Initialize and deploy to development
terraform init
terraform apply -var-file="environments/development.tfvars"
```

For detailed instructions, see the [Quick Start Guide](infrastructure/QUICKSTART.md).

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Infrastructure as Code](#infrastructure-as-code)
- [Deployment](#deployment)
- [Development](#development)
- [Documentation](#documentation)
- [Contributing](#contributing)

## Overview

This project implements a modern shopping cart application with:

- **Application**: ASP.NET Core 9.0 MVC web application
- **Infrastructure**: Terraform-based IaC for Azure
- **Containerization**: Docker and Docker Compose support
- **Deployment**: Multi-environment support (development, staging, production)

## Features

### Application Features
- Web-based shopping cart interface
- MVC architecture with ASP.NET Core 9.0
- Responsive design
- Error handling and logging

### Infrastructure Features
- ✅ **Automated Provisioning**: Terraform configuration for Azure resources
- ✅ **Multi-Environment**: Separate configurations for dev, staging, and production
- ✅ **Containerization**: Docker support for local development and cloud deployment
- ✅ **Security**: Azure Key Vault integration, Managed Identity, HTTPS-only
- ✅ **Monitoring**: Application Insights integration
- ✅ **Scalability**: Auto-scaling capable infrastructure
- ✅ **Documentation**: Comprehensive deployment and architecture guides

## Architecture

The application uses the following Azure resources:

- **App Service**: Linux-based web application hosting
- **Application Insights**: Application performance monitoring
- **Storage Account**: Asset and data storage
- **Key Vault**: Secure secrets management
- **SQL Server** (optional): Relational database

For detailed architecture information, see [Architecture Documentation](infrastructure/ARCHITECTURE.md).

## Prerequisites

### For Local Development
- [.NET 9.0 SDK](https://dotnet.microsoft.com/download)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)

### For Azure Deployment
- [Terraform](https://www.terraform.io/downloads) (>= 1.0)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Active Azure subscription

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd GH-900
```

### 2. Run Locally with Docker

```bash
# Build and start the application
docker compose up --build

# The application will be available at http://localhost:8080
```

### 3. Run Locally with .NET SDK

```bash
# Restore dependencies
dotnet restore

# Run the application
dotnet run

# The application will be available at https://localhost:5001
```

## Infrastructure as Code

This project uses **Terraform** for infrastructure provisioning on Azure.

### Directory Structure

```
infrastructure/
├── terraform/
│   ├── main.tf                 # Main infrastructure configuration
│   ├── variables.tf            # Variable definitions
│   ├── outputs.tf              # Output values
│   └── environments/
│       ├── development.tfvars  # Development environment
│       ├── staging.tfvars      # Staging environment
│       └── production.tfvars   # Production environment
├── scripts/
│   ├── deploy.sh              # Deployment script (Bash)
│   ├── deploy.ps1             # Deployment script (PowerShell)
│   ├── destroy.sh             # Cleanup script
│   └── validate.sh            # Validation script
├── README.md                   # IaC documentation
├── QUICKSTART.md              # Quick start guide
└── ARCHITECTURE.md            # Architecture documentation
```

### Quick Deploy

Using the deployment script:

```bash
# Make script executable
chmod +x infrastructure/scripts/deploy.sh

# Deploy to development
./infrastructure/scripts/deploy.sh development
```

Or manually with Terraform:

```bash
cd infrastructure/terraform
terraform init
terraform plan -var-file="environments/development.tfvars"
terraform apply -var-file="environments/development.tfvars"
```

## Deployment

### Environment Configuration

The project supports three environments:

1. **Development**: Basic tier (B1), for testing and development
2. **Staging**: Standard tier (S1), for QA and pre-production testing
3. **Production**: Premium tier (P1V2), for live production workloads

### Deployment Options

#### Option 1: Using Deployment Scripts

```bash
# Deploy
./infrastructure/scripts/deploy.sh <environment>

# Validate
./infrastructure/scripts/validate.sh

# Destroy
./infrastructure/scripts/destroy.sh <environment>
```

#### Option 2: Direct Terraform Commands

```bash
cd infrastructure/terraform

# Development
terraform apply -var-file="environments/development.tfvars"

# Staging
terraform apply -var-file="environments/staging.tfvars"

# Production
terraform apply -var-file="environments/production.tfvars"
```

#### Option 3: Docker Container to Azure

```bash
# Build the Docker image
docker build -t shopping-cart:latest .

# Push to Azure Container Registry (requires ACR)
docker tag shopping-cart:latest <your-acr>.azurecr.io/shopping-cart:latest
docker push <your-acr>.azurecr.io/shopping-cart:latest
```

## Development

### Project Structure

```
GH-900/
├── Controllers/           # MVC Controllers
├── Models/               # Data models
├── Views/                # Razor views
├── wwwroot/              # Static files
├── Program.cs            # Application entry point
├── appsettings.json      # Application configuration
├── Dockerfile            # Docker configuration
├── docker-compose.yml    # Docker Compose configuration
└── infrastructure/       # IaC configurations
```

### Local Development Workflow

1. Make code changes
2. Test locally with Docker or .NET SDK
3. Commit changes to version control
4. Deploy to development environment
5. Test in development
6. Promote to staging/production

### Testing Locally

```bash
# Run with Docker Compose
docker compose up

# Run with .NET SDK
dotnet run

# Build for production
dotnet publish -c Release
```

## Documentation

Comprehensive documentation is available:

- **[Quick Start Guide](infrastructure/QUICKSTART.md)**: Get started quickly
- **[Full IaC Documentation](infrastructure/README.md)**: Detailed infrastructure guide
- **[Architecture Documentation](infrastructure/ARCHITECTURE.md)**: System architecture and design

### Key Topics Covered

- Infrastructure setup and configuration
- Terraform usage and best practices
- Docker containerization
- Azure resource provisioning
- Environment management
- Security considerations
- Troubleshooting guide

## Security

This project implements several security best practices:

- ✅ HTTPS-only access
- ✅ Azure Managed Identity for resource access
- ✅ Secrets stored in Azure Key Vault
- ✅ Non-root Docker container user
- ✅ Network security configurations
- ✅ Regular security updates

For more details, see the [Security section](infrastructure/README.md#security-considerations) in the infrastructure documentation.

## Monitoring

Application monitoring is provided by Azure Application Insights:

- Request tracking and performance
- Exception monitoring
- Custom telemetry
- Live metrics
- Log analytics

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is part of the GH-900 repository.

## Support

For issues and questions:

1. Check the [documentation](infrastructure/README.md)
2. Review the [troubleshooting guide](infrastructure/README.md#troubleshooting)
3. Open an issue in the repository

---

## Next Steps

After deployment:

1. ✅ Configure custom domain and SSL certificates
2. ✅ Set up CI/CD pipelines
3. ✅ Configure monitoring alerts
4. ✅ Implement backup strategies
5. ✅ Add database migrations
6. ✅ Configure auto-scaling policies

For detailed next steps, see the [Infrastructure Documentation](infrastructure/README.md#next-steps).
