# 部署

## 1. 部署 kube-ovn

由于 kubecombo 依赖 vip 以及 fip，所以直接拉起来一个具备 fip 的模拟环境用于测试

```bash
# git clone kube-ovn 

# 然后创建 kube-ovn kind 环境

make release

make kind-init; make kind-install-webhook

make kind-install-webhook
# webhook 最好执行两次

make ovn-vpc-nat-gw-conformance-e2e


```

可以在 `ovn-vpc-nat-gw-conformance-e2e` 加一行 time.Sleep(), 用于保持 e2e 环境， 便于测试。

## 2. 部署 cert-manager

`kind-install-webhook` 已经部署了 cert-manager

但是有时候可能会因为网络问题，导致 cert-manager yaml 下载不下来， 所以有必要提前下载下来准备好

```bash
wget https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml

wget https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml

# 下载后应用即可

```

开启特性门

```bash

# 注意需要手动启用特性门
# 编辑 控制器以及 webhook 组件的 deployment 用于开启特性门

k edit deployment -n cert-manager   cert-manager
k edit deployment -n cert-manager   cert-manager-webhook

# 在启动参数中添加启用特性门

      - args:
        - --feature-gates=AdditionalCertificateOutputFormats=true

# ref https://cert-manager.io/docs/usage/certificate/#additional-certificate-output-formats

```

## 3. 部署 kube-combo

### 3.1 构建

```bash
# 基于 host network 模式构建更为稳定，需要创建一个 host network builder

docker buildx create --use --name hostbuilder --driver-opt network=host --buildkitd-flags '--allow-insecure-entitlement network.host' --platform linux/amd64

make docker-build-all

# 或者 

# 构建 kube-combo controller
make docker-build-base
make docker-build

# 构建 kube-combo 能提供的网元功能的依赖镜像
make docker-build-keepalived
make docker-build-ipsec-vpn
make docker-build-ssl-vpn




```

### 3.2 push

```bash

make docker-push-base
make docker-push
make docker-push-ssl-vpn
make docker-push-ipsec-vpn
make docker-push-keepalived

# 或者
make docker-push-all

```

### 3.3. run

注意事项：

- kind 测试环境上尚未支持启用 webhook

切换到 kube-combo repo，执行:

```bash
# 准备 kustomize 工具

ln -s /snap/bin/kustomize /root/kubecombo/kube-combo/bin/kustomize

```

```bash
# install kubecombo crd

make manifests

make install

```

``` bash

# 装载镜像到 kind kube-ovn cluster
make kind-load-image

# install kubecombo controller manager
make deploy

# refesh kubecombo controller manager
make kind-reload

```

在 containerd 环境中进行测试

```bash

# 装载镜像到 kind kube-ovn cluster
## kube-rbac-proxy 很有可能下载不到，所以手动 load
ctr -n=k8s.io image import /tmp/kube-rbac-proxy.v0.15.0.tar
make crictl-pull-image

# install kubecombo controller manager
make deploy

# refesh kubecombo controller manager
make ctd-reload

```
