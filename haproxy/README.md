# HAProxy

HAProxy is used to load balance traffic to the Kubernetes API servers.

## Why HAProxy?

- Provides a single access point for the Kubernetes API
- Balances traffic across healthy control-plane nodes
- Helps achieve high availability together with Keepalived

## Traffic Flow

Client -> VIP:7443 -> HAProxy -> kube-apiserver nodes:6443

## Backend Targets

- 192.168.1.10:6443
- 192.168.1.11:6443
- 192.168.1.12:6443