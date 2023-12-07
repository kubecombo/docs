# ssl vpn gw

ssl vpn gw 基于 keepalived vip 来保证高可用， vip 在两个后端 pod 中其中一个存在，一旦主 pod 故障，则 keepalived 会漂移 vip。

使用 ssl vpn gw 包括以下步骤：

- 准备 certificates

## 1. 准备 certificates

在 `ssl-vpn` 目录下，包括一个基本的 e2e 的 ssl vpn gw 的测试步骤， 进入 `ssl-vpn` 目录下，执行以下命令：

```bash

# pwd
/root/kubecombo/docs/docs/guide/ssl-vpn

cd 00-cert-manager
bash -x init.sh

```

## 2. 确保 kube-ovn 具备提供公网的网桥以及网卡

``` bash

# tree ssl-vpn/01-provider-network/

01-provider-network/
├── 01-provider-network.yaml
├── 02-vlan.yaml
├── 03-vlan-subnet.yaml
├── clean.sh
└── init.sh

0 directories, 5 files

```

## 3. 确保 kube-ovn 具备自定义 vpc 以及子网

``` bash

# tree ssl-vpn/02-ns1/

02-ns1/
├── 00-gw-cm.yaml
├── 00-ns.yml
├── 01-ns1-vpc1-subnet.yaml
├── clean.sh
└── init.sh

cd 02-ns1
bash -x init.sh

```

## 4. 使用 ssl vpn gw

```bash
# tree ssl-vpn/03-ssl-vpn-gw/
ssl-vpn/03-ssl-vpn-gw/
├── 01-keepalived-vip-fip.yaml
├── 02-ovpn-auto-secret.yaml
├── 03-nginx.yaml
├── clean.sh
├── get-ovpn-client.sh
├── init.sh
├── README
└── zz-generate-a-ovpn-client.sh

cd ssl-vpn/03-ssl-vpn-gw/

bash -x init.sh

# 执行后，可以看到一下资源

root@empty:~/kubecombo/docs/docs/guide/ssl-vpn/03-ssl-vpn-gw# k get po -n ns1
NAME             READY   STATUS    RESTARTS   AGE
keepalived01-0   2/2     Running   0          7m56s
keepalived01-1   2/2     Running   0          7m54s
vpc1-nginx       2/2     Running   0          2m11s

# keepalived01 是主备维护的 ssl vpn gw 网关

# vpc1-nginx 是用于经过 vpn gw pod 访问到的 vpc subnet 内部的资源

```

## 4.1 基于 pod 主网卡 fip 建立 openvpn 客户端到服务端的链接

### 4.1.1 基于 pod 主网卡 fip 获取 ssl vpn 客户端配置

按照实际情况，修改 get-ovpn-client.sh 中的必要参数：

```bash
PUBLIC_IP="172.19.0.17" # 这个是 pod 主网卡 ip 对应的 fip
SECRET_NAME="ovpncli1"
NS="ns1"

# 以上字段有可能需要修改
```

按需修改后，执行该脚本获取 ssl vpn 客户端配置：

```bash

bash get-ovpn-client.sh

# 查看 ssl vpn 客户端文件

# ls -l /tmp/ovpncli1.ovpn
-rw-r--r-- 1 root root 7391 Dec  6 10:05 /tmp/ovpncli1.ovpn

```

### 4.1.2 基于 ssl vpn 客户端连接到 ssl vpn gw 中的服务

目前有几个开源免费客户端推荐使用：

- windows 使用 openvpn.exe
- mac 使用 Tunnelblick.app
- ubunutu (22.04) 使用 openvpn

```bash
apt install openvpn network-manager-openvpn-gnome

openvpn --config /tmp/ovpncli1.ovpn

```

测试结果:

