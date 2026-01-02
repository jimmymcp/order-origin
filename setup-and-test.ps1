#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Creates a Business Central container and runs AL tests
.DESCRIPTION
    This script sets up a Business Central Docker container using BcContainerHelper
    and runs the AL tests from the Test folder.
#>

param(
    [string]$containerName = "bcserver",
    [string]$accept_eula = "Y",
    [string]$auth = "UserPassword",
    [string]$username = "admin",
    [string]$password = "P@ssw0rd"
)

# Import BcContainerHelper module
Write-Host "Importing BcContainerHelper module..." -ForegroundColor Green
Import-Module BcContainerHelper -WarningAction SilentlyContinue

# Set accept EULA
$accept_eula = $true

# Container parameters
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)

# Get artifact URL for BC version 25.0
Write-Host "Getting artifact URL for Business Central version 25.0..." -ForegroundColor Green
$artifactUrl = Get-BCArtifactUrl -type OnPrem -version "25.0" -country "gb" -select Latest

if (-not $artifactUrl) {
    Write-Error "Failed to get artifact URL"
    exit 1
}

Write-Host "Using artifact URL: $artifactUrl" -ForegroundColor Cyan

# Check if container already exists
$existingContainer = docker ps -a --filter "name=^${containerName}$" --format "{{.Names}}"
if ($existingContainer) {
    Write-Host "Container '$containerName' already exists. Removing it..." -ForegroundColor Yellow
    docker rm -f $containerName | Out-Null
}

# Create the container
Write-Host "Creating Business Central container '$containerName'..." -ForegroundColor Green
Write-Host "This may take several minutes..." -ForegroundColor Yellow

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
    Write-Host "`nContainer Information:" -ForegroundColor Cyan
    Get-BcContainerEventLog -containerName $containerName -doNotOpen | Select-Object -Last 20
    
    # Compile and publish the main app
    Write-Host "`nCompiling and publishing Order Origin app..." -ForegroundColor Green
    $appFolder = Join-Path $PSScriptRoot "App"
    Compile-AppInBcContainer -containerName $containerName -credential $credential -appProjectFolder $appFolder -appOutputFolder "output" -EnableCodeCop -EnableAppSourceCop -EnableUICop -EnablePerTenantExtensionCop
    
    $appFile = Get-ChildItem -Path "output" -Filter "*.app" | Select-Object -First 1
    if ($appFile) {
        Publish-BcContainerApp -containerName $containerName -appFile $appFile.FullName -sync -install -credential $credential
        Write-Host "App published successfully!" -ForegroundColor Green
    }
    
    # Compile and publish the test app
    Write-Host "`nCompiling and publishing Order Origin Tests app..." -ForegroundColor Green
    $testFolder = Join-Path $PSScriptRoot "Test"
    Compile-AppInBcContainer -containerName $containerName -credential $credential -appProjectFolder $testFolder -appOutputFolder "output" -EnableCodeCop -EnableAppSourceCop -EnableUICop -EnablePerTenantExtensionCop
    
    $testAppFile = Get-ChildItem -Path "output" -Filter "*Test*.app" | Select-Object -First 1
    if ($testAppFile) {
        Publish-BcContainerApp -containerName $containerName -appFile $testAppFile.FullName -sync -install -credential $credential
        Write-Host "Test app published successfully!" -ForegroundColor Green
    }
    
    # Run tests
    Write-Host "`nRunning tests..." -ForegroundColor Green
    $testResults = Run-TestsInBcContainer -containerName $containerName -credential $credential -detailed -returnTrueIfAllPassed
    
    if ($testResults) {
        Write-Host "`nAll tests passed!" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "`nSome tests failed!" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Error "Error: $_"
    Write-Host "Container logs:" -ForegroundColor Yellow
    Get-BcContainerEventLog -containerName $containerName -doNotOpen | Select-Object -Last 50
    exit 1
}
