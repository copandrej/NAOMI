#!/bin/bash

# Check if uv is installed, install if not
if ! command -v uv > /dev/null 2>&1; then
    echo "Installing uv package manager..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# Create virtual environment and sync dependencies
uv sync || { echo "pyproject.toml not found. Did you run the script from the root of the repository?"; exit 1; }

# Install flytectl
curl -sL https://ctl.flyte.org/install | sudo bash -s -- -b /usr/local/bin

# Ask the user if Kubernetes is running on the same machine
read -p "Is Kubernetes cluster with flyte running on this machine (y/n)? " answer

case ${answer:0:1} in
    y|Y )
        # If yes, get the IP of VM
        IP=$(hostname -I | awk '{print $1}')
    ;;
    * )
        # If no, ask the user to input the IP of the machine running Kubernetes
        read -p "Please enter the IP of the machine running Kubernetes: " IP
    ;;
esac

# Connect flyte
flytectl config init --host=$IP:31081 --console=$IP:31082 --insecure

rm -f temp.yaml # cleanup
echo "Run to start using env:"
echo "source .venv/bin/activate"
