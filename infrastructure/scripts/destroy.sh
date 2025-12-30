#!/bin/bash

# Destroy Infrastructure Script
# Usage: ./destroy.sh <environment>
# Example: ./destroy.sh development

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
    echo "Usage: ./destroy.sh <environment>"
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

# Extra confirmation for production
if [ "$ENVIRONMENT" == "production" ]; then
    print_warning "⚠️  WARNING: You are about to destroy PRODUCTION infrastructure! ⚠️"
    read -p "Type 'destroy-production' to confirm: " PROD_CONFIRM
    
    if [ "$PROD_CONFIRM" != "destroy-production" ]; then
        print_info "Destruction cancelled"
        exit 0
    fi
fi

# Check if tfvars file exists
if [ ! -f "$TFVARS_FILE" ]; then
    print_error "Environment file not found: $TFVARS_FILE"
    exit 1
fi

print_warning "Starting infrastructure destruction for environment: $ENVIRONMENT"

# Navigate to Terraform directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"
cd "$TERRAFORM_DIR"

# Create destroy plan
print_info "Creating destroy plan..."
terraform plan -destroy -var-file="$TFVARS_FILE"

# Prompt for confirmation
print_warning "Please review the destroy plan above."
read -p "Are you sure you want to destroy all resources? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    print_info "Destruction cancelled by user"
    exit 0
fi

# Destroy infrastructure
print_info "Destroying infrastructure..."
terraform destroy -var-file="$TFVARS_FILE" -auto-approve

if [ $? -eq 0 ]; then
    print_info "Infrastructure destroyed successfully ✓"
else
    print_error "Destruction failed"
    exit 1
fi

print_info "Destruction process completed"
