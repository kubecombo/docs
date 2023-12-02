# 部署

## 1. 部署 kube-ovn

```bash
# git clone kube-ovn 
# 然后创建 kube-ovn kind 环境

make release
make kind-init; make kind-install
make kind-install-webhook
```

## 2. 部署 cert-manager

`kind-install-webhook` 已经部署了 cert-manager

## 3. 部署 kube-combo
