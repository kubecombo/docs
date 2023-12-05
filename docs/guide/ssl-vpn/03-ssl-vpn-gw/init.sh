#!/bin/bash
kubectl apply -f 01-keepalived-vip-fip.yaml -f 02-ovpn-auto-secret.yaml -f 02-ovpn.yaml -f 03-nginx.yaml

