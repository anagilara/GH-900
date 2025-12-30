# Production Environment Configuration
project_name    = "shopping-cart"
environment     = "production"
location        = "East US"
app_service_sku = "P1V2"

common_tags = {
  ManagedBy   = "Terraform"
  Project     = "Shopping Cart"
  Environment = "Production"
  CostCenter  = "Production"
}
