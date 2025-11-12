#!/bin/bash
# FirePrint Installer Script
# Author: FIRE90YT
# GitHub: https://github.com/FIRE90YT/Fire-print-

set -e

# Colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m" # No Color

clear
echo -e "${YELLOW}==============================="
echo -e "🔥 FIREPRINT INSTALLER 🔥"
echo -e "===============================${NC}"
echo ""
echo "1) Install FirePrint"
echo "2) Delete FirePrint"
echo "3) Install All (Dependencies + Setup)"
echo "0) Exit"
echo ""

read -p "Choose an option [0-3]: " choice

case $choice in
  1)
    echo -e "${GREEN}Installing FirePrint...${NC}"
    # Clone repo if not present
    if [ ! -d "/opt/Fire-print" ]; then
      sudo git clone https://github.com/FIRE90YT/Fire-print-.git /opt/Fire-print
    fi

    cd /opt/Fire-print
    npm install

    sudo cp fireprint.sh /usr/local/bin/fireprint
    sudo chmod +x /usr/local/bin/fireprint

    echo -e "${GREEN}✅ FirePrint installed! Run it with: fireprint${NC}"
    ;;

  2)
    echo -e "${RED}Deleting FirePrint...${NC}"
    sudo rm -rf /opt/Fire-print
    sudo rm -f /usr/local/bin/fireprint
    echo -e "${RED}❌ FirePrint completely removed.${NC}"
    ;;

  3)
    echo -e "${YELLOW}Installing all dependencies and FirePrint setup...${NC}"
    sudo apt update
    sudo apt install -y curl wget git unzip zip ca-certificates gnupg nodejs npm

    # Add Node.js repository (for Node 20)
    if ! command -v node &> /dev/null || [[ $(node -v) != v20* ]]; then
      echo -e "${YELLOW}Installing Node.js 20...${NC}"
      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
      echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
      sudo apt update
      sudo apt install -y nodejs
    fi

    # Clone and install FirePrint
    if [ ! -d "/opt/Fire-print" ]; then
      sudo git clone https://github.com/FIRE90YT/Fire-print-.git /opt/Fire-print
    fi

    cd /opt/Fire-print
    npm install

    sudo cp fireprint.sh /usr/local/bin/fireprint
    sudo chmod +x /usr/local/bin/fireprint

    echo -e "${GREEN}✅ All components installed successfully!${NC}"
    ;;

  0)
    echo "Exiting..."
    exit 0
    ;;

  *)
    echo -e "${RED}Invalid option!${NC}"
    ;;
esac


# ===============================
# Optional: Install Blueprint for Pterodactyl
# ===============================
export PTERODACTYL_DIRECTORY=/var/www/pterodactyl

echo -e "${YELLOW}Setting up Blueprint for Pterodactyl (optional)...${NC}"
sudo apt install -y curl wget unzip git

cd $PTERODACTYL_DIRECTORY

# Download and extract latest Blueprint release
LATEST_URL=$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)
wget "$LATEST_URL" -O release.zip
unzip -o release.zip
rm -f release.zip

# Install Node dependencies for Pterodactyl + Blueprint
npm i -g yarn
yarn install

# Configure Blueprint runtime
cat <<EOF > $PTERODACTYL_DIRECTORY/.blueprintrc
WEBUSER="www-data";
OWNERSHIP="www-data:www-data";
USERSHELL="/bin/bash";
EOF

chmod +x $PTERODACTYL_DIRECTORY/blueprint.sh
bash $PTERODACTYL_DIRECTORY/blueprint.sh

echo -e "${GREEN}✅ Blueprint installation completed!${NC}"
