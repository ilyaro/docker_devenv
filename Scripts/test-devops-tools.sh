#!/bin/bash
# filepath: /Users/ilyaro/GitHub/docker_devenv/Scripts/test-devops-tools.sh
# Comprehensive DevOps Tools Validation Script
# Tests all tools defined in Config/tools_list.yaml to ensure proper installation

echo "=== DevOps Tools Validation Test Suite ==="

# Configuration and script setup - use YAML config as single source of truth
TOOLS_CONFIG="Config/tools_list.yaml"
TOTAL_TESTS=0          # Counter for total number of tests executed
FAILED_TESTS=0         # Counter for failed tests
FAILED_TOOLS=()        # Array to store names of failed tools
SKIPPED_TESTS=0        # Counter for skipped tests

# Function to execute tool tests with comprehensive error handling
test_tool() {
    local tool_name="$1"      # Name of the tool being tested
    local command="$2"        # Command to execute for testing
    local category="${3:-General}"  # Category of the tool (default: General)
    local optional="${4:-false}"    # Whether the tool is optional (default: false)
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo "Testing [$category] $tool_name..."
    
    # Execute test command and capture both stdout and stderr for better debugging
    local output
    if output=$(eval "$command" 2>&1); then
        echo "✅ $tool_name: PASSED"
        # Display version information for key infrastructure tools to aid in debugging
        if [[ "$tool_name" =~ ^(terraform|kubectl|helm|docker)$ ]]; then
            echo "   📋 $(echo "$output" | head -1)"
        fi
    else
        # Handle test failures based on whether tool is optional
        if [[ "$optional" == "true" ]]; then
            echo "⚠️  $tool_name: SKIPPED (optional tool)"
            SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
        else
            echo "❌ $tool_name: FAILED"
            echo "   💻 Command executed: $command"
            echo "   📝 Error output: $output"
            echo "   ---"
            FAILED_TESTS=$((FAILED_TESTS + 1))
            FAILED_TOOLS+=("$tool_name")
        fi
    fi
}

# Function to generate appropriate test command for DNF packages
# This handles the variety of ways different packages can be tested
get_dnf_test_command() {
    local tool="$1"
    
    case "$tool" in
        # Tools that support standard --version flag
        bash-completion|bc|git|less|nano|htop|tree|jq|make|man-db) 
            echo "$tool --version 2>/dev/null || which $tool"
            ;;
        # Vim variants - test using vim command with version flag
        vim*) 
            echo "vim --version | head -1"
            ;;
        # Python and pip related tools
        python3-pip) 
            echo "pip3 --version" 
            ;;
        # Network diagnostic tools
        bind-utils) 
            echo "nslookup -version 2>/dev/null || which nslookup || which dig" 
            ;;
        # Certificate management verification
        ca-certificates) 
            echo "ls /etc/pki/tls/certs/ca-bundle.crt" 
            ;;
        # Development header packages (verify via rpm since they don't have executables)
        *-devel) 
            echo "rpm -q $tool" 
            ;;
        # Container runtime tools
        docker*) 
            echo "docker --version 2>/dev/null || which docker" 
            ;;
        # Cloud CLI tools
        awscli) 
            echo "aws --version" 
            ;;
        # Shell environments
        zsh) 
            echo "zsh --version | head -1" 
            ;;
        # Programming language runtimes
        golang) 
            echo "go version" 
            ;;
        nodejs) 
            echo "node --version" 
            ;;
        # System monitoring tools with special handling
        htop) 
            echo "htop --version 2>/dev/null || which htop" 
            ;;
        # Default approach: check existence using which or rpm query
        *) 
            echo "which $tool 2>/dev/null || rpm -q $tool 2>/dev/null" 
            ;;
    esac
}

# Validate that tools configuration file exists
if [[ ! -f "$TOOLS_CONFIG" ]]; then
    echo "❌ Tools configuration file not found: $TOOLS_CONFIG"
    echo "   Please ensure the tools_list.yaml file exists in the Config directory"
    exit 1
fi

# Ensure yq YAML parser is available for configuration processing
if ! command -v yq &> /dev/null; then
    echo "⚠️  yq YAML processor not found, attempting installation..."
    if command -v go &> /dev/null; then
        echo "   Installing yq using Go package manager..."
        go install github.com/mikefarah/yq/v4@latest
        export PATH="$PATH:$(go env GOPATH)/bin"
    else
        echo "❌ Cannot parse YAML configuration without yq or Go runtime"
        echo "   Please install either 'yq' or 'go' to continue"
        exit 1
    fi
fi

echo "📋 Loading and processing tools configuration from: $TOOLS_CONFIG"

# Test all DNF packages organized by category
echo ""
echo "=== Validating DNF System Packages ==="
for category in $(yq eval '.dnf_packages | keys | .[]' "$TOOLS_CONFIG"); do
    echo ""
    echo "--- Testing DNF Package Category: $category ---"
    
    # Process each tool in the current category
    yq eval ".dnf_packages.$category[]" "$TOOLS_CONFIG" | while read -r tool; do
        [[ -z "$tool" ]] && continue  # Skip empty entries
        test_command=$(get_dnf_test_command "$tool")
        test_tool "$tool" "$test_command" "DNF-$category"
    done
done

