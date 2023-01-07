#!/bin/bash

# Updating APT
echo "===> Updating Apt"
apt-get update -qq

# Install Additional Packages
echo "===> Installing additional packages"
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -qq      \
            acl             \
            aptitude        \
            bash-completion \
            ca-certificates \
            curl            \
            dnsutils        \
            git             \
            gnupg           \
            htop            \
            lsb-release     \
            mlocate         \
            net-tools       \
            openssl         \
            pwgen           \
            resolvconf      \
            tldr            \
            unzip

# Updating MLocate database
echo "===> Updating MLocate database"
updatedb
