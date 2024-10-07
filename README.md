# Script Collection

Welcome to the **Scripts Collection** repository! This repository contains various useful scripts for automation, server management, and system administration tasks.

## Table of Contents

- [SSH Key Publisher](#ssh-key-publisher)
- [List and connect to ssh alias](#list-and-connect-to-ssh-alias)

## SSH Key Publisher

### Description
The **SSH Key Publisher** script automates the process of uploading a public SSH key to a remote server's `~/.ssh/authorized_keys` file. It also allows the creation of a quick connection alias in the `~/.ssh/config` file for easy access.

### Features
- Uploads a public SSH key to a remote server.
- Option to create a quick SSH connection alias.
- Lists existing SSH keys for selection.
- Supports password-based authentication.
- Validates provided SSH keys.

### Usage
To use the SSH Key Publisher script, run the following command:

```bash
./publish_key.sh --help

# Options:

- `--help` Show this help message and exit.
- `--no-alias` Skip adding an alias to the `~/.ssh/config` file.
- `-h`, `--host` Specify the remote host (hostname or IP address).
- `-u`, `--user` Specify the remote user.
- `-i`, `--key` Path to the public key file (optional).
- `-a`, `--alias` Alias for quick SSH connection (optional).
- `-p` The password for the remote user (if applicable).
```

## List and connect to ssh alias

The `list_ssh_aliases.sh` script displays all current SSH aliases stored in the `~/.ssh/config` file in a neatly formatted table. It allows users to easily identify their SSH configurations and quickly connect to a desired host by selecting the corresponding entry number.

### Features

- *Lists all SSH aliases along with their corresponding hosts and users in a structured format.
- Automatically establishes an SSH connection to the selected host using the appropriate user.

### Usage
#### Run the Script
- `bash ./list_ssh_aliases.sh`

#### Add as alias
- `vim ~/.bashrc` or `vim ~/.zshrc`
- Add `alias sshm='/path/to/your/scripts/list_ssh_aliases.sh'`
- `source ~/.bashrc` or `source ~/.zshrc`
- `sshm`