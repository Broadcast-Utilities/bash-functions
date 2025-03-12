#!/bin/bash

# Exit script on any error
set -e

# Initialize color variables for terminal text.
set_colors() {
    GREEN='\033[1;32m'
    RED='\033[1;31m'
    YELLOW='\033[0;33m'
    BLUE='\033[1;36m'
    NC='\033[0m'
    BOLD='\033[1m'
    UNDERLINE='\033[4m'
}

# Ensure script runs only on Linux
is_this_linux() {
    if [[ "$(uname -s)" != "Linux" ]]; then
        echo -e "${RED}Error: This script supports only Linux.${NC}"
        exit 1
    fi
}

# Ensure script runs on 64-bit OS
is_this_os_64bit() {
    if [[ "$(getconf LONG_BIT)" -ne 64 ]]; then
        echo -e "${RED}Error: 64-bit operating system required.${NC}"
        exit 1
    fi
}

# Ensure `apt` is available
check_apt() {
    if ! command -v apt >/dev/null 2>&1; then
        echo -e "${RED}Error: 'apt' package manager not found. Exiting...${NC}"
        exit 1
    fi
}

# Ensure user is root or non-root based on parameter
check_user_privileges() {
    local required_privilege="$1"

    if [[ "$required_privilege" == "privileged" && "$(id -u)" -ne 0 ]]; then
        echo -e "${RED}Error: Run this script as root (use 'sudo').${NC}"
        exit 1
    elif [[ "$required_privilege" == "regular" && "$(id -u)" -eq 0 ]]; then
        echo -e "${RED}Error: Do not run this script as root.${NC}"
        exit 1
    fi
}

# Backup file if it exists
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup_path="${file}.bak.$(date +%Y%m%d%H%M%S)"
        install -m 600 "$file" "$backup_path"
        echo -e "${YELLOW}Backup of '$file' created at '$backup_path'.${NC}"
    fi
}

# Update system packages (silent mode supported)
update_os() {
    check_apt
    echo -e "${BLUE}►► Updating system packages...${NC}"
    sudo apt-get -qq -y update
    sudo apt-get -qq -y full-upgrade
    sudo apt-get -qq -y autoremove
}

# Install required packages
install_packages() {
    check_apt
    local packages=("$@")
    if [[ ${#packages[@]} -eq 0 ]]; then
        echo -e "${RED}Error: No packages specified.${NC}"
        exit 1
    fi
    echo -e "${BLUE}►► Installing: ${packages[*]}...${NC}"
    sudo apt-get install -y "${packages[@]}"
}

# Set system timezone
set_timezone() {
    local timezone="$1"
    if [[ -f "/usr/share/zoneinfo/${timezone}" ]]; then
        echo -e "${BLUE}►► Setting timezone to ${timezone}...${NC}"
        sudo ln -fs "/usr/share/zoneinfo/$timezone" /etc/localtime
        sudo dpkg-reconfigure -f noninteractive tzdata
    else
        echo -e "${RED}Error: Invalid timezone: ${timezone}${NC}"
    fi
}

# Check if required tools exist
require_tool() {
    local missing_tools=()
    for tool in "$@"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    if [[ ${#missing_tools[@]} -ne 0 ]]; then
        echo -e "${RED}Error: Missing required tools: ${missing_tools[*]}${NC}"
        exit 1
    fi
}

# Prompt user for input with validation
ask_user() {
    local var_name="$1"
    local default_value="$2"
    local prompt="$3"
    local var_type="${4:-str}"
    local input

    while true; do
        read -r -p "${prompt} [default: ${default_value}]: " input
        input="${input:-$default_value}"

        case "$var_type" in
            'y/n')
                [[ "$input" =~ ^(y|n)$ ]] && break || echo "Invalid input. Enter 'y' or 'n'."
                ;;
            'num')
                [[ "$input" =~ ^[0-9]+$ ]] && break || echo "Invalid input. Enter a number."
                ;;
            'str')
                [[ -n "$input" ]] && break || echo "Invalid input. Enter a string."
                ;;
            'email')
                [[ "$input" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]] && break || echo "Invalid email format."
                ;;
            'host')
                [[ "$input" =~ ^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][a-zA-Z0-9\-]*[A-Za-z0-9])$ ]] && break || echo "Invalid hostname."
                ;;
            *)
                echo "Unknown validation type: $var_type"
                return 1
                ;;
        esac
    done

    eval "$var_name=\"$input\""
}

# Main execution
main() {
    set_colors
    is_this_linux
    is_this_os_64bit
    check_apt
    check_user_privileges "privileged"

    echo -e "${GREEN}Starting system setup...${NC}"
    
    # Example usage:
    update_os
    install_packages curl wget git
    set_timezone "UTC"
    require_tool curl wget

    echo -e "${GREEN}Setup complete.${NC}"
}

# Run the script
main