#!/bin/bash

# Variables
DOWNLOAD_URL="https://download.docker.com/linux/ubuntu"
KEYRING_LOCATION="/etc/apt/keyrings"
# The channel to install from:
#   * nightly
#   * test
#   * stable
#   * edge (deprecated)
CHANNEL="stable"

# Remove any potential packages already installed
apt-get remove -y -qq      \
             docker        \
             docker-engine \
             docker.io     \
             containerd    \
             runc

# Add Docker’s official GPG key
mkdir -m 0755 -p ${KEYRING_LOCATION}
curl -fsSL ${DOWNLOAD_URL}/gpg | gpg --dearmor --yes -o ${KEYRING_LOCATION}/docker.gpg
chmod a+r ${KEYRING_LOCATION}/docker.gpg

# Use the following command to set up the repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=${KEYRING_LOCATION}/docker.gpg] ${DOWNLOAD_URL} $(lsb_release -cs) ${CHANNEL}" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Updating APT
apt-get update

# Installing packages
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -qq \
        docker-ce      \
        docker-ce-cli  \
        containerd.io  \
        docker-compose-plugin
