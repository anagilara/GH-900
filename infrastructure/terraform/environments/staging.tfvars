# Staging Environment Configuration
project_name    = "shopping-cart"
environment     = "staging"
location        = "East US"
app_service_sku = "S1"

common_tags = {
  ManagedBy   = "Terraform"
  Project     = "Shopping Cart"
  Environment = "Staging"
  CostCenter  = "QA"
}
