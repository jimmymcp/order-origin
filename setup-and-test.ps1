#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Creates a Business Central container and runs AL tests
.DESCRIPTION
    This script sets up a Business Central Docker container using BcContainerHelper
    and runs the AL tests from the Test folder.
    
    Prerequisites:
    - Docker must be installed and running
    - Internet access to download BC artifacts (or provide a local artifact URL)
    - BcContainerHelper PowerShell module must be installed
    
.PARAMETER containerName
    Name for the Business Central container
.PARAMETER artifactUrl
    (Optional) URL to Business Central artifacts. If not provided, will attempt to download latest
.PARAMETER accept_eula
    Accept the Microsoft EULA for Business Central
.PARAMETER auth
    Authentication type (UserPassword or Windows)
.PARAMETER username
    Username for container authentication
.PARAMETER password
    Password for container authentication

.EXAMPLE
    # Create container with latest BC 25.0 artifacts
    ./setup-and-test.ps1
    
.EXAMPLE
    # Create container with specific artifact URL (e.g., from local cache)
    ./setup-and-test.ps1 -artifactUrl "https://bcartifacts.azureedge.net/onprem/25.0.0.0/gb"
#>

param(
    [string]$containerName = "bcserver",
    [string]$artifactUrl = "",
    [switch]$accept_eula = $true,
    [string]$auth = "UserPassword",
    [string]$username = "admin",
    [string]$password = "P@ssw0rd"
)

# Import BcContainerHelper module
Write-Host "Importing BcContainerHelper module..." -ForegroundColor Green
try {
    Import-Module BcContainerHelper -ErrorAction Stop -WarningAction SilentlyContinue
    Write-Host "BcContainerHelper module imported successfully" -ForegroundColor Green
} catch {
    Write-Error "Failed to import BcContainerHelper module. Please install it first:"
    Write-Error "  Install-Module -Name BcContainerHelper -Force"
    exit 1
}

# Container parameters
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)

# Get artifact URL if not provided
if (-not $artifactUrl) {
    Write-Host "Getting artifact URL for Business Central version 25.0..." -ForegroundColor Green
    Write-Host "Note: This requires internet access to download BC artifacts" -ForegroundColor Yellow
    
    try {
        $artifactUrl = Get-BCArtifactUrl -type OnPrem -version "25.0" -country "gb" -select Latest -ErrorAction Stop
        Write-Host "Using artifact URL: $artifactUrl" -ForegroundColor Cyan
    } catch {
        Write-Error "Failed to get artifact URL. You may need to provide a local artifact URL:"
        Write-Error "  ./setup-and-test.ps1 -artifactUrl 'https://your-artifact-url'"
        Write-Error "Or ensure internet access is available to download artifacts"
        exit 1
    }
} else {
    Write-Host "Using provided artifact URL: $artifactUrl" -ForegroundColor Cyan
}

# Check if container already exists
Write-Host "Checking for existing container..." -ForegroundColor Green
$existingContainer = docker ps -a --filter "name=^${containerName}$" --format "{{.Names}}"
if ($existingContainer) {
    Write-Host "Container '$containerName' already exists. Removing it..." -ForegroundColor Yellow
    docker rm -f $containerName | Out-Null
    Write-Host "Container removed" -ForegroundColor Green
}

# Create the container
Write-Host "`nCreating Business Central container '$containerName'..." -ForegroundColor Green
Write-Host "This may take 10-20 minutes depending on your network speed..." -ForegroundColor Yellow

$containerParams = @{
    accept_eula = $accept_eula
    containerName = $containerName
    auth = $auth
    Credential = $credential
    artifactUrl = $artifactUrl
    updateHosts = $false
    isolation = "process"
    memoryLimit = "8G"
    includeTestToolkit = $true
    includeTestLibrariesOnly = $true
    doNotExportObjectsToText = $true
    shortcuts = "None"
}

