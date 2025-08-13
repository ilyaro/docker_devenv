#!/bin/bash
set -xeuo pipefail
echo "=== Starting DevOps Tools Test Suite ==="

# Global variables for tracking test results
TOTAL_TESTS=0
FAILED_TESTS=0
FAILED_TOOLS=()

# Function to extract tools from Dockerfile and generate test commands
extract_dockerfile_tools() {
    local dockerfile_path="../Dockerfiles/Dockerfile_amazonlinux_2023"

    echo "=== Extracting tools from Dockerfile ==="
    
    # Check if Dockerfile exists
    if [[ ! -f "$dockerfile_path" ]]; then
        echo "❌ Dockerfile not found at: $dockerfile_path"
        exit 1
    fi
    
    # Extract DNF packages from RUN dnf install commands with better filtering
    # Fix: Escape the regex pattern properly and simplify the extraction logic
    echo "Extracting DNF packages..."
    grep -E "^[[:space:]]*RUN[[:space:]]+dnf[[:space:]]+install.*-y" "$dockerfile_path" | \
        sed 's/RUN dnf install -y//' | \
        sed 's/\\$//' | \
        tr ' ' '\n' | \
        grep -v "^$" | \
        grep -v "^#" | \
        grep -v "^&&" | \
        grep -v "dnf" | \
        grep -v "clean" | \
        grep -v "all" | \
        grep -v "upgrade" | \
        grep -v '\${.*}' | \
        grep -v "^-" | \
        grep -E "^[a-zA-Z][a-zA-Z0-9_-]*$" | \
        sort -u > /tmp/dnf_packages.txt
    
    # Extract Python packages from pip install commands with better filtering
    # Fix: Use POSIX character classes and properly escape regex patterns
    echo "Extracting Python packages..."
    grep -E "pip install" "$dockerfile_path" | \
        sed 's/.*pip install[^a-zA-Z]*//' | \
        sed 's/--[a-zA-Z-]*//g' | \
        sed 's/&&.*//' | \
        tr ' ' '\n' | \
        grep -v "^$" | \
        grep -v '\${.*}' | \
        grep -v "^-" | \
        grep -v "upgrade" | \
        grep -E "^[a-zA-Z][a-zA-Z0-9_-]*$" | \
        sort -u > /tmp/pip_packages.txt
    
    # Extract Go-installed tools with better filtering
    # Fix: Simplify regex patterns and avoid complex character classes
    echo "Extracting Go tools..."
    grep -E "go install" "$dockerfile_path" | \
        sed 's/.*go install //' | \
        sed 's/@latest//' | \
        sed 's/@.*//' | \
        sed 's/&&.*//' | \
        awk -F'/' '{print $NF}' | \
        grep -v "^$" | \
        grep -v '\${.*}' | \
        grep -v "upgrade" | \
        grep -v "^v[0-9]" | \
        grep -E "^[a-zA-Z][a-zA-Z0-9_-]*$" | \
        sort -u > /tmp/go_tools.txt
    
    # Extract manually installed binaries - predefined list of known tools
    echo "Extracting manually installed tools..."
    {
        echo "terraform"
        echo "kubectl"
        echo "helm"
        echo "helmfile"
        echo "eksctl"
        echo "terragrunt"
        echo "sops"
        echo "regctl"
        echo "crane"
        echo "yq"
        echo "brew"
        echo "pyenv"
        echo "aws"
        echo "az"
        echo "kustomize"
    } > /tmp/manual_tools.txt
}

# Function to test a tool with comprehensive error handling
test_tool() {
    local tool_name="$1"
    local command="$2"
    local category="${3:-General}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo "Testing [$category] $tool_name..."
    
    # Capture both stdout and stderr from the command execution
    local output
    if output=$(eval "$command" 2>&1); then
        echo "✅ $tool_name: PASSED"
    else
        echo "❌ $tool_name: FAILED"
        echo "   Command: $command"
        echo "   Error output: $output"
        echo "---"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        FAILED_TOOLS+=("$tool_name")
    fi
}