# Test all Python packages with import verification
echo ""
echo "=== Validating Python Packages ==="
for category in $(yq eval '.python_packages | keys | .[]' "$TOOLS_CONFIG"); do
    echo ""
    echo "--- Testing Python Package Category: $category ---"
    
    # Test Python packages with appropriate import or command tests
    yq eval ".python_packages.$category[]" "$TOOLS_CONFIG" | while read -r package; do
        [[ -z "$package" ]] && continue  # Skip empty entries
        
        # Generate appropriate test command based on package name
        case "$package" in
            pyyaml) 
                test_tool "$package" "python3 -c 'import yaml; print(\"PyYAML version:\", yaml.__version__)'" "Python-$category" 
                ;;
            redis) 
                test_tool "$package" "python3 -c 'import redis; print(\"Redis client library available\")'" "Python-$category" 
                ;;
            aws-sso-util) 
                test_tool "$package" "aws-sso-util --version" "Python-$category" 
                ;;
            awsume) 
                test_tool "$package" "awsume --version" "Python-$category" 
                ;;
            git-remote-codecommit) 
                test_tool "$package" "python3 -c 'import git_remote_codecommit; print(\"CodeCommit helper available\")'" "Python-$category" 
                ;;
            azure-cli) 
                test_tool "$package" "az --version | head -3" "Python-$category" 
                ;;
            *) 
                # Generic Python import test for unlisted packages
                test_tool "$package" "python3 -c 'import $package; print(\"$package library available\")'" "Python-$category" 
                ;;
        esac
    done
done

# Test all Go-based tools
echo ""
echo "=== Validating Go-based Tools ==="
for category in $(yq eval '.go_tools | keys | .[]' "$TOOLS_CONFIG"); do
    echo ""
    echo "--- Testing Go Tools Category: $category ---"
    
    # Process Go packages and test the resulting binaries
    yq eval ".go_tools.$category[]" "$TOOLS_CONFIG" | while read -r go_package; do
        [[ -z "$go_package" ]] && continue  # Skip empty entries
        
        # Extract binary name from Go package path (usually the last component)
        tool_name=$(basename "$go_package")
        
        # Handle special cases for Go tools that have different binary names
        case "$go_package" in
            *github.com/mikefarah/yq/v4*) 
                test_tool "yq" "yq --version" "Go-$category" 
                ;;
            *github.com/google/go-containerregistry/cmd/crane*) 
                test_tool "crane" "crane version" "Go-$category" 
                ;;
            *) 
                test_tool "$tool_name" "$tool_name --version 2>/dev/null || which $tool_name" "Go-$category"
                ;;
        esac
    done
done

# Test manually installed binary tools
echo ""
echo "=== Validating Manually Installed Tools ==="
for category in $(yq eval '.manual_tools | keys | .[]' "$TOOLS_CONFIG"); do
    echo ""
    echo "--- Testing Manual Tools Category: $category ---"
    
    # Get count of tools in this category for iteration
    tool_count=$(yq eval ".manual_tools.$category | length" "$TOOLS_CONFIG")
    
    # Process each tool in the category
    for i in $(seq 0 $((tool_count - 1))); do
        tool_name=$(yq eval ".manual_tools.$category[$i].name" "$TOOLS_CONFIG")
        test_command=$(yq eval ".manual_tools.$category[$i].test_command" "$TOOLS_CONFIG")
        
        # Skip entries with null or empty values
        [[ -z "$tool_name" || "$tool_name" == "null" ]] && continue
        [[ -z "$test_command" || "$test_command" == "null" ]] && continue
        
        test_tool "$tool_name" "$test_command" "Manual-$category"
    done
done

# Execute special validation tests for complex scenarios
echo ""
echo "=== Running Special Validation Tests ==="
for category in $(yq eval '.special_tests | keys | .[]' "$TOOLS_CONFIG"); do
    echo ""
    echo "--- Testing Special Category: $category ---"
    
    # Get count of tests in this category
    test_count=$(yq eval ".special_tests.$category | length" "$TOOLS_CONFIG")
    
    # Execute each special test
    for i in $(seq 0 $((test_count - 1))); do
        test_name=$(yq eval ".special_tests.$category[$i].name" "$TOOLS_CONFIG")
        test_command=$(yq eval ".special_tests.$category[$i].command" "$TOOLS_CONFIG")
        
        # Skip entries with null or empty values
        [[ -z "$test_name" || "$test_name" == "null" ]] && continue
        [[ -z "$test_command" || "$test_command" == "null" ]] && continue
        
        test_tool "$test_name" "$test_command" "Special-$category"
    done
done

# Generate comprehensive test execution summary
echo ""
echo "=== DevOps Tools Test Suite Summary Report ==="
echo "📊 Total tests executed: $TOTAL_TESTS"
echo "✅ Tests passed: $((TOTAL_TESTS - FAILED_TESTS - SKIPPED_TESTS))"
echo "❌ Tests failed: $FAILED_TESTS"
echo "⚠️  Tests skipped: $SKIPPED_TESTS"

# Calculate and display success rate
if [ $TOTAL_TESTS -gt 0 ]; then
    success_rate=$(echo "scale=2; ($TOTAL_TESTS - $FAILED_TESTS) * 100 / $TOTAL_TESTS" | bc 2>/dev/null || echo "N/A")
    echo "📈 Success rate: ${success_rate}%"
fi

# Final exit logic based on test results
if [ $FAILED_TESTS -eq 0 ]; then
    echo ""
    echo "🎉 All critical tools from configuration validated successfully!"
    echo "✅ DevOps environment is ready for use"
    echo "✅ Test Suite Status: PASSED"
    exit 0
else
    echo ""
    echo "🚨 The following tools failed validation:"
    printf '   ❌ %s\n' "${FAILED_TOOLS[@]}"
    echo ""
    echo "💡 Troubleshooting Tips:"
    echo "   • Verify that all tools are properly installed in the container"
    echo "   • Check the tool names and test commands in $TOOLS_CONFIG"
    echo "   • Ensure all dependencies and prerequisites are available"
    echo "   • Review the error output above for specific failure details"
    echo ""
    echo "❌ Test Suite Status: FAILED ($FAILED_TESTS/$TOTAL_TESTS failures)"
    exit 1
fi