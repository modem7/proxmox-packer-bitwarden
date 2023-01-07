#!/bin/bash

# Variables
swaptype="auto" # Do either 'auto' or 'manual'
SWAP_SIZE="${SWAP_SIZE:-2G}"
conf=/etc/fstab

if [[ "$swaptype" == "auto" ]]; then
    echo "===> Swap configuration set to auto"
    # Install swapspace package
    apt-get install -qq -y swapspace
    # Disable swap
    sudo swapoff -a || exit 1
    if grep '^/swapfile' ${conf} &> /dev/null ;then
        sed -i '/\/swapfile/s/^/#/' ${conf} || exit 1
        echo "Updated ${conf}"
    fi
    if [ -f /swapfile ] ; then
        rm -vf /swapfile || exit 1
    fi
elif [[ "$swaptype" == "manual" ]]; then
    echo "===> Swap configuration set to manual"
    fallocate -l $SWAP_SIZE /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a ${conf}
else
    echo "Swap script failed."
    exit 1
fi

exit 0