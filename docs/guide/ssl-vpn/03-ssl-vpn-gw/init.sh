#!/bin/bash

kubectl apply -f 00-keepalived-vip-fip.yaml -f 01-gw-vip-fip.yaml

kubectl get vip keepalived-vip

echo 
echo "修改  02-ovpn-auto-secret.yaml vpngw 中的 vip"
echo 



kubectl get ofip keepalived-fip

echo 
echo "修改 get-ovpn-client.sh  中的 PUBLIC_IP"
echo 
