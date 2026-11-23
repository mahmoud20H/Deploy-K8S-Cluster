# Kubernetes API and Cilium network map

**Cluster CIDR:** `192.168.1.0/24` (assumed `/24`; confirm subnet mask).  
**API VIP:** `192.168.1.100:7443` — **specified for this cluster**; must be confirmed unused and reserved before deployment.

```text
Admin / workers / automation
       │  TLS TCP 7443
       ▼
Floating VIP 192.168.1.100:7443  ◀─ Keepalived master1/master2/master3 (IP protocol 112)
       │  VIP is owned by one control plane at a time
       ▼
HAProxy :7443 on current VIP owner
       │  TCP health-check and forwarding to :6443
       ├── master1  192.168.1.10:6443  (kube-apiserver + etcd)
       ├── master2  192.168.1.11:6443  (kube-apiserver + etcd)
       └── master3  192.168.1.12:6443  (kube-apiserver + etcd)

master1 / master2 / master3 etcd: TCP 2379 (client), TCP 2380 (peer)

worker1 192.168.1.13     worker2 192.168.1.14
worker3 192.168.1.15     worker4 192.168.1.16
worker5 192.168.1.17

Pod on worker1
       │ Cilium eBPF datapath
       ▼
192.168.1.13 ───────── Cilium VXLAN UDP 8472 ─────────▶ 192.168.1.14
                                                           │ Cilium eBPF
                                                           ▼
                                                    Pod on worker2
```

This diagram illustrates traffic classes, **not** a literal direct network cable between all peers. Control planes and workers also need kubelet access (`10250/TCP`) and other Kubernetes ports as defined in the [firewall matrix](../prerequisites/04-time-sync-firewall-ports.md). Confirm physical interfaces, routes, VRRP support, ARP behavior, firewall rules and IP allocation for your network.
