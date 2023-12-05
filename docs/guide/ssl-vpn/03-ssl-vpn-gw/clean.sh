#!/bin/bash


kubectl delete -f 01-nginx.yaml -f 02-ovpn.yaml -f 03-ovpn-auto-secret.yaml


kubectl delete po -n kube-system -l app=kube-ovn-controller


