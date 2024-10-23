#!/bin/bash

# Exit if any command fails
set -e

# Define the version or branch of Terragrunt (optional)
TERRAGRUNT_VERSION="v0.50.0"  # Change to the desired version or branch

# Directory where the Terragrunt repo will be cloned
BUILD_DIR="$HOME/terragrunt_build"

# Go installation check
if ! command -v go &> /dev/null
then
    echo "Go is not installed. Please install Go before running this script."
    exit 1
fi

# Remove existing build directory if it exists
if [ -d "$BUILD_DIR" ]; then
    echo "Removing existing build directory..."
    rm -rf "$BUILD_DIR"
fi

# Clone the Terragrunt repository
echo "Cloning the Terragrunt repository..."
git clone https://github.com/gruntwork-io/terragrunt.git "$BUILD_DIR"

# Navigate into the cloned repository
cd "$BUILD_DIR"

# Checkout the specific version or branch
if [ -n "$TERRAGRUNT_VERSION" ]; then
    echo "Checking out version: $TERRAGRUNT_VERSION"
    git checkout "$TERRAGRUNT_VERSION"
fi

go clean -modcache

# Build the Terragrunt binary
echo "Building Terragrunt..."
go build -o terragrunt

# Move the binary to /usr/local/bin or a preferred location
echo "Moving Terragrunt binary to /usr/local/bin..."
sudo mv terragrunt /usr/local/bin/

# Verify installation
echo "Verifying the installation..."
terragrunt --version

echo "Terragrunt has been successfully installed!"
rm -rf $BUILD_DIR