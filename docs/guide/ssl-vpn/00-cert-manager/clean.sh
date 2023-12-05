kubectl delete -f 01-cluster-issuer.yaml -f 02-ns-vpn-gw-ca.yaml -f 03-ns-vpc1-issuer.yaml -f 04-ovpn-server-ca.yaml -f 05-ovpn-client-ca.yaml  -f dh-secret.yaml 


# secret 是用来存储 ca 的，需要手动删除

kubectl delete secret -n ns1 ovpn vpn-gw-ca ovpnsrv ovpncli1 ssl-vpn-dh-pem

