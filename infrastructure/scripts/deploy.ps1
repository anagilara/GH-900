# Deploy Infrastructure Script (PowerShell)
# Usage: .\deploy.ps1 -Environment <environment>
# Example: .\deploy.ps1 -Environment development

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("development", "staging", "production")]
    [string]$Environment
)

$ErrorActionPreference = "Stop"

# Function to print colored output
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

Write-Info "Starting deployment for environment: $Environment"

$TfvarsFile = "environments\$Environment.tfvars"

# Check if tfvars file exists
if (-not (Test-Path $TfvarsFile)) {
    Write-Error-Custom "Environment file not found: $TfvarsFile"
    exit 1
}

# Check prerequisites
Write-Info "Checking prerequisites..."

# Check if Terraform is installed
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Error-Custom "Terraform is not installed. Please install Terraform first."
    exit 1
}

# Check if Azure CLI is installed
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error-Custom "Azure CLI is not installed. Please install Azure CLI first."
    exit 1
}

# Check Azure login status
Write-Info "Checking Azure authentication..."
try {
    az account show | Out-Null
} catch {
    Write-Error-Custom "Not logged in to Azure. Please run 'az login' first."
    exit 1
}

Write-Info "Prerequisites check passed ✓"

# Navigate to Terraform directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TerraformDir = Join-Path $ScriptDir "..\terraform"
Set-Location $TerraformDir

# Initialize Terraform
Write-Info "Initializing Terraform..."
terraform init

# Validate Terraform configuration
Write-Info "Validating Terraform configuration..."
terraform validate

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Terraform validation failed"
    exit 1
}

Write-Info "Terraform configuration is valid ✓"

# Format Terraform files
Write-Info "Formatting Terraform files..."
terraform fmt -recursive

# Create Terraform plan
Write-Info "Creating Terraform plan..."
terraform plan -var-file="$TfvarsFile" -out=tfplan

# Prompt for confirmation
Write-Warning-Custom "Please review the plan above."
$Confirm = Read-Host "Do you want to apply this plan? (yes/no)"

if ($Confirm -ne "yes") {
    Write-Info "Deployment cancelled by user"
    Remove-Item tfplan -ErrorAction SilentlyContinue
    exit 0
}

# Apply Terraform plan
Write-Info "Applying Terraform plan..."
terraform apply tfplan

if ($LASTEXITCODE -eq 0) {
    Write-Info "Deployment completed successfully! ✓"
    
    # Show outputs
    Write-Info "Infrastructure outputs:"
    terraform output
    
    # Save outputs to file
    $OutputFile = "outputs-$Environment.txt"
    terraform output | Out-File $OutputFile
    Write-Info "Outputs saved to: $OutputFile"
} else {
    Write-Error-Custom "Deployment failed"
    exit 1
}

# Cleanup
Remove-Item tfplan -ErrorAction SilentlyContinue

Write-Info "Deployment process completed"
