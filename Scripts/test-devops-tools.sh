#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "=== Starting DevOps Tools Test Suite ==="

# Function to test a command and report status
test_tool() {
    local tool_name="$1"
    local command="$2"
    
    echo "Testing $tool_name..."
    if eval "$command" > /dev/null 2>&1; then
        echo "✅ $tool_name: PASSED"
    else
        echo "❌ $tool_name: FAILED"
        echo "Command failed: $command"
        exit 1
    fi
}

# Test AWS and authentication tools
test_tool "AWS CLI" "aws --version"
test_tool "AWS SSO Utils" "aws-sso-util --version"
test_tool "Awsume" "awsume --version"

# Test secrets management
test_tool "SOPS" "sops --version"

# Test Infrastructure as Code tools
test_tool "Terraform" "terraform version"
test_tool "Terragrunt" "terragrunt --version"

# Test Kubernetes tools
test_tool "Kubectl" "kubectl version --client"
test_tool "Helm" "helm version"
test_tool "Helmfile" "helmfile --version"
test_tool "eksctl" "eksctl version"

# Test container and registry tools
test_tool "Docker" "docker --version"
test_tool "regctl" "regctl version"
test_tool "crane" "crane version"

# Test development tools
test_tool "Git" "git --version"
test_tool "Python3" "python3 --version"
test_tool "pip3" "pip3 --version"
test_tool "Go" "go version"
test_tool "Node.js" "node --version"

# Test text processing tools
test_tool "jq" "jq --version"
test_tool "yq" "yq --version"

# Test system tools
test_tool "Vim" "vim --version"
test_tool "Zsh" "zsh --version"
test_tool "htop" "htop --version"

# Test package managers
test_tool "Homebrew" "brew --version"
test_tool "pyenv" "pyenv --version"

# Test Azure CLI
test_tool "Azure CLI" "az --version"

# Test Python packages
echo "Testing Python packages..."
if python3 -c "import yaml; print('PyYAML:', yaml.__version__)" > /dev/null 2>&1; then
    echo "✅ PyYAML: PASSED"
else
    echo "❌ PyYAML: FAILED"
    exit 1
fi

if python3 -c "import redis; print('Redis Python client available')" > /dev/null 2>&1; then
    echo "✅ Redis Python client: PASSED"
else
    echo "❌ Redis Python client: FAILED"
    exit 1
fi

echo "=== All DevOps tools tested successfully! ==="
echo "✅ Test Suite: COMPLETED"