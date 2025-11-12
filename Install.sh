#!/bin/bash
# FirePrint Installer Script
# Author: YourName
# GitHub: https://github.com/username/fireprint

set -e

# Colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m" # No Color

echo -e "${YELLOW}==============================="
echo -e "🔥 FIREPRINT INSTALLER 🔥"
echo -e "===============================${NC}"
echo ""
echo "1) Install FirePrint"
echo "2) Delete FirePrint"
echo "3) Install All"
echo "0) Exit"
echo ""

read -p "Choose an option [1-3]: " choice

case $choice in
  1)
    echo -e "${GREEN}Installing FirePrint...${NC}"
    # 🔹 Your install command(s) here:
    sudo cp fireprint.sh /usr/local/bin/fireprint
    sudo chmod +x /usr/local/bin/fireprint
    echo -e "${GREEN}✅ FirePrint installed! Run with: fireprint${NC}"
    ;;

  2)
    echo -e "${RED}Deleting FirePrint...${NC}"
    # 🔹 Your delete command(s) here:
    sudo rm -f /usr/local/bin/fireprint
    echo -e "${RED}❌ FirePrint removed.${NC}"
    ;;

  3)
    echo -e "${YELLOW}Installing all components...${NC}"
    # 🔹 Commands for “Install All”
    sudo apt update
    sudo apt install -y git curl
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
