#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PTERODACTYL_DIRECTORY=${PTERODACTYL_DIRECTORY:-/var/www/pterodactyl}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

uninstall_fireprint() {
    print_warning "=== FIRE-PRINT UNINSTALLATION ==="
    print_warning "This will remove all Fire-print files and configurations."
    
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Uninstallation cancelled."
        exit 0
    fi
    
    print_status "Starting Fire-print uninstallation..."
    
    # Remove Fire-print files
    local files_to_remove=(
        "$PTERODACTYL_DIRECTORY/blueprint.sh"
        "$PTERODACTYL_DIRECTORY/.blueprintrc"
        "$PTERODACTYL_DIRECTORY/fire-print.sh"
        "$PTERODACTYL_DIRECTORY/release.zip"
    )
    
    for file in "${files_to_remove[@]}"; do
        if [[ -f "$file" ]] || [[ -d "$file" ]]; then
            sudo rm -rf "$file"
            print_status "Removed: $file"
        fi
    done
    
    # Remove any Fire-print specific directories
    local dirs_to_remove=(
        "$PTERODACTYL_DIRECTORY/fire-print"
        "$PTERODACTYL_DIRECTORY/blueprint"
    )
    
    for dir in "${dirs_to_remove[@]}"; do
        if [[ -d "$dir" ]]; then
            sudo rm -rf "$dir"
            print_status "Removed directory: $dir"
        fi
    done
    
    print_success "Fire-print uninstallation completed!"
    print_warning "Note: System dependencies (Node.js, Yarn, etc.) were not removed."
    print_warning "To remove dependencies, run: sudo apt remove --purge nodejs yarn -y"
}

# Main execution
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
    exit 1
fi

uninstall_fireprint
