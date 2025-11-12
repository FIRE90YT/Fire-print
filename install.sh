#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Banner
echo "========================================="
echo "   Blueprint Framework Installer"
echo "   studio.ggnodes.xyz"
echo "========================================="

# Check sudo
if ! sudo -n true 2>/dev/null; then
    log_error "sudo access required"
    exit 1
fi

# Set directory
PTERODACTYL_DIRECTORY="/var/www/pterodactyl"

# Check if Pterodactyl directory exists
if [ ! -d "$PTERODACTYL_DIRECTORY" ]; then
    log_error "Pterodactyl directory not found: $PTERODACTYL_DIRECTORY"
    log_info "Please install Pterodactyl first or specify custom directory"
    read -p "Enter custom Pterodactyl directory path: " custom_dir
    if [ -n "$custom_dir" ] && [ -d "$custom_dir" ]; then
        PTERODACTYL_DIRECTORY="$custom_dir"
        log_info "Using custom directory: $PTERODACTYL_DIRECTORY"
    else
        log_error "Invalid directory. Exiting."
        exit 1
    fi
fi

export PTERODACTYL_DIRECTORY

log_step "1. Installing system dependencies..."
sudo apt update
sudo apt install -y curl wget unzip ca-certificates git gnupg zip

log_step "2. Downloading Blueprint Framework..."
cd "$PTERODACTYL_DIRECTORY"
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)
log_info "Downloading from: $DOWNLOAD_URL"
wget "$DOWNLOAD_URL" -O release.zip
unzip -o release.zip
rm -f release.zip

log_step "3. Installing Node.js..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update
sudo apt install -y nodejs

log_step "4. Installing project dependencies..."
npm i -g yarn
yarn install

log_step "5. Creating configuration..."
cat > .blueprintrc << EOF
WEBUSER="www-data"
OWNERSHIP="www-data:www-data"
USERSHELL="/bin/bash"
EOF

log_step "6. Setting up Blueprint..."
chmod +x blueprint.sh

log_info "🎉 Installation ready!"
echo ""
log_info "To complete setup, run:"
echo "cd $PTERODACTYL_DIRECTORY"
echo "bash blueprint.sh"
echo ""
read -p "Do you want to run blueprint.sh now? (y/n): " run_now
if [ "$run_now" = "y" ] || [ "$run_now" = "Y" ]; then
    log_info "Running blueprint.sh..."
    bash blueprint.sh
else
    log_info "You can run it later with: bash $PTERODACTYL_DIRECTORY/blueprint.sh"
fi
