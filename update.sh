#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PTERODACTYL_DIRECTORY=${PTERODACTYL_DIRECTORY:-/var/www/pterodactyl}
FIREPRINT_REPO="https://github.com/FIRE90YT/Fire-print.git"

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

update_fireprint() {
    print_status "Checking for Fire-print updates..."
    
    # Navigate to Pterodactyl directory
    cd "$PTERODACTYL_DIRECTORY" || {
        print_error "Cannot access Pterodactyl directory: $PTERODACTYL_DIRECTORY"
        exit 1
    }
    
    # Backup current configuration
    if [[ -f ".blueprintrc" ]]; then
        cp .blueprintrc .blueprintrc.backup
        print_status "Configuration backed up to .blueprintrc.backup"
    fi
    
    # Download latest version
    print_status "Downloading latest Fire-print release..."
    
    if wget "$(curl -s https://api.github.com/repos/FIRE90YT/Fire-print/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip 2>/dev/null; then
        # Remove old files (keep backup)
        [[ -f "blueprint.sh" ]] && mv blueprint.sh blueprint.sh.old
        [[ -f "fire-print.sh" ]] && mv fire-print.sh fire-print.sh.old
        
        # Extract new files
        unzip -o release.zip
        rm -f release.zip
        
        # Restore configuration if needed
        if [[ -f ".blueprintrc.backup" ]] && [[ ! -f ".blueprintrc" ]]; then
            cp .blueprintrc.backup .blueprintrc
            print_status "Configuration restored from backup"
        fi
        
        # Set execute permissions
        chmod +x blueprint.sh fire-print.sh 2>/dev/null || true
        
        print_success "Fire-print updated successfully!"
        
        # Clean up old files
        rm -f blueprint.sh.old fire-print.sh.old .blueprintrc.backup
        
    else
        print_error "Failed to download update. Please check your internet connection."
        exit 1
    fi
}

# Main execution
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
    exit 1
fi

update_fireprint
