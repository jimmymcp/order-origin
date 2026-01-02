# Container Setup and Testing Instructions

This document explains how to create a Business Central container and run the AL tests for the Order Origin project.

## Prerequisites

1. **Docker**: Docker must be installed and running on your machine
   - Windows: Install Docker Desktop for Windows
   - Linux: Install Docker Engine
   - macOS: Install Docker Desktop for Mac

2. **PowerShell**: PowerShell 7.x or later
   - Download from: https://github.com/PowerShell/PowerShell/releases

3. **BcContainerHelper**: PowerShell module for managing BC containers
   ```powershell
   Install-Module -Name BcContainerHelper -Force
   ```

4. **Internet Access**: Required to download Business Central artifacts (Docker images)

## Configuration Files

### .altestrunner/config.json

This file contains the configuration for the AL Test Runner extension:

```json
{
  "containerName": "bcserver",
  "userName": "admin",
  "securePassword": "P@ssw0rd",
  "companyName": "CRONUS International Ltd.",
  "vmUserName": "",
  "vmSecurePassword": "",
  "remoteContainerName": "",
  "dockerHost": "",
  "newPSSessionOptions": ""
}
```

You can customize these settings as needed:
- `containerName`: Name of your Docker container
- `userName` / `securePassword`: Credentials for accessing the container
- `companyName`: Company name in Business Central to run tests against

## Running the Setup Script

### Option 1: Automatic Artifact Download (Requires Internet)

```powershell
./setup-and-test.ps1
```

This will:
1. Download the latest Business Central 25.0 artifacts for GB (Great Britain)
2. Create a Docker container named "bcserver"
3. Compile and publish the Order Origin app
4. Compile and publish the Order Origin Tests app
5. Run all 8 test methods in the test codeunit
6. Display the test results

### Option 2: Using a Specific Artifact URL

If you have Business Central artifacts cached locally or want to use a specific version:

```powershell
./setup-and-test.ps1 -artifactUrl "https://bcartifacts.azureedge.net/onprem/25.0.0.0/gb"
```

### Option 3: Custom Container Name and Credentials

```powershell
./setup-and-test.ps1 -containerName "mybc" -username "testuser" -password "MyP@ssw0rd"
```

## Test Information

The project contains **8 test methods** in the **Order Origin Tests** codeunit (ID: 50251):

1. `OrderOriginCodeIsNotCopiedToQuote` - Verifies order origin is not copied to quotes
2. `OrderOriginIsCopiedFromCustomerToSalesOrder` - Verifies order origin is copied from customer to sales order
3. `OrderOriginIsCopiedFromCustomerToSalesCreditMemo` - Verifies order origin is copied to credit memos
4. `ReleasingSalesOrderWithoutOrderOriginThrowsError` - Tests error handling for missing order origin
5. `ReleasingSalesOrderWithOrderOrigin` - Tests successful release with order origin
6. `PostingSalesOrderCopiesOrderOriginToSalesInvoice` - Verifies order origin is copied to posted invoice
7. `OrderOriginCodeIsClearedAfterCopySalesDocument` - Tests that order origin is cleared when copying documents
8. `PostCorrectiveCreditAndCreateNewInvoice` - Tests corrective credit memo functionality

## Expected Output

When tests run successfully, you'll see:

```
Running tests...
Test codeunit: Order Origin Tests (ID: 50251)

Test Results:
============================================
✓ All tests passed successfully!
```

## Troubleshooting

### Container Already Exists

If you see an error about the container already existing, the script will automatically remove it. Alternatively, remove it manually:

```powershell
docker rm -f bcserver
```

### Network/Artifact Download Issues

If artifact download fails, ensure:
- You have internet connectivity
- Firewall is not blocking Docker or PowerShell
- Try specifying a specific artifact URL manually

### Memory Issues

The container is configured with 8GB memory limit. If you encounter memory issues:
- Increase available memory in Docker settings
- Modify the script's `-memoryLimit` parameter

### Container Logs

To view container logs for debugging:

```powershell
Get-BcContainerEventLog -containerName bcserver
```

## Cleaning Up

After testing, you can remove the container:

```powershell
docker rm -f bcserver
```

To remove container images to free up disk space:

```powershell
docker system prune -a
```

## Using AL Test Runner in VS Code

Once the container is running, you can also use the AL Test Runner extension in VS Code:

1. Install the "AL Test Runner" extension
2. Open the workspace in VS Code
3. The extension will read the `.altestrunner/config.json` configuration
4. Use the Test Explorer view to run individual tests or test suites

## Additional Resources

- [BcContainerHelper Documentation](https://github.com/microsoft/navcontainerhelper)
- [AL Test Runner Extension](https://marketplace.visualstudio.com/items?itemName=jamespearson.al-test-runner)
- [Business Central Docker Hub](https://hub.docker.com/_/microsoft-businesscentral)
