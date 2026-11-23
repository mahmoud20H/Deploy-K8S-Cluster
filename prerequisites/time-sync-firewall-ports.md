# Time sync and firewall / traffic matrix

Ensure NTP/chrony sync and test allowed flows **from the actual hosts**. Open only necessary ports to authorized sources, not `0.0.0.0/0`. Control plane components might bind loopback for metrics; do not publish them without a use case.

| Source → Destination | Protocol / port | Why |
|---|---|---|
| Admin, nodes → API VIP (currently owned by one CP) | TCP `7443` | HAProxy entry point for Kubernetes API |
| Each HAProxy process → master1/master2/master3 | TCP `6443` | kube-apiserver backends |
| master1 ↔ master2 ↔ master3 | TCP `2379`, `2380` | stacked etcd client/peer traffic as configured |
| master1 ↔ master2 ↔ master3 | IP **protocol 112** (not TCP/UDP port 112) | unicast Keepalived VRRP |
| Control planes → all nodes | TCP `10250` | kubelet API for logs, exec, metrics |
| Nodes → control-plane API VIP | TCP `7443` | kubelet/API clients |
| All Kubernetes nodes ↔ each other | UDP `8472` | Cilium VXLAN transport in this configured setup |
| All Kubernetes nodes ↔ each other | TCP `4240` (when health endpoint enabled) | Cilium health checks, verify deployment requirements |
| Nodes ↔ external DNS/NTP | UDP/TCP `53`, UDP `123` (as required) | name resolution, clock sync |
| Nodes → artifact registries/repositories | TCP `443` | download images, OS packages, Cilium Helm OCI chart |
| NodePort clients → permitted nodes | TCP/UDP `30000-32767` **only if enabled/required** | Kubernetes NodePort services |


### VIP validation before bootstrap

```bash
ip -br addr                   # identify NIC: ens160 is only an example
ip -4 route
# From another host on the subnet, while VIP is NOT configured:
# verify the selected VIP is not already allocated; ping alone is insufficient.
```

VRRP frequently fails on networks that block L2 MAC movement or IP protocol 112; check platform constraints with the network team. When using firewalls that are stateful and asymmetric, validate replies through the VIP too.

Official reference: https://kubernetes.io/docs/reference/networking/ports-and-protocols/
