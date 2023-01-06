#!/bin/bash

# Variables
HOST="$(hostname)"
POSTFIX_RELAY="${POSTFIX_RELAY:-smtp-relay.sendinblue.com:587}"
POSTFIX_DOMAIN="${POSTFIX_DOMAIN:-mydomain.com}"
POSTFIX_USER="${POSTFIX_USER:-myuser@example.com}"
POSTFIX_PASS="${POSTFIX_PASS:-MyPa$$w0rd}"
FROM_EMAIL="${FROM_EMAIL:-$HOST@$MYDOMAIN}"

# To send a test email
# apt install -y bsd-mailx
# echo "Configuration Works" | mail -s "Working Config" $POSTFIX_USER

# Install Postfix
echo "===> Installing Postfix"
export DEBIAN_FRONTEND=noninteractive
apt-get install -y \
        libsasl2-modules \
        openssl \
        postfix

# Configure Authentication files
echo "===> Creating credentials file"
echo "${POSTFIX_RELAY}      ${POSTFIX_USER}:${POSTFIX_PASS}" > /etc/postfix/sasl_passwd

# Configure sender maps
tee /etc/postfix/sender_canonical_maps >/dev/null << EOF
/.+/    ${FROM_EMAIL}
EOF

# Configure header check
tee /etc/postfix/header_check >/dev/null << EOF
/From:.*/ REPLACE From: ${FROM_EMAIL}
EOF

# Hash files
echo "===> Hashing files"
postmap /etc/postfix/sasl_passwd

# Secure files
echo "===> Applying security permissions"
chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db

# Configure Postfix
echo "===> Configuring Postfix"
postconf -e "myhostname=$HOST"
postconf -e "mydestination=\$myhostname, localhost.${MYDOMAIN}, localhost"
postconf -e "mynetworks=127.0.0.0/8"
postconf -e "inet_interfaces=loopback-only"
postconf -e "relayhost=${POSTFIX_RELAY}"
postconf -e "smtp_use_tls=yes"
postconf -e "smtp_sasl_auth_enable=yes"
postconf -e "smtp_sasl_security_options="
postconf -e "smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd"
postconf -e "smtp_tls_CAfile=/etc/ssl/certs/Entrust_Root_Certification_Authority.pem"
postconf -e "smtp_tls_session_cache_timeout=3600s"
postconf -e "readme_directory=no"
postconf -e "smtp_tls_security_level=may"
postconf -e "sender_canonical_classes=envelope_sender, header_sender"
postconf -e "sender_canonical_maps=regexp:/etc/postfix/sender_canonical_maps"
postconf -e "smtp_header_checks=regexp:/etc/postfix/header_check"

# Reload Postfix
echo "===> Reloading Postfix"
postfix reload
