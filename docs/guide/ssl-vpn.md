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

### 4.1 获取 ssl vpn 客户端配置

按照实际情况，修改 get-ovpn-client.sh 中的必要参数：

```bash
PUBLIC_IP="172.19.0.17"
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

### 4.2 基于 ssl vpn 客户端连接到 ssl vpn gw 中的服务

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
