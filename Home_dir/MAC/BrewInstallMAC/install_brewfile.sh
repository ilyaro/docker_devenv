#!/bin/bash

# Print header
echo "=========================================================="
echo "Executing Brewfile"
echo "=========================================================="

# Check if Homebrew is installed, install if not
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for the current session if needed
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> $HOME/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "Homebrew is already installed. Updating..."
    brew update
fi

# Check if Brewfile exists in current directory
if [ -f "./Brewfile" ]; then
    BREWFILE="./Brewfile"
elif [ -f "$HOME/Brewfile" ]; then
    BREWFILE="$HOME/Brewfile"
else
    echo "Error: Brewfile not found in current directory or home directory."
    exit 1
fi

echo "=========================================================="
echo "Running brew bundle with Brewfile: $BREWFILE"
echo "=========================================================="

# Execute the Brewfile
brew bundle --file=$BREWFILE

echo "=========================================================="
echo "Brewfile installation complete. Installing additional tools..."
echo "=========================================================="

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh is already installed."
fi

# Install Powerlevel10k theme if not already installed
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    echo "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    echo "Powerlevel10k theme is already installed."
fi

# Install ZSH plugins if not already installed
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
else
    echo "zsh-autosuggestions is already installed."
fi

if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-interactive-cd" ]; then
    echo "Installing zsh-interactive-cd..."
    git clone https://github.com/changyuheng/zsh-interactive-cd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-interactive-cd
else
    echo "zsh-interactive-cd is already installed."
fi

# Install helm-secrets plugin if helm is installed
if command -v helm &> /dev/null; then
    if ! helm plugin list 2>/dev/null | grep -q "secrets"; then
        echo "Installing helm-secrets..."
        helm plugin install https://github.com/jkroepke/helm-secrets
    else
        echo "helm-secrets plugin is already installed."
    fi
else
    echo "Helm is not installed yet. Skipping helm-secrets installation."
fi

# Install SOPS if not already installed
if ! command -v sops &> /dev/null; then
    echo "Installing SOPS..."
    if [[ $(uname -m) == 'arm64' ]]; then
        curl -LO https://github.com/getsops/sops/releases/download/v3.9.4/sops-v3.9.4.darwin.arm64
        sudo mv sops-v3.9.4.darwin.arm64 /usr/local/bin/sops
        sudo chmod +x /usr/local/bin/sops
    else
        curl -LO https://github.com/getsops/sops/releases/download/v3.9.4/sops-v3.9.4.darwin.amd64
        sudo mv sops-v3.9.4.darwin.amd64 /usr/local/bin/sops
        sudo chmod +x /usr/local/bin/sops
    fi
else
    echo "SOPS is already installed."
fi

# Setup m1-terraform-provider-helper if on Apple Silicon
if [[ $(uname -m) == 'arm64' ]] && command -v m1-terraform-provider-helper &> /dev/null; then
    echo "Setting up m1-terraform-provider-helper..."
    m1-terraform-provider-helper activate
    m1-terraform-provider-helper install hashicorp/template -v v2.2.0
fi

# Update .zshrc if it exists
if [ -f "$HOME/.zshrc" ] && command -v zsh &> /dev/null; then
    echo "Updating .zshrc configuration..."
    
    # Check if plugins line exists in .zshrc
    if grep -q "^plugins=(" "$HOME/.zshrc"; then
        # Add plugins if they're not already in the list
        if ! grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
            sed -i '' -e 's/^plugins=(/plugins=(zsh-autosuggestions /' "$HOME/.zshrc" 2>/dev/null || \
            sed -i -e 's/^plugins=(/plugins=(zsh-autosuggestions /' "$HOME/.zshrc"
        fi
        if ! grep -q "zsh-interactive-cd" "$HOME/.zshrc"; then
            sed -i '' -e 's/^plugins=(/plugins=(zsh-interactive-cd /' "$HOME/.zshrc" 2>/dev/null || \
            sed -i -e 's/^plugins=(/plugins=(zsh-interactive-cd /' "$HOME/.zshrc"
        fi
    else
        echo 'plugins=(git zsh-autosuggestions zsh-interactive-cd)' >> "$HOME/.zshrc"
    fi
    
    # Set theme to powerlevel10k if not already set
    if ! grep -q "ZSH_THEME=\"powerlevel10k\/powerlevel10k\"" "$HOME/.zshrc"; then
        sed -i '' -e 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc" 2>/dev/null || \
        sed -i -e 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
    fi
fi

echo "=========================================================="
echo "Environment setup complete"
echo "=========================================================="

echo "To apply changes to your current shell, restart your terminal or run:"
echo "source ~/.zshrc"
