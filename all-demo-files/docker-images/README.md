# Demo Images for Trusted Supply Chain

This directory contains Dockerfiles and build scripts to create realistic demo images for the Trusted Supply Chain demos.

## Overview

The demo requires 11 container images that are currently referenced but don't exist. This directory provides:

- **Dockerfiles** for each service
- **Build script** to build and push all images
- **Update script** to update YAML files with new image references

## Images Created

### Shell-Based Job Images (6)
These run as Kubernetes Jobs and output verification results:

1. `model-verifier` - Verifies ML model signatures
2. `artifact-verifier` - Verifies signed artifacts from multiple clouds
3. `sbom-generator` - Generates SBOM lineage
4. `vex-verifier` - Verifies VEX statements
5. `compliance-verifier` - Verifies NIST SSDF compliance
6. `report-generator` - Generates compliance reports

### Python-Based Service Images (5)
These run as HTTP services on port 8080:

1. `security-assistant` - Security monitoring service
2. `compliance-dashboard` - Compliance dashboard web UI
3. `aws-connector` - AWS ECR connector service
4. `azure-connector` - Azure ACR connector service
5. `compliance-report-generator` - Report generation service

## Quick Start

### Step 1: Login to Quay.io

```bash
docker login quay.io
# Enter username: flyers22
# Enter password: <your-quay-password>
```

Or with Podman:
```bash
podman login quay.io
```

### Step 2: Build and Push All Images

```bash
cd rh-trusted-sc/all-demo-files/docker-images
./build-and-push-all.sh
```

This will:
- Build all 11 images
- Tag them as `quay.io/flyers22/<image-name>:latest`
- Push them to your Quay.io repository

### Step 3: Update YAML Files

```bash
cd rh-trusted-sc/all-demo-files
./update-image-references.sh
```

This updates all YAML files to use `quay.io/flyers22/*` instead of `quay.io/redhat-appstudio/*`.

## Directory Structure

```
docker-images/
├── README.md                    # This file
├── BUILD_INSTRUCTIONS.md        # Detailed build instructions
├── build-and-push-all.sh        # Main build script
├── shell-jobs/                  # Shell-based job images
│   ├── Dockerfile.model-verifier
│   ├── Dockerfile.artifact-verifier
│   ├── Dockerfile.sbom-generator
│   ├── Dockerfile.vex-verifier
│   ├── Dockerfile.compliance-verifier
│   └── Dockerfile.report-generator
└── python-services/             # Python-based service images
    ├── Dockerfile.security-assistant
    ├── Dockerfile.compliance-dashboard
    ├── Dockerfile.aws-connector
    ├── Dockerfile.azure-connector
    └── Dockerfile.compliance-report-generator
```

## Manual Build

If you prefer to build images individually:

### Shell-Based Jobs

```bash
cd shell-jobs
docker build -t quay.io/flyers22/model-verifier:latest -f Dockerfile.model-verifier .
docker push quay.io/flyers22/model-verifier:latest
```

### Python Services

```bash
cd python-services
docker build -t quay.io/flyers22/security-assistant:latest -f Dockerfile.security-assistant .
docker push quay.io/flyers22/security-assistant:latest
```

## Image Details

### Base Images

- **Shell jobs**: `registry.access.redhat.com/ubi8/ubi-minimal:latest`
  - Requires Red Hat registry authentication
  - Lightweight for shell scripts
  
- **Python services**: `registry.access.redhat.com/ubi8/python-39:latest`
  - Requires Red Hat registry authentication
  - Includes Python 3.9 runtime

### Image Sizes

Approximate sizes:
- Shell jobs: ~100-150 MB
- Python services: ~300-400 MB

## Verification

After building and pushing, verify images are accessible:

```bash
# Check if images exist on Quay.io
curl -s "https://quay.io/api/v1/repository?namespace=flyers22" | jq '.repositories[].name'

# Or visit in browser
# https://quay.io/repository/flyers22/<image-name>
```

## Troubleshooting

### Authentication Issues

```bash
# Check login status
docker info | grep -i username

# Re-login if needed
docker login quay.io
```

### Build Failures

1. Ensure Docker/Podman is running: `docker ps`
2. Check disk space: `df -h`
3. Verify base images are accessible (may need Red Hat registry auth)

### Push Failures

1. Verify repository exists on Quay.io
2. Check repository is set to public (or you have proper permissions)
3. Verify network connectivity: `ping quay.io`

## Next Steps

After building and pushing all images:

1. ✅ Images are available on `quay.io/flyers22`
2. ✅ YAML files updated with new image references
3. ✅ Deploy to OpenShift cluster
4. ✅ Run demo commands
5. ✅ Verify all pods start successfully

## Notes

- All images use the `latest` tag
- Images are designed to be lightweight and fast to build
- Shell jobs output the expected demo output format
- Python services provide basic HTTP endpoints for demo purposes
- For production use, you would enhance these with full functionality
