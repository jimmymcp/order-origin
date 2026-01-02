# Docker Container and AL Test Execution Guide

This guide provides complete instructions for creating a Docker container and running AL tests using the al-test-runner MCP server.

## Overview

The repository includes scripts and configuration for:
1. Setting up a Business Central Docker container using BCDevOnLinux
2. Compiling AL applications
3. Publishing apps to the container
4. Running AL tests using the al-test-runner MCP server

## Complete Workflow

### Step 1: Run the Setup Script

The `run-al-tests.ps1` script orchestrates the complete setup:

```powershell
pwsh ./.github/scripts/run-al-tests.ps1
```

This script:
1. Sets up BC Docker container using BCDevOnLinux
2. Starts the container and waits for it to become healthy (up to 20 minutes)
3. Installs .NET SDK and AL Language development tools
4. Downloads BC symbols from the container
5. Compiles the main App and Test App
6. Publishes apps to the BC container
7. Prepares for test execution

### Step 2: Use al-test-runner MCP Server

Once the container is running and apps are published, use the al-test-runner MCP server tools.

#### Get Test Configuration

Tool: `al-test-runner-get_test_configuration`

Parameters:
```json
{
  "workspacePath": "/path/to/order-origin/Test"
}
```

Returns:
- Test app metadata from app.json
- Container configuration from .altestrunner.json

#### Discover Tests

Tool: `al-test-runner-discover_al_tests`

Parameters:
```json
{
  "workspacePath": "/path/to/order-origin/Test"
}
```

Returns:
- List of test codeunits (Subtype = Test)
- Test methods in each codeunit ([Test] attribute)

Example Output:
```json
{
  "success": true,
  "testCodeunitsFound": 1,
  "totalTestMethods": 8,
  "testCodeunits": [
    {
      "id": 50251,
      "name": "Order Origin Tests",
      "filePath": "/path/to/Test/src/Tests/OrderOriginTests.Codeunit.al",
      "methods": [
        {"name": "OrderOriginCodeIsNotCopiedToQuote", "lineNumber": 13},
        {"name": "OrderOriginIsCopiedFromCustomerToSalesOrder", "lineNumber": 33},
        ...
      ]
    }
  ]
}
```

#### Run All Tests

Tool: `al-test-runner-run_al_tests`

Parameters:
```json
{
  "workspacePath": "/path/to/order-origin/Test",
  "containerName": "bcserver",
  "userName": "admin",
  "password": "Pass@word1",
  "companyName": "My Company"
}
```

#### Run Specific Test Codeunit

Tool: `al-test-runner-run_al_tests`

Parameters:
```json
{
  "workspacePath": "/path/to/order-origin/Test",
  "containerName": "bcserver",
  "userName": "admin",
  "password": "Pass@word1",
  "companyName": "My Company",
  "codeunitId": 50251
}
```

#### Run Specific Test Method

Tool: `al-test-runner-run_al_tests`

Parameters:
```json
{
  "workspacePath": "/path/to/order-origin/Test",
  "containerName": "bcserver",
  "userName": "admin",
  "password": "Pass@word1",
  "companyName": "My Company",
  "codeunitId": 50251,
  "methodName": "OrderOriginIsCopiedFromCustomerToSalesOrder"
}
```

## Configuration Files

### .altestrunner.json (Test folder)

Defines default container connection settings:

```json
{
    "containerName": "bcserver",
    "userName": "admin",
    "password": "Pass@word1",
    "companyName": "My Company"
}
```

### app.json (Test folder)

Defines the test app metadata and dependencies:

```json
{
  "id": "16f4bfb2-7be2-4d00-90f8-001547492522",
  "name": "Order Origin Tests",
  "publisher": "James Pearson",
  "version": "1.0.0.0",
  "dependencies": [
    {
      "id": "dd0be2ea-f733-4d65-bb34-a28f4624fb14",
      "publisher": "Microsoft",
      "name": "Library Assert",
      "version": "21.0.0.0"
    },
    {
      "id": "5d86850b-0d76-4eca-bd7b-951ad998e997",
      "publisher": "Microsoft",
      "name": "Tests-TestLibraries",
      "version": "21.0.0.0"
    },
    {
      "id": "c7f567b5-8d5b-40a4-bda1-d4126071b2d7",
      "name": "Order Origin",
      "publisher": "James Pearson",
      "version": "1.0.0.0"
    }
  ]
}
```

## Test Codeunits

### Order Origin Tests (50251)

