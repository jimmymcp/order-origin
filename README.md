# Order Origin

Business Central extension for managing order origins on sales documents.

## Overview

This extension adds an "Order Origin" field to sales documents (orders, credit memos) to track the source/channel of orders. The order origin is copied from the customer record when creating sales documents and is preserved through posting.

## Features

- Order Origin table and page for managing origin codes
- Order Origin field on Customer records
- Automatic copying of order origin to sales orders and credit memos
- Order origin preserved on posted sales invoices
- Validation to ensure order origin is set before releasing sales orders
- Order origin cleared when copying sales documents

## Testing

The project includes 8 automated tests covering all functionality. See the [Test folder](./Test) for test codeunits.

## Container Setup and Testing

To create a Business Central container and run the automated tests:

### Quick Start (With Internet Access)

```bash
# Using bash (generates secure password automatically)
./setup-and-test.sh

# Using PowerShell (generates secure password automatically)
./setup-and-test.ps1 -accept_eula

# Or set password via environment variable
BC_PASSWORD='YourSecurePassword' ./setup-and-test.sh
```

### Documentation

- **[CONTAINER_SETUP.md](./CONTAINER_SETUP.md)** - Complete guide for setting up and running tests with automatic artifact download
- **[MANUAL_SETUP.md](./MANUAL_SETUP.md)** - Step-by-step manual setup for offline environments or custom configurations

### Prerequisites

- Docker (installed and running)
- PowerShell 7.x or later
- BcContainerHelper PowerShell module
- Internet access (for downloading BC artifacts) or local artifact cache

## AL-Go Integration

This template repository can be used for managing AppSource Apps for Business Central.

Please go to https://aka.ms/AL-Go to learn more.

## Contributing

Please read [this](https://github.com/microsoft/AL-Go/blob/main/Scenarios/Contribute.md) description on how to contribute to AL-Go for GitHub.

We do not accept Pull Requests on the template repository directly.
