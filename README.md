# proxmox-packer-bitwarden

Packer Build Template Code For Proxmox with Bitwarden-cli support.

## Installing Bitwarden CLI

```bash
apt install unzip curl
curl -SLo bw.zip 'https://vault.bitwarden.com/download/?app=cli&platform=linux'
unzip -o bw.zip -d /usr/local/bin
rm -f bw.zip
chmod +x /usr/local/bin/bw
```

## Login to Bitwarden CLI

Further information: <https://bitwarden.com/help/personal-api-key/>

```bash
bw config server https://bitwarden.example.com
bw login --apikey
```

## Create your secrets in Bit/Vaultwarden

In Bit/Vaultwarden:

```text
- Add Item.
- Secure Note.
- Set the name and set the secret in the "notes" field.
- Modify `credentials.sh` with your variables.
- Modify `variables.pkr.hcl` with your variables.
```

## Validate Packer Config

```bash
cd ubuntu-cloud-jammy-master
packer validate .
```

## Source Bitwarden Variables

```bash
source ./credentials.sh
```

## Initialise Packer Config

```bash
packer init .
```

## Build Packer Config

```bash
packer build .
```