```bash
root@empty:~/kubecombo/docs/docs/guide/ssl-vpn/03-ssl-vpn-gw# openvpn --config /tmp/1264.ovpn
2023-12-06 20:41:18 WARNING: --keysize is DEPRECATED and will be removed in OpenVPN 2.6
2023-12-06 20:41:18 OpenVPN 2.5.9 x86_64-pc-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] built on Sep 29 2023
2023-12-06 20:41:18 library versions: OpenSSL 3.0.2 15 Mar 2022, LZO 2.10
2023-12-06 20:41:18 WARNING: No server certificate verification method has been enabled.  See http://openvpn.net/howto.html#mitm for more info.
2023-12-06 20:41:18 WARNING: normally if you use --mssfix and/or --fragment, you should also set --tun-mtu 1500 (currently it is 1279)
2023-12-06 20:41:18 TCP/UDP: Preserving recently used remote address: [AF_INET]192.168.7.4:1194
2023-12-06 20:41:18 UDP link local: (not bound)
2023-12-06 20:41:18 UDP link remote: [AF_INET]192.168.7.4:1194
2023-12-06 20:41:18 [ovpnsrv.vpn.gw.com] Peer Connection Initiated with [AF_INET]192.168.7.4:1194
2023-12-06 20:41:18 OPTIONS IMPORT: WARNING: peer-id set, but link-mtu fixed by config - reducing tun-mtu to 1276, expect MTU problems
2023-12-06 20:41:18 TUN/TAP device tun0 opened
2023-12-06 20:41:18 net_iface_mtu_set: mtu 1276 for tun0
2023-12-06 20:41:18 net_iface_up: set tun0 up
2023-12-06 20:41:18 net_addr_ptp_v4_add: 10.240.0.6 peer 10.240.0.5 dev tun0
2023-12-06 20:41:18 Initialization Sequence Completed

```

可以看到 openvpn client 可以稳定连接到 vpn gw pod 的 fip

```bash

root@empty:~# k get ofip
NAME             VPC    V4EIP           V4IP        READY   IPTYPE   IPNAME
keepalived-fip   vpc1   192.168.7.3     10.1.0.2    true    vip      keepalived-vip
keepalived01-0   vpc1   192.168.7.4     10.1.0.14   true             keepalived01-0.ns1
keepalived01-1   vpc1   192.168.7.5     10.1.0.15   true             keepalived01-1.ns1
nginx            vpc1   192.168.7.110   10.1.0.6    true             vpc1-nginx.ns1
root@empty:~# kgp | grep -E "keepalived|nginx"
ns1            keepalived01-0                                   2/2     Running   0          20m     10.1.0.14         empty   <none>           <none>
ns1            keepalived01-1                                   2/2     Running   0          20m     10.1.0.15         empty   <none>           <none>
ns1            vpc1-nginx                                       2/2     Running   0          5h20m   10.1.0.6          empty   <none>           <none>
root@empty:~#

root@empty:~# k get subnet
NAME           PROVIDER   VPC           PROTOCOL   CIDR             PRIVATE   NAT     DEFAULT   GATEWAYTYPE   V4USED   V4AVAILABLE   V6USED   V6AVAILABLE   EXCLUDEIPS        U2OINTERCONNECTIONIP
external       ovn        ovn-cluster   IPv4       192.168.7.0/24   false     false   false     distributed   5        248           0        0             ["192.168.7.1"]
join           ovn        ovn-cluster   IPv4       100.64.0.0/16    false     false   false     distributed   1        65532         0        0             ["100.64.0.1"]
ovn-default    ovn        ovn-cluster   IPv4       10.16.0.0/16     false     true    true      distributed   7        65526         0        0             ["10.16.0.1"]
vpc1-subnet1   ovn        vpc1          IPv4       10.1.0.0/24      false     false   false     distributed   4        249           0        0             ["10.1.0.1"]

# 可以看到可以直接访问到自定义 vpc subnet 内的服务

root@empty:~# curl 10.1.0.6
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
root@empty:~#
```

注意测试完毕后，关闭 openvpn 客户端。 否则所有流量都会走到 vpn gw pod，无法使用互联网。

## 4.2 基于 keepalived vip 的 fip 建立 openvpn 客户端到服务端的链接

