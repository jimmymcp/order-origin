#!/bin/bash
#
# Shell wrapper for setup-and-test.ps1
# This script provides a convenient way to run the PowerShell setup script from bash
#

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default values
CONTAINER_NAME="bcserver"
USERNAME="admin"
PASSWORD="${BC_PASSWORD:-}"  # Use environment variable if set
ARTIFACT_URL=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--container)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        -u|--username)
            USERNAME="$2"
            shift 2
            ;;
        -p|--password)
            PASSWORD="$2"
            shift 2
            ;;
        -a|--artifact)
            ARTIFACT_URL="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -c, --container NAME    Container name (default: bcserver)"
            echo "  -u, --username USER     Username (default: admin)"
            echo "  -p, --password PASS     Password (if not set, a random one will be generated)"
            echo "  -a, --artifact URL      BC artifact URL (optional)"
            echo "  -h, --help              Show this help message"
            echo ""
            echo "Environment Variables:"
            echo "  BC_PASSWORD             Set password via environment variable (more secure)"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Use defaults, generate password"
            echo "  $0 -c mycontainer -u testuser         # Custom container/user, generate password"
            echo "  BC_PASSWORD='MyPass123' $0            # Set password via environment"
            echo "  $0 -a 'https://bcartifacts.../gb'    # Use specific artifact URL"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Check prerequisites
echo -e "${GREEN}Checking prerequisites...${NC}"

# Check if PowerShell is installed
if ! command -v pwsh &> /dev/null; then
    echo -e "${RED}Error: PowerShell (pwsh) is not installed${NC}"
    echo "Please install PowerShell 7.x from: https://github.com/PowerShell/PowerShell/releases"
    exit 1
fi
echo -e "${GREEN}✓ PowerShell is installed${NC}"

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    echo "Please install Docker from: https://www.docker.com/get-started"
    exit 1
fi
echo -e "${GREEN}✓ Docker is installed${NC}"

if ! docker ps &> /dev/null; then
    echo -e "${RED}Error: Docker daemon is not running${NC}"
    echo "Please start Docker and try again"
    exit 1
fi
echo -e "${GREEN}✓ Docker is running${NC}"

# Check if BcContainerHelper module is available
echo -e "${YELLOW}Checking BcContainerHelper module...${NC}"
if ! pwsh -Command "Import-Module BcContainerHelper -ErrorAction SilentlyContinue; exit \$?" &> /dev/null; then
    echo -e "${YELLOW}BcContainerHelper module not found. Installing...${NC}"
    pwsh -Command "Install-Module -Name BcContainerHelper -Force -Scope CurrentUser"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to install BcContainerHelper module${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✓ BcContainerHelper module is available${NC}"

# Generate or validate password
if [ -z "$PASSWORD" ]; then
    echo -e "${YELLOW}No password provided. Generating secure random password...${NC}"
    PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)
    echo -e "${CYAN}Generated password (save this): $PASSWORD${NC}"
fi

# Build PowerShell command
PS_COMMAND="./setup-and-test.ps1 -containerName '$CONTAINER_NAME' -username '$USERNAME' -password '$PASSWORD' -accept_eula"
if [ -n "$ARTIFACT_URL" ]; then
    PS_COMMAND="$PS_COMMAND -artifactUrl '$ARTIFACT_URL'"
fi

# Run the PowerShell script
echo ""
echo -e "${GREEN}Starting container setup and test execution...${NC}"
echo -e "${YELLOW}This may take 10-20 minutes depending on your network speed...${NC}"
echo ""

pwsh -Command "$PS_COMMAND"
EXIT_CODE=$?

# Report results
echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ Tests completed successfully!${NC}"
else
    echo -e "${RED}✗ Tests failed or errors occurred${NC}"
fi

exit $EXIT_CODE
