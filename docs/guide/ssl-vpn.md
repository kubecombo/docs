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
