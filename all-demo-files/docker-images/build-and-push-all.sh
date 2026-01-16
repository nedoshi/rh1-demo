#!/bin/bash
################################################################################
# Build and Push All Demo Images to Quay.io
#
# This script builds all demo images and pushes them to quay.io/flyers22
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
QUAY_USERNAME="flyers22"
QUAY_REGISTRY="quay.io"
IMAGE_TAG="latest"

# Detect container runtime
if command -v podman &> /dev/null; then
    CONTAINER_CMD="podman"
elif command -v docker &> /dev/null; then
    CONTAINER_CMD="docker"
else
    echo -e "${RED}Error: Neither podman nor docker found${NC}"
    exit 1
fi

echo -e "${GREEN}Using container runtime: ${CONTAINER_CMD}${NC}"

# Check if logged in to quay.io
echo -e "${YELLOW}Checking quay.io authentication...${NC}"
if ! ${CONTAINER_CMD} login --get-login ${QUAY_REGISTRY} &>/dev/null; then
    echo -e "${YELLOW}Not logged in to ${QUAY_REGISTRY}. Please login:${NC}"
    ${CONTAINER_CMD} login ${QUAY_REGISTRY}
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Function to build and push an image
build_and_push() {
    local image_name=$1
    local dockerfile=$2
    local context=$3
    
    local full_image="${QUAY_REGISTRY}/${QUAY_USERNAME}/${image_name}:${IMAGE_TAG}"
    
    echo -e "\n${GREEN}Building ${image_name}...${NC}"
    echo "  Dockerfile: ${dockerfile}"
    echo "  Context: ${context}"
    echo "  Image: ${full_image}"
    
    cd "$context"
    # Build for linux/amd64 platform (OpenShift clusters typically run on x86_64)
    # Use --platform flag to ensure correct architecture
    if [ "$CONTAINER_CMD" = "docker" ]; then
        ${CONTAINER_CMD} build --platform linux/amd64 -t "${full_image}" -f "${dockerfile}" .
    elif [ "$CONTAINER_CMD" = "podman" ]; then
        ${CONTAINER_CMD} build --platform linux/amd64 -t "${full_image}" -f "${dockerfile}" .
    else
        ${CONTAINER_CMD} build -t "${full_image}" -f "${dockerfile}" .
    fi
    
    echo -e "${GREEN}Pushing ${full_image}...${NC}"
    ${CONTAINER_CMD} push "${full_image}"
    
    echo -e "${GREEN}✓ Successfully built and pushed ${image_name}${NC}"
    cd "$SCRIPT_DIR"
}

# Build shell-based job images
echo -e "\n${YELLOW}========================================${NC}"
echo -e "${YELLOW}Building Shell-Based Job Images${NC}"
echo -e "${YELLOW}========================================${NC}"

SHELL_JOBS_DIR="${SCRIPT_DIR}/shell-jobs"

build_and_push "model-verifier" "Dockerfile.model-verifier" "${SHELL_JOBS_DIR}"
build_and_push "artifact-verifier" "Dockerfile.artifact-verifier" "${SHELL_JOBS_DIR}"
build_and_push "sbom-generator" "Dockerfile.sbom-generator" "${SHELL_JOBS_DIR}"
build_and_push "vex-verifier" "Dockerfile.vex-verifier" "${SHELL_JOBS_DIR}"
build_and_push "compliance-verifier" "Dockerfile.compliance-verifier" "${SHELL_JOBS_DIR}"
build_and_push "report-generator" "Dockerfile.report-generator" "${SHELL_JOBS_DIR}"

# Build Python-based service images
echo -e "\n${YELLOW}========================================${NC}"
echo -e "${YELLOW}Building Python-Based Service Images${NC}"
echo -e "${YELLOW}========================================${NC}"

PYTHON_SERVICES_DIR="${SCRIPT_DIR}/python-services"

build_and_push "security-assistant" "Dockerfile.security-assistant" "${PYTHON_SERVICES_DIR}"
build_and_push "compliance-dashboard" "Dockerfile.compliance-dashboard" "${PYTHON_SERVICES_DIR}"
build_and_push "aws-connector" "Dockerfile.aws-connector" "${PYTHON_SERVICES_DIR}"
build_and_push "azure-connector" "Dockerfile.azure-connector" "${PYTHON_SERVICES_DIR}"
build_and_push "compliance-report-generator" "Dockerfile.compliance-report-generator" "${PYTHON_SERVICES_DIR}"

# Summary
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Build Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "All images have been built and pushed to:"
echo "  ${QUAY_REGISTRY}/${QUAY_USERNAME}/*:${IMAGE_TAG}"
echo ""
echo "Next steps:"
echo "  1. Update YAML files to use new image references"
echo "  2. Run: cd .. && ./update-image-references.sh"
echo ""
