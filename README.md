# packer-proxmox-template
Packer Image Build Template Code For Proxmox

### Installing Bitwarden CLI
#### Install Github CLI:
```
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

#### Install Bitwarden CLI
```
sudo apt install unzip
gh release list -R bitwarden/clients - get latest version
gh release download cli-v2022.10.0 -p 'bw-linux-*.zip' -R bitwarden/clients -D /tmp/
unzip /tmp/bw-linux-*.zip
sudo install bw /usr/local/bin/
rm -f /tmp/bw-linux-*.zip bw
```

#### Login to Bitwarden CLI
```
bw config server https://bitwarden.example.com
bw login --apikey
```

### Validate Packer Config
```
packer validate -var-file=credentials.pkr.hcl ubuntu-server-focal-docker.pkr.hcl
```

### Initialise Packer Config
```
packer init ubuntu-server-focal-docker.pkr.hcl
```

### Build Packer Config
```
packer build -var-file=credentials.pkr.hcl ubuntu-server-focal-docker.pkr.hcl
```

---

### Build Packer config with Vaultwarden
```
source ../credentials.sh && packer build ubuntu-server-jammy.pkr.hcl
```

