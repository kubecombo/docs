#!/bin/bash

kubectl create ns ns1

kubectl apply -f 01-cluster-issuer.yaml -f 02-ns-vpn-gw-ca.yaml -f 03-ns-vpc1-issuer.yaml -f 04-vpc1-moon-ca.yaml -f 05-vpc1-sun-ca.yaml -f 06-vpc1-mars-ca.yaml 

