# proxmox-packer-bitwarden
Packer Image Build Template Code For Proxmox with Bitwarden-cli support.

### Installing Bitwarden CLI
```
apt install unzip curl
curl -SLo bw.zip 'https://vault.bitwarden.com/download/?app=cli&platform=linux'
unzip -o bw.zip -d /usr/local/bin
rm -f bw.zip
chmod +x /usr/local/bin/bw
```

### Login to Bitwarden CLI
Further information: https://bitwarden.com/help/personal-api-key/
```
bw config server https://bitwarden.example.com
bw login --apikey
```

### Create your secrets in Bit/Vaultwarden:
In Bit/Vaultwarden:
```
- Add Item.
- Secure Note.
- Set the name and set the secret in the "notes" field.
- Modify `credentials.sh` with your variables.
- Modify `variables.pkr.hcl` with your variables.
```

### Validate Packer Config
```
cd ubuntu-cloud-jammy-master
packer validate .
```

### Source Bitwarden Variables
```
source ./credentials.sh
```

### Initialise Packer Config
```
packer init .
```

### Build Packer Config
```
packer build .
```

