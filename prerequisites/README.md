# Prerequisites and host preparation

**Target:** fresh Ubuntu 22.04 / 24.04 lab hosts. The scripts are intentionally not run automatically. Read each one before executing with sudo.

## Minimum planning checklist

- [ ] Three independently hosted control-plane machines, five worker machines and adequate CPU/RAM/storage
- [ ] Stable per-node hostnames and unique static IPs; DNS or `/etc/hosts` resolves all nodes
- [ ] A reserved **unused** VIP in the same supported Layer-2 subnet as control planes
- [ ] Exact interface (`ip -br addr`), VRRP unicast peers and upstream firewall ACLs agreed
- [ ] Clock sync using `timedatectl`; NTP service healthy
- [ ] Swap disabled if using standard kubeadm/kubelet behavior; see Kubernetes docs for alternate swap support
- [ ] Root or sudo access; connectivity to `pkgs.k8s.io`, `registry.k8s.io`, Cilium OCI registry or preloaded artifacts
- [ ] Ports in [firewall matrix](time-sync-firewall-ports.md) approved; IP protocol **112** between three control planes
- [ ] Unique Pod and Service CIDRs that do not overlap node networks or existing routes
- [ ] Backup and restoration plan for the **etcd state** in any non-disposable cluster

## Run on every node

- Run it in sequence on each node, or copy the scripts to each node and run them individually. The scripts are idempotent and can be re-run if needed.
```bash
sudo bash prerequisites/prepare-node.sh
sudo bash prerequisites/install-containerd.sh
sudo K8S_MINOR=v1.36 bash prerequisites/install-kubernetes.sh
sudo bash prerequisites/preflight.sh
```

If scripts were copied onto each node individually, adjust the paths. For production hosts use approved OS baselines and configuration management instead of ad hoc scripts.

## Scripts

| File | Purpose |
|---|---|
| `prepare-node.sh` | Disables swap, loads overlay + br_netfilter, writes Kubernetes sysctl settings |
| `install-containerd.sh` | Installs containerd, generates local config, enables CRI and systemd cgroups |
| `install-kubernetes.sh` | Adds signed `pkgs.k8s.io` apt repo for selected minor and installs Kubernetes tools |
| `preflight.sh` | Reports host, kernel, swap, CRI service and network prerequisites |

See [Kubernetes installation reference](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) and [containerd configuration](https://kubernetes.io/docs/setup/production-environment/container-runtimes/).