# Function to generate appropriate test command for each tool type
get_test_command() {
    local tool="$1"
    
    case "$tool" in
        # System tools - use 'which' to check if binary exists in PATH
        bash-completion|bc|git|gcc|gcc-c++|gdb|golang|less|make|nc|passwd|screen|sudo|tar|tmux|unzip|vim|wget|which|dos2unix|jq|htop|tree|hostname|nano|openssl|nodejs|docker|zsh)
            echo "which $tool"
            ;;
        # Fix: Remove wildcard patterns that can cause parsing issues
        vim-*)
            echo "which vim"
            ;;
        openssl-*)
            echo "which openssl"
            ;;
        docker-*)
            echo "which docker"
            ;;
        pip*)
            echo "pip3 --version"
            ;;
        # AWS CLI with specific version command
        awscli|aws) echo "aws --version" ;;
        # Python pip package manager
        python3-pip) echo "pip3 --version" ;;
        # SSL certificates - check file existence
        ca-certificates) echo "ls /etc/pki/tls/certs/ca-bundle.crt" ;;
        # Development libraries - use RPM package manager to verify
        python3-devel|libffi-devel|openssl-devel) echo "rpm -q $tool" ;;
        # DNS utilities
        bind-utils) echo "nslookup --version || which nslookup" ;;
        # Infrastructure tools with version commands
        terraform) echo "terraform version" ;;
        kubectl) echo "kubectl version --client" ;;
        helm) echo "helm version" ;;
        helmfile) echo "helmfile --version" ;;
        eksctl) echo "eksctl version" ;;
        terragrunt) echo "terragrunt --version" ;;
        sops) echo "sops --version" ;;
        regctl) echo "regctl version" ;;
        crane) echo "crane version" ;;
        yq) echo "yq --version" ;;
        brew) echo "brew --version" ;;
        pyenv) echo "pyenv --version" ;;
        az) echo "az --version" ;;
        kustomize) echo "kustomize version" ;;
        # Python packages - import test to verify installation
        pyyaml) echo "python3 -c 'import yaml; print(yaml.__version__)'" ;;
        redis) echo "python3 -c 'import redis; print(\"Redis client available\")'" ;;
        aws-sso-util) echo "aws-sso-util --version" ;;
        awsume) echo "awsume --version" ;;
        git-remote-codecommit) echo "python3 -c 'import git_remote_codecommit; print(\"git-remote-codecommit available\")'" ;;
        azure-cli) echo "az --version" ;;
        # Default fallback - try both 'which' and RPM package check
        *) echo "which $tool || rpm -q $tool" ;;
    esac
}

# Main execution flow starts here
extract_dockerfile_tools

# Test DNF packages extracted from Dockerfile
echo ""
echo "=== Testing DNF Packages ==="
if [[ -f /tmp/dnf_packages.txt ]]; then
    while IFS= read -r tool; do
        [[ -z "$tool" ]] && continue
        test_command=$(get_test_command "$tool")
        test_tool "$tool" "$test_command" "DNF Package"
    done < /tmp/dnf_packages.txt
fi

# Test Python packages installed via pip
echo ""
echo "=== Testing Python Packages ==="
if [[ -f /tmp/pip_packages.txt ]]; then
    while IFS= read -r tool; do
        [[ -z "$tool" ]] && continue
        test_command=$(get_test_command "$tool")
        test_tool "$tool" "$test_command" "Python Package"
    done < /tmp/pip_packages.txt
fi

# Test Go tools installed via 'go install'
echo ""
echo "=== Testing Go Tools ==="
if [[ -f /tmp/go_tools.txt ]]; then
    while IFS= read -r tool; do
        [[ -z "$tool" ]] && continue
        test_command=$(get_test_command "$tool")
        test_tool "$tool" "$test_command" "Go Tool"
    done < /tmp/go_tools.txt
fi

# Test manually installed binary tools
echo ""
echo "=== Testing Manually Installed Tools ==="
if [[ -f /tmp/manual_tools.txt ]]; then
    while IFS= read -r tool; do
        [[ -z "$tool" ]] && continue
        test_command=$(get_test_command "$tool")
        test_tool "$tool" "$test_command" "Manual Install"
    done < /tmp/manual_tools.txt
fi

# Clean up temporary files created during extraction
rm -f /tmp/dnf_packages.txt /tmp/pip_packages.txt /tmp/go_tools.txt /tmp/manual_tools.txt

# Display comprehensive test results summary
echo ""
echo "=== Test Suite Summary ==="
echo "Total tests run: $TOTAL_TESTS"
echo "Passed: $((TOTAL_TESTS - FAILED_TESTS))"
echo "Failed: $FAILED_TESTS"

# Exit with appropriate status code based on test results
if [ $FAILED_TESTS -eq 0 ]; then
    echo "✅ All tools from Dockerfile tested successfully!"
    echo "✅ Test Suite: COMPLETED"
    exit 0
else
    echo "❌ Failed tools:"
    printf '   - %s\n' "${FAILED_TOOLS[@]}"
    echo "❌ Test Suite: $FAILED_TESTS/$TOTAL_TESTS tests failed"
    exit 1
fi