```bash
root@empty:~/kubecombo/docs/docs/guide/ssl-vpn/03-ssl-vpn-gw# kgp
NAMESPACE      NAME                                             READY   STATUS             RESTARTS     AGE   IP                NODE    NOMINATED NODE   READINESS GATES
cert-manager   cert-manager-8646fc6bc9-f7swx                    1/1     Running            0            29h   10.16.0.13        empty   <none>           <none>
cert-manager   cert-manager-cainjector-69b45d68bb-lb5wt         1/1     Running            0            29h   10.16.0.10        empty   <none>           <none>
cert-manager   cert-manager-webhook-7f9cf97dcd-r2lfj            1/1     Running            0            29h   10.16.0.14        empty   <none>           <none>
kube-system    coredns-67ddbf998c-49xwd                         1/1     Running            0            29h   10.16.0.8         empty   <none>           <none>
kube-system    coredns-67ddbf998c-tpmr4                         1/1     Running            0            29h   10.16.0.7         empty   <none>           <none>
kube-system    kube-apiserver-empty                             1/1     Running            0            29h   192.168.100.100   empty   <none>           <none>
kube-system    kube-combo-controller-manager-555f86948d-lh7tp   2/2     Running            0            34s   10.16.0.24        empty   <none>           <none>
kube-system    kube-controller-manager-empty                    1/1     Running            0            29h   192.168.100.100   empty   <none>           <none>
kube-system    kube-ovn-cni-zwqgp                               1/1     Running            0            29h   192.168.100.100   empty   <none>           <none>
kube-system    kube-ovn-controller-5b8847866-pzx92              1/1     Running            0            26h   192.168.100.100   empty   <none>           <none>
kube-system    kube-ovn-monitor-78647b59cd-ws9ls                1/1     Running            0            29h   192.168.100.100   empty   <none>           <none>
kube-system    kube-ovn-pinger-gmqp2                            1/1     Running            0            29h   10.16.0.9         empty   <none>           <none>
kube-system    kube-proxy-gf7kz                                 1/1     Running            0            29h   192.168.100.100   empty   <none>           <none>
kube-system    kube-scheduler-empty                             1/1     Running            0            29h   192.168.100.100   empty   <none>           <none>
kube-system    nodelocaldns-b6ppr                               1/1     Running            0            29h   192.168.100.100   empty   <none>           <none>
kube-system    ovn-central-5458d5dd9f-jhn87                     1/1     Running            0            29h   192.168.100.100   empty   <none>           <none>
kube-system    ovs-ovn-x9xdk                                    1/1     Running            0            29h   192.168.100.100   empty   <none>           <none>
ns1            keepalived01-0                                   1/2     CrashLoopBackOff   1 (3s ago)   5s    10.1.0.50         empty   <none>           <none>
ns1            vpc1-nginx                                       2/2     Running            0            26h   10.1.0.6          empty   <none>           <none>
(reverse-i-search)`log': k ^Cgs -f -n ns1            keepalived01-0
root@empty:~/kubecombo/docs/docs/guide/ssl-vpn/03-ssl-vpn-gw# k get ofip
NAME             VPC    V4EIP           V4IP        READY   IPTYPE   IPNAME
keepalived-fip   vpc1   192.168.7.23    10.1.0.49   true    vip      keepalived-vip
keepalived01-0   vpc1   192.168.7.24    10.1.0.50   true             keepalived01-0.ns1
keepalived01-1   vpc1   192.168.7.25    10.1.0.51   true             keepalived01-1.ns1
nginx            vpc1   192.168.7.110   10.1.0.6    true             vpc1-nginx.ns1
test-vip         vpc1   192.168.7.9     10.1.0.29   true    vip      test-vip
root@empty:~/kubecombo/docs/docs/guide/ssl-vpn/03-ssl-vpn-gw#
root@empty:~/kubecombo/docs/docs/guide/ssl-vpn/03-ssl-vpn-gw# vi get-ovpn-client.sh
root@empty:~/kubecombo/docs/docs/guide/ssl-vpn/03-ssl-vpn-gw#
root@empty:~/kubecombo/docs/docs/guide/ssl-vpn/03-ssl-vpn-gw#
root@empty:~/kubecombo/docs/docs/guide/ssl-vpn/03-ssl-vpn-gw#
root@empty:~/kubecombo/docs/docs/guide/ssl-vpn/03-ssl-vpn-gw# bash -x get-ovpn-client.sh
+ set -euo pipefail
+ PUBLIC_IP=192.168.7.23
+ SECRET_NAME=ovpncli1
+ NS=ns1
+ SSL_VPN_SERVER_PORT=1194
+ CIPHER=AES-256-GCM
+ AUTH=SHA1
+ rm -f /tmp/ovpncli1.ovpn
+ cat
++ kubectl get secret -n ns1 ovpncli1 -o 'jsonpath={.data['\''tls\.key'\'']}'
++ base64 -d
++ kubectl get secret -n ns1 ovpncli1 -o 'jsonpath={.data['\''tls\.crt'\'']}'
++ base64 -d
++ openssl x509 --noout --text
++ kubectl get secret -n ns1 ovpncli1 -o 'jsonpath={.data['\''tls\.crt'\'']}'
++ base64 -d
++ kubectl get secret -n ns1 ovpncli1 -o 'jsonpath={.data['\''ca\.crt'\'']}'
++ base64 -d
+ kubectl get secret -n ns1 ovpncli1 -o 'jsonpath={.data['\''tls\.key'\'']}'
+ base64 -d
+ kubectl get secret -n ns1 ovpncli1 -o 'jsonpath={.data['\''tls\.crt'\'']}'
+ base64 -d
+ kubectl get secret -n ns1 ovpncli1 -o 'jsonpath={.data['\''ca\.crt'\'']}'
+ base64 -d
+ ls -l /tmp/ovpncli1.ca /tmp/ovpncli1.ovpn /tmp/ovpncli1.tls.crt /tmp/ovpncli1.tls.key
-rw-r--r-- 1 root root 1099 Dec  7 19:05 /tmp/ovpncli1.ca
-rw-r--r-- 1 root root 7172 Dec  7 19:05 /tmp/ovpncli1.ovpn
-rw-r--r-- 1 root root 1155 Dec  7 19:05 /tmp/ovpncli1.tls.crt
-rw-r--r-- 1 root root 1675 Dec  7 19:05 /tmp/ovpncli1.tls.key
root@empty:~/kubecombo/docs/docs/guide/ssl-vpn/03-ssl-vpn-gw#
root@empty:~/kubecombo/docs/docs/guide/ssl-vpn/03-ssl-vpn-gw#
root@empty:~/kubecombo/docs/docs/guide/ssl-vpn/03-ssl-vpn-gw# openvpn --config /tmp/ovpncli1.ovpn
2023-12-07 19:05:12 WARNING: --keysize is DEPRECATED and will be removed in OpenVPN 2.6
2023-12-07 19:05:12 OpenVPN 2.5.9 x86_64-pc-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] built on Sep 29 2023
2023-12-07 19:05:12 library versions: OpenSSL 3.0.2 15 Mar 2022, LZO 2.10
2023-12-07 19:05:12 WARNING: No server certificate verification method has been enabled.  See http://openvpn.net/howto.html#mitm for more info.
2023-12-07 19:05:12 WARNING: normally if you use --mssfix and/or --fragment, you should also set --tun-mtu 1500 (currently it is 1279)
2023-12-07 19:05:12 TCP/UDP: Preserving recently used remote address: [AF_INET]192.168.7.23:1194
2023-12-07 19:05:12 UDP link local: (not bound)
2023-12-07 19:05:12 UDP link remote: [AF_INET]192.168.7.23:1194
2023-12-07 19:05:12 [ovpnsrv.vpn.gw.com] Peer Connection Initiated with [AF_INET]192.168.7.23:1194
2023-12-07 19:05:14 OPTIONS IMPORT: WARNING: peer-id set, but link-mtu fixed by config - reducing tun-mtu to 1276, expect MTU problems
2023-12-07 19:05:14 TUN/TAP device tun0 opened
2023-12-07 19:05:14 net_iface_mtu_set: mtu 1276 for tun0
2023-12-07 19:05:14 net_iface_up: set tun0 up
2023-12-07 19:05:14 net_addr_ptp_v4_add: 10.240.0.6 peer 10.240.0.5 dev tun0
2023-12-07 19:05:14 Initialization Sequence Completed

