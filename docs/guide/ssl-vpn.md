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
