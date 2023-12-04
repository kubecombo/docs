# ssl vpn gw

ssl vpn gw 基于 keepalived vip 来保证高可用， vip 在两个后端 pod 中其中一个存在，一旦主 pod 故障，则 keepalived 会漂移 vip。

## 1. 使用 ssl vpn
