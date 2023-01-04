#!/bin/sh

# Variables
SSHCONF="/etc/ssh/sshd_config"
SSHUSERS="modem7"

# Re-generate the RSA and ED25519 keys
rm /etc/ssh/ssh_host_*
ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""

# Remove small Diffie-Hellman moduli
awk '$5 >= 3071' /etc/ssh/moduli > /etc/ssh/moduli.safe
mv /etc/ssh/moduli.safe /etc/ssh/moduli

# Enable the RSA and ED25519 keys
# Enable the RSA and ED25519 HostKey directives in the /etc/ssh/sshd_config file:
sed -i 's/^\#HostKey \/etc\/ssh\/ssh_host_\(rsa\|ed25519\)_key$/HostKey \/etc\/ssh\/ssh_host_\1_key/g' ${SSHCONF}

# Restrict supported key exchange, cipher, and MAC algorithms
tee ${SSHCONF}.d/ssh-audit_hardening.conf << EOF
# Restrict key exchange, cipher, and MAC algorithms, as per sshaudit.com hardening guide.
KexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,gss-curve25519-sha256-,diffie-hellman-group16-sha512,gss-group16-sha512-,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com
HostKeyAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256,rsa-sha2-256-cert-v01@openssh.com
EOF

sed -i "/PermitRootLogin/c\PermitRootLogin no" ${SSHCONF}
echo "Protocol 2" >> ${SSHCONF}

# echo "AllowUsers '$SSHUSERS'" >> ${SSHCONF}

sed -i "/LogLevel/c\LogLevel VERBOSE" ${SSHCONF}

sed -i "/LoginGraceTime/c\LoginGraceTime 1m" ${SSHCONF}

sed -i "/MaxAuthTries/c\MaxAuthTries 3" ${SSHCONF}
sed -i "/MaxSessions/c\MaxSessions 2" ${SSHCONF}

sed -i "/#PubkeyAuthentication yes/c\PubkeyAuthentication yes" ${SSHCONF}

sed -i "/PasswordAuthentication/c\PasswordAuthentication no" ${SSHCONF}
sed -i "/PermitEmptyPasswords/c\PermitEmptyPasswords no" ${SSHCONF}

sed -i "/ChallengeResponseAuthentication/c\ChallengeResponseAuthentication no" ${SSHCONF}

sed -i "/GSSAPIAuthentication/c\GSSAPIAuthentication no" ${SSHCONF}
sed -i "/KerberosAuthentication/c\KerberosAuthentication no" ${SSHCONF}

sed -i "/UsePAM/c\UsePAM no" ${SSHCONF}

sed -i "/AllowAgentForwarding/c\AllowAgentForwarding yes" ${SSHCONF}

sed -i "/AllowStreamLocalForwarding/c\AllowStreamLocalForwarding no" ${SSHCONF}

sed -i "/X11Forwarding/c\X11Forwarding yes" ${SSHCONF}

sed -i "/PrintMotd/c\PrintMotd no" ${SSHCONF}

sed -i "/TCPKeepAlive/c\TCPKeepAlive yes" ${SSHCONF}

sed -i "/PermitUserEnvironment/c\PermitUserEnvironment no" ${SSHCONF}

sed -i "/Compression/c\Compression no" ${SSHCONF}

echo "PermitOpen *:22" >> ${SSHCONF}

sed -i "/Banner none/c\Banner none" ${SSHCONF}

sed -i "/Subsystem/c\Subsystem sftp \/usr\/lib\/sftp-server -f AUTHPRIV -l INFO" ${SSHCONF}

# tee -a ${SSHCONF} > /dev/null <<EOF
# Match User *,!$SSHUSERS
#     ForceCommand /bin/echo 'This bastion does not support interactive commands.'
# EOF

sed -i "/ClientAliveInterval/c\ClientAliveInterval 180" ${SSHCONF}

sed -i "/RekeyLimit/c\RekeyLimit 1G 1h" ${SSHCONF}