# Architecture Overview

## Infrastructure Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Azure Cloud                              │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Resource Group                                 │ │
│  │                                                              │ │
│  │  ┌──────────────────┐        ┌────────────────────────┐   │ │
│  │  │  App Service     │        │  Application Insights  │   │ │
│  │  │  Plan (Linux)    │        │  (Monitoring)          │   │ │
│  │  └────────┬─────────┘        └────────────────────────┘   │ │
│  │           │                                                 │ │
│  │  ┌────────▼─────────────────────────────────────────────┐ │ │
│  │  │  App Service (Web App)                              │ │ │
│  │  │  - ASP.NET Core 9.0                                 │ │ │
│  │  │  - Shopping Cart Application                        │ │ │
│  │  │  - System-Assigned Managed Identity                 │ │ │
│  │  └──────────┬───────────────────────┬──────────────────┘ │ │
│  │             │                       │                     │ │
│  │  ┌──────────▼────────┐   ┌─────────▼──────────────────┐ │ │
│  │  │  Azure Key Vault  │   │  Storage Account           │ │ │
│  │  │  - Secrets        │   │  - Application Assets     │ │ │
│  │  │  - Config         │   │  - Blob Storage            │ │ │
│  │  └───────────────────┘   └────────────────────────────┘ │ │
│  │                                                            │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │  SQL Server (Optional)                               │ │ │
│  │  │  - Shopping Cart Database                            │ │ │
│  │  │  - Product Catalog                                   │ │ │
│  │  │  - Order Management                                  │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Component Descriptions

### App Service Plan
- **Purpose**: Hosting infrastructure for the web application
- **OS**: Linux
- **Tiers**: 
  - Development: B1 (Basic)
  - Staging: S1 (Standard)
  - Production: P1V2 (Premium)

### App Service (Web App)
- **Runtime**: ASP.NET Core 9.0
- **Features**:
  - HTTPS-only access
  - Health check monitoring
  - Auto-scaling capabilities (on Premium tier)
  - Managed Identity for secure Azure resource access

### Application Insights
- **Purpose**: Application performance monitoring and diagnostics
- **Features**:
  - Request tracking
  - Exception monitoring
  - Performance metrics
  - Custom telemetry

### Storage Account
- **Purpose**: Store application assets, files, and blob data
- **Features**:
  - Blob containers for assets
  - GRS replication for production
  - LRS for development/staging

### Azure Key Vault
- **Purpose**: Secure storage for secrets and configuration
- **Features**:
  - Connection strings
  - API keys
  - Certificates
  - Access via Managed Identity

### SQL Server (Optional)
- **Purpose**: Relational database for application data
- **Features**:
  - Product catalog
  - Shopping cart data
  - Order history
  - User management

## Security Model

### Identity and Access Management
```
App Service
    │
    ├─► System-Assigned Managed Identity
    │       │
    │       ├─► Key Vault (Secret Reader)
    │       └─► Storage Account (Contributor)
    │
    └─► HTTPS-only access
```

### Network Flow
```
Internet
    │
    ├─► HTTPS (443) ──► App Service
    │                      │
    │                      ├─► Application Insights
    │                      ├─► Key Vault
    │                      ├─► Storage Account
    │                      └─► SQL Server (if enabled)
```

## Deployment Environments

### Development
- **Purpose**: Developer testing and feature development
- **Resources**: Minimal (B1 tier)
- **Data**: Test data only
- **Monitoring**: Basic logging

### Staging
- **Purpose**: Pre-production testing and QA
- **Resources**: Medium (S1 tier)
- **Data**: Sanitized production-like data
- **Monitoring**: Full monitoring enabled

### Production
- **Purpose**: Live application serving customers
- **Resources**: Premium (P1V2 tier)
- **Data**: Production data with backups
- **Monitoring**: Full monitoring with alerts

## Container Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Container                         │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  ASP.NET Core Runtime (mcr.microsoft.com/dotnet/      │  │
│  │  aspnet:9.0)                                          │  │
│  │                                                        │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │  Shopping Cart Application                      │  │  │
│  │  │  - myGHrepo.dll                                 │  │  │
│  │  │  - wwwroot/                                     │  │  │
│  │  │  - appsettings.json                             │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  │                                                        │  │
│  │  Port: 8080                                            │  │
│  │  User: appuser (non-root)                             │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Local Development with Docker Compose

```
┌─────────────────────────────────────────────────────────────┐
│               Docker Compose Environment                     │
│                                                               │
│  ┌────────────────────┐          ┌─────────────────────┐   │
│  │  Web Container     │          │  SQL Server         │   │
│  │  (Port 8080)       │◄────────►│  (Port 1433)        │   │
│  │  - ASP.NET App     │          │  - Optional         │   │
│  └────────────────────┘          └─────────────────────┘   │
│           │                                                  │
│           │                                                  │
│  ┌────────▼──────────────────────────────────────────────┐ │
│  │  Shared Network: shopping-cart-network                │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Infrastructure as Code Workflow

```
┌──────────────┐
│  Developer   │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│  Version Control (Git)                                   │
│  - Terraform files                                       │
│  - Docker configuration                                  │
│  - Application code                                      │
└──────┬───────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│  CI/CD Pipeline (Future)                                 │
│  - Terraform plan                                        │
│  - Terraform apply                                       │
│  - Build Docker image                                    │
│  - Deploy to Azure                                       │
└──────┬───────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│  Azure Cloud                                             │
│  - Provisioned resources                                 │
│  - Running application                                   │
│  - Monitored services                                    │
└──────────────────────────────────────────────────────────┘
```

## Scaling Strategy

### Horizontal Scaling
- App Service can scale out to multiple instances
- Premium tier supports auto-scaling rules
- Load balancing handled automatically by Azure

### Vertical Scaling
- Change App Service Plan tier as needed
- Update `app_service_sku` in environment tfvars
- Apply Terraform changes

### Database Scaling
- SQL Database supports elastic pools
- Can scale up/down database tier as needed
- Implement read replicas for read-heavy workloads

## Disaster Recovery

### Backup Strategy
- App Service: Automated backups (Premium tier)
- Database: Automated backups with point-in-time restore
- Storage: Geo-redundant storage for production

### Recovery Objectives
- **RTO** (Recovery Time Objective): < 1 hour
- **RPO** (Recovery Point Objective): < 15 minutes

## Cost Optimization

### Development
- Use Basic tier (B1)
- Stop resources when not in use
- Use shared resources where possible

### Production
- Right-size resources based on usage
- Implement auto-scaling to optimize costs
- Use reserved instances for predictable workloads
- Monitor and analyze costs with Azure Cost Management

## Monitoring and Observability

### Metrics Tracked
- Application performance (response times)
- Error rates and exceptions
- Resource utilization (CPU, memory)
- Database performance
- Storage usage

### Alerting
- High error rates
- Performance degradation
- Resource exhaustion
- Security events
