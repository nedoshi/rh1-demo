# Quick Start Guide - Building Demo Images

## 🚀 Three Simple Steps

### Step 1: Login to Quay.io

```bash
docker login quay.io
# Username: flyers22
# Password: <your-quay-password>
```

**Note**: If you use Podman instead of Docker:
```bash
podman login quay.io
```

### Step 2: Build and Push All Images

```bash
cd rh-trusted-sc/all-demo-files/docker-images
./build-and-push-all.sh
```

This script will:
- ✅ Build all 11 images automatically
- ✅ Tag them as `quay.io/flyers22/<image-name>:latest`
- ✅ Push them to your Quay.io repository

**Expected time**: 10-15 minutes (depending on network speed)

### Step 3: Update YAML Files

```bash
cd rh-trusted-sc/all-demo-files
./update-image-references.sh
```

This updates all demo YAML files to use your new images.

## ✅ Verification

Check that images were pushed successfully:

```bash
# List your repositories on Quay.io
curl -s "https://quay.io/api/v1/repository?namespace=flyers22" | jq '.repositories[].name'
```

Or visit: https://quay.io/repository/flyers22/

## 📦 Images Created

All images will be available at: `quay.io/flyers22/<name>:latest`

1. `model-verifier`
2. `security-assistant`
3. `compliance-dashboard`
4. `artifact-verifier`
5. `sbom-generator`
6. `vex-verifier`
7. `compliance-verifier`
8. `report-generator`
9. `aws-connector`
10. `azure-connector`
11. `compliance-report-generator`

## 🎯 What's Next?

After completing these steps:

1. Your images are on Quay.io ✅
2. YAML files are updated ✅
3. Deploy to OpenShift cluster
4. Run demo commands
5. All pods should start successfully! 🎉

## ❓ Troubleshooting

**Problem**: Build fails with authentication error
- **Solution**: Make sure you're logged in: `docker login quay.io`

**Problem**: Push fails with permission error
- **Solution**: Verify repository exists on Quay.io and is set to public (or you have write permissions)

**Problem**: Base image pull fails
- **Solution**: You may need Red Hat registry authentication for UBI images. See `BUILD_INSTRUCTIONS.md` for alternatives.

## 📚 More Information

- **Detailed instructions**: See `BUILD_INSTRUCTIONS.md`
- **Directory structure**: See `README.md`
- **Manual build**: See `README.md` for individual image builds
