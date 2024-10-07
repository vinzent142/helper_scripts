#!/bin/bash

# Define the SSH config file path
SSH_CONFIG_FILE="$HOME/.ssh/config"

# Check if the config file exists
if [[ ! -f $SSH_CONFIG_FILE ]]; then
    echo -e "\e[31mSSH config file not found: $SSH_CONFIG_FILE\e[0m" # Red error message
    exit 1
fi

# Define color codes
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

# Function to parse the SSH config file
function parse_ssh_config() {
    local index=1
    printf "${BOLD}%-5s %-15s %-20s %-10s %-30s${NORMAL}\n" "Index" "Alias" "HostName" "User" "IdentityFile"
    echo "-------------------------------------------------------------------------------------------------"
    
    # Variables to store details
    local alias=""
    local hostname=""
    local user=""
    local identityfile=""

    # Read the config file and extract relevant fields
    while IFS= read -r line; do
        if [[ $line =~ ^Host\ (.+) ]]; then
            # Print the previous host's information if it exists
            if [[ -n $alias ]]; then
                printf "%-5s ${GREEN}%-15s${NORMAL} ${YELLOW}%-20s${NORMAL} ${BLUE}%-10s${NORMAL} ${RESET}%-30s\n" \
                    "$index" "$alias" "${hostname:-N/A}" "${user:-N/A}" "${identityfile:-N/A}"
                index=$((index + 1))
            fi
            # Start a new entry
            alias=${BASH_REMATCH[1]}
            hostname=""
            user=""
            identityfile=""
        elif [[ $line =~ ^[[:space:]]*HostName[[:space:]]+(.*) ]]; then
            hostname=${BASH_REMATCH[1]}
        elif [[ $line =~ ^[[:space:]]*User[[:space:]]+(.*) ]]; then
            user=${BASH_REMATCH[1]}
        elif [[ $line =~ ^[[:space:]]*IdentityFile[[:space:]]+(.*) ]]; then
            identityfile=${BASH_REMATCH[1]}
        fi
    done < "$SSH_CONFIG_FILE"

    # Print the last host's information if it exists
    if [[ -n $alias ]]; then
        printf "%-5s ${GREEN}%-15s${NORMAL} ${YELLOW}%-20s${NORMAL} ${BLUE}%-10s${NORMAL} ${RESET}%-30s\n" \
            "$index" "$alias" "${hostname:-N/A}" "${user:-N/A}" "${identityfile:-N/A}"
    fi
}

# Call the function to parse and display the SSH config
parse_ssh_config

# Prompt for the index
echo -n "Enter the index to connect (or leave blank to exit): "
read -r index

# If the index is blank, exit
if [[ -z "$index" ]]; then
    echo "Exiting."
    exit 0
fi

# Validate the index
if ! [[ "$index" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input. Please enter a valid index.${NORMAL}"
    exit 1
fi

# Get the selected host details
selected_alias=$(awk "/^Host / {i++} i==${index} {print \$2; exit}" "$SSH_CONFIG_FILE")

# Validate the selected alias
if [[ -z "$selected_alias" ]]; then
    echo -e "${RED}No host found for index $index.${NORMAL}"
    exit 1
fi

# Connect to the SSH host using the alias
echo -e "${BOLD}Connecting to $selected_alias...${NORMAL}"
ssh "$selected_alias"