```

主 keepalived 客户端建立连接时的 log

```bash

+ openvpn --config /etc/openvpn/openvpn.conf
2023-12-07 10:10:20 WARNING: --topology net30 support for server configs with IPv4 pools will be removed in a future release. Please migrate to --topology subnet as soon as possible.
2023-12-07 10:10:20 WARNING: --keysize is DEPRECATED and will be removed in OpenVPN 2.6
2023-12-07 10:10:20 OpenVPN 2.5.5 x86_64-pc-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] built on Jul 14 2022
2023-12-07 10:10:20 library versions: OpenSSL 3.0.2 15 Mar 2022, LZO 2.10
2023-12-07 10:10:20 net_route_v4_best_gw query: dst 0.0.0.0
2023-12-07 10:10:20 net_route_v4_best_gw result: via 10.1.0.1 dev eth0
2023-12-07 10:10:20 Diffie-Hellman initialized with 2048 bit key
2023-12-07 10:10:20 WARNING: normally if you use --mssfix and/or --fragment, you should also set --tun-mtu 1500 (currently it is 1279)
2023-12-07 10:10:20 net_route_v4_best_gw query: dst 0.0.0.0
2023-12-07 10:10:20 net_route_v4_best_gw result: via 10.1.0.1 dev eth0
2023-12-07 10:10:20 ROUTE_GATEWAY 10.1.0.1/255.255.255.0 IFACE=eth0 HWADDR=00:00:00:cd:0d:54
2023-12-07 10:10:20 TUN/TAP device tun0 opened
2023-12-07 10:10:20 net_iface_mtu_set: mtu 1279 for tun0
2023-12-07 10:10:20 net_iface_up: set tun0 up
2023-12-07 10:10:20 net_addr_ptp_v4_add: 10.240.0.1 peer 10.240.0.2 dev tun0
2023-12-07 10:10:20 net_route_v4_add: 10.240.0.0/16 via 10.240.0.2 dev [NULL] table 0 metric -1
2023-12-07 10:10:20 Could not determine IPv4/IPv6 protocol. Using AF_INET
2023-12-07 10:10:20 Socket Buffers: R=[212992->212992] S=[212992->212992]
2023-12-07 10:10:20 UDPv4 link local (bound): [AF_INET]10.1.0.49:1194
2023-12-07 10:10:20 UDPv4 link remote: [AF_UNSPEC]
2023-12-07 10:10:20 GID set to nogroup
2023-12-07 10:10:20 UID set to nobody
2023-12-07 10:10:20 MULTI: multi_init called, r=256 v=256
2023-12-07 10:10:20 IFCONFIG POOL IPv4: base=10.240.0.4 size=16382
2023-12-07 10:10:20 Initialization Sequence Completed


