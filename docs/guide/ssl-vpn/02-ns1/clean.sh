#!/bin/bash

kubectl delete -f 01-ns1-vpc1-subnet.yaml

kubectl delete ip ovpn-0.ns1

kubectl ko nbctl ls-del vpc1-subnet1

