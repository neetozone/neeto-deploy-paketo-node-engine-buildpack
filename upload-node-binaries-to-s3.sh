#!/usr/bin/env bash

set -eu
set -o pipefail

S3_BUCKET="paketo-artifacts"
S3_PREFIX="node-engine"
TEMP_DIR=$(mktemp -d)

# Cleanup function
cleanup() {
  rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

echo "=========================================="
echo "Downloading and uploading Node.js binaries to S3"
echo "=========================================="
echo ""

# Array of Node.js binaries to download (both amd64 and arm64)
declare -a NODE_BINARIES=(
  # Node.js 18.x
  "https://nodejs.org/dist/v18.20.7/node-v18.20.7-linux-x64.tar.xz"
  "https://nodejs.org/dist/v18.20.7/node-v18.20.7-linux-arm64.tar.xz"
  "https://nodejs.org/dist/v18.20.8/node-v18.20.8-linux-x64.tar.xz"
  "https://nodejs.org/dist/v18.20.8/node-v18.20.8-linux-arm64.tar.xz"
  # Node.js 20.x
  "https://nodejs.org/dist/v20.19.5/node-v20.19.5-linux-x64.tar.xz"
  "https://nodejs.org/dist/v20.19.5/node-v20.19.5-linux-arm64.tar.xz"
  "https://nodejs.org/dist/v20.19.6/node-v20.19.6-linux-x64.tar.xz"
  "https://nodejs.org/dist/v20.19.6/node-v20.19.6-linux-arm64.tar.xz"
  # Node.js 22.x
  "https://nodejs.org/dist/v22.13.1/node-v22.13.1-linux-x64.tar.xz"
  "https://nodejs.org/dist/v22.13.1/node-v22.13.1-linux-arm64.tar.xz"
  "https://nodejs.org/dist/v22.21.0/node-v22.21.0-linux-x64.tar.xz"
  "https://nodejs.org/dist/v22.21.0/node-v22.21.0-linux-arm64.tar.xz"
  "https://nodejs.org/dist/v22.21.1/node-v22.21.1-linux-x64.tar.xz"
  "https://nodejs.org/dist/v22.21.1/node-v22.21.1-linux-arm64.tar.xz"
  # Node.js 24.x
  "https://nodejs.org/dist/v24.11.0/node-v24.11.0-linux-x64.tar.xz"
  "https://nodejs.org/dist/v24.11.0/node-v24.11.0-linux-arm64.tar.xz"
  "https://nodejs.org/dist/v24.11.1/node-v24.11.1-linux-x64.tar.xz"
  "https://nodejs.org/dist/v24.11.1/node-v24.11.1-linux-arm64.tar.xz"
)

# Download and upload each binary
for url in "${NODE_BINARIES[@]}"; do
  filename=$(basename "${url}")
  local_path="${TEMP_DIR}/${filename}"
  s3_path="s3://${S3_BUCKET}/${S3_PREFIX}/${filename}"
  
  echo "Processing: ${filename}"
  echo "  Downloading from: ${url}"
  
  # Download the file
  if curl -f -L -o "${local_path}" "${url}"; then
    echo "  ✓ Downloaded successfully"
    
    # Upload to S3
    echo "  Uploading to: ${s3_path}"
    if aws s3 cp "${local_path}" "${s3_path}"; then
      echo "  ✓ Uploaded successfully"
      echo "  Public URL: https://${S3_BUCKET}.s3.us-east-1.amazonaws.com/${S3_PREFIX}/${filename}"
    else
      echo "  ✗ Failed to upload to S3"
      exit 1
    fi
  else
    echo "  ✗ Failed to download"
    exit 1
  fi
  
  echo ""
done

echo "=========================================="
echo "All Node.js binaries uploaded successfully!"
echo "=========================================="
echo ""
echo "S3 Location: s3://${S3_BUCKET}/${S3_PREFIX}/"
echo "Public URLs:"
for url in "${NODE_BINARIES[@]}"; do
  filename=$(basename "${url}")
  echo "  https://${S3_BUCKET}.s3.us-east-1.amazonaws.com/${S3_PREFIX}/${filename}"
done

