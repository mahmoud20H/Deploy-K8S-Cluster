# VIP failover decision flow

```mermaid
flowchart TD
    A[Admin sends API request to VIP:7443] --> B{Who owns the VIP?}
    B -->|Healthy elected CP| C[That CP's HAProxy listener]
    C --> D{Healthy API backend on TCP 6443?}
    D -->|Yes| E[Proxy to selected kube-apiserver]
    D -->|No| F[API request fails until backend returns]
    B -->|Owner's HAProxy fails| G[Keepalived tracking script fails]
    G --> H[Current owner releases VIP / enters FAULT]
    H --> I{Other VRRP peer healthy and reachable?}
    I -->|Yes| J[Peer acquires VIP; sends gratuitous ARP]
    J --> C
    I -->|No| K[VIP unavailable; manual investigation]
```

## What to observe

- Failover might introduce an **observable gap** until peer election and ARP update complete.
- If protocol 112 is blocked or a peer owns the VIP elsewhere, **split brain** is possible; stop tests and inspect infrastructure.
- VIP failover is independent of etcd **majority**: a reachable API process cannot complete state changes if etcd quorum is unavailable.
