#!/bin/bash

kubectl create ns ns1

kubectl apply -f 00-ns.yml -f 01-ns1-vpc1-subnet.yaml
