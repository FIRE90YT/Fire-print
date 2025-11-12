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
echo "3) Install All (Deps + Setup)"
echo "0) Exit"
echo ""

read -p "Choose an option [0-3]: " choice

case $choice in
  1)
    echo -e "${GREEN}Installing FirePrint...${NC}"
    # Clone repo if not present
    if [ ! -d "/opt/Fire-print-" ]; then
      sudo git clone https://github.com/FIRE90YT/Fire-print-.git /opt/Fire-print
    fi
    cd /opt/Fire-print-
    npm install
    sudo cp fireprint.sh /usr/local/bin/fireprint
    sudo chmod +x /usr/local/bin/fireprint
    echo -e "${GREEN}✅ FirePrint installed! Run it with: fireprint${NC}"
    ;;

  2)
    echo -e "${RED}Deleting FirePrint...${NC}"
    sudo rm -rf /opt/Fire-print-
    sudo rm -f /usr/local/bin/fireprint
    echo -e "${RED}❌ FirePrint completely removed.${NC}"
    ;;

  3)
    echo -e "${YELLOW}Installing all components...${NC}"
    sudo apt update
    sudo apt install -y git curl nodejs npm
    if [ ! -d "/opt/Fire-print-" ]; then
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
