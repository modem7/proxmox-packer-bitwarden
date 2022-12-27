#!/bin/sh

# Variables
SSHCONF="/etc/ssh/sshd_config"
SSHUSERS="modem7"

awk '$5 >= 3071' /etc/ssh/moduli > /etc/ssh/moduli.tmp && mv /etc/ssh/moduli.tmp /etc/ssh/moduli

sed -i "/PermitRootLogin/c\PermitRootLogin no" /etc/ssh/sshd_config
bash -c 'echo "Protocol 2" >> /etc/ssh/sshd_config'

sed -i "/HostKey \/etc\/ssh\/ssh_host_ed25519_key/c\HostKey \/etc\/ssh\/ssh_host_ed25519_key" /etc/ssh/sshd_config
sed -i "/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/c\HostKey \/etc\/ssh\/ssh_host_ecdsa_key" /etc/ssh/sshd_config
sed -i "/HostKey \/etc\/ssh\/ssh_host_rsa_key/c\HostKey \/etc\/ssh\/ssh_host_rsa_key" /etc/ssh/sshd_config

# bash -c 'echo "AllowUsers '$SSHUSERS'" >> /etc/ssh/sshd_config'

sed -i "/LogLevel/c\LogLevel VERBOSE" /etc/ssh/sshd_config

sed -i "/LoginGraceTime/c\LoginGraceTime 1m" /etc/ssh/sshd_config

sed -i "/MaxAuthTries/c\MaxAuthTries 3" /etc/ssh/sshd_config
sed -i "/MaxSessions/c\MaxSessions 2" /etc/ssh/sshd_config

sed -i "/#PubkeyAuthentication yes/c\PubkeyAuthentication yes" /etc/ssh/sshd_config

sed -i "/PasswordAuthentication/c\PasswordAuthentication no" /etc/ssh/sshd_config
sed -i "/PermitEmptyPasswords/c\PermitEmptyPasswords no" /etc/ssh/sshd_config

sed -i "/ChallengeResponseAuthentication/c\ChallengeResponseAuthentication no" /etc/ssh/sshd_config

sed -i "/GSSAPIAuthentication/c\GSSAPIAuthentication no" /etc/ssh/sshd_config
sed -i "/KerberosAuthentication/c\KerberosAuthentication no" /etc/ssh/sshd_config

sed -i "/UsePAM/c\UsePAM no" /etc/ssh/sshd_config

sed -i "/AllowAgentForwarding/c\AllowAgentForwarding yes" /etc/ssh/sshd_config

sed -i "/AllowStreamLocalForwarding/c\AllowStreamLocalForwarding no" /etc/ssh/sshd_config

sed -i "/X11Forwarding/c\X11Forwarding yes" /etc/ssh/sshd_config

sed -i "/PrintMotd/c\PrintMotd no" /etc/ssh/sshd_config

sed -i "/TCPKeepAlive/c\TCPKeepAlive yes" /etc/ssh/sshd_config

sed -i "/PermitUserEnvironment/c\PermitUserEnvironment no" /etc/ssh/sshd_config

sed -i "/Compression/c\Compression no" /etc/ssh/sshd_config

bash -c 'echo "PermitOpen *:22" >> /etc/ssh/sshd_config'

sed -i "/Banner none/c\Banner none" /etc/ssh/sshd_config

sed -i "/Subsystem/c\Subsystem sftp \/usr\/lib\/sftp-server -f AUTHPRIV -l INFO" /etc/ssh/sshd_config

bash -c 'echo "KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256" >> /etc/ssh/sshd_config'
bash -c 'echo "Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr" >> /etc/ssh/sshd_config'
bash -c 'echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com"  >> /etc/ssh/sshd_config'

# tee -a /etc/ssh/sshd_config > /dev/null <<EOF
# Match User *,!$SSHUSERS
#     ForceCommand /bin/echo 'This bastion does not support interactive commands.'
# EOF

sed -i "/ClientAliveInterval/c\ClientAliveInterval 180" /etc/ssh/sshd_config

sed -i "/RekeyLimit/c\RekeyLimit 1G 1h" /etc/ssh/sshd_config