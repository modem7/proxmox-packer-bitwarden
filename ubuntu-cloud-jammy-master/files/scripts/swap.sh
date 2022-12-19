#!/bin/sh

# Variables
SWAP_SIZE="${SWAP_SIZE:-2G}"

# Remove Snap
echo "===> Creating Swap File"
fallocate -l $SWAP_SIZE /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
