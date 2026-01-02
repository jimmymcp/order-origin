#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Demonstration script for running AL tests using the al-test-runner MCP server

.DESCRIPTION
    This script demonstrates how to use the al-test-runner MCP server tools
    to discover and run AL tests in a Business Central container.
    
    This is a documentation/example script. The actual test execution is performed
    using the al-test-runner MCP server tools which are available through the
    GitHub Coding Agent.

.PARAMETER WorkspacePath
    Path to the Test workspace (default: ./Test)

.PARAMETER ContainerName
    Name of the BC container (default: bcserver)

.PARAMETER Username
    BC admin username (default: admin)

.PARAMETER Password
    BC admin password (default: Pass@word1)

.PARAMETER CompanyName
    Company name to run tests against (default: My Company)

.EXAMPLE
    ./demonstrate-al-test-runner.ps1

.NOTES
    This script provides example commands and parameter values for using
    the al-test-runner MCP server. The actual execution happens through
    the MCP server tools in the GitHub Coding Agent environment.
#>

param(
    [string]$WorkspacePath = "./Test",
    [string]$ContainerName = "bcserver",
    [string]$Username = "admin",
    [string]$Password = "Pass@word1",
    [string]$CompanyName = "My Company"
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$TestWorkspacePath = Join-Path $RepoRoot $WorkspacePath -Resolve

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AL Test Runner MCP Server Demonstration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script demonstrates how to use the al-test-runner MCP server" -ForegroundColor Yellow
Write-Host "to discover and execute AL tests in a Business Central container." -ForegroundColor Yellow
Write-Host ""

# Step 1: Get Test Configuration
Write-Host "Step 1: Get Test Configuration" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Use the 'get_test_configuration' tool with these parameters:" -ForegroundColor White
Write-Host ""
Write-Host "  Tool: al-test-runner-get_test_configuration" -ForegroundColor Gray
Write-Host "  Parameters:" -ForegroundColor Gray
Write-Host "    workspacePath: $TestWorkspacePath" -ForegroundColor Gray
Write-Host ""
Write-Host "This retrieves configuration from:" -ForegroundColor White
Write-Host "  - .altestrunner.json (container name, credentials, company)" -ForegroundColor Gray
Write-Host "  - app.json (test app metadata, dependencies)" -ForegroundColor Gray
Write-Host ""

# Step 2: Discover Tests
Write-Host "Step 2: Discover Tests" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Use the 'discover_al_tests' tool with these parameters:" -ForegroundColor White
Write-Host ""
Write-Host "  Tool: al-test-runner-discover_al_tests" -ForegroundColor Gray
Write-Host "  Parameters:" -ForegroundColor Gray
Write-Host "    workspacePath: $TestWorkspacePath" -ForegroundColor Gray
Write-Host ""
Write-Host "This scans for:" -ForegroundColor White
Write-Host "  - Test codeunits (Subtype = Test)" -ForegroundColor Gray
Write-Host "  - Test methods ([Test] attribute)" -ForegroundColor Gray
Write-Host ""
Write-Host "Expected output: List of test codeunits and their test methods" -ForegroundColor White
Write-Host ""

# Step 3: Run All Tests
Write-Host "Step 3: Run All Tests" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Use the 'run_al_tests' tool with these parameters:" -ForegroundColor White
Write-Host ""
Write-Host "  Tool: al-test-runner-run_al_tests" -ForegroundColor Gray
Write-Host "  Parameters:" -ForegroundColor Gray
Write-Host "    workspacePath: $TestWorkspacePath" -ForegroundColor Gray
Write-Host "    containerName: $ContainerName" -ForegroundColor Gray
Write-Host "    userName: $Username" -ForegroundColor Gray
Write-Host "    password: $Password" -ForegroundColor Gray
Write-Host "    companyName: $CompanyName" -ForegroundColor Gray
Write-Host ""
Write-Host "This executes all tests in the Test workspace." -ForegroundColor White
Write-Host ""

# Step 4: Run Specific Test Codeunit
Write-Host "Step 4: Run Specific Test Codeunit" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Use the 'run_al_tests' tool with a codeunit ID:" -ForegroundColor White
Write-Host ""
Write-Host "  Tool: al-test-runner-run_al_tests" -ForegroundColor Gray
Write-Host "  Parameters:" -ForegroundColor Gray
Write-Host "    workspacePath: $TestWorkspacePath" -ForegroundColor Gray
Write-Host "    containerName: $ContainerName" -ForegroundColor Gray
Write-Host "    userName: $Username" -ForegroundColor Gray
Write-Host "    password: $Password" -ForegroundColor Gray
Write-Host "    companyName: $CompanyName" -ForegroundColor Gray
Write-Host "    codeunitId: 50251  # Order Origin Tests" -ForegroundColor Gray
Write-Host ""
Write-Host "This executes all tests in the specified codeunit." -ForegroundColor White
Write-Host ""

# Step 5: Run Specific Test Method
Write-Host "Step 5: Run Specific Test Method" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Use the 'run_al_tests' tool with codeunit ID and method name:" -ForegroundColor White
Write-Host ""
Write-Host "  Tool: al-test-runner-run_al_tests" -ForegroundColor Gray
Write-Host "  Parameters:" -ForegroundColor Gray
Write-Host "    workspacePath: $TestWorkspacePath" -ForegroundColor Gray
Write-Host "    containerName: $ContainerName" -ForegroundColor Gray
Write-Host "    userName: $Username" -ForegroundColor Gray
Write-Host "    password: $Password" -ForegroundColor Gray
Write-Host "    companyName: $CompanyName" -ForegroundColor Gray
Write-Host "    codeunitId: 50251" -ForegroundColor Gray
Write-Host "    methodName: OrderOriginIsCopiedFromCustomerToSalesOrder" -ForegroundColor Gray
Write-Host ""
Write-Host "This executes only the specified test method." -ForegroundColor White
Write-Host ""

# Configuration Details
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuration Details" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Test Workspace:" -ForegroundColor Yellow
Write-Host "  Path: $TestWorkspacePath" -ForegroundColor Gray
if (Test-Path (Join-Path $TestWorkspacePath ".altestrunner.json")) {
    Write-Host "  ✓ .altestrunner.json found" -ForegroundColor Green
    $config = Get-Content (Join-Path $TestWorkspacePath ".altestrunner.json") | ConvertFrom-Json
    Write-Host "    Container: $($config.containerName)" -ForegroundColor Gray
    Write-Host "    Username: $($config.userName)" -ForegroundColor Gray
    Write-Host "    Company: $($config.companyName)" -ForegroundColor Gray
}
else {
    Write-Host "  ⚠ .altestrunner.json not found" -ForegroundColor Yellow
}

if (Test-Path (Join-Path $TestWorkspacePath "app.json")) {
    Write-Host "  ✓ app.json found" -ForegroundColor Green
    $appJson = Get-Content (Join-Path $TestWorkspacePath "app.json") | ConvertFrom-Json
    Write-Host "    Name: $($appJson.name)" -ForegroundColor Gray
    Write-Host "    Version: $($appJson.version)" -ForegroundColor Gray
    Write-Host "    Dependencies: $($appJson.dependencies.Count)" -ForegroundColor Gray
}
else {
    Write-Host "  ⚠ app.json not found" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "Container Connection:" -ForegroundColor Yellow
Write-Host "  Container Name: $ContainerName" -ForegroundColor Gray
Write-Host "  Username: $Username" -ForegroundColor Gray
Write-Host "  Password: ********" -ForegroundColor Gray
Write-Host "  Company: $CompanyName" -ForegroundColor Gray
Write-Host ""

Write-Host "Test Codeunits:" -ForegroundColor Yellow
$testFiles = Get-ChildItem -Path (Join-Path $TestWorkspacePath "src") -Filter "*.al" -Recurse
$testCodeunits = @()
foreach ($file in $testFiles) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match 'codeunit\s+(\d+)\s+"([^"]+)"\s+{\s+Subtype\s*=\s*Test') {
        $codeunitId = $matches[1]
        $codeunitName = $matches[2]
        $testCodeunits += [PSCustomObject]@{
            Id   = $codeunitId
            Name = $codeunitName
            File = $file.Name
        }
    }
}

if ($testCodeunits.Count -gt 0) {
    foreach ($codeunit in $testCodeunits) {
        Write-Host "  ✓ $($codeunit.Id): $($codeunit.Name)" -ForegroundColor Green
        Write-Host "    File: $($codeunit.File)" -ForegroundColor Gray
    }
}
else {
    Write-Host "  ⚠ No test codeunits found" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Ready for Test Execution" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Use the parameter values shown above with the al-test-runner MCP server tools." -ForegroundColor White
Write-Host ""
Write-Host "Available Tools:" -ForegroundColor Yellow
Write-Host "  1. al-test-runner-get_test_configuration" -ForegroundColor Gray
Write-Host "  2. al-test-runner-discover_al_tests" -ForegroundColor Gray
Write-Host "  3. al-test-runner-run_al_tests" -ForegroundColor Gray
Write-Host ""
