# Order Origin

Business Central extension for managing order origins on sales documents.

## Features

- Track order origins on sales documents
- Copy order origin from customer to sales orders and credit memos
- Validate order origin on document release
- Preserve order origin on posted documents

## Testing

This repository includes comprehensive test automation using Docker containers and the al-test-runner MCP server.

### Quick Start

Run the complete test setup:

```bash
pwsh ./.github/scripts/run-al-tests.ps1
```

This will:
1. Set up a Business Central Docker container
2. Compile the apps
3. Publish to the container
4. Prepare for test execution

### Using al-test-runner MCP Server

The repository is configured for use with the [al-test-runner MCP server](https://github.com/your-repo/al-test-runner) to discover and execute AL tests.

Available tools:
- `discover_al_tests` - Scan test codeunits and methods
- `get_test_configuration` - Retrieve test configuration
- `run_al_tests` - Execute tests in BC container

For detailed documentation, see:
- [DOCKER-TESTING.md](DOCKER-TESTING.md) - Complete testing guide
- [.github/scripts/README.md](.github/scripts/README.md) - Script reference

### Test Results

The repository includes 8 automated tests covering:
- Order origin copying from customer to documents
- Validation on document release
- Posted document behavior
- Document copy functionality
- Corrective credit memo workflow

## Development

### Prerequisites

- Docker
- PowerShell Core (pwsh)
- .NET SDK
- AL Language extension for VS Code

### Build

Compile the apps:

```bash
pwsh ./.github/scripts/compile-al-apps.ps1
```

### Container Management

See [.github/scripts/README.md](.github/scripts/README.md) for complete container management commands.

## AL-Go

This template repository can be used for managing AppSource Apps for Business Central.

Please go to https://aka.ms/AL-Go to learn more.

## Contributing

Please read [this](https://github.com/microsoft/AL-Go/blob/main/Scenarios/Contribute.md) description on how to contribute to AL-Go for GitHub.

We do not accept Pull Requests on the template repository directly.
