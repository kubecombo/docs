#!/bin/bash

echo "该操作会清理 vip，fip，如果需要保留 vip fip，请中断该脚本"

sleep 10

kubectl delete -f 01-keepalived-vip-fip.yaml -f 02-ovpn-auto-secret.yaml  -f 03-nginx.yaml

