# Scripts Collection

Welcome to the **Scripts Collection** repository! This repository contains various useful scripts for automation, server management, and system administration tasks.

## Table of Contents

- [SSH Key Publisher](#ssh-key-publisher)

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

#### Options

- `--help` Show this help message and exit.
- `--no-alias` Skip adding an alias to the `~/.ssh/config` file.
- `-h`, `--host` Specify the remote host (hostname or IP address).
- `-u`, `--user` Specify the remote user.
- `-i`, `--key` Path to the public key file (optional).
- `-a`, `--alias` Alias for quick SSH connection (optional).
- `-p` The password for the remote user (if applicable).