#!/bin/bash

# To run the script, use "source credentials.sh" or ". ./credentials.sh"
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
    export PROX_API_URL=$(bw get notes packer_proxmox_api_url)
    export PROX_API_ID=$(bw get notes packer_proxmox_api_token_id)
    export PROX_API_SECRET=$(bw get notes packer_proxmox_api_token_secret)
}

# Apply extra cron if it's set
if [[ -n "$BW_SESSION" ]]
then
    getcreds
else
    bwunlock
    getcreds
fi
