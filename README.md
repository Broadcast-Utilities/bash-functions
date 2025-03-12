# Bash Functions Library

This is a Bash shell library that provides a set of common utility functions to streamline the scripting process in Debian-based environments, particularly optimized for Ubuntu.

## Function Definitions

1. **`set_colors`**: Initializes color and text variables for terminal text.
2. **`is_silent`**: Checks if the first parameter is `'silent'`. If it is, output from commands can be suppressed.
3. **`is_this_linux`**: Checks if the script is running on a Linux distribution.
4. **`is_this_os_64bit`**: Checks if the system is a 64-bit system.
5. **`check_rpi_model`**: Checks if the script is running on a Raspberry Pi with a model number equal to or higher than the input parameter.
6. **`check_user_privileges`**: Checks if the script is running with the required privileges. Takes one parameter: `'privileged'` to check if the user is root, `'regular'` to check if the user is not root.
7. **`check_apt`**: Checks if the `'apt'` package manager is present.
8. **`update_os`**: Updates the operating system using the `'apt'` package manager.
9. **`install_packages`**: Installs packages using the `'apt'` package manager.
10. **`set_timezone`**: Sets the system timezone.
11. **`require_tool`**: Checks if the system has specific commands/tools installed. Can check for one or more tools.
12. **`ask_user`**: Prompts the user for input with different input types including `'y/n'`, `'num'`, `'str'`, `'email'`, and `'host'`.
13. **`backup_file`**: Backs up a specified file if it exists. Creates a timestamped backup to preserve the original before modifications.

## How to Use

These functions can be imported and used in your own Bash scripts. To import the functions, use the following lines in your script:

```bash
# Remove old functions library and download the latest version
rm -f /tmp/functions.sh
if ! curl -s -o /tmp/functions.sh https://gitlab.broadcastutilities.nl/broadcastutilities/radio/bash-functions/-/raw/main/common-functions.sh?ref_type=heads; then
  echo -e "*** Failed to download functions library. Please check your network connection! ***"
  exit 1
fi

# Source the functions file
source /tmp/functions.sh
```

### Example Usage

#### Set Terminal Text Colors:
```bash
set_colors
echo -e "${GREEN}This text is green!${NC}"
```

#### Check for Required Tools:
```bash
require_tool git curl wget
```

#### Prompt the User for Input:
```bash
ask_user "SSL" "n" "Do you want Let's Encrypt to get a certificate for this server? (y/n)" "y/n"
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

