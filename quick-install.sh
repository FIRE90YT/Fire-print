#!/bin/bash
set -e

echo "🚀 Starting Quick Blueprint Installation..."
export PTERODACTYL_DIRECTORY=/var/www/pterodactyl

# Check directory
if [ ! -d "$PTERODACTYL_DIRECTORY" ]; then
    echo "❌ Pterodactyl directory not found. Please install Pterodactyl first."
    exit 1
fi

cd $PTERODACTYL_DIRECTORY

# Install dependencies
sudo apt update
sudo apt install -y curl wget unzip ca-certificates git gnupg zip

# Download Blueprint
wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip
unzip -o release.zip
rm release.zip

# Install Node.js
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update
sudo apt install -y nodejs

# Install dependencies
npm i -g yarn
yarn install

# Create config
cat > .blueprintrc << 'EOF'
WEBUSER="www-data"
OWNERSHIP="www-data:www-data"
USERSHELL="/bin/bash"
EOF

# Make executable and run
chmod +x blueprint.sh
echo "✅ Installation complete! Run: bash blueprint.sh"
