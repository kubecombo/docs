#!/bin/bash

kubectl delete -f 01-cluster-issuer.yaml -f 02-ns-vpn-gw-ca.yaml -f 03-ns-vpc1-issuer.yaml -f 04-vpc1-moon-ca.yaml -f 05-vpc1-sun-ca.yaml -f 06-vpc1-mars-ca.yaml 

# secret 是用来存储 ca 的，需要手动删除

kubectl delete secret -n ns1 moon-ipsec-vpn sun-ipsec-vpn vpn-gw-ca 

