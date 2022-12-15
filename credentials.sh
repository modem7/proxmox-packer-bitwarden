#!/bin/bash

# Install Bitwarden CLI:
# curl -SLo bw.zip 'https://vault.bitwarden.com/download/?app=cli&platform=linux'
# sudo unzip -o bw.zip -d /usr/local/bin
# rm -f bw.zip
# sudo chmod +x /usr/local/bin/bw

# Login with your API key: https://bitwarden.com/help/personal-api-key/

# Create your secrets in Bit/Vaultwarden:
# Add Item > Secure Note > Set the name and set the secret in the "notes" field.
# To run the script, use "source credentials.sh"
# To run this with Packer build, run (for example) "source ../credentials.sh && packer build ubuntu-server-jammy.pkr.hcl"

# Unlock Bitwarden Vault
bwunlock() {
    echo "BW_SESSION is not set..."
    echo "Unlocking Vault"
    export BW_SESSION="$(bw unlock --raw)"
    bw sync -f
}

# Get and set variables
getcreds() {
    echo "Setting Packer variables..."
    bw sync -f
    export PROX_API_ID=$(bw get notes packer_proxmox_api_token_id)
    export PROX_API_SECRET=$(bw get notes packer_proxmox_api_token_secret)
    export POSTFIX_USER=$(bw get notes packer_postfix_user)
    export POSTFIX_PASS=$(bw get notes packer_postfix_pass)
    export POSTFIX_DOMAIN=$(bw get notes packer_postfix_domain)
    export POSTFIX_RELAY=$(bw get notes packer_postfix_relay)
}

# Check if script is sourced
if [ "$0" = "$BASH_SOURCE" ]; then
    echo "Error: Script must be sourced"
    exit 1
fi

# Run functions
if [[ -n "$BW_SESSION" ]]
then
    getcreds
else
    bwunlock
    getcreds
fi
