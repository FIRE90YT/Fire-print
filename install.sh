
## install.sh

```bash
#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default Pterodactyl directory
PTERODACTYL_DIRECTORY=${PTERODACTYL_DIRECTORY:-/var/www/pterodactyl}
FIREPRINT_REPO="https://github.com/FIRE90YT/Fire-print.git"

# Function to print colored output
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

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
        exit 1
    fi
}

# Function to install dependencies
install_dependencies() {
    print_status "Installing system dependencies..."
    sudo apt update
    sudo apt install -y curl wget unzip ca-certificates git gnupg zip
}

# Function to install Node.js
install_nodejs() {
    print_status "Installing Node.js..."
    
    # Check if Node.js is already installed
    if command -v node &> /dev/null && node --version | grep -q "v20"; then
        print_success "Node.js 20+ is already installed"
        return 0
    fi
    
    # Add Node.js apt repository
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
    
    sudo apt update
    sudo apt install -y nodejs
    
    # Verify installation
    if command -v node &> /dev/null; then
        print_success "Node.js $(node --version) installed successfully"
    else
        print_error "Failed to install Node.js"
        return 1
    fi
}

# Function to install Yarn
install_yarn() {
    print_status "Installing Yarn..."
    
    if command -v yarn &> /dev/null; then
        print_success "Yarn is already installed"
        return 0
    fi
    
    npm i -g yarn
    
    if command -v yarn &> /dev/null; then
        print_success "Yarn installed successfully"
    else
        print_error "Failed to install Yarn"
        return 1
    fi
}

# Function to download and extract Fire-print
download_fireprint() {
    print_status "Downloading Fire-print..."
    
    cd "$PTERODACTYL_DIRECTORY" || {
        print_error "Failed to navigate to Pterodactyl directory: $PTERODACTYL_DIRECTORY"
        return 1
    }
    
    # Try to download from latest release
    if wget "$(curl -s https://api.github.com/repos/FIRE90YT/Fire-print/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O "$PTERODACTYL_DIRECTORY/release.zip" 2>/dev/null; then
        unzip -o release.zip
        rm -f release.zip
        print_success "Fire-print downloaded and extracted successfully"
    else
        print_warning "Failed to download from releases, trying git clone..."
        git clone "$FIREPRINT_REPO" temp_fireprint
        cp -r temp_fireprint/* .
        cp -r temp_fireprint/.* . 2>/dev/null || true
        rm -rf temp_fireprint
        print_success "Fire-print cloned and copied successfully"
    fi
}

# Function to setup configuration
setup_config() {
    print_status "Setting up configuration..."
    
    touch "$PTERODACTYL_DIRECTORY/.blueprintrc"
    cat > "$PTERODACTYL_DIRECTORY/.blueprintrc" << EOF
WEBUSER="www-data"
OWNERSHIP="www-data:www-data"
USERSHELL="/bin/bash"
EOF
    
    # Give execute permissions to blueprint.sh if it exists
    if [[ -f "$PTERODACTYL_DIRECTORY/blueprint.sh" ]]; then
        chmod +x "$PTERODACTYL_DIRECTORY/blueprint.sh"
    fi
    
    print_success "Configuration setup completed"
}

# Function to install Fire-print files only
install_files_only() {
    print_status "Installing Fire-print files only..."
    
    install_dependencies
    download_fireprint
    setup_config
    
    print_success "Fire-print files installed successfully"
    print_warning "Note: You need to manually run the blueprint.sh script to complete the setup"
}

# Function for full installation
full_installation() {
    print_status "Starting full Fire-print installation..."
    
    # Check if Pterodactyl directory exists
    if [[ ! -d "$PTERODACTYL_DIRECTORY" ]]; then
        print_error "Pterodactyl directory not found: $PTERODACTYL_DIRECTORY"
        print_error "Please set PTERODACTYL_DIRECTORY environment variable or install Pterodactyl first"
        exit 1
    fi
    
    install_dependencies
    install_nodejs
    install_yarn
    download_fireprint
    
    # Install Node.js dependencies
    print_status "Installing Node.js dependencies..."
    cd "$PTERODACTYL_DIRECTORY"
    yarn install
    
    setup_config
    
    # Run blueprint.sh if it exists
    if [[ -f "$PTERODACTYL_DIRECTORY/blueprint.sh" ]]; then
        print_status "Running blueprint.sh..."
        bash "$PTERODACTYL_DIRECTORY/blueprint.sh"
    else
        print_warning "blueprint.sh not found, installation might be incomplete"
    fi
    
    print_success "Fire-print installation completed successfully!"
}

# Function to delete Fire-print
delete_fireprint() {
    print_warning "This will remove Fire-print files from your system."
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Deletion cancelled."
        exit 0
    fi
    
    print_status "Removing Fire-print files..."
    
    # List of files/directories to remove (adjust based on actual Fire-print structure)
    FILES_TO_REMOVE=(
        "$PTERODACTYL_DIRECTORY/blueprint.sh"
        "$PTERODACTYL_DIRECTORY/.blueprintrc"
        "$PTERODACTYL_DIRECTORY/release.zip"
    )
    
    for file in "${FILES_TO_REMOVE[@]}"; do
        if [[ -f "$file" ]] || [[ -d "$file" ]]; then
            sudo rm -rf "$file"
            print_status "Removed: $file"
        fi
    done
    
    print_success "Fire-print files removed successfully"
    print_warning "Note: This only removes Fire-print specific files. Node.js and other dependencies remain installed."
}

# Main menu function
show_menu() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════╗"
    echo "║           Fire-print Installer       ║"
    echo "╠══════════════════════════════════════╣"
    echo "║ 1. Install Fire-print (Full)         ║"
    echo "║ 2. Delete Fire-print                 ║"
    echo "║ 3. Install Files Only                ║"
    echo "║ 4. Exit                              ║"
    echo "╚══════════════════════════════════════╣"
    echo -e "${NC}"
}

# Main script execution
main() {
    check_root
    
    echo -e "${GREEN}Fire-print Installer${NC}"
    echo "Pterodactyl Directory: $PTERODACTYL_DIRECTORY"
    echo ""
    
    while true; do
        show_menu
        read -p "Please choose an option (1-4): " choice
        
        case $choice in
            1)
                full_installation
                break
                ;;
            2)
                delete_fireprint
                break
                ;;
            3)
                install_files_only
                break
                ;;
            4)
                print_status "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option. Please choose 1, 2, 3, or 4."
                ;;
        esac
    done
}

# Run main function
main
