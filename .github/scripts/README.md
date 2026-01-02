# AL Test Execution Scripts

This directory contains scripts for setting up a Business Central Docker container and running AL tests.

## Overview

The main entry point is `run-al-tests.ps1`, which orchestrates the complete test execution workflow:

1. **Container Setup** - Sets up BC Docker container using BCDevOnLinux
2. **Container Start** - Starts the container and waits for it to become healthy
3. **Tool Setup** - Installs .NET SDK and AL Language development tools
4. **Symbol Download** - Downloads BC symbols from the container
5. **Compilation** - Compiles the main App and Test App
6. **Publishing** - Publishes apps to the BC container
7. **Test Execution** - Runs AL tests using the al-test-runner MCP server

## Prerequisites

- Docker installed and running
- PowerShell Core (pwsh) installed
- Internet connection for downloading BC artifacts and symbols

## Quick Start

Run the complete workflow with default settings:

```powershell
pwsh ./.github/scripts/run-al-tests.ps1
```

This will:
- Create a BC container using default BC version (BC 26 Sandbox W1)
- Use default credentials (admin / Pass@word1)
- Compile and publish apps
- Prepare for test execution

## Advanced Usage

### Specify BC Version

```powershell
pwsh ./.github/scripts/run-al-tests.ps1 -BCArtifactUrl "https://bcartifacts.azureedge.net/sandbox/27.1/w1"
```

### Skip Steps (for faster iteration)

If the container is already running:
```powershell
pwsh ./.github/scripts/run-al-tests.ps1 -SkipContainerSetup
```

If apps are already compiled:
```powershell
pwsh ./.github/scripts/run-al-tests.ps1 -SkipContainerSetup -SkipCompilation
```

If apps are already published:
```powershell
pwsh ./.github/scripts/run-al-tests.ps1 -SkipContainerSetup -SkipCompilation -SkipPublish
```

### Custom Credentials

```powershell
pwsh ./.github/scripts/run-al-tests.ps1 -Username "myuser" -Password "MyP@ssword123"
```

## Environment Variables

The following environment variables can be set to override defaults:

- `BC_USERNAME` - BC admin username (default: admin)
- `BC_PASSWORD` - BC admin password (default: Pass@word1)
- `SA_PASSWORD` - SQL Server SA password (default: Pass@word1234)

Example:
```powershell
$env:BC_PASSWORD = "MySecurePassword123!"
pwsh ./.github/scripts/run-al-tests.ps1
```

## Using al-test-runner MCP Server

After running the setup script successfully, you can use the al-test-runner MCP server to execute tests.

### Discover Tests

Use the `discover_al_tests` tool with the Test workspace path:

```
workspacePath: /home/runner/work/order-origin/order-origin/Test
```

This will scan all test codeunits and methods in the Test app.

### Run Tests

Use the `run_al_tests` tool with the following parameters:

```
workspacePath: /home/runner/work/order-origin/order-origin/Test
containerName: bcserver
userName: admin
password: Pass@word1
companyName: My Company
```

Optional parameters:
- `codeunitId` - Run tests from a specific test codeunit
- `methodName` - Run a specific test method (requires codeunitId)

### Get Test Configuration

Use the `get_test_configuration` tool to retrieve the current test configuration:

```
workspacePath: /home/runner/work/order-origin/order-origin/Test
```

This reads the `.altestrunner.json` and `app.json` files.

## Individual Scripts

Each step can also be run independently:

### setup-bc-container.ps1
Sets up the BCDevOnLinux environment and configures the container.

```powershell
pwsh ./.github/scripts/setup-bc-container.ps1 `
  -BCDevRepo "https://github.com/StefanMaron/BCDevOnLinux.git" `
  -BCDevBranch "main" `
  -BCArtifactUrl "https://bcartifacts.azureedge.net/sandbox/27.1/w1"
```

### start-bc-container.ps1
Builds and starts the BC container, waits for it to become healthy.

```powershell
pwsh ./.github/scripts/start-bc-container.ps1 -MaxWaitSeconds 1200
```

### setup-dotnet-and-al.ps1
Installs .NET SDK and AL Language development tools.

```powershell
pwsh ./.github/scripts/setup-dotnet-and-al.ps1
```

### download-bc-symbols.ps1
Downloads BC symbols from the running container.

```powershell
pwsh ./.github/scripts/download-bc-symbols.ps1
```

### compile-al-apps.ps1
Compiles the AL applications.

```powershell
# Compile both App and Test
pwsh ./.github/scripts/compile-al-apps.ps1

# Compile only main App
pwsh ./.github/scripts/compile-al-apps.ps1 -ProjectPath "./App"

# Compile only Test App
pwsh ./.github/scripts/compile-al-apps.ps1 -ProjectPath "./Test"
```

### publish-apps-to-container.ps1
Publishes compiled apps to the BC container.

```powershell
$env:BC_PASSWORD = "Pass@word1"
pwsh ./.github/scripts/publish-apps-to-container.ps1 -Username "admin"
```

## Troubleshooting

### Container won't start
- Check Docker is running: `docker ps`
- View container logs: `cd bcdev-temp && docker compose logs bc`
- Increase wait time: `-MaxWaitSeconds 1800` (30 minutes)

### Compilation fails
- Ensure symbols are downloaded: Check `.alpackages` directory
- Verify AL tools are installed: `al --version`
- Check app.json dependencies match available symbols

### App publishing fails
- Verify container is healthy: `docker ps`
- Check container API is accessible: `curl http://localhost:7049/BC/dev/apps`
- Ensure credentials are correct

### Tests fail
- Verify apps are published: Check in BC container
- Ensure test toolkit is imported (IMPORT_TEST_TOOLKIT=true in .env)
- Check `.altestrunner.json` configuration

## Container Management

### Stop container
```bash
cd bcdev-temp
docker compose down
```

### View logs
```bash
cd bcdev-temp
docker compose logs -f bc
```

### Restart container
```bash
cd bcdev-temp
docker compose restart
```

### Remove container and cleanup
```bash
cd bcdev-temp
docker compose down -v
cd ..
rm -rf bcdev-temp
```
