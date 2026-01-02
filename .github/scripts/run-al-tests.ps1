#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Complete workflow to setup BC container, compile apps, and run AL tests

.DESCRIPTION
    This script orchestrates the complete test execution workflow:
    1. Sets up Business Central Docker container using BCDevOnLinux
    2. Downloads BC symbols
    3. Compiles the main App and Test App
    4. Publishes apps to the BC container
    5. Runs AL tests using the container

.PARAMETER BCDevRepo
    BCDevOnLinux repository URL (default: https://github.com/StefanMaron/BCDevOnLinux.git)

.PARAMETER BCDevBranch
    BCDevOnLinux repository branch (default: main)

.PARAMETER BCArtifactUrl
    BC Artifact URL to use for the container (optional, uses BCDevOnLinux defaults if not specified)

.PARAMETER ContainerName
    Name of the BC container (default: bcserver)

.PARAMETER Username
    BC admin username (default: admin)

.PARAMETER Password
    BC admin password (default: Pass@word1)

.PARAMETER CompanyName
    Company name to run tests against (default: My Company)

.PARAMETER SkipContainerSetup
    Skip container setup (assumes container is already running)

.PARAMETER SkipCompilation
    Skip app compilation (assumes apps are already compiled)

.PARAMETER SkipPublish
    Skip app publishing (assumes apps are already published)

.EXAMPLE
    # Full workflow with default settings
    ./run-al-tests.ps1

.EXAMPLE
    # Full workflow with specific BC version
    ./run-al-tests.ps1 -BCArtifactUrl "https://bcartifacts.azureedge.net/sandbox/27.1/w1"

.EXAMPLE
    # Skip container setup if already running
    ./run-al-tests.ps1 -SkipContainerSetup

.NOTES
    Requires Docker to be installed and running.
    For container setup, requires environment variables:
    - SA_PASSWORD: SQL Server SA password (optional, uses default if not set)
    - BC_USERNAME: Business Central admin username (optional, uses $Username if not set)
    - BC_PASSWORD: Business Central admin user password (optional, uses $Password if not set)
#>

param(
    [string]$BCDevRepo = "https://github.com/StefanMaron/BCDevOnLinux.git",
    [string]$BCDevBranch = "main",
    [string]$BCArtifactUrl = "",
    [string]$ContainerName = "bcserver",
    [string]$Username = "admin",
    [string]$Password = "Pass@word1",
    [string]$CompanyName = "My Company",
    [switch]$SkipContainerSetup,
    [switch]$SkipCompilation,
    [switch]$SkipPublish
)

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
$RepoRoot = Split-Path (Split-Path $ScriptDir -Parent) -Parent

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AL Test Execution Workflow" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set environment variables for BC container (if not already set)
if (-not $env:BC_USERNAME) {
    $env:BC_USERNAME = $Username
}
if (-not $env:BC_PASSWORD) {
    $env:BC_PASSWORD = $Password
}
if (-not $env:SA_PASSWORD) {
    $env:SA_PASSWORD = "Pass@word1234"
}

# Step 1: Setup BC Container
if (-not $SkipContainerSetup) {
    Write-Host "Step 1: Setting up Business Central Container" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Yellow
    
    Push-Location $RepoRoot
    try {
        $setupScript = Join-Path $ScriptDir "setup-bc-container.ps1"
        $params = @{
            BCDevRepo   = $BCDevRepo
            BCDevBranch = $BCDevBranch
        }
        if ($BCArtifactUrl) {
            $params['BCArtifactUrl'] = $BCArtifactUrl
        }
        
        & $setupScript @params
        if ($LASTEXITCODE -ne 0) {
            throw "Container setup failed with exit code: $LASTEXITCODE"
        }
    }
    finally {
        Pop-Location
    }
    
    Write-Host ""
    Write-Host "Step 2: Starting Business Central Container" -ForegroundColor Yellow
    Write-Host "===========================================" -ForegroundColor Yellow
    
    Push-Location $RepoRoot
    try {
        $startScript = Join-Path $ScriptDir "start-bc-container.ps1"
        & $startScript -MaxWaitSeconds 1200
        if ($LASTEXITCODE -ne 0) {
            throw "Container start failed with exit code: $LASTEXITCODE"
        }
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Host "Step 1-2: Skipping container setup (using existing container)" -ForegroundColor Gray
    
    # Verify container is running
    $containerStatus = docker ps --filter "name=$ContainerName" --format "{{.Status}}"
    if (-not $containerStatus) {
        Write-Host "ERROR: Container '$ContainerName' is not running" -ForegroundColor Red
        Write-Host "Remove -SkipContainerSetup flag to create and start the container" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "  Container '$ContainerName' is running: $containerStatus" -ForegroundColor Green
}

Write-Host ""

# Step 3: Setup .NET and AL Tools
Write-Host "Step 3: Setting up .NET and AL Development Tools" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Yellow

Push-Location $RepoRoot
try {
    $setupDotnetScript = Join-Path $ScriptDir "setup-dotnet-and-al.ps1"
    & $setupDotnetScript
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Warning: Setup script returned exit code $LASTEXITCODE, but continuing..." -ForegroundColor Yellow
    }
    
    # Ensure dotnet tools are in PATH for current session
    $dotnetToolsPath = Join-Path $HOME ".dotnet/tools"
    if (-not ($env:PATH -like "*$dotnetToolsPath*")) {
        $env:PATH = "$env:PATH$([System.IO.Path]::PathSeparator)$dotnetToolsPath"
        Write-Host "Added dotnet tools to PATH: $dotnetToolsPath" -ForegroundColor Gray
    }
}
finally {
    Pop-Location
}

Write-Host ""

# Step 4: Download BC Symbols
Write-Host "Step 4: Downloading Business Central Symbols" -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Yellow

Push-Location $RepoRoot
try {
    $downloadSymbolsScript = Join-Path $ScriptDir "download-bc-symbols.ps1"
    & $downloadSymbolsScript
    if ($LASTEXITCODE -ne 0) {
        throw "Symbol download failed with exit code: $LASTEXITCODE"
    }
}
finally {
    Pop-Location
}

Write-Host ""

# Step 5: Compile Apps
if (-not $SkipCompilation) {
    Write-Host "Step 5: Compiling AL Applications" -ForegroundColor Yellow
    Write-Host "===================================" -ForegroundColor Yellow
    
    Push-Location $RepoRoot
    try {
        $compileScript = Join-Path $ScriptDir "compile-al-apps.ps1"
        & $compileScript
        if ($LASTEXITCODE -ne 0) {
            throw "Compilation failed with exit code: $LASTEXITCODE"
        }
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Host "Step 5: Skipping app compilation (using existing compiled apps)" -ForegroundColor Gray
    
    # Verify compiled apps exist
    $appFile = Get-ChildItem -Path (Join-Path $RepoRoot "App") -Filter "*.app" -File | Select-Object -First 1
    $testAppFile = Get-ChildItem -Path (Join-Path $RepoRoot "Test") -Filter "*.app" -File | Select-Object -First 1
    
    if (-not $appFile -or -not $testAppFile) {
        Write-Host "ERROR: Compiled app files not found" -ForegroundColor Red
        Write-Host "Remove -SkipCompilation flag to compile the apps" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "  Found: $($appFile.Name)" -ForegroundColor Green
    Write-Host "  Found: $($testAppFile.Name)" -ForegroundColor Green
}

Write-Host ""

# Step 6: Publish Apps to Container
if (-not $SkipPublish) {
    Write-Host "Step 6: Publishing Apps to BC Container" -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Yellow
    
    Push-Location $RepoRoot
    try {
        $publishScript = Join-Path $ScriptDir "publish-apps-to-container.ps1"
        & $publishScript -Username $Username
        if ($LASTEXITCODE -ne 0) {
            throw "App publishing failed with exit code: $LASTEXITCODE"
        }
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Host "Step 6: Skipping app publishing (using existing published apps)" -ForegroundColor Gray
}

Write-Host ""

# Step 7: Run AL Tests
Write-Host "Step 7: Running AL Tests" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

Write-Host "Test execution via al-test-runner MCP server" -ForegroundColor Cyan
Write-Host ""
Write-Host "Container Configuration:" -ForegroundColor Gray
Write-Host "  Container Name: $ContainerName" -ForegroundColor Gray
Write-Host "  Username: $Username" -ForegroundColor Gray
Write-Host "  Company: $CompanyName" -ForegroundColor Gray
Write-Host "  Test Workspace: $(Join-Path $RepoRoot 'Test')" -ForegroundColor Gray
Write-Host ""
Write-Host "To run tests, use the al-test-runner MCP server with these parameters:" -ForegroundColor Yellow
Write-Host "  workspacePath: $(Join-Path $RepoRoot 'Test')" -ForegroundColor Gray
Write-Host "  containerName: $ContainerName" -ForegroundColor Gray
Write-Host "  userName: $Username" -ForegroundColor Gray
Write-Host "  password: $Password" -ForegroundColor Gray
Write-Host "  companyName: $CompanyName" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setup Complete - Ready for Testing" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Container is running and apps are published." -ForegroundColor Green
Write-Host "You can now run AL tests using the al-test-runner MCP server." -ForegroundColor Green
