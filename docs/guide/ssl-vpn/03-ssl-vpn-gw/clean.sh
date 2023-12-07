#!/bin/bash

kubectl delete -f 00-keepalived-vip-fip.yaml -f 01-gw-vip-fip.yaml -f 02-ovpn-auto-secret.yaml
