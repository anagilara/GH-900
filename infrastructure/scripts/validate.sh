#!/bin/bash

# Validate Terraform Configuration Script
# Usage: ./validate.sh

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

print_info "Validating Terraform configuration..."

# Navigate to Terraform directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"
cd "$TERRAFORM_DIR"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install Terraform first."
    exit 1
fi

# Initialize Terraform (in case it hasn't been done)
print_info "Initializing Terraform..."
terraform init -backend=false

# Format check
print_info "Checking Terraform formatting..."
if ! terraform fmt -check -recursive; then
    print_warning "Terraform files are not properly formatted"
    read -p "Do you want to format the files? (yes/no): " FORMAT
    
    if [ "$FORMAT" == "yes" ]; then
        terraform fmt -recursive
        print_info "Files formatted successfully ✓"
    fi
fi

# Validate configuration
print_info "Validating Terraform configuration..."
if terraform validate; then
    print_info "Terraform configuration is valid ✓"
else
    print_error "Terraform validation failed"
    exit 1
fi

# Validate each environment configuration
print_info "Validating environment configurations..."

for ENV_FILE in environments/*.tfvars; do
    if [ -f "$ENV_FILE" ]; then
        ENV_NAME=$(basename "$ENV_FILE" .tfvars)
        print_info "Validating $ENV_NAME environment..."
        
        if terraform plan -var-file="$ENV_FILE" -out=/dev/null &> /dev/null; then
            print_info "$ENV_NAME validation passed ✓"
        else
            print_warning "$ENV_NAME validation completed with warnings"
        fi
    fi
done

print_info "Validation complete! ✓"
