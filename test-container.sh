#!/bin/bash

# Verify tag argument provided
if [ -z "$1" ]; then
  echo "Error: Please specify container image tag"
  echo "Usage: $0 <image-tag>"
  exit 1
fi

TAG=$1
TEST_DIR="test-project"

# Function to remove the Podman volume
cleanup() {
  echo "Removing Podman volume..."
  podman volume rm solana-test-vol
}

# Set up the trap to call the cleanup function on script exit
trap cleanup EXIT

echo "Testing container image with tag: $TAG"
echo "========================================"

# Run container with temporary volume
podman run -it --rm \
  --mount type=volume,src=solana-test-vol,dst=/workspace \
  "localhost/solana-toolchain:$TAG" /bin/bash -c "
    set -ex
    anchor init test-project
    cd test-project
    solana-keygen new --no-passphrase
    anchor build
    anchor test
  "

# Check the exit status of the podman run command
if [ $? -eq 0 ]; then
  echo -e "\nTest successful!"
else
  echo -e "\nTest failed!"
  exit 1
fi