#!/bin/bash
set -euo pipefail
# PUBLIC_IP should be lb service external ip or floating ip

PUBLIC_IP="192.168.7.3"
SECRET_NAME="ovpncli1"
NS="ns1"
SSL_VPN_SERVER_PORT="1194" # 目前不支持修改, udp 1194, tcp 443, udp 性能往往更好
CIPHER="AES-256-CBC" # 保持和服务端一致
AUTH="SHA1" # 保持和服务端一致

rm -f "/tmp/${SECRET_NAME}".ovpn

cat >"/tmp/${SECRET_NAME}".ovpn <<EOF
client
auth-nocache
remote-cert-tls server
nobind
dev tun
cipher ${CIPHER}
auth ${AUTH}

# remote-cert-tls server # mitigate mitm
# 注意这里由于 cert-manager 签的secret 没有 Key Usage, 所以这里需要屏蔽掉
# https://superuser.com/questions/1446201/openvpn-certificate-does-not-have-key-usage-extension

float
remote ${PUBLIC_IP} ${SSL_VPN_SERVER_PORT} udp  
# default udp 1194
# defualt tcp 443

redirect-gateway def1

<key>
$(kubectl get secret -n ${NS} ${SECRET_NAME} -o jsonpath="{.data['tls\.key']}" | base64 -d)
</key>
<cert>
$(kubectl get secret -n ${NS} ${SECRET_NAME} -o jsonpath="{.data['tls\.crt']}" | base64 -d | openssl x509 --noout --text )
$(kubectl get secret -n ${NS} ${SECRET_NAME} -o jsonpath="{.data['tls\.crt']}" | base64 -d )
</cert>
<ca>
$(kubectl get secret -n ${NS} ${SECRET_NAME} -o jsonpath="{.data['ca\.crt']}" | base64 -d)
</ca>
EOF

#
# debug 
kubectl get secret -n ${NS} ${SECRET_NAME} -o jsonpath="{.data['tls\.key']}" | base64 -d > "/tmp/${SECRET_NAME}".tls.key
kubectl get secret -n ${NS} ${SECRET_NAME} -o jsonpath="{.data['tls\.crt']}" | base64 -d > "/tmp/${SECRET_NAME}".tls.crt
kubectl get secret -n ${NS} ${SECRET_NAME} -o jsonpath="{.data['ca\.crt']}" | base64 -d > "/tmp/${SECRET_NAME}".ca
ls -l /tmp/${SECRET_NAME}.*
cat "/tmp/${SECRET_NAME}".ovpn
