variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "shopping-cart"
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "development"
  
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "app_service_sku" {
  description = "SKU for App Service Plan"
  type        = string
  default     = "B1"
  
  validation {
    condition     = contains(["B1", "B2", "B3", "S1", "S2", "S3", "P1V2", "P2V2", "P3V2"], var.app_service_sku)
    error_message = "Invalid App Service SKU."
  }
}

variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
  default     = "sqladmin"
  sensitive   = true
}

variable "sql_admin_password" {
  description = "SQL Server administrator password (required if SQL Server is enabled)"
  type        = string
  sensitive   = true
  default     = ""
  
  validation {
    condition     = var.sql_admin_password == "" || (length(var.sql_admin_password) >= 8 && can(regex("[A-Z]", var.sql_admin_password)) && can(regex("[a-z]", var.sql_admin_password)) && can(regex("[0-9]", var.sql_admin_password)) && can(regex("[^A-Za-z0-9]", var.sql_admin_password)))
    error_message = "Password must be at least 8 characters and contain uppercase, lowercase, numeric, and special characters."
  }
}

variable "sql_sku_name" {
  description = "SKU for SQL Database"
  type        = string
  default     = "Basic"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "Shopping Cart"
  }
}
