#!/bin/bash

rm -f /tmp/test.ovpn

NS="ns1"
POD_NAME="keepalived01-0"
KEY_NAME="test"
PUBLIC_IP="172.19.0.17"

kubectl --namespace $NS exec -it "$POD_NAME" /etc/openvpn/setup/zz-generate-openvpn-client-cert.sh "$KEY_NAME" "$PUBLIC_IP"

kubectl --namespace $NS exec -it "$POD_NAME" -- cat "/etc/openvpn/certs/pki/$KEY_NAME.ovpn" > "/tmp/$KEY_NAME.ovpn" 


