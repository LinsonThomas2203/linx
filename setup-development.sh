#!/bin/bash
echo "=================================================="
echo "🚀 ULTIMATE DEVELOPMENT ENVIRONMENT SETUP"
echo "=================================================="

# Update system first
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# ============================================================================
# DEVELOPMENT TOOLS INSTALLATION
# ============================================================================

echo "🐍 Installing Python and Data Science Stack..."
sudo apt install -y python3 python3-pip python3-venv python3-dev
pip3 install jupyter notebook jupyterlab pandas numpy matplotlib seaborn scikit-learn flask django requests

echo "☕ Installing Java and Spring Boot..."
sudo apt install -y openjdk-17-jdk maven gradle

echo "🟢 Installing Node.js and Next.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g npm@latest
sudo npm install -g create-next-app express nodemon react react-dom

echo "🛠️ Installing Development Tools..."
sudo snap install code --classic
sudo snap install postman
sudo apt install -y git curl wget vim nano htop tree

echo "🐘 Installing PostgreSQL..."
sudo apt install -y postgresql postgresql-contrib

echo "🐳 Installing Docker..."
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER

# ============================================================================
# DIRECTORY STRUCTURE SETUP
# ============================================================================

echo "📁 Creating directory structure..."

# Development workspace
sudo mkdir -p /projects/development/python-projects/{flask-apps,django-projects,ml-models}
sudo mkdir -p /projects/development/java-apps/{spring-boot,microservices}
sudo mkdir -p /projects/development/nodejs-apps/{nextjs-projects,express-apis}
sudo mkdir -p /projects/development/jupyter-notebooks/{data-science,experiments}
sudo mkdir -p /projects/development/ide-workspace
sudo mkdir -p /projects/git-repos
sudo mkdir -p /projects/builds
sudo mkdir -p /projects/archives

# Data directory
sudo mkdir -p /data/datasets/{csv,json,sqlite,images}
sudo mkdir -p /data/backups/{database,configs,code}
sudo mkdir -p /data/media/{images,videos,documents}
sudo mkdir -p /data/shared
sudo mkdir -p /data/production-configs

# Docker staging
sudo mkdir -p /var/lib/docker/staging/{postgres-data,superset,springboot,nextjs,monitoring}

# User workspace
mkdir -p /home/$USER/Linson_Thomas/{Documents,Downloads,Desktop,Pictures,Personal,Work,Projects,Data}

# Set ownership
sudo chown -R $USER:$USER /projects /data

# Create symlinks
ln -s /projects /home/$USER/Linson_Thomas/Projects
ln -s /data /home/$USER/Linson_Thomas/Data

# ============================================================================
# DOCKER STAGING ENVIRONMENT SETUP
# ============================================================================

echo "🐳 Setting up Docker Staging Environment..."

# Create docker-compose file for staging
sudo tee /var/lib/docker/staging/docker-compose.staging.yml << 'DOCKEREOF'
version: '3.8'
services:
  postgres-staging:
    image: postgres:15
    container_name: postgres-staging
    environment:
      POSTGRES_DB: staging_db
      POSTGRES_USER: developer
      POSTGRES_PASSWORD: lat123
    volumes:
      - ./postgres-data:/var/lib/postgresql/data
    ports:
      - "5433:5432"
    networks:
      - staging-network

  superset-staging:
    image: apache/superset
    container_name: superset-staging
    environment:
      SUPERSET_SECRET_KEY: development-key-123-linson-thomas
    ports:
      - "8088:8088"
    depends_on:
      - postgres-staging
    networks:
      - staging-network

  pgadmin-staging:
    image: dpage/pgadmin4
    container_name: pgadmin-staging
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@localhost.com
      PGADMIN_DEFAULT_PASSWORD: lat123
    ports:
      - "5050:80"
    depends_on:
      - postgres-staging
    networks:
      - staging-network

networks:
  staging-network:
    driver: bridge
DOCKEREOF

# ============================================================================
# VS CODE EXTENSIONS SETUP
# ============================================================================

echo "🔧 Installing VS Code Extensions..."

# Install essential VS Code extensions
code --install-extension ms-python.python
code --install-extension vscjava.vscode-java-pack
code --install-extension ms-vscode.vscode-typescript-next
code --install-extension bradlc.vscode-tailwindcss
code --install-extension ms-azuretools.vscode-docker
code --install-extension formulahendry.auto-rename-tag
code --install-extension esbenp.prettier-vscode
code --install-extension ritwickdey.liveserver

# ============================================================================
# ENVIRONMENT CONFIGURATION
# ============================================================================

