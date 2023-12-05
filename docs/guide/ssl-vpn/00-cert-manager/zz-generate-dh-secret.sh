#!/bin/bash
set -eux

dhbase64=`openssl dhparam 2048 2> /dev/null | base64 | tr -d '\n'`

cat >dh-secret.yaml <<EOF
apiVersion: v1
data:
  dh.pem: "${dhbase64}"
kind: Secret
metadata:
  name: ssl-vpn-dh-pem
  namespace: ns1

EOF


