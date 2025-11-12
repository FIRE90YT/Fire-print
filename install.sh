#!/bin/bash
# ===================================================
# 🔥 FirePrint Installer Script
# Author: FIRE90YT
# GitHub: https://github.com/FIRE90YT/Fire-print
# ===================================================

set -e

# Colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m"

# Directory
export PTERODACTYL_DIRECTORY=/var/www/pterodactyl

clear
echo -e "${YELLOW}==============================="
echo -e "🔥 FIREPRINT INSTALLER 🔥"
echo -e "===============================${NC}"
echo ""
echo "Select an option:"
echo "1) Install FirePrint"
echo "2) Delete FirePrint"
echo "3) Install FirePrint Files (Dependencies & Setup)"
echo ""
read -p "Enter choice [1-3]: " choice

case $choice in
1)
    echo -e "${GREEN}Installing FirePrint...${NC}"
    cd /var/www/pterodactyl
    git clone https://github.com/FIRE90YT/Fire-print.git fireprint-temp
    cp -r fireprint-temp/* .
    rm -rf fireprint-temp
    echo -e "${GREEN}✅ FirePrint installed successfully!${NC}"
    ;;
2)
    echo -e "${RED}Deleting FirePrint...${NC}"
    cd /var/www/pterodactyl
    rm -rf fireprint-temp Fire-print fireprint.sh
    echo -e "${GREEN}🗑️ FirePrint deleted successfully.${NC}"
    ;;
3)
    echo -e "${YELLOW}Installing dependencies and files...${NC}"
    sudo apt install -y curl wget unzip git ca-certificates gnupg zip

    cd $PTERODACTYL_DIRECTORY

    wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip
    unzip -o release.zip
    rm release.zip

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
    sudo apt update
    sudo apt install -y nodejs

    npm i -g yarn
    yarn install

    touch $PTERODACTYL_DIRECTORY/.blueprintrc
    echo 'WEBUSER="www-data";
OWNERSHIP="www-data:www-data";
USERSHELL="/bin/bash";' > $PTERODACTYL_DIRECTORY/.blueprintrc

    chmod +x $PTERODACTYL_DIRECTORY/blueprint.sh
    bash $PTERODACTYL_DIRECTORY/blueprint.sh

    echo -e "${GREEN}✅ All dependencies and setup files installed successfully!${NC}"
    ;;
*)
    echo -e "${RED}❌ Invalid choice. Please run the script again.${NC}"
    ;;
esac
