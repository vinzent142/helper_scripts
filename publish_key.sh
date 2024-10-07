#!/bin/bash

# Author: vinzent142
# GitHub: https://github.com/vinzent142
# Date Created: 2024-10-07
# Version: 1
# Date Updated: 2024-10-07
# Description:
#   This script uploads a public SSH key to a remote server's ~/.ssh/authorized_keys file
#   and optionally creates a quick connection alias in the ~/.ssh/config file.
#   
#   Usage:
#     publish_key.sh [OPTIONS]
#   
#   Options:
#     --help         Show this help message and exit.
#     --no-alias     Skip adding an alias to the ~/.ssh/config file.
#     --host         Specify the remote host (hostname or IP address).
#     --user         Specify the remote user.
#     --key          Path to the public key file (optional).
#     --alias        Alias for quick SSH connection (optional).
#     PASSWORD       The password for the remote user (if applicable).
#   
#   The script will prompt for the remote host and user if not provided.
#   If no key is given, it will list existing keys in the user's ~/.ssh directory for selection.
#   Password-based authentication is supported if necessary.


# Function to list available SSH keys
list_ssh_keys() {
    echo "Available SSH keys:"
    # Find public keys in the .ssh directory
    keys=($(ls ~/.ssh/*.pub 2>/dev/null))
    if [ ${#keys[@]} -eq 0 ]; then
        echo "No SSH keys found in ~/.ssh directory."
        exit 1
    fi

    # List them with indices
    for i in "${!keys[@]}"; do
        echo "$((i+1)). ${keys[$i]}"
    done

    # Ask user to select a key
    read -p "Select a key to upload (enter the number): " key_number
    if ! [[ "$key_number" =~ ^[0-9]+$ ]] || [ "$key_number" -le 0 ] || [ "$key_number" -gt "${#keys[@]}" ]; then
        echo "Invalid selection. Exiting."
        exit 1
    fi

    # Return the selected key
    selected_key="${keys[$((key_number-1))]}"
}

# Function to check if a file contains a valid public key
is_valid_public_key() {
    local key_file="$1"
    # Check for valid SSH public key formats (ssh-rsa, ssh-ed25519, ecdsa-sha2)
    if grep -E '^(ssh-(rsa|ed25519)|ecdsa-sha2-nistp)' "$key_file" >/dev/null 2>&1; then
        return 0  # Valid public key
    else
        return 1  # Not a valid public key
    fi
}

# Function to add an SSH alias in ~/.ssh/config
add_ssh_config_entry() {
    local alias_name="$1"
    local host="$2"
    local remote_user="$3"
    local private_key="$4"
    local config_file="$HOME/.ssh/config"

    # Ensure the .ssh directory and config file exist
    mkdir -p ~/.ssh
    touch "$config_file"

    # Check if the alias already exists in the config file
    if [ -f "$config_file" ]; then
        if grep -q "Host $alias_name" "$config_file"; then
            echo -e "\033[1;31mError:\033[0m The alias '$alias_name' already exists in $config_file."
            exit 1
        fi
    else
        echo -e "\033[1;33mNote:\033[0m The config file '$config_file' does not exist and will be created."
    fi

    # Add the SSH alias to the config file
    echo "Adding alias '$alias_name' to $config_file..."
    {
        echo ""
        echo "Host $alias_name"
        echo "    HostName $host"
        echo "    User $remote_user"
        echo "    IdentityFile $private_key"  # Add private key path for quick connection
    } >> "$config_file"

    echo -e "\033[1;32mAlias '$alias_name' added to $config_file.\033[0m"
}

# Function to show a beautiful help message
show_help() {
    echo -e "\033[1;34mUsage:\033[0m"
    echo -e "  \033[1;32mpublish_key.sh [OPTIONS]\033[0m\n"
    echo -e "\033[1;34mDescription:\033[0m"
    echo -e "  This script uploads a public SSH key to a remote server's \033[1m~/.ssh/authorized_keys\033[0m"
    echo -e "  and optionally creates an SSH alias in the \033[1m~/.ssh/config\033[0m file for quick connection.\n"

    echo -e "\033[1;34mOptions:\033[0m"
    echo -e "  \033[1;33m--help\033[0m         Show this help message and exit"
    echo -e "  \033[1;33m--no-alias\033[0m     Skip adding an alias to the \033[1m~/.ssh/config\033[0m file"
    echo -e "  \033[1;33m-h, --host\033[0m      Specify the remote host (hostname or IP address)"
    echo -e "  \033[1;33m-u, --user\033[0m      Specify the remote user"
    echo -e "  \033[1;33m-i, --key\033[0m       Path to the public key file (optional)"
    echo -e "  \033[1;33m-a, --alias\033[0m     Alias for quick SSH connection (optional)\n"
    
    echo -e "\033[1;34mPositional Arguments (optional):\033[0m"
    echo -e "  \033[1;32mPASSWORD\033[0m      The password for the remote user (if applicable)\n"

    echo -e "\033[1;34mExamples:\033[0m"
    echo -e "  \033[1;33m1.\033[0m \033[1m./publish_key.sh --host remote_host --user remote_user --key ~/.ssh/id_rsa.pub --alias myalias\033[0m"
    echo -e "     Uploads the key and creates the alias 'myalias'."
    echo -e "  \033[1;33m2.\033[0m \033[1m./publish_key.sh --host remote_host --user remote_user --key ~/.ssh/id_rsa.pub --no-alias\033[0m"
    echo -e "     Uploads the key but skips creating an alias."
    echo -e "  \033[1;33m3.\033[0m \033[1m./publish_key.sh\033[0m"
    echo -e "     Prompts for host, user, key, and alias.\n"

    echo -e "\033[1;31mNote:\033[0m The script will automatically check if the public key is valid."
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --help) show_help; exit 0 ;;
        --no-alias) no_alias=true; shift ;;
        -h|--host) host="$2"; shift 2 ;;
        -u|--user) remote_user="$2"; shift 2 ;;
        -i|--key) public_key="$2"; shift 2 ;;
        -a|--alias) alias_name="$2"; shift 2 ;;
        -p) password="$2"; shift 2 ;;  # Get password if provided
        *) password="$1"; shift ;;  # Assume anything else is a password
    esac
done

# Check if the host argument is given, if not, ask for it
if [ -z "$host" ]; then
    read -p "Enter the remote host (hostname or IP): " host
fi

# Check if the remote user is given, if not, ask for it
if [ -z "$remote_user" ]; then
    read -p "Enter the remote username: " remote_user
fi

# Check if the SSH alias is provided, if not, ask for it unless --no-alias is used
if [ -z "$alias_name" ] && [ -z "$no_alias" ]; then
    read -p "Enter an alias for quick SSH connection (leave blank for no alias): " alias_name
fi

# Check if the key file is provided, if not, prompt to select from existing keys
if [ -z "$public_key" ]; then
    echo "No SSH public key provided."
    list_ssh_keys  # Call function to list and select keys
else
    # Validate that the provided file is a valid public key
    if [ -f "$public_key" ]; then
        if is_valid_public_key "$public_key"; then
            selected_key="$public_key"
        else
            echo -e "\033[1;31mError:\033[0m The provided file is not a valid public key."
            exit 1
        fi
    else
        echo -e "\033[1;31mError:\033[0m The provided file does not exist."
        exit 1
    fi
fi

# Extract private key path from the public key path by removing the .pub extension
private_key="${selected_key%.pub}"

# Check if the private key exists
if [ ! -f "$private_key" ]; then
    echo -e "\033[1;31mWarning:\033[0m The corresponding private key ($private_key) does not exist."
    exit 1
fi

# Check if the SSH alias already exists
if [ -n "$alias_name" ]; then
    # Check if the alias already exists in the config file
    config_file="$HOME/.ssh/config"
    if [ -f "$config_file" ]; then
        if grep -q "Host $alias_name" "$config_file"; then
            echo -e "\033[1;31mError:\033[0m The alias '$alias_name' already exists in $config_file."
            exit 1
        fi
    else
        echo -e "\033[1;33mNote:\033[0m The config file '$config_file' does not exist and will be created."
    fi
fi

# Check if SSH directory exists on the remote server and create it if necessary
if [ -z "$password" ]; then
    ssh "$remote_user@$host" "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
else
    sshpass -p "$password" ssh "$remote_user@$host" "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
fi

# Upload the public key to the remote server
if [ -z "$password" ]; then
    cat "$selected_key" | ssh "$remote_user@$host" "cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
else
    cat "$selected_key" | sshpass -p "$password" ssh "$remote_user@$host" "cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
fi

if [ $? -eq 0 ]; then
    echo -e "\033[1;32mSSH public key successfully uploaded to $remote_user@$host\033[0m"

    # Check if the --no-alias flag is provided
    if [ -z "$no_alias" ] && [ -n "$alias_name" ]; then
        add_ssh_config_entry "$alias_name" "$host" "$remote_user" "$private_key"
    fi
else
    echo -e "\033[1;31mFailed to upload SSH public key.\033[0m"
    exit 1
fi