2023-12-07 11:05:12 192.168.7.200:23564 WARNING: normally if you use --mssfix and/or --fragment, you should also set --tun-mtu 1500 (currently it is 1279)
2023-12-07 11:05:12 192.168.7.200:23564 TLS: Initial packet from [AF_INET]192.168.7.200:23564, sid=c42ae898 04f1b023
2023-12-07 11:05:12 192.168.7.200:23564 VERIFY OK: depth=1, CN=ns1.vpn.gw.com
2023-12-07 11:05:12 192.168.7.200:23564 VERIFY OK: depth=0, CN=ovpncli1.vpn.gw.com
2023-12-07 11:05:12 192.168.7.200:23564 peer info: IV_VER=2.5.9
2023-12-07 11:05:12 192.168.7.200:23564 peer info: IV_PLAT=linux
2023-12-07 11:05:12 192.168.7.200:23564 peer info: IV_PROTO=6
2023-12-07 11:05:12 192.168.7.200:23564 peer info: IV_NCP=2
2023-12-07 11:05:12 192.168.7.200:23564 peer info: IV_CIPHERS=AES-256-GCM:AES-128-GCM
2023-12-07 11:05:12 192.168.7.200:23564 peer info: IV_LZ4=1
2023-12-07 11:05:12 192.168.7.200:23564 peer info: IV_LZ4v2=1
2023-12-07 11:05:12 192.168.7.200:23564 peer info: IV_LZO=1
2023-12-07 11:05:12 192.168.7.200:23564 peer info: IV_COMP_STUB=1
2023-12-07 11:05:12 192.168.7.200:23564 peer info: IV_COMP_STUBv2=1
2023-12-07 11:05:12 192.168.7.200:23564 peer info: IV_TCPNL=1
2023-12-07 11:05:14 192.168.7.200:23564 Control Channel: TLSv1.3, cipher TLSv1.3 TLS_AES_256_GCM_SHA384, peer certificate: 2048 bit RSA, signature: RSA-SHA256
2023-12-07 11:05:14 192.168.7.200:23564 [ovpncli1.vpn.gw.com] Peer Connection Initiated with [AF_INET]192.168.7.200:23564
2023-12-07 11:05:14 192.168.7.200:23564 PUSH: Received control message: 'PUSH_REQUEST'
2023-12-07 11:05:14 ovpncli1.vpn.gw.com/192.168.7.200:23564 MULTI_sva: pool returned IPv4=10.240.0.6, IPv6=(Not enabled)
2023-12-07 11:05:14 ovpncli1.vpn.gw.com/192.168.7.200:23564 MULTI: Learn: 10.240.0.6 -> ovpncli1.vpn.gw.com/192.168.7.200:23564
2023-12-07 11:05:14 ovpncli1.vpn.gw.com/192.168.7.200:23564 MULTI: primary virtual IP for ovpncli1.vpn.gw.com/192.168.7.200:23564: 10.240.0.6
2023-12-07 11:05:14 ovpncli1.vpn.gw.com/192.168.7.200:23564 Outgoing Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
2023-12-07 11:05:14 ovpncli1.vpn.gw.com/192.168.7.200:23564 Incoming Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
2023-12-07 11:05:14 ovpncli1.vpn.gw.com/192.168.7.200:23564 SENT CONTROL [ovpncli1.vpn.gw.com]: 'PUSH_REPLY,route 10.1.0.0 255.255.255.0,dhcp-option DOMAIN-SEARCH ns1.svc.cluster.local,dhcp-option DOMAIN-SEARCH svc.cluster.local,dhcp-option DOMAIN-SEARCH cluster.local,route 10.240.0.1,topology net30,ping 10,ping-restart 120,ifconfig 10.240.0.6 10.240.0.5,peer-id 0,cipher AES-256-GCM' (status=1)

