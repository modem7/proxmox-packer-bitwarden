#!/bin/bash

# Variables
SSHCONF="/etc/ssh/sshd_config"
#SSHUSERS="modem7" # Uncomment if you want to restrict to a user.
#SSHPORT="32223" # Uncomment if you want to set a different SSH port

# Re-generate the RSA and ED25519 keys
rm -f /etc/ssh/ssh_host_*
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

# AllowUsers
if [ -v SSHUSERS ]
then
    SSHKEY="AllowUsers"
    echo " - Changing value ${SSHKEY} to ${SSHUSERS}."
    echo "${SSHKEY} ${SSHUSERS}" >> ${SSHCONF}
    tee -a ${SSHCONF} > /dev/null << EOF
    Match User *,!${SSHUSERS}
    ForceCommand /bin/echo 'This bastion does not support interactive commands.'
EOF
fi

# Port
if [ -v SSHPORT ]
then
  SSHKEY="Port"
  SSHVALUE="${SSHPORT}"
  echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
  if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
    echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
  else
    sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
    sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  fi
fi

# PermitOpen
if [ -v SSHPORT ]
then
  SSHKEY="PermitOpen"
  SSHVALUE="*:${SSHPORT}"
  echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
  if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
    echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
  else
    sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
    sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  fi
fi

# Protocol
SSHKEY="Protocol"
SSHVALUE="2"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# PermitRootLogin
SSHKEY="PermitRootLogin"
SSHVALUE="no"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# LogLevel
SSHKEY="LogLevel"
SSHVALUE="VERBOSE"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# LoginGraceTime
SSHKEY="LoginGraceTime"
SSHVALUE="1m"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# MaxAuthTries
SSHKEY="MaxAuthTries"
SSHVALUE="3"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# MaxSessions
SSHKEY="MaxSessions"
SSHVALUE="2"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# PubkeyAuthentication
SSHKEY="PubkeyAuthentication"
SSHVALUE="yes"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# PasswordAuthentication
SSHKEY="PasswordAuthentication"
SSHVALUE="no"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# PermitEmptyPasswords
SSHKEY="PermitEmptyPasswords"
SSHVALUE="no"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# ChallengeResponseAuthentication
SSHKEY="ChallengeResponseAuthentication"
SSHVALUE="no"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# GSSAPIAuthentication
SSHKEY="GSSAPIAuthentication"
SSHVALUE="no"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# KerberosAuthentication
SSHKEY="KerberosAuthentication"
SSHVALUE="no"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# UsePAM
SSHKEY="UsePAM"
SSHVALUE="no"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# AllowTcpForwarding
SSHKEY="AllowTcpForwarding"
SSHVALUE="yes"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# AllowAgentForwarding
SSHKEY="AllowAgentForwarding"
SSHVALUE="yes"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# AllowStreamLocalForwarding
SSHKEY="AllowStreamLocalForwarding"
SSHVALUE="no"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# X11Forwarding
SSHKEY="X11Forwarding"
SSHVALUE="yes"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# PrintMotd
SSHKEY="PrintMotd"
SSHVALUE="no"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# UseDNS
SSHKEY="UseDNS"
SSHVALUE="no"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# TCPKeepAlive
SSHKEY="TCPKeepAlive"
SSHVALUE="yes"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# PermitUserEnvironment
SSHKEY="PermitUserEnvironment"
SSHVALUE="no"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# Compression
SSHKEY="Compression"
SSHVALUE="no"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# Banner
SSHKEY="Banner"
SSHVALUE="none"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# ClientAliveInterval
SSHKEY="ClientAliveInterval"
SSHVALUE="180"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# RekeyLimit
SSHKEY="RekeyLimit"
SSHVALUE="1G 1h"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi

# Subsystem
SSHKEY="Subsystem"
SSHVALUE="Subsystem sftp \/usr\/lib\/sftp-server -f AUTHPRIV -l INFO"
echo " - Changing value ${SSHKEY} to ${SSHVALUE}."
if [ $(cat ${SSHCONF} | grep ${SSHKEY} | wc -l) -eq 0 ]; then
  echo "${SSHKEY} ${SSHVALUE}" >> ${SSHCONF}
else
  sed -i -e "1,/#${SSHKEY} [a-zA-Z0-9].*/s/#${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
  sed -i -e "1,/${SSHKEY} [a-zA-Z0-9].*/s/${SSHKEY} [a-zA-Z0-9].*/${SSHKEY} ${SSHVALUE}/" ${SSHCONF}
fi
