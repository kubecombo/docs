#!/bin/bash

kind load docker-image --name kube-ovn docker.io/library/nginx:latest

kubectl apply -f 02-moon.yaml -f 02-sun.yaml -f 02-mars.yaml -f 01-alice-bob.yaml

