#!/bin/sh

# Variables
HOSTNAME="$(hostname)"
POSTFIX_RELAY="${POSTFIX_RELAY:-smtp.gmail.com:587}"
POSTFIX_DOMAIN="${POSTFIX_DOMAIN:-mydomain.com}"
POSTFIX_USER="${POSTFIX_USER:-myuser@gmail.com}"
POSTFIX_PASS="${POSTFIX_PASS:-MyPa$$w0rd}"
PCRE_SUBJECT="${PCRE_SUBJECT:-$HOSTNAME}"
PCRE_EMAIL="${PCRE_EMAIL:-$HOSTNAME.$POSTFIX_DOMAIN.com}"

# To send a test email
# apt install -y bsd-mailx
# echo "Configuration Works" | mail -s "Working Config" $POSTFIX_USER

# Install Postfix
echo "===> Installing Postfix"
export DEBIAN_FRONTEND=noninteractive
apt-get install -y \
        libsasl2-modules \
        openssl \
        postfix \
        postfix-pcre

# Configure Authentication files
echo "===> Creating credentials file"
echo "$POSTFIX_RELAY      $POSTFIX_USER:$POSTFIX_PASS" > /etc/postfix/sasl_passwd

# Configure Postfix-PCRE
echo "===> Configuring Postfix-PCRE"
tee /etc/postfix/smtp_header_checks >/dev/null << EOF
/^From:.*/ REPLACE From: $PCRE_SUBJECT $PCRE_EMAIL
EOF

# Hash files
echo "===> Hashing files"
postmap /etc/postfix/sasl_passwd
postmap /etc/postfix/smtp_header_checks

# Secure files
echo "===> Applying security permissions"
chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db

# Configure Postfix
echo "===> Configuring Postfix"
postconf -e "inet_interfaces=loopback-only"
postconf -e "mydestination=$myhostname, localhost.$mydomain, localhost"
postconf -e "myhostname=$HOSTNAME"
postconf -e "mynetworks=127.0.0.0/8"
postconf -e "readme_directory=no"
postconf -e "relayhost=$POSTFIX_RELAY"
postconf -e "smtp_header_checks=pcre:/etc/postfix/smtp_header_checks"
postconf -e "smtp_sasl_auth_enable=yes"
postconf -e "smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd"
postconf -e "smtp_sasl_security_options="
postconf -e "smtp_tls_CAfile=/etc/ssl/certs/Entrust_Root_Certification_Authority.pem"
postconf -e "smtp_tls_security_level=may"
postconf -e "smtp_tls_session_cache_timeout=3600s"
postconf -e "smtp_use_tls=yes"

# Reload Postfix
echo "===> Reloading Postfix"
postfix reload
