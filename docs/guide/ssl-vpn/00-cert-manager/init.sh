kubectl create ns ns1

kubectl apply -f 01-cluster-issuer.yaml -f 02-ns-vpn-gw-ca.yaml -f 03-ns-vpc1-issuer.yaml -f 04-ovpn-server-ca.yaml -f 05-ovpn-client-ca.yaml -f dh-secret.yaml

sleep 3
kubectl get secret -n ns1


