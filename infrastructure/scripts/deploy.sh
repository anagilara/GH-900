#!/bin/bash

# Deploy Infrastructure Script
# Usage: ./deploy.sh <environment>
# Example: ./deploy.sh development

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if environment parameter is provided
if [ -z "$1" ]; then
    print_error "Environment parameter is required"
    echo "Usage: ./deploy.sh <environment>"
    echo "Available environments: development, staging, production"
    exit 1
fi

ENVIRONMENT=$1
TFVARS_FILE="environments/${ENVIRONMENT}.tfvars"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT"
    echo "Available environments: development, staging, production"
    exit 1
fi

# Check if tfvars file exists
if [ ! -f "$TFVARS_FILE" ]; then
    print_error "Environment file not found: $TFVARS_FILE"
    exit 1
fi

print_info "Starting deployment for environment: $ENVIRONMENT"

# Check prerequisites
print_info "Checking prerequisites..."

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install Terraform first."
    exit 1
fi

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install Azure CLI first."
    exit 1
fi

# Check Azure login status
print_info "Checking Azure authentication..."
if ! az account show &> /dev/null; then
    print_error "Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

print_info "Prerequisites check passed ✓"

# Navigate to Terraform directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"
cd "$TERRAFORM_DIR"

# Initialize Terraform
print_info "Initializing Terraform..."
terraform init

# Validate Terraform configuration
print_info "Validating Terraform configuration..."
terraform validate

if [ $? -ne 0 ]; then
    print_error "Terraform validation failed"
    exit 1
fi

print_info "Terraform configuration is valid ✓"

# Format Terraform files
print_info "Formatting Terraform files..."
terraform fmt -recursive

# Create Terraform plan
print_info "Creating Terraform plan..."
terraform plan -var-file="$TFVARS_FILE" -out=tfplan

# Prompt for confirmation
print_warning "Please review the plan above."
read -p "Do you want to apply this plan? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    print_info "Deployment cancelled by user"
    rm -f tfplan
    exit 0
fi

# Apply Terraform plan
print_info "Applying Terraform plan..."
terraform apply tfplan

if [ $? -eq 0 ]; then
    print_info "Deployment completed successfully! ✓"
    
    # Show outputs
    print_info "Infrastructure outputs:"
    terraform output
    
    # Save outputs to file
    OUTPUT_FILE="outputs-${ENVIRONMENT}.txt"
    terraform output > "$OUTPUT_FILE"
    print_info "Outputs saved to: $OUTPUT_FILE"
else
    print_error "Deployment failed"
    exit 1
fi

# Cleanup
rm -f tfplan

print_info "Deployment process completed"
