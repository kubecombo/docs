#!/bin/bash

rm -fr vagrant/*

kubectl cp ns1/moon:/vagrant vagrant/ -c ipsec

tree vagrant

kubectl cp vagrant ns1/sun:/ -c ipsec

