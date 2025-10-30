#!/bin/bash
# Post-Installation Setup - Runs after system installation
# Installs development tools and configures environment

set -e

LOG_FILE="/var/log/post-install.log"
exec > >(tee -a $LOG_FILE) 2>&1

log() {
    echo "$(date): $1" | tee -a $LOG_FILE
}

install_development_tools() {
    log "Installing development tools..."
    
    # Update system
    apt update && apt upgrade -y
    
    # Essential development tools
    apt install -y \
        git curl wget vim nano \
        build-essential software-properties-common \
        apt-transport-https ca-certificates gnupg lsb-release
    
    # Version Control
    apt install -y git git-lfs
    
    # Container tools
    apt install -y docker.io docker-compose podman buildah
    usermod -aG docker $SUDO_USER
    
    # Programming Languages
    apt install -y python3 python3-pip python3-venv python3-dev
    apt install -y openjdk-17-jdk maven gradle
    
    # Node.js
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt install -y nodejs
    
    # Database
    apt install -y postgresql postgresql-contrib
    apt install -y sqlite3
    
    log "Development tools installed successfully"
}

install_applications() {
    log "Installing applications..."
    
    # VS Code
    snap install code --classic
    
    # Jupyter
    pip3 install jupyter jupyterlab notebook
    
    # Postman
    snap install postman
    
    # Chrome
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
    apt update && apt install -y google-chrome-stable
    
    # Spotify
    snap install spotify
    
    log "Applications installed successfully"
}

configure_development_environment() {
    log "Configuring development environment..."
    
    # Create development directory structure
    mkdir -p /workspace/projects
    mkdir -p /workspace/sandbox
    mkdir -p /workspace/temp
    
    # Set permissions
    chown -R $SUDO_USER:$SUDO_USER /workspace
    chown -R $SUDO_USER:$SUDO_USER /opt/ide
    
    # Configure Git
    sudo -u $SUDO_USER git config --global user.name "Developer"
    sudo -u $SUDO_USER git config --global user.email "developer@localhost"
    
    # Install VS Code extensions
    sudo -u $SUDO_USER code --install-extension ms-python.python
    sudo -u $SUDO_USER code --install-extension ms-vscode.vscode-typescript-next
    sudo -u $SUDO_USER code --install-extension vscjava.vscode-java-pack
    sudo -u $SUDO_USER code --install-extension bradlc.vscode-tailwindcss
    
    log "Development environment configured"
}

main() {
    log "=== Starting Post-Installation Setup ==="
    
    # Wait for network
    while ! ping -c1 archive.ubuntu.com &>/dev/null; do
        log "Waiting for network connection..."
        sleep 5
    done
    
    install_development_tools
    install_applications
    configure_development_environment
    
    log "=== Post-Installation Setup Complete ==="
    log "System ready for development work!"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

main "$@"