Located: `Test/src/Tests/OrderOriginTests.Codeunit.al`

Test Methods:
1. `OrderOriginCodeIsNotCopiedToQuote` - Verifies order origin is not copied to quotes
2. `OrderOriginIsCopiedFromCustomerToSalesOrder` - Verifies order origin is copied from customer to sales order
3. `OrderOriginIsCopiedFromCustomerToSalesCreditMemo` - Verifies order origin is copied to credit memos
4. `ReleasingSalesOrderWithoutOrderOriginThrowsError` - Validates error handling
5. `ReleasingSalesOrderWithOrderOrigin` - Tests releasing orders with order origin
6. `PostingSalesOrderCopiesOrderOriginToSalesInvoice` - Verifies order origin on posted invoices
7. `OrderOriginCodeIsClearedAfterCopySalesDocument` - Tests document copy behavior
8. `PostCorrectiveCreditAndCreateNewInvoice` - Tests corrective credit memo workflow

## Advanced Options

### Skip Container Setup (for faster iteration)

If the container is already running:

```powershell
pwsh ./.github/scripts/run-al-tests.ps1 -SkipContainerSetup
```

### Skip Compilation

If apps are already compiled:

```powershell
pwsh ./.github/scripts/run-al-tests.ps1 -SkipContainerSetup -SkipCompilation
```

### Skip Publishing

If apps are already published:

```powershell
pwsh ./.github/scripts/run-al-tests.ps1 -SkipContainerSetup -SkipCompilation -SkipPublish
```

### Specify BC Version

To use a specific BC version:

```powershell
pwsh ./.github/scripts/run-al-tests.ps1 -BCArtifactUrl "https://bcartifacts.azureedge.net/sandbox/27.1/w1"
```

## Environment Variables

Override defaults with environment variables:

```powershell
$env:BC_USERNAME = "myuser"
$env:BC_PASSWORD = "MySecurePassword123!"
$env:SA_PASSWORD = "MySqlPassword123!"
pwsh ./.github/scripts/run-al-tests.ps1
```

## Container Management

### View Container Status

```bash
cd bcdev-temp
docker compose ps
```

### View Logs

```bash
cd bcdev-temp
docker compose logs -f bc
```

### Stop Container

```bash
cd bcdev-temp
docker compose down
```

### Restart Container

```bash
cd bcdev-temp
docker compose restart
```

### Full Cleanup

```bash
cd bcdev-temp
docker compose down -v
cd ..
rm -rf bcdev-temp
```

## Troubleshooting

### Container Takes Long to Start
- BC containers can take 10-20 minutes to become healthy
- Large artifacts need to be downloaded (platform + application)
- Database initialization takes time

### Database Connection Errors
- Ensure SQL container is healthy: `docker ps`
- Check SQL logs: `docker compose logs sql`
- Verify network connectivity between containers

### Compilation Errors
- Ensure symbols are downloaded: Check `.alpackages` directory
- Verify dependencies in app.json match available symbols
- Run symbol download again: `pwsh ./.github/scripts/download-bc-symbols.ps1`

### Publishing Errors
- Verify container is healthy: `docker ps`
- Check API is accessible: `curl http://localhost:7049/BC/dev/apps`
- Ensure credentials are correct
- Check container logs for errors

### Test Execution Errors
- Verify apps are published in the container
- Ensure test toolkit is installed (IMPORT_TEST_TOOLKIT=true)
- Check .altestrunner.json configuration
- Verify company name exists in BC

## Demonstration Script

A demonstration script is provided to show al-test-runner usage:

```powershell
pwsh ./.github/scripts/demonstrate-al-test-runner.ps1
```

This script:
- Shows how to use each al-test-runner MCP server tool
- Displays current configuration
- Lists available test codeunits and methods
- Provides example parameters for test execution

## Summary

The complete workflow for running AL tests:

1. **Setup Container**: Run `run-al-tests.ps1` to set up BC container, compile, and publish apps
2. **Discover Tests**: Use `discover_al_tests` tool to scan test codeunits and methods
3. **Run Tests**: Use `run_al_tests` tool to execute tests
4. **Review Results**: Check test results returned by the MCP server

The al-test-runner MCP server provides three main tools:
- `get_test_configuration` - Retrieve test configuration
- `discover_al_tests` - Scan for test codeunits and methods
- `run_al_tests` - Execute tests in BC container

All tools work with the Test workspace path and container configuration defined in `.altestrunner.json`.
