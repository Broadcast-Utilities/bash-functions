#!/bin/bash

# Exit script immediately on error
set -e

# ========================================================
# FUNCTION: set_colors
# DESCRIPTION:
#   Initializes color codes for terminal output styling.
# PARAMETERS: None
# ========================================================
set_colors() {
    GREEN='\033[1;32m'   # Success messages
    RED='\033[1;31m'     # Error messages
    YELLOW='\033[0;33m'  # Warnings
    BLUE='\033[1;36m'    # Informational messages
    NC='\033[0m'         # Reset color
    BOLD='\033[1m'       # Bold text
    UNDERLINE='\033[4m'  # Underlined text
}

# ========================================================
# FUNCTION: is_this_linux
# DESCRIPTION:
#   Ensures the script is running on a Linux OS.
#   Exits if the OS is not Linux.
# PARAMETERS: None
# ========================================================
is_this_linux() {
    if [[ "$(uname -s)" != "Linux" ]]; then
        echo -e "${RED}Error: This script is only compatible with Linux.${NC}"
        exit 1
    fi
}

# ========================================================
# FUNCTION: is_this_os_64bit
# DESCRIPTION:
#   Ensures the system architecture is 64-bit.
#   Exits if the system is not 64-bit.
# PARAMETERS: None
# ========================================================
is_this_os_64bit() {
    if [[ "$(getconf LONG_BIT)" -ne 64 ]]; then
        echo -e "${RED}Error: A 64-bit operating system is required.${NC}"
        exit 1
    fi
}

# ========================================================
# FUNCTION: check_apt
# DESCRIPTION:
#   Verifies that the 'apt' package manager is available.
#   Exits if 'apt' is not found (ensuring Ubuntu/Debian compatibility).
# PARAMETERS: None
# ========================================================
check_apt() {
    if ! command -v apt >/dev/null 2>&1; then
        echo -e "${RED}Error: 'apt' package manager not found. Exiting...${NC}"
        exit 1
    fi
}

# ========================================================
# FUNCTION: check_user_privileges
# DESCRIPTION:
#   Ensures the script is executed with the correct user privileges.
#   Can check for either root or non-root execution.
# PARAMETERS:
#   $1 - "privileged" (requires root) or "regular" (must not be root)
# ========================================================
check_user_privileges() {
    local required_privilege="$1"

    if [[ "$required_privilege" == "privileged" && "$(id -u)" -ne 0 ]]; then
        echo -e "${RED}Error: This script must be run as root (use 'sudo').${NC}"
        exit 1
    elif [[ "$required_privilege" == "regular" && "$(id -u)" -eq 0 ]]; then
        echo -e "${RED}Error: Do not run this script as root.${NC}"
        exit 1
    fi
}

# ========================================================
# FUNCTION: backup_file
# DESCRIPTION:
#   Creates a timestamped backup of a given file if it exists.
# PARAMETERS:
#   $1 - The file path to back up
# ========================================================
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup_path="${file}.bak.$(date +%Y%m%d%H%M%S)"
        install -m 600 "$file" "$backup_path"  # Secure backup with correct permissions
        echo -e "${YELLOW}Backup created: '$backup_path'.${NC}"
    fi
}

# ========================================================
# FUNCTION: update_os
# DESCRIPTION:
#   Updates and upgrades all system packages using 'apt'.
#   Removes unnecessary packages automatically.
# PARAMETERS: None
# ========================================================
update_os() {
    check_apt
    echo -e "${BLUE}►► Updating system packages...${NC}"
    sudo apt-get -qq -y update
    sudo apt-get -qq -y full-upgrade
    sudo apt-get -qq -y autoremove
}

# ========================================================
# FUNCTION: install_packages
# DESCRIPTION:
#   Installs a list of specified packages using 'apt'.
# PARAMETERS:
#   $@ - List of package names to install
# ========================================================
install_packages() {
    check_apt
    local packages=("$@")
    if [[ ${#packages[@]} -eq 0 ]]; then
        echo -e "${RED}Error: No packages specified for installation.${NC}"
        exit 1
    fi
    echo -e "${BLUE}►► Installing: ${packages[*]}...${NC}"
    sudo apt-get install -y "${packages[@]}"
}

# ========================================================
# FUNCTION: set_timezone
# DESCRIPTION:
#   Configures the system timezone.
# PARAMETERS:
#   $1 - The timezone to set (e.g., "Europe/Berlin")
# ========================================================
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

# ========================================================
# FUNCTION: require_tool
# DESCRIPTION:
#   Ensures that specified command-line tools exist, or exits.
# PARAMETERS:
#   $@ - List of command names to check
# ========================================================
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

# ========================================================
# FUNCTION: ask_user
# DESCRIPTION:
#   Prompts the user for input with a default value.
# PARAMETERS:
#   $1 - Variable name to store the input
#   $2 - Default value
#   $3 - Prompt message
#   $4 - (Optional) Validation type: "y/n", "num", "str", "email", "host"
# ========================================================
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
            'y/n') [[ "$input" =~ ^(y|n)$ ]] && break || echo "Enter 'y' or 'n'." ;;
            'num') [[ "$input" =~ ^[0-9]+$ ]] && break || echo "Enter a number." ;;
            'str') [[ -n "$input" ]] && break || echo "Enter a non-empty string." ;;
            'email') [[ "$input" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]] && break || echo "Enter a valid email." ;;
            'host') [[ "$input" =~ ^([a-zA-Z0-9][a-zA-Z0-9\-]*\.)+[a-zA-Z0-9\-]+$ ]] && break || echo "Enter a valid hostname." ;;
            *) echo "Unknown validation type: $var_type"; return 1 ;;
        esac
    done

    eval "$var_name=\"$input\""
}

# ========================================================
# FUNCTION: main
# DESCRIPTION:
#   Executes the main logic of the script.
# ========================================================
main() {
    set_colors
    is_this_linux
    is_this_os_64bit
    check_apt
    check_user_privileges "privileged"

    echo -e "${GREEN}Starting system setup...${NC}"
    
    update_os
    install_packages curl wget git
    set_timezone "UTC"
    require_tool curl wget

    echo -e "${GREEN}Setup complete.${NC}"
}

# Run the script
main