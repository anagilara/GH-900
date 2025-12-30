terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Backend configuration for remote state (uncomment and configure as needed)
  # backend "azurerm" {
  #   resource_group_name  = "tfstate-rg"
  #   storage_account_name = "tfstate"
  #   container_name       = "tfstate"
  #   key                  = "shopping-cart.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location
  
  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Project     = var.project_name
    }
  )
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "${var.project_name}-${var.environment}-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  
  tags = var.common_tags
}

# App Service
resource "azurerm_linux_web_app" "main" {
  name                = "${var.project_name}-${var.environment}-app"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id
  
  site_config {
    always_on = var.environment == "production" ? true : false
    
    application_stack {
      dotnet_version = "9.0"
    }
    
    health_check_path = "/"
  }
  
  app_settings = {
    "ASPNETCORE_ENVIRONMENT"           = var.environment == "production" ? "Production" : "Development"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }
  
  https_only = true
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = var.common_tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "${var.project_name}-${var.environment}-insights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  
  tags = var.common_tags
}

# SQL Database (optional - uncomment if needed for shopping cart)
# resource "azurerm_mssql_server" "main" {
#   name                         = "${var.project_name}-${var.environment}-sqlserver"
#   location                     = azurerm_resource_group.main.location
#   resource_group_name          = azurerm_resource_group.main.name
#   version                      = "12.0"
#   administrator_login          = var.sql_admin_username
#   administrator_login_password = var.sql_admin_password
#   
#   tags = var.common_tags
# }

# resource "azurerm_mssql_database" "main" {
#   name      = "${var.project_name}-${var.environment}-db"
#   server_id = azurerm_mssql_server.main.id
#   sku_name  = var.sql_sku_name
#   
#   tags = var.common_tags
# }

# Storage Account (for application data, images, etc.)
resource "azurerm_storage_account" "main" {
  name                     = lower(substr(replace("${var.project_name}${var.environment}sa", "-", ""), 0, 24))
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  account_tier             = "Standard"
  account_replication_type = var.environment == "production" ? "GRS" : "LRS"
  
  tags = var.common_tags
}

# Storage Container for application assets
resource "azurerm_storage_container" "assets" {
  name                  = "assets"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "blob"
}

# Key Vault for secrets management
resource "azurerm_key_vault" "main" {
  name                       = "${var.project_name}-${var.environment}-kv"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = var.environment == "production" ? true : false
  
  tags = var.common_tags
}

data "azurerm_client_config" "current" {}

# Grant App Service access to Key Vault
resource "azurerm_key_vault_access_policy" "app_service" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_web_app.main.identity[0].principal_id
  
  secret_permissions = [
    "Get",
    "List"
  ]
}
