#!/usr/bin/env bash

# provide url to check cert (without protocol name):
#   cert_exp.sh google.com
# if you are providing balancer url, you can provide two arguments - balancer url/api and application dns:
#  cert_exp.sh node1.company.com myapplication.company.com
#

IFS=: read url port<<<"$1"
[ -z "$port" ] && port=443
if [ -n "$2" ]; then
  echo "" | openssl s_client -connect $url:$port -servername $2 2>&1|openssl x509 -noout -dates -subject -issuer
else
  echo "" | openssl s_client -connect $url:$port -servername $url 2>&1|openssl x509 -noout -dates -subject -issuer
fi
