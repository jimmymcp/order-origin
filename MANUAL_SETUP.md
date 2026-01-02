# Manual Container Setup and Test Execution

This guide is for environments where internet access is restricted or unavailable. Follow these steps to manually set up and run tests.

## Prerequisites Verification

Before starting, ensure you have:

1. ✓ Docker installed and running
2. ✓ PowerShell 7.x or later installed
3. ✓ BcContainerHelper module installed (see offline installation below)
4. ✓ Business Central Docker image or artifact cache available locally

## Installing BcContainerHelper Without Internet

### Option 1: Manual Module Installation

1. Download BcContainerHelper from another machine with internet:
   ```powershell
   # On a machine with internet
   Save-Module -Name BcContainerHelper -Path C:\temp\modules
   ```

2. Transfer the module folder to your offline machine

3. Copy to PowerShell modules directory:
   ```powershell
   # On the offline machine
   Copy-Item -Path "C:\temp\modules\BcContainerHelper" -Destination "$HOME\.local\share\powershell\Modules\" -Recurse
   ```

### Option 2: Clone from GitHub

1. Clone the repository on a machine with internet:
   ```bash
   git clone https://github.com/microsoft/navcontainerhelper.git
   ```

2. Transfer to offline machine and copy to PowerShell modules:
   ```bash
   cp -r navcontainerhelper ~/.local/share/powershell/Modules/BcContainerHelper
   ```

## Getting Business Central Artifacts Offline

### Option 1: Pre-download BC Docker Image

On a machine with internet access, pull and save the BC Docker image:

```bash
# Pull the Business Central image
docker pull mcr.microsoft.com/businesscentral/onprem:25.0-gb

# Save to tar file
docker save -o bc-25-gb.tar mcr.microsoft.com/businesscentral/onprem:25.0-gb
```

Transfer the tar file to your offline machine and load it:

```bash
docker load -i bc-25-gb.tar
```

### Option 2: Cache BC Artifacts Locally

On a machine with internet, download and cache artifacts:

```powershell
Import-Module BcContainerHelper
Download-Artifacts -artifactUrl (Get-BCArtifactUrl -type OnPrem -version "25.0" -country "gb") -includePlatform
```

This downloads artifacts to: `C:\bcartifacts.cache` (Windows) or `~/.bcartifacts.cache` (Linux)

Transfer this cache directory to your offline machine.

## Manual Container Creation Steps

### Step 1: Verify BcContainerHelper

```powershell
Import-Module BcContainerHelper
Get-Command -Module BcContainerHelper | Select-Object -First 5
```

### Step 2: Prepare Container Parameters

```powershell
$containerName = "bcserver"
$password = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$credential = New-Object PSCredential("admin", $password)

# If using cached artifacts, specify the path
$artifactUrl = "C:\bcartifacts.cache\onprem\25.0.0.0\gb"  # Windows
# OR
$artifactUrl = "$HOME/.bcartifacts.cache/onprem/25.0.0.0/gb"  # Linux
```

### Step 3: Create Container

```powershell
New-BcContainer `
    -accept_eula `
    -containerName $containerName `
    -auth UserPassword `
    -Credential $credential `
    -artifactUrl $artifactUrl `
    -updateHosts:$false `
    -isolation process `
    -memoryLimit 8G `
    -includeTestToolkit `
    -includeTestLibrariesOnly `
    -doNotExportObjectsToText `
    -shortcuts None
```

### Step 4: Compile and Publish Main App

```powershell
# Compile the Order Origin app
Compile-AppInBcContainer `
    -containerName $containerName `
    -credential $credential `
    -appProjectFolder "./App" `
    -appOutputFolder "./output"

# Publish the app
$appFile = Get-ChildItem "./output" -Filter "*.app" | Where-Object { $_.Name -notlike "*Test*" } | Select-Object -First 1
Publish-BcContainerApp `
    -containerName $containerName `
    -appFile $appFile.FullName `
    -sync `
    -install `
    -credential $credential `
    -skipVerification
```

### Step 5: Compile and Publish Test App

```powershell
# Compile the test app
Compile-AppInBcContainer `
    -containerName $containerName `
    -credential $credential `
    -appProjectFolder "./Test" `
    -appOutputFolder "./output"

# Publish the test app
$testAppFile = Get-ChildItem "./output" -Filter "*Test*.app" | Select-Object -First 1
Publish-BcContainerApp `
    -containerName $containerName `
    -appFile $testAppFile.FullName `
    -sync `
    -install `
    -credential $credential `
    -skipVerification
```

### Step 6: Run Tests

```powershell
# Run all tests
Run-TestsInBcContainer `
    -containerName $containerName `
    -credential $credential `
    -detailed `
    -AzureDevOps None `
    -returnTrueIfAllPassed

# Or run specific test codeunit
Run-TestsInBcContainer `
    -containerName $containerName `
    -credential $credential `
    -testCodeunit 50251 `
    -detailed
```

## Alternative: Using the Provided Scripts with Local Artifacts

If you have local artifacts, you can still use the provided scripts:

```bash
# Using PowerShell script
./setup-and-test.ps1 -artifactUrl "C:\bcartifacts.cache\onprem\25.0.0.0\gb"

# Using Bash wrapper
./setup-and-test.sh -a "C:\bcartifacts.cache\onprem\25.0.0.0\gb"
```

## Test Information

The Order Origin Tests codeunit (ID: 50251) contains 8 test methods:

| # | Test Method Name | Purpose |
|---|------------------|---------|
| 1 | OrderOriginCodeIsNotCopiedToQuote | Verifies order origin not copied to quotes |
| 2 | OrderOriginIsCopiedFromCustomerToSalesOrder | Verifies copy to sales order |
| 3 | OrderOriginIsCopiedFromCustomerToSalesCreditMemo | Verifies copy to credit memo |
| 4 | ReleasingSalesOrderWithoutOrderOriginThrowsError | Tests validation logic |
| 5 | ReleasingSalesOrderWithOrderOrigin | Tests successful release |
| 6 | PostingSalesOrderCopiesOrderOriginToSalesInvoice | Tests posting |
| 7 | OrderOriginCodeIsClearedAfterCopySalesDocument | Tests document copy |
| 8 | PostCorrectiveCreditAndCreateNewInvoice | Tests corrective scenarios |

## Troubleshooting

### Check Container Status

```powershell
docker ps -a
Get-BcContainerEventLog -containerName bcserver | Select-Object -Last 50
```

### View Container Logs

```powershell
docker logs bcserver
```

### Remove and Recreate Container

```powershell
docker rm -f bcserver
# Then re-run creation steps
```

### Verify Apps are Installed

```powershell
Get-BcContainerAppInfo -containerName bcserver
```

## Cleanup

```powershell
# Remove container
docker rm -f bcserver

# Remove all BC containers
Get-BcContainers | ForEach-Object { Remove-BcContainer -containerName $_ }

# Clean up artifacts cache (if needed)
Remove-Item -Recurse -Force "$HOME/.bcartifacts.cache"
```

## Using AL Test Runner Extension in VS Code

Once the container is running:

1. Install "AL Test Runner" extension in VS Code
2. Configuration is already in `.altestrunner/config.json`
3. Open Command Palette (Ctrl+Shift+P)
4. Run: "AL Test Runner: Run All Tests"

Or use the Test Explorer in the sidebar to run tests individually.
