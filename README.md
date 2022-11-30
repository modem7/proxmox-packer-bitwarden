# packer-proxmox-template
Packer Image Build Template Code For Proxmox

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