echo "⚙️ Configuring environment..."

# Add to bashrc
cat >> /home/$USER/.bashrc << 'BASHRCEOF'

# ============================================================================
# DEVELOPMENT ENVIRONMENT VARIABLES
# ============================================================================
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin
export NODE_ENV=development
export PYTHONPATH=/projects/development/python-projects:$PYTHONPATH

# Application Aliases
alias docker-staging='cd /var/lib/docker/staging && docker-compose -f docker-compose.staging.yml'
alias jupyter-dev='jupyter notebook --notebook-dir=/projects/development/jupyter-notebooks --ip=0.0.0.0 --no-browser'
alias projects='cd /projects/development'
alias data='cd /data'
alias staging='cd /var/lib/docker/staging'

# Quick verification commands
alias check-storage='df -h | grep nvme'
alias check-docker='docker ps'
alias check-services='sudo systemctl status postgresql docker'

echo "=== DEVELOPMENT ENVIRONMENT LOADED ==="
echo "Commands: docker-staging, jupyter-dev, projects, data, staging"
echo "Verification: check-storage, check-docker, check-services"
BASHRCEOF

# ============================================================================
# JUPYTER NOTEBOOK CONFIGURATION
# ============================================================================

echo "📓 Configuring Jupyter Notebook..."
jupyter notebook --generate-config

# Update Jupyter config to use our workspace
JUPYTER_CONFIG=/home/$USER/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.notebook_dir = '/projects/development/jupyter-notebooks'" >> $JUPYTER_CONFIG
echo "c.NotebookApp.allow_origin = '*'" >> $JUPYTER_CONFIG
echo "c.NotebookApp.open_browser = False" >> $JUPYTER_CONFIG

# ============================================================================
# GIT CONFIGURATION
# ============================================================================

echo "🔧 Configuring Git..."
git config --global user.name "Linson Thomas"
git config --global user.email "linson-thomas@localhost"
git config --global init.defaultBranch main

# ============================================================================
# POSTGRESQL CONFIGURATION
# ============================================================================

echo "🐘 Configuring PostgreSQL..."
sudo -u postgres psql -c "CREATE USER linson_thomas WITH PASSWORD 'lat123';"
sudo -u postgres psql -c "ALTER USER linson_thomas CREATEDB;"
sudo -u postgres psql -c "CREATE DATABASE linson_dev OWNER linson_thomas;"

# ============================================================================
# FINAL SETUP AND PERMISSIONS
# ============================================================================

echo "🔐 Setting final permissions..."
sudo chown -R $USER:$USER /projects
sudo chown -R $USER:$USER /data
sudo chmod -R 755 /projects
sudo chmod -R 755 /data

# Start and enable services
sudo systemctl enable postgresql
sudo systemctl enable docker
sudo systemctl start postgresql
sudo systemctl start docker

# ============================================================================
# COMPLETION MESSAGE
# ============================================================================

echo ""
echo "=================================================="
echo "🎉 DEVELOPMENT ENVIRONMENT SETUP COMPLETE!"
echo "=================================================="
echo ""
echo "✅ STORAGE ARCHITECTURE:"
echo "   /projects/development/    - Active coding workspace"
echo "   /var/lib/docker/staging/  - Container staging environment"
echo "   /data/                    - Datasets and backups"
echo "   /home/linson-thomas/      - User configuration"
echo ""
echo "✅ APPLICATIONS INSTALLED:"
echo "   🐍 Python 3 + Jupyter + Data Science Stack"
echo "   ☕ Java 17 + Spring Boot + Maven/Gradle"
echo "   🟢 Node.js + Next.js + npm"
echo "   🛠️ VS Code + Postman + Git"
echo "   🐘 PostgreSQL + PgAdmin"
echo "   📊 Apache Superset"
echo "   🐳 Docker + Docker Compose"
echo ""
echo "🚀 QUICK START COMMANDS:"
echo "   docker-staging up -d      # Start staging environment"
echo "   jupyter-dev               # Start Jupyter notebooks"
echo "   code /projects/development # Open VS Code"
echo "   check-storage             # Verify storage architecture"
echo ""
echo "🌐 STAGING SERVICES:"
echo "   Superset:    http://localhost:8088"
echo "   PgAdmin:     http://localhost:5050"
echo "   PostgreSQL:  localhost:5433"
echo ""
echo "🔧 RESTART TERMINAL TO LOAD NEW ALIASES: source ~/.bashrc"
echo "=================================================="

# Reload bash configuration
source /home/$USER/.bashrc
