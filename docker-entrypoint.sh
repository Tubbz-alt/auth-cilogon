#!/bin/bash

# clear
rm -rf /run/httpd/* /tmp/httpd*

ln -sf /etc/httpd/certs/cert.crt /etc/pki/tls/certs/localhost.crt
ln -sf /etc/httpd/certs/cert.key /etc/pki/tls/private/localhost.key

# server names and admin
export SERVER_NAME="${SERVER_NAME:-localhost}"

# config path
export PROXY_APP_CONF="${PROXY_APP_CONF:-/etc/httpd/conf.d/proxy-app.conf}"

###
# modify apache configuration for app
###
sed -i "s|ServerName localhost|ServerName ${SERVER_NAME}|g" /etc/httpd/conf/httpd.conf
sed -i "s|# ServerName localhost|ServerName ${SERVER_NAME}|g" ${PROXY_APP_CONF}
export SERVER_ADMIN="${SERVER_ADMIN:-admin@localhost.com}"
sed -i "s|ServerAdmin admin@localhost.com|ServerAdmin ${SERVER_ADMIN}|g" /etc/httpd/conf/httpd.conf
sed -i "s|# ServerAdmin admin@localhost.com|ServerAdmin ${SERVER_ADMIN}|g" ${PROXY_APP_CONF}

# proxy settings
export PROXY_HOST="${PROXY_HOST:-localhost}"
export PROXY_PORT="${PROXY_PORT:-8000}"
export PROXY_WS_PORT="${PROXY_WS_PORT:-5000}"
sed -i "s|http://proxy-app:8000/|http://${PROXY_HOST}:${PROXY_PORT}/|g" ${PROXY_APP_CONF}
sed -i "s|ws://proxy-app:5000/|ws://${PROXY_HOST}:${PROXY_WS_PORT}/|g" ${PROXY_APP_CONF}

# redirect
export HTTPS_REDIRECT="${HTTPS_REDIRECT:-https://localhost/}"
sed -i "s|Redirect permanent / https://localhost/|Redirect permanent / ${HTTPS_REDIRECT}|g" ${PROXY_APP_CONF}

###
# modify oidc conf
###

export OIDC_CONF=${OIDC_CONF:-/etc/httpd/conf.d/openidc.conf}

sed -i "s|YOUR CLIENT IDENTIFIER|${OIDC_CLIENT_ID}|g" ${OIDC_CONF}
sed -i "s|YOUR CLIENT SECRET|${OIDC_CLIENT_SECRET}|g" ${OIDC_CONF}
sed -i "s|https://www.example.org/oidc/redirect|${OIDC_REDIRECT_URI:-https://localhost/oidc/redirect}|g" ${OIDC_CONF}
sed -i "s|A PASSPHRASE OF YOUR CHOOSING|${OIDC_CRYPTO_PASSPHRASE}|g" ${OIDC_CONF}


###
# control top level access
###
if [[ ! -z "${REQUIRE_VALID_USER}" ]]; then
  sed -i "s|\# AuthType openid-connect|AuthType openid-connect|g" ${PROXY_APP_CONF}
  sed -i "s|\# require valid-user| require valid-user|g" ${PROXY_APP_CONF}
fi


###
# generate a fake ssl cert
###
if [[ ! -z "${GENERATE_DUMMY_CERTS}" ]]; then
  
  echo "******** GENERATING DUMMY SSL CERTS ********"
  if [[ ! -s /etc/httpd/certs/cert.crt && ! -s /etc/httpd/certs/cert.key  ]]; then
    openssl req -x509 -nodes -days 2 -newkey rsa:2048 -subj '/CN=localhost' -keyout /etc/httpd/certs/cert.key -out /etc/httpd/certs/cert.crt
  else
    echo "ERROR: certificates are not zero length; not overwriting - are you sure you want to generate dummy certificates?"
    exit 1
  fi
  
fi

###
# fakeauth stuff
###
if [[ ! -z "${FAKE_AUTH}" ]]; then
  export FAKE_AUTH_USER="${FAKE_AUTH_USER:-someone}"
  echo "******** SETTING UP FAKE AUTHENTICATION AS ${FAKE_AUTH_USER} ********"

  sed -i "s|\#SetEnv REMOTE_USER someone|SetEnv REMOTE_USER ${FAKE_AUTH_USER}|g" ${PROXY_APP_CONF}
  # sed -i "s|\#SetEnv AUTH_TYPE WebAuth|SetEnv AUTH_TYPE WebAuth|g" ${PROXY_APP_CONF}
  export FAKE_AUTH_START=`date +%s`
  export FAKE_AUTH_END=`expr $PROXY_EPOCH + 500000000`
fi

/usr/sbin/apachectl -V

exec /usr/sbin/apachectl -DFOREGROUND