try {
    New-BcContainer @containerParams
    
    Write-Host "`nContainer created successfully!" -ForegroundColor Green
    
    # Get container information
    Write-Host "`nGetting container information..." -ForegroundColor Cyan
    $containerInfo = Get-BcContainerEventLog -containerName $containerName -doNotOpen | Select-Object -Last 10
    $containerInfo | ForEach-Object { Write-Host $_ }
    
    # Create output directory for compiled apps
    $outputPath = Join-Path $PSScriptRoot "output"
    if (Test-Path $outputPath) {
        Remove-Item $outputPath -Recurse -Force
    }
    New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
    
    # Compile and publish the main app
    Write-Host "`nCompiling and publishing Order Origin app..." -ForegroundColor Green
    $appFolder = Join-Path $PSScriptRoot "App"
    
    Compile-AppInBcContainer `
        -containerName $containerName `
        -credential $credential `
        -appProjectFolder $appFolder `
        -appOutputFolder $outputPath `
        -EnableCodeCop `
        -EnableAppSourceCop `
        -EnableUICop `
        -EnablePerTenantExtensionCop
    
    $appFile = Get-ChildItem -Path $outputPath -Filter "*.app" | Where-Object { $_.Name -notlike "*Test*" } | Select-Object -First 1
    if ($appFile) {
        Write-Host "Publishing app: $($appFile.Name)" -ForegroundColor Cyan
        Publish-BcContainerApp `
            -containerName $containerName `
            -appFile $appFile.FullName `
            -sync `
            -install `
            -credential $credential `
            -skipVerification
        Write-Host "App published successfully!" -ForegroundColor Green
    } else {
        Write-Error "Failed to compile the main app"
        exit 1
    }
    
    # Compile and publish the test app
    Write-Host "`nCompiling and publishing Order Origin Tests app..." -ForegroundColor Green
    $testFolder = Join-Path $PSScriptRoot "Test"
    
    Compile-AppInBcContainer `
        -containerName $containerName `
        -credential $credential `
        -appProjectFolder $testFolder `
        -appOutputFolder $outputPath `
        -EnableCodeCop `
        -EnableAppSourceCop `
        -EnableUICop `
        -EnablePerTenantExtensionCop
    
    $testAppFile = Get-ChildItem -Path $outputPath -Filter "*Test*.app" | Select-Object -First 1
    if ($testAppFile) {
        Write-Host "Publishing test app: $($testAppFile.Name)" -ForegroundColor Cyan
        Publish-BcContainerApp `
            -containerName $containerName `
            -appFile $testAppFile.FullName `
            -sync `
            -install `
            -credential $credential `
            -skipVerification
        Write-Host "Test app published successfully!" -ForegroundColor Green
    } else {
        Write-Error "Failed to compile the test app"
        exit 1
    }
    
    # Run tests
    Write-Host "`nRunning tests..." -ForegroundColor Green
    Write-Host "Test codeunit: Order Origin Tests (ID: 50251)" -ForegroundColor Cyan
    
    $testResults = Run-TestsInBcContainer `
        -containerName $containerName `
        -credential $credential `
        -detailed `
        -AzureDevOps None `
        -returnTrueIfAllPassed
    
    Write-Host "`nTest Results:" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    
    if ($testResults) {
        Write-Host "✓ All tests passed successfully!" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "✗ Some tests failed" -ForegroundColor Red
        Write-Host "Check the output above for details" -ForegroundColor Yellow
        exit 1
    }
    
} catch {
    Write-Error "Error occurred: $_"
    Write-Host "`nAttempting to get container logs..." -ForegroundColor Yellow
    try {
        $logs = Get-BcContainerEventLog -containerName $containerName -doNotOpen | Select-Object -Last 50
        $logs | ForEach-Object { Write-Host $_ }
    } catch {
        Write-Host "Could not retrieve container logs" -ForegroundColor Red
    }
    exit 1
} finally {
    Write-Host "`n============================================" -ForegroundColor Cyan
    Write-Host "Container '$containerName' is still running" -ForegroundColor Yellow
    Write-Host "To remove it, run: docker rm -f $containerName" -ForegroundColor Yellow
    Write-Host "============================================" -ForegroundColor Cyan
}