```

主 keepalived 环境信息

```bash
root@empty:~#
root@empty:~# k exec -it -n ns1            keepalived01-0 -- bash
Defaulted container "ssl" out of: ssl, keepalived
root@keepalived01-0:/#
root@keepalived01-0:/#
root@keepalived01-0:/# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
4: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1279 qdisc fq_codel state UNKNOWN group default qlen 500
    link/none
    inet 10.240.0.1 peer 10.240.0.2/32 scope global tun0
       valid_lft forever preferred_lft forever
321: eth0@if322: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1400 qdisc noqueue state UP group default
    link/ether 00:00:00:cd:0d:54 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.0.50/24 brd 10.1.0.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet 10.1.0.49/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::200:ff:fecd:d54/64 scope link
       valid_lft forever preferred_lft forever
root@keepalived01-0:/# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.1.0.1        0.0.0.0         UG    0      0        0 eth0
10.1.0.0        0.0.0.0         255.255.255.0   U     0      0        0 eth0
10.240.0.0      10.240.0.2      255.255.0.0     UG    0      0        0 tun0
10.240.0.2      0.0.0.0         255.255.255.255 UH    0      0        0 tun0
root@keepalived01-0:/# ip route list
default via 10.1.0.1 dev eth0
10.1.0.0/24 dev eth0 proto kernel scope link src 10.1.0.50
10.240.0.0/16 via 10.240.0.2 dev tun0
10.240.0.2 dev tun0 proto kernel scope link src 10.240.0.1
root@keepalived01-0:/# ss -tunlp
Netid                     State                      Recv-Q                     Send-Q                                          Local Address:Port                                           Peer Address:Port                     Process
udp                       UNCONN                     0                          0                                                   10.1.0.49:1194                                                0.0.0.0:*                         users:(("openvpn",pid=55,fd=5))
root@keepalived01-0:/#
